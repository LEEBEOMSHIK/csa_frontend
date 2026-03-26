#!/usr/bin/env python3
"""
split_assets.py — Character Sprite Sheet Asset Pipeline
========================================================
Splits a character sprite sheet PNG into individual transparent PNG parts
for use as Flame / Flutter Image.asset sprite layers.

Supports single file or entire folder processing.
Output is organized by image name for easy multi-character management.

Usage:
  # Single image
  python split_assets.py --input assets/images/before/남자아이.png

  # Entire folder (processes every PNG inside)
  python split_assets.py --input assets/images/before/

  # Full options
  python split_assets.py --input ./남자아이.png --output ./out \\
      --canvas 512 --gap 50 --tol 45 --override category_override.json

  # Use anchor override (skip face estimation, use fixed coords)
  python split_assets.py --input ./남자아이.png --anchor-override anchor_override.json

  # Skip debug image generation
  python split_assets.py --input ./남자아이.png --no-debug

Output structure (for an image named "남자아이.png"):
  {output}/남자아이/
  ├── body/         body_01.png
  ├── hair/         hair_01.png … hair_N.png
  ├── hat/          hat_01.png  … hat_N.png
  ├── glasses/      glasses_01.png … glasses_N.png
  ├── accessory/    accessory_01.png … accessory_N.png
  ├── debug/        (skipped with --no-debug)
  │   ├── debug_detection.png    — all detected blobs, numbered
  │   ├── debug_categories.png   — colour-coded categories + face anchor + arrows
  │   └── debug_preview.png      — grid of all extracted parts
  └── offsets.json               — per-part offset & layer metadata

offsets.json structure:
  {
    "hat_01": {
      "category":     "hat",
      "zIndex":       30,
      "anchor":       "face_center",
      "offsetX":      -10,
      "offsetY":     -120,
      "offsetRatioX": -0.0195,   // offsetX / canvasSize  (scale-independent)
      "offsetRatioY": -0.2344,
      "assetPath":    "assets/character_parts/남자아이/hat/hat_01.png",
      "canvasSize":   512
    }
  }

anchor_override.json format (manual face anchor per character):
  {
    "남자아이": { "x": 256, "y": 180 },
    "여자아이": { "x": 260, "y": 175 }
  }

category_override.json format (manual blob classification):
  Blob numbers match labels in debug_detection.png (1-indexed).
  {
    "blob_3": "hat",
    "blob_7": "glasses"
  }

Requirements:
  pip install Pillow
"""
from __future__ import annotations

import argparse
import json
import logging
import math
import os
import sys
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

# ── Logging ────────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)-8s %(message)s',
)
logger = logging.getLogger('split_assets')

# ── Type alias ─────────────────────────────────────────────────────────────────
Blob = list[tuple[int, int]]  # list of (x, y) foreground pixel coords


# ═══════════════════════════════════════════════════════════════════════════════
#  Pure image utilities
# ═══════════════════════════════════════════════════════════════════════════════

def _l1(a: tuple, b: tuple) -> int:
    """L1 colour distance between two RGB triples."""
    return abs(int(a[0]) - int(b[0])) + abs(int(a[1]) - int(b[1])) + abs(int(a[2]) - int(b[2]))


def build_edge_mask(img_rgba: Image.Image, threshold: int = 30) -> bytearray:
    """
    Detect edges using Pillow's FIND_EDGES filter (Sobel-based convolution).

    Returns a flat bytearray: 1 = edge pixel (must NOT be erased by BFS).
    Edge pixels are protected so thin lines, hair tips, and bright-coloured
    foreground parts on pastel backgrounds are preserved even when their
    colour is close to the background.

    Args:
        img_rgba:  Source image (RGBA).
        threshold: Sobel response magnitude threshold (0–255).
                   Lower → protects more pixels (safer but may keep BG fringe).
                   Higher → protects only sharp edges.
    """
    iw, ih = img_rgba.size
    # Edge detection on the RGB channels (alpha not needed here)
    gray = img_rgba.convert('L')
    edges = gray.filter(ImageFilter.FIND_EDGES)
    edge_px = edges.load()
    mask = bytearray(iw * ih)
    for y in range(ih):
        for x in range(iw):
            if edge_px[x, y] > threshold:
                mask[y * iw + x] = 1
    return mask


def remove_background(img_rgba: Image.Image, tol: int,
                      edge_mask: bytearray | None = None) -> Image.Image:
    """
    BFS flood-fill from all four image edges with gradient-tracking reference colour.

    Edge-aware improvement:
      If `edge_mask` is provided, any pixel flagged as an edge is treated as
      foreground regardless of its colour. This prevents thin lines, hair tips,
      and bright parts on pastel backgrounds from being accidentally erased.

    Args:
        img_rgba:   Source image (RGBA).
        tol:        L1 colour tolerance for background detection.
        edge_mask:  Optional bytearray from build_edge_mask(). 1 = protected pixel.
    """
    result = img_rgba.copy()
    px = result.load()
    iw, ih = result.size
    visited = bytearray(iw * ih)

    def idx(x: int, y: int) -> int:
        return y * iw + x

    def is_bg(x: int, y: int, ref: tuple) -> bool:
        # Edge pixels are always foreground — never erase them
        if edge_mask and edge_mask[idx(x, y)]:
            return False
        p = px[x, y]
        return p[3] < 15 or _l1(p[:3], ref) < tol

    q: deque = deque()
    for x in range(iw):
        for y_e in (0, ih - 1):
            i = idx(x, y_e)
            if not visited[i] and is_bg(x, y_e, px[x, y_e][:3]):
                visited[i] = 1
                q.append((x, y_e, px[x, y_e][:3]))
    for y in range(ih):
        for x_e in (0, iw - 1):
            i = idx(x_e, y)
            if not visited[i] and is_bg(x_e, y, px[x_e, y][:3]):
                visited[i] = 1
                q.append((x_e, y, px[x_e, y][:3]))

    DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))
    while q:
        x, y, ref = q.popleft()
        px[x, y] = (0, 0, 0, 0)
        for dx, dy in DIRS:
            nx, ny = x + dx, y + dy
            if 0 <= nx < iw and 0 <= ny < ih:
                ni = idx(nx, ny)
                if not visited[ni] and is_bg(nx, ny, ref):
                    visited[ni] = 1
                    q.append((nx, ny, ref))
    return result


def build_alpha_mask(img_rgba: Image.Image) -> tuple[bytearray, int, int]:
    """Return (flat bytearray mask, width, height); 1 = foreground pixel."""
    iw, ih = img_rgba.size
    px = img_rgba.load()
    mask = bytearray(iw * ih)
    for y in range(ih):
        for x in range(iw):
            mask[y * iw + x] = 1 if px[x, y][3] > 30 else 0
    return mask, iw, ih


def connected_components(mask: bytearray, iw: int, ih: int) -> list[Blob]:
    """BFS-based connected-component labelling. O(width × height)."""
    visited = bytearray(iw * ih)
    blobs: list[Blob] = []
    DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))
    for sy in range(ih):
        for sx in range(iw):
            si = sy * iw + sx
            if not mask[si] or visited[si]:
                continue
            blob: Blob = []
            q: deque = deque([(sx, sy)])
            visited[si] = 1
            while q:
                x, y = q.popleft()
                blob.append((x, y))
                for dx, dy in DIRS:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < iw and 0 <= ny < ih:
                        ni = ny * iw + nx
                        if mask[ni] and not visited[ni]:
                            visited[ni] = 1
                            q.append((nx, ny))
            blobs.append(blob)
    return blobs


def bbox(blob: Blob) -> tuple[int, int, int, int]:
    """Return (x0, y0, x1, y1) — x1/y1 exclusive."""
    xs = [p[0] for p in blob]
    ys = [p[1] for p in blob]
    return min(xs), min(ys), max(xs) + 1, max(ys) + 1


def bbox_gap(a: tuple, b: tuple) -> float:
    """Minimum separation between two bounding boxes (0 when touching/overlapping)."""
    ax0, ay0, ax1, ay1 = a
    bx0, by0, bx1, by1 = b
    dx = max(0, max(ax0, bx0) - min(ax1, bx1))
    dy = max(0, max(ay0, by0) - min(ay1, by1))
    return math.sqrt(dx * dx + dy * dy)


def should_merge(box_a: tuple, box_b: tuple, gap: int) -> bool:
    """
    Improved merge decision: distance AND geometric compatibility.

    Two blobs are merged only when ALL conditions hold:
      1. Bounding boxes are within `gap` pixels of each other.
      2. Y-centers are in the same horizontal band — within 1.5× the
         average height of the two boxes. This prevents a glasses lens
         from accidentally merging with a hat that happens to be close.
      3. Heights are within a 5× ratio of each other — avoids merging a
         tiny decoration speck into a large hair block.

    This is especially important for glasses (two lenses separated by a
    nose bridge gap) vs. unrelated parts that are merely nearby.
    """
    if bbox_gap(box_a, box_b) > gap:
        return False

    ay_c = (box_a[1] + box_a[3]) / 2
    by_c = (box_b[1] + box_b[3]) / 2
    ah = max(box_a[3] - box_a[1], 1)
    bh = max(box_b[3] - box_b[1], 1)
    avg_h = (ah + bh) / 2

    # Different horizontal bands → do not merge
    if abs(ay_c - by_c) > avg_h * 1.5:
        return False

    # Wildly different heights → do not merge (tiny speck + large part)
    h_ratio = max(ah, bh) / min(ah, bh)
    if h_ratio > 5.0:
        return False

    return True


def merge_nearby(blobs: list[Blob], gap: int) -> list[Blob]:
    """
    Union-Find merge: groups blobs that pass the should_merge() test.
    Handles multi-piece items (glasses lenses, accessories with sub-shapes)
    while avoiding false merges between geometrically incompatible parts.
    """
    n = len(blobs)
    if n == 0:
        return []
    boxes = [bbox(b) for b in blobs]
    parent = list(range(n))

    def find(i: int) -> int:
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    def union(i: int, j: int) -> None:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj

    for i in range(n):
        for j in range(i + 1, n):
            if should_merge(boxes[i], boxes[j], gap):
                union(i, j)

    groups: dict[int, Blob] = {}
    for i, blob in enumerate(blobs):
        groups.setdefault(find(i), []).extend(blob)
    return list(groups.values())


def render_part(blob: Blob, src: Image.Image, size: int
                ) -> tuple[Image.Image, int, int]:
    """
    Crop the blob's bounding box from src, center it on a size×size
    transparent canvas.

    Returns:
        canvas        — the RGBA image
        content_off_x — content center X offset from canvas center (px)
        content_off_y — content center Y offset from canvas center (px)
    """
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    x0, y0, x1, y1 = bbox(blob)
    cropped = src.crop((x0, y0, x1, y1))
    cw, ch = cropped.size
    px_x = (size - cw) // 2
    px_y = (size - ch) // 2
    canvas.paste(cropped, (px_x, px_y), cropped)
    content_cx = px_x + cw // 2
    content_cy = px_y + ch // 2
    return canvas, content_cx - size // 2, content_cy - size // 2


# ═══════════════════════════════════════════════════════════════════════════════
#  CharacterSplitter — reusable pipeline class
# ═══════════════════════════════════════════════════════════════════════════════

class CharacterSplitter:
    """
    Reusable sprite-sheet splitter for character customization games.

    One instance can process multiple images:
        splitter = CharacterSplitter(canvas=512)
        splitter.process_file('남자아이.png', 'assets/character_parts')
        splitter.process_file('여자아이.png', 'assets/character_parts')
    """

    # ── Layer z-index (stack order for Flutter / Flame) ──────────────────────
    LAYER_ORDER: dict[str, int] = {
        'body':       0,
        'hair':      10,
        'glasses':   20,
        'hat':       30,
        'accessory': 40,
    }

    # ── Debug visualisation colours (RGB) ────────────────────────────────────
    CATEGORY_COLORS: dict[str, tuple] = {
        'body':      (255,  70,  70),
        'hair':      ( 60, 140, 255),
        'hat':       (255, 200,  30),
        'glasses':   ( 50, 210, 110),
        'accessory': (200,  60, 240),
        'unknown':   (170, 170, 170),
    }

    # X-center < image_width × this ratio → "left zone" (body candidate)
    BODY_LEFT_RATIO: float = 0.38

    # Ratio-based noise filter: blob must occupy at least this fraction of image
    MIN_BLOB_RATIO: float = 0.0002   # 0.02% of total pixels

    # Absolute floor (px²): keeps small-but-valid accessories on tiny images
    MIN_BLOB_AREA: int = 200

    # Maximum aspect ratio (w/h or h/w) to reject "line" noise blobs
    MAX_LINE_RATIO: float = 15.0

    # Edge protection threshold for Sobel edge mask
    EDGE_THRESHOLD: int = 30

    # Face region: top [FACE_TOP_RATIO, FACE_BOTTOM_RATIO] of body height
    FACE_TOP_RATIO: float = 0.00
    FACE_BOTTOM_RATIO: float = 0.40   # top 40 % of body = face area

    def __init__(self, canvas: int = 512, gap: int = 50, tol: int = 45,
                 debug: bool = True) -> None:
        self.canvas = canvas
        self.gap = gap
        self.tol = tol
        self.debug = debug

    # ── Public API ────────────────────────────────────────────────────────────

    def process_file(self, src_path: str, out_root: str,
                     override_path: str | None = None,
                     anchor_override_path: str | None = None) -> bool:
        """
        Process a single sprite sheet image.

        Returns True on success, False on any error (so batch runs can continue).
        """
        stem = Path(src_path).stem
        out_dir = os.path.join(out_root, stem)

        print(f'\n{"─" * 60}')
        print(f'Image  : {src_path}')
        print(f'Output : {out_dir}')
        print(f'{"─" * 60}')

        try:
            self._run(src_path, out_dir, stem, override_path, anchor_override_path)
        except FileNotFoundError as exc:
            logger.error('File not found: %s', exc)
            return False
        except OSError as exc:
            logger.error('I/O error processing %s: %s', src_path, exc)
            return False
        except Exception as exc:  # pylint: disable=broad-except
            logger.error('Unexpected error processing %s: %s', src_path, exc,
                         exc_info=True)
            return False
        return True

    def process_folder(self, folder: str, out_root: str,
                       override_path: str | None = None,
                       anchor_override_path: str | None = None) -> None:
        """
        Process every PNG file inside `folder`.

        Errors in individual images are logged and skipped; processing continues.
        """
        pngs = sorted(Path(folder).glob('*.png'))
        if not pngs:
            logger.warning('No PNG files found in %s', folder)
            return

        logger.info('Found %d PNG(s) in %s', len(pngs), folder)
        ok, failed = 0, 0
        for p in pngs:
            success = self.process_file(str(p), out_root,
                                        override_path, anchor_override_path)
            if success:
                ok += 1
            else:
                failed += 1
                logger.warning('Skipped %s due to errors', p.name)

        print(f'\n{"═" * 60}')
        print(f'Batch complete — {ok} succeeded, {failed} failed')
        print(f'{"═" * 60}')

    # ── Internal pipeline ─────────────────────────────────────────────────────

    def _run(self, src_path: str, out_dir: str, stem: str,
             override_path: str | None,
             anchor_override_path: str | None) -> None:
        """Full pipeline for a single image. Raises on error."""

        # ── Load overrides ────────────────────────────────────────────────────
        category_override: dict[str, str] = {}
        if override_path and os.path.exists(override_path):
            with open(override_path, encoding='utf-8') as f:
                category_override = json.load(f)
            logger.info('Category override: %d rule(s) from %s',
                        len(category_override), override_path)

        anchor_override: dict[str, dict] = {}
        if anchor_override_path and os.path.exists(anchor_override_path):
            with open(anchor_override_path, encoding='utf-8') as f:
                anchor_override = json.load(f)
            logger.info('Anchor override: %d entry/entries from %s',
                        len(anchor_override), anchor_override_path)

        # ── Load image ────────────────────────────────────────────────────────
        if not os.path.exists(src_path):
            raise FileNotFoundError(src_path)
        src = Image.open(src_path).convert('RGBA')
        iw, ih = src.size
        total_px = iw * ih
        print(f'Size   : {iw} × {ih} px  ({total_px:,} total)\n')

        # ── Step 1: Edge mask ─────────────────────────────────────────────────
        print('[1/8] Building edge mask (Sobel) …')
        edge_mask = build_edge_mask(src, threshold=self.EDGE_THRESHOLD)
        edge_count = sum(edge_mask)
        logger.info('Edge pixels protected: %d (%.1f%%)',
                    edge_count, 100 * edge_count / total_px)

        # ── Step 2: Remove background ─────────────────────────────────────────
        print('[2/8] Removing background (BFS + edge guard) …')
        cleaned = remove_background(src, self.tol, edge_mask=edge_mask)

        # ── Step 3: Foreground mask ───────────────────────────────────────────
        print('[3/8] Building foreground mask …')
        mask, mw, mh = build_alpha_mask(cleaned)

        # ── Step 4: Connected components ──────────────────────────────────────
        print('[4/8] Finding connected components …')
        raw_blobs = connected_components(mask, mw, mh)
        logger.info('Raw blobs: %d', len(raw_blobs))

        # Ratio-based noise filter (also respects absolute floor)
        min_area = max(self.MIN_BLOB_AREA, int(total_px * self.MIN_BLOB_RATIO))
        logger.info('Min blob area threshold: %d px²', min_area)

        def _keep(b: Blob) -> bool:
            area = len(b)
            if area < min_area:
                return False
            x0, y0, x1, y1 = bbox(b)
            w, h = x1 - x0, y1 - y0
            aspect = w / max(h, 1)
            # Reject if it looks like a single-pixel-wide line
            if aspect > self.MAX_LINE_RATIO or aspect < 1 / self.MAX_LINE_RATIO:
                logger.debug('Dropped line-noise blob: area=%d w=%d h=%d', area, w, h)
                return False
            return True

        raw_blobs = [b for b in raw_blobs if _keep(b)]
        print(f'      blobs after ratio/line filter: {len(raw_blobs)}')

        # ── Step 5: Merge nearby blobs ────────────────────────────────────────
        print('[5/8] Merging nearby blobs (gap + Y-band + height ratio) …')
        parts = merge_nearby(raw_blobs, self.gap)
        print(f'      merged parts: {len(parts)}')

        # ── Step 6: Classify ──────────────────────────────────────────────────
        print('[6/8] Classifying parts …')
        categorised = self._classify_parts(parts, iw, ih, category_override)
        for cat in self.LAYER_ORDER:
            count = len(categorised.get(cat, []))
            print(f'      {cat:<12}: {count}')
        total = sum(len(v) for v in categorised.values())
        print(f'      {"total":<12}: {total}')

        # ── Step 7: Face anchor ───────────────────────────────────────────────
        print('[7/8] Computing face anchor …')
        face_anchor = self._calculate_anchor(categorised, anchor_override, stem)
        print(f'      face anchor (canvas coords): {face_anchor}')

        # ── Step 7b: Debug images ─────────────────────────────────────────────
        if self.debug:
            print('[7b]  Saving debug images …')
            self._make_debug_images(src, cleaned, parts, categorised, face_anchor,
                                    os.path.join(out_dir, 'debug'))

        # ── Step 8: Export assets ─────────────────────────────────────────────
        print('[8/8] Exporting assets …')
        offsets = self._export_assets(categorised, cleaned, face_anchor, out_dir, stem)

        json_path = os.path.join(out_dir, 'offsets.json')
        os.makedirs(out_dir, exist_ok=True)
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(offsets, f, ensure_ascii=False, indent=2)
        _log_file(json_path, out_dir)

        print(f'\n✓ {total} parts exported → {out_dir}')
        self._print_usage_guide(stem, out_dir)

    # ── Step 6: Classification ────────────────────────────────────────────────

    def _classify_parts(self, parts: list[Blob], iw: int, ih: int,
                        override: dict[str, str]) -> dict[str, list[Blob]]:
        """
        Assign each merged blob to a category.

        Priority (highest → lowest):
          1. Manual override JSON (blob_{N} → category, 1-indexed).
          2. Body: largest blob whose x-center is in the left zone.
          3. Scoring classifier: combines aspect ratio, relative area, and
             relative Y-position — no hardcoded pixel values.
        """
        result: dict[str, list[Blob]] = {k: [] for k in self.LAYER_ORDER}

        body_x_limit = iw * self.BODY_LEFT_RATIO
        left: list[tuple[int, Blob]] = []
        right: list[tuple[int, Blob]] = []

        for i, blob in enumerate(parts):
            x0, y0, x1, y1 = bbox(blob)
            cx = (x0 + x1) / 2
            (left if cx < body_x_limit else right).append((i, blob))

        # ── Body ──────────────────────────────────────────────────────────────
        body_idx: int | None = None
        if left:
            body_idx, body_blob = max(left, key=lambda t: len(t[1]))
            result['body'].append(body_blob)
            for i, b in left:
                if i != body_idx:
                    cat = override.get(f'blob_{i + 1}', 'accessory')
                    result.setdefault(cat, []).append(b)

        if not right:
            return result

        # ── Right-side context (for relative feature computation) ─────────────
        all_y = [y for _, bl in right for _, y in bl]
        all_x = [x for _, bl in right for x, _ in bl]
        y_min, y_max = min(all_y), max(all_y)
        right_h = max(y_max - y_min, 1)
        right_w = max(max(all_x) - min(all_x), 1)
        max_area = max(len(bl) for _, bl in right)

        # ── Classify each right-side blob using scoring ───────────────────────
        for i, blob in right:
            blob_key = f'blob_{i + 1}'
            if blob_key in override:
                result.setdefault(override[blob_key], []).append(blob)
                continue

            x0, y0, x1, y1 = bbox(blob)
            w = x1 - x0
            h = y1 - y0
            aspect = w / max(h, 1)
            rel_area = len(blob) / max_area
            rel_y = ((y0 + y1) / 2 - y_min) / right_h   # 0=top, 1=bottom

            cat = self._score_classify(aspect, rel_area, rel_y, w, h,
                                       right_w, right_h)
            result[cat].append(blob)

        return result

    def _score_classify(self, aspect: float, rel_area: float, rel_y: float,
                        w: int, h: int, right_w: int, right_h: int) -> str:
        """
        Heuristic scoring classifier for right-side blobs.

        Each category accumulates score points from several independent
        signals (shape, size, position). The category with the highest
        total score wins. Ties default to 'accessory'.

        Tune the weights here if classification is consistently wrong
        for a particular image, or use category_override.json for
        individual misclassified blobs.
        """
        scores: dict[str, float] = {cat: 0.0 for cat in self.LAYER_ORDER
                                     if cat != 'body'}

        # ── Glasses ───────────────────────────────────────────────────────────
        # Very wide & very thin: strongest glasses signal
        if aspect > 3.0:
            scores['glasses'] += 4.0
        elif aspect > 2.0:
            scores['glasses'] += 2.0
        if h < right_h * 0.09:
            scores['glasses'] += 3.0
        elif h < right_h * 0.14:
            scores['glasses'] += 1.5
        # Glasses typically sit in the middle vertical range of the face panel
        if 0.25 < rel_y < 0.65:
            scores['glasses'] += 0.5

        # ── Hat ───────────────────────────────────────────────────────────────
        # Upper zone
        if rel_y < 0.20:
            scores['hat'] += 4.0
        elif rel_y < 0.35:
            scores['hat'] += 2.5
        elif rel_y < 0.45:
            scores['hat'] += 0.5
        # Medium-to-large relative area
        if rel_area > 0.35:
            scores['hat'] += 2.0
        elif rel_area > 0.20:
            scores['hat'] += 1.0
        # Hats tend to be squarish (not ultrawide)
        if 0.6 < aspect < 2.0:
            scores['hat'] += 0.5

        # ── Hair ──────────────────────────────────────────────────────────────
        # Upper-to-mid zone
        if rel_y < 0.35:
            scores['hair'] += 2.5
        elif rel_y < 0.55:
            scores['hair'] += 1.0
        # Hair is wide relative to its height
        if aspect > 2.0:
            scores['hair'] += 2.5
        elif aspect > 1.3:
            scores['hair'] += 1.0
        # Hair occupies meaningful area
        if rel_area > 0.25:
            scores['hair'] += 1.5
        elif rel_area > 0.10:
            scores['hair'] += 0.5

        # ── Accessory ─────────────────────────────────────────────────────────
        # Lower zone → strong accessory signal
        if rel_y > 0.70:
            scores['accessory'] += 3.0
        elif rel_y > 0.55:
            scores['accessory'] += 1.0
        # Small items
        if rel_area < 0.08:
            scores['accessory'] += 1.5
        elif rel_area < 0.15:
            scores['accessory'] += 0.5

        best = max(scores, key=lambda k: scores[k])
        if scores[best] == 0.0:
            return 'accessory'
        logger.debug('Classified → %s (scores: %s)', best,
                     {k: round(v, 1) for k, v in scores.items()})
        return best

    # ── Step 7: Face anchor ───────────────────────────────────────────────────

    def _calculate_anchor(self, categorised: dict[str, list[Blob]],
                          anchor_override: dict[str, dict],
                          stem: str) -> tuple[int, int]:
        """
        Determine the face center in CANVAS coordinates.

        Resolution order:
          1. anchor_override.json — exact (x, y) provided by the developer.
          2. Body-based estimation:
               • Locate the body blob's bounding box.
               • Define the face region as the top [FACE_TOP_RATIO, FACE_BOTTOM_RATIO]
                 fraction of body height (default: top 0–40 % = face area).
               • Face center = vertical midpoint of that region, horizontally centered.
               • Translate to canvas coordinates using the same center-paste offset
                 that render_part() uses.

        Falls back to canvas center (512//2, 512//2) when no body is detected.

        Fine-tune: if the yellow dot in debug_categories.png sits too high or
        low, adjust FACE_BOTTOM_RATIO (class constant) or provide an
        anchor_override.json entry for this character.
        """
        half = self.canvas // 2

        # ── Priority 1: developer-supplied anchor ──────────────────────────────
        if stem in anchor_override:
            ov = anchor_override[stem]
            anchor = (int(ov['x']), int(ov['y']))
            logger.info('Using anchor override for "%s": %s', stem, anchor)
            return anchor

        # ── Priority 2: body-based estimation ────────────────────────────────
        bodies = categorised.get('body', [])
        if not bodies:
            logger.warning('No body detected — using canvas center as anchor')
            return (half, half)

        bx0, by0, bx1, by1 = bbox(bodies[0])
        bw, bh = bx1 - bx0, by1 - by0

        # Body is center-pasted on the canvas (same logic as render_part)
        paste_x = (self.canvas - bw) // 2
        paste_y = (self.canvas - bh) // 2

        # Face region: FACE_TOP_RATIO to FACE_BOTTOM_RATIO of body height
        face_y_top = paste_y + int(bh * self.FACE_TOP_RATIO)
        face_y_bot = paste_y + int(bh * self.FACE_BOTTOM_RATIO)
        face_canvas_x = paste_x + bw // 2
        face_canvas_y = (face_y_top + face_y_bot) // 2   # midpoint of face region

        logger.info('Face anchor estimated at canvas (%d, %d)', face_canvas_x, face_canvas_y)
        return (face_canvas_x, face_canvas_y)

    # ── Step 8: Export assets ─────────────────────────────────────────────────

    def _export_assets(self, categorised: dict[str, list[Blob]],
                       cleaned: Image.Image,
                       face_anchor: tuple[int, int],
                       out_dir: str, stem: str) -> dict:
        """
        Render each part onto a canvas, save as PNG, compute offsets.

        Offset structure in offsets.json:
          offsetX/Y      — pixel shift from face center (positive = right/down)
          offsetRatioX/Y — offsetX/Y ÷ canvasSize (scale-independent ratio)
        """
        offsets: dict = {}
        face_cx, face_cy = face_anchor
        half = self.canvas // 2

        for cat in self.LAYER_ORDER:
            blobs = categorised.get(cat, [])
            if not blobs:
                continue
            blobs_sorted = sorted(blobs, key=lambda b: (bbox(b)[1], bbox(b)[0]))
            cat_dir = os.path.join(out_dir, cat)

            for idx, blob in enumerate(blobs_sorted, start=1):
                fname = f'{cat}_{idx:02d}.png'
                fpath = os.path.join(cat_dir, fname)

                try:
                    canvas_img, cx_off, cy_off = render_part(blob, cleaned, self.canvas)
                    _save_png(canvas_img, fpath, out_dir)
                except Exception as exc:  # pylint: disable=broad-except
                    logger.error('Failed to render %s: %s', fname, exc)
                    continue

                content_cx = half + cx_off
                content_cy = half + cy_off
                offset_x = content_cx - face_cx
                offset_y = content_cy - face_cy

                entry: dict = {
                    'category':     cat,
                    'zIndex':       self.LAYER_ORDER[cat],
                    'anchor':       'face_center',
                    'offsetX':      offset_x,
                    'offsetY':      offset_y,
                    'offsetRatioX': round(offset_x / self.canvas, 4),
                    'offsetRatioY': round(offset_y / self.canvas, 4),
                    'assetPath':    f'assets/character_parts/{stem}/{cat}/{fname}',
                    'canvasSize':   self.canvas,
                }
                if cat == 'body' and idx == 1:
                    entry['faceAnchorX'] = face_cx
                    entry['faceAnchorY'] = face_cy

                offsets[fname.replace('.png', '')] = entry

        return offsets

    # ── Debug images ──────────────────────────────────────────────────────────

    def _make_debug_images(self, src: Image.Image, cleaned: Image.Image,
                           parts: list[Blob],
                           categorised: dict[str, list[Blob]],
                           face_anchor: tuple[int, int],
                           debug_dir: str) -> None:
        try:
            det = self._debug_detection(src, parts)
            _save_png(det, os.path.join(debug_dir, 'debug_detection.png'), debug_dir)
        except Exception as exc:
            logger.warning('Could not save debug_detection: %s', exc)

        try:
            cats = self._debug_categories(src, categorised, face_anchor)
            _save_png(cats, os.path.join(debug_dir, 'debug_categories.png'), debug_dir)
        except Exception as exc:
            logger.warning('Could not save debug_categories: %s', exc)

        try:
            preview = self._debug_preview(categorised, cleaned)
            _save_png(preview, os.path.join(debug_dir, 'debug_preview.png'), debug_dir)
        except Exception as exc:
            logger.warning('Could not save debug_preview: %s', exc)

    def _debug_detection(self, src: Image.Image, parts: list[Blob]) -> Image.Image:
        """
        Draw each detected (merged) blob's bounding box + 1-indexed label.
        Blob numbers here match the keys used in category_override.json.
        """
        debug = src.convert('RGBA').copy()
        overlay = Image.new('RGBA', debug.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        palette = [
            (255, 80, 80), (80, 160, 255), (80, 220, 80), (255, 200, 30),
            (200, 80, 255), (255, 130, 0), (0, 200, 200), (200, 200, 0),
        ]
        for i, blob in enumerate(parts):
            x0, y0, x1, y1 = bbox(blob)
            c = palette[i % len(palette)]
            draw.rectangle([x0, y0, x1, y1],
                           fill=c + (40,), outline=c + (255,), width=2)
            draw.text((x0 + 3, y0 + 2), str(i + 1), fill=(0, 0, 0, 255))
        return Image.alpha_composite(debug, overlay)

    def _debug_categories(self, src: Image.Image,
                          categorised: dict[str, list[Blob]],
                          face_anchor: tuple[int, int]) -> Image.Image:
        """
        Draw bounding boxes colour-coded by category.

        Visual elements:
          • Coloured bbox per part
          • Filled dot at content center of each part
          • Arrow from face anchor → each non-body part center
            (shows offsetX/Y direction and magnitude)
          • Yellow circle on body at estimated face position
          • Category label (e.g. H1, G2)
        """
        debug = src.convert('RGBA').copy()
        overlay = Image.new('RGBA', debug.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)

        # ── Bounding boxes + center dots ──────────────────────────────────────
        for cat, blobs in categorised.items():
            c = self.CATEGORY_COLORS.get(cat, (170, 170, 170))
            for idx_b, blob in enumerate(blobs, 1):
                x0, y0, x1, y1 = bbox(blob)
                draw.rectangle([x0, y0, x1, y1],
                               fill=c + (50,), outline=c + (255,), width=3)
                pcx, pcy = (x0 + x1) // 2, (y0 + y1) // 2
                # Filled center dot
                draw.ellipse([pcx - 5, pcy - 5, pcx + 5, pcy + 5],
                             fill=c + (230,), outline=(255, 255, 255, 255), width=1)
                # Label
                label = f'{cat[0].upper()}{idx_b}'
                tw = len(label) * 7
                draw.rectangle([x0, y0, x0 + tw + 4, y0 + 16], fill=(0, 0, 0, 160))
                draw.text((x0 + 2, y0 + 1), label, fill=(255, 255, 255, 255))

        # ── Face anchor marker on body (in SRC image coordinates) ─────────────
        for blob in categorised.get('body', []):
            bx0, by0, bx1, by1 = bbox(blob)
            bh = by1 - by0
            face_src_x = (bx0 + bx1) // 2
            face_src_y = by0 + int(bh * ((self.FACE_TOP_RATIO + self.FACE_BOTTOM_RATIO) / 2))
            r = 12
            draw.ellipse([face_src_x - r, face_src_y - r,
                          face_src_x + r, face_src_y + r],
                         fill=(255, 255, 0, 230), outline=(0, 0, 0, 255), width=2)
            draw.text((face_src_x + r + 3, face_src_y - 8), 'face',
                      fill=(255, 255, 0, 255))

            # ── Arrows: face anchor → each non-body part center ───────────────
            for cat, blobs in categorised.items():
                if cat == 'body':
                    continue
                c = self.CATEGORY_COLORS.get(cat, (170, 170, 170))
                for b in blobs:
                    px0, py0, px1, py1 = bbox(b)
                    pcx, pcy = (px0 + px1) // 2, (py0 + py1) // 2
                    _draw_arrow(draw,
                                face_src_x, face_src_y, pcx, pcy,
                                fill=c + (160,), width=2, head_len=10, head_w=5)

        return Image.alpha_composite(debug, overlay)

    def _debug_preview(self, categorised: dict[str, list[Blob]],
                       cleaned: Image.Image) -> Image.Image:
        """
        Grid preview: columns = categories (with zIndex), rows = individual parts.
        Each cell has a checkerboard background so transparency is visible.
        """
        cats = list(self.LAYER_ORDER.keys())
        thumb = 128
        col_counts = [len(categorised.get(c, [])) for c in cats]
        max_rows = max(col_counts, default=1)

        cell_gap = 8
        header_h = 28
        sheet_w = len(cats) * thumb + (len(cats) + 1) * cell_gap
        sheet_h = max_rows * thumb + (max_rows + 1) * cell_gap + header_h

        sheet = Image.new('RGBA', (sheet_w, sheet_h), (240, 240, 240, 255))
        draw = ImageDraw.Draw(sheet)

        for col_i, cat in enumerate(cats):
            cx = col_i * (thumb + cell_gap) + cell_gap
            c = self.CATEGORY_COLORS.get(cat, (200, 200, 200))
            draw.rectangle([cx, 0, cx + thumb, header_h - 2], fill=c)
            draw.text((cx + 4, 6), f'{cat} z={self.LAYER_ORDER[cat]}',
                      fill=(0, 0, 0, 255))

            blobs_sorted = sorted(categorised.get(cat, []),
                                  key=lambda b: (bbox(b)[1], bbox(b)[0]))
            for row_i, blob in enumerate(blobs_sorted):
                cy = row_i * (thumb + cell_gap) + cell_gap + header_h
                try:
                    part_canvas, _, _ = render_part(blob, cleaned, self.canvas)
                    thumb_img = part_canvas.resize((thumb, thumb), Image.LANCZOS)
                except Exception as exc:
                    logger.warning('Preview thumb failed: %s', exc)
                    continue
                checker = Image.new('RGBA', (thumb, thumb), (255, 255, 255, 255))
                for ty in range(0, thumb, 8):
                    for tx in range(0, thumb, 8):
                        if (tx // 8 + ty // 8) % 2:
                            checker.paste((200, 200, 200, 255), (tx, ty, tx + 8, ty + 8))
                checker.paste(thumb_img, (0, 0), thumb_img)
                sheet.paste(checker, (cx, cy))
                draw.text((cx + 2, cy + 2), f'{row_i + 1}', fill=(0, 0, 0, 200))

        return sheet

    # ── Usage guide ───────────────────────────────────────────────────────────

    def _print_usage_guide(self, stem: str, out_dir: str) -> None:
        print()
        print('━' * 60)
        print('FILES CREATED')
        print(f'  {out_dir}/')
        print(f'    body/         body_01.png')
        print(f'    hair/         hair_01.png … hair_NN.png')
        print(f'    hat/          hat_01.png  … hat_NN.png')
        print(f'    glasses/      glasses_01.png … glasses_NN.png')
        print(f'    accessory/    accessory_01.png … accessory_NN.png')
        print(f'    offsets.json')
        if self.debug:
            print(f'    debug/        debug_detection.png')
            print(f'                  debug_categories.png  (face anchor + arrows)')
            print(f'                  debug_preview.png')

        print()
        print('VERIFICATION CHECKLIST')
        print('  1. debug/debug_detection.png')
        print('     → Blobs numbered 1-N. Use these in category_override.json.')
        print('     → Blobs stuck together? increase --gap')
        print('     → One part split in two? decrease --gap')
        print()
        print('  2. debug/debug_categories.png')
        print('     → R=body  B=hair  Y=hat  G=glasses  P=accessory')
        print('     → Yellow circle on body = estimated face anchor')
        print('     → Arrows show offsetX/Y direction per part')
        print()
        print('  3. Fix misclassified blobs → category_override.json:')
        print('     { "blob_3": "hat", "blob_7": "glasses" }')
        print(f'     python split_assets.py --input <src> --override category_override.json')
        print()
        print('  4. Fix wrong face anchor → anchor_override.json:')
        print(f'     {{ "{stem}": {{ "x": 256, "y": 180 }} }}')
        print(f'     python split_assets.py --input <src> --anchor-override anchor_override.json')
        print()
        print('FLAME / FLUTTER INTEGRATION')
        print('  z-order: body(0) → hair(10) → glasses(20) → hat(30) → accessory(40)')
        print()
        print('  pubspec.yaml:')
        print('    assets:')
        print(f'      - assets/character_parts/{stem}/')
        print()
        print('  offsetX/Y = px shift from face center (positive → right/down).')
        print('  offsetRatioX/Y = offsetX/Y ÷ canvasSize (use this when canvas changes).')
        print()
        print('  Flutter Stack example:')
        print('    // face position on screen:')
        print('    //   screenFaceX = widget.left + body.faceAnchorX')
        print('    //   screenFaceY = widget.top  + body.faceAnchorY')
        print('    // per-part positioning:')
        print('    //   left = screenFaceX + part.offsetX - canvasSize / 2')
        print('    //   top  = screenFaceY + part.offsetY - canvasSize / 2')
        print('━' * 60)


# ═══════════════════════════════════════════════════════════════════════════════
#  Drawing helpers
# ═══════════════════════════════════════════════════════════════════════════════

def _draw_arrow(draw: ImageDraw.ImageDraw,
                x1: int, y1: int, x2: int, y2: int,
                fill: tuple, width: int = 2,
                head_len: int = 12, head_w: int = 5) -> None:
    """
    Draw a line with an arrowhead at (x2, y2).

    The arrowhead is a small filled triangle pointing in the direction of
    travel, giving a clear indication of the offset direction in debug images.
    """
    draw.line([x1, y1, x2, y2], fill=fill, width=width)

    dx = x2 - x1
    dy = y2 - y1
    length = math.sqrt(dx * dx + dy * dy)
    if length < head_len + 1:
        return

    # Unit direction vector
    ux, uy = dx / length, dy / length
    # Perpendicular vector
    px, py = -uy, ux

    # Arrowhead triangle vertices
    tip   = (x2, y2)
    left  = (x2 - ux * head_len + px * head_w, y2 - uy * head_len + py * head_w)
    right = (x2 - ux * head_len - px * head_w, y2 - uy * head_len - py * head_w)
    draw.polygon([tip, left, right], fill=fill)


# ═══════════════════════════════════════════════════════════════════════════════
#  File I/O helpers
# ═══════════════════════════════════════════════════════════════════════════════

def _save_png(img: Image.Image, path: str, ref_dir: str | None = None) -> None:
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    img.save(path, 'PNG')
    display = os.path.relpath(path, ref_dir) if ref_dir else path
    print(f'    ✓  {display}')


def _log_file(path: str, ref_dir: str) -> None:
    print(f'    ✓  {os.path.relpath(path, ref_dir)}')


# ═══════════════════════════════════════════════════════════════════════════════
#  CLI entry point
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> None:
    p = argparse.ArgumentParser(
        prog='split_assets.py',
        description='Character sprite-sheet asset pipeline for Flame / Flutter.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
examples:
  python split_assets.py --input assets/images/before/남자아이.png
  python split_assets.py --input assets/images/before/
  python split_assets.py --input 남자아이.png --output ./out --canvas 512
  python split_assets.py --input 남자아이.png --override category_override.json
  python split_assets.py --input 남자아이.png --anchor-override anchor_override.json --no-debug

category_override.json  (fix misclassified blobs — numbers from debug_detection.png):
  { "blob_3": "hat", "blob_7": "glasses" }

anchor_override.json  (fix wrong face anchor per character):
  { "남자아이": { "x": 256, "y": 180 } }
        """,
    )
    p.add_argument('--input',           required=True,
                   help='Path to a PNG file OR a folder of PNG files')
    p.add_argument('--output',          default='assets/character_parts',
                   help='Root output directory (default: assets/character_parts)')
    p.add_argument('--canvas',          type=int, default=512,
                   help='Output canvas size in px (default: 512)')
    p.add_argument('--gap',             type=int, default=50,
                   help='Blob merge gap in px (default: 50)')
    p.add_argument('--tol',             type=int, default=45,
                   help='Background removal L1 tolerance (default: 45)')
    p.add_argument('--override',        default=None,
                   help='Path to category_override.json')
    p.add_argument('--anchor-override', default=None,
                   help='Path to anchor_override.json')
    p.add_argument('--no-debug',        action='store_true',
                   help='Skip debug image generation (faster)')
    args = p.parse_args()

    splitter = CharacterSplitter(
        canvas=args.canvas,
        gap=args.gap,
        tol=args.tol,
        debug=not args.no_debug,
    )

    anchor_ov = getattr(args, 'anchor_override', None)

    if os.path.isfile(args.input):
        splitter.process_file(args.input, args.output, args.override, anchor_ov)
    elif os.path.isdir(args.input):
        splitter.process_folder(args.input, args.output, args.override, anchor_ov)
    else:
        logger.error('--input path not found: %s', args.input)
        sys.exit(1)


if __name__ == '__main__':
    main()
