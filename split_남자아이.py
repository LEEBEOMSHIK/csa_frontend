#!/usr/bin/env python3
"""
split_남자아이.py
=================
Splits assets/images/before/남자아이.png into individual transparent PNG parts
for use as Flame / Flutter Image.asset sprite layers.

Expected contents (from image analysis):
  body × 1  |  hair × 8  |  hat × 7  |  glasses × 4  |  accessory × 8

Output structure:
  assets/character_parts/
  ├── body/
  │   └── body_01.png
  ├── hair/
  │   ├── hair_01.png … hair_08.png
  ├── hat/
  │   ├── hat_01.png  … hat_07.png
  ├── glasses/
  │   ├── glasses_01.png … glasses_04.png
  ├── accessory/
  │   ├── accessory_01.png … accessory_08.png
  └── debug/
      ├── debug_detection.png   (all detected blobs + bounding boxes)
      └── debug_categories.png  (colour-coded by category)

  assets/character_parts/offsets.json

Usage:
  python split_남자아이.py [--canvas 512] [--gap 40] [--tol 45] [--debug]

Requirements:
  pip install Pillow
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from collections import deque
from PIL import Image, ImageDraw, ImageFont

# ── Paths ─────────────────────────────────────────────────────────────────────

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_PATH = os.path.join(BASE_DIR, 'assets', 'images', 'before', '남자아이.png')
OUT_DIR  = os.path.join(BASE_DIR, 'assets', 'character_parts')

# ── Tunable parameters (override via CLI flags) ────────────────────────────────

CANVAS_SIZE   = 512   # All output PNGs → CANVAS_SIZE × CANVAS_SIZE square
BG_EDGE_TOL   = 45   # BFS background removal: colour-distance tolerance
MIN_BLOB_AREA = 300   # px² — discard noise blobs smaller than this
MERGE_GAP     = 50   # px  — merge two blobs if their bounding boxes are ≤ this apart

# ── Classification thresholds ─────────────────────────────────────────────────

# A blob whose x-center < image_width × this ratio is a "left-side" candidate (body)
BODY_LEFT_RATIO = 0.38

# Within the RIGHT-SIDE content region, classify by y-center (0.0=top, 1.0=bottom).
# Tune these if debug output shows wrong categories.
CATEGORY_BANDS: dict[str, tuple[float, float]] = {
    'hair':      (0.00, 0.30),
    'hat':       (0.30, 0.55),
    'glasses':   (0.55, 0.72),
    'accessory': (0.72, 1.00),
}

# Expected part counts per category (used only for validation warnings)
EXPECTED_COUNTS = {'hair': 8, 'hat': 7, 'glasses': 4, 'accessory': 8}

# ── Anchor offsets for Flame rendering ────────────────────────────────────────
# All parts are centered on a CANVAS_SIZE × CANVAS_SIZE canvas.
# In Flutter Stack / Flame, lay all same-size images on top of each other —
# the offsets here represent how each CATEGORY should be shifted
# relative to the body's center so items land in the right place.
# Positive X = right, positive Y = down (screen coordinates).
# Fine-tune these values after reviewing the extracted assets.
DEFAULT_OFFSETS: dict[str, dict] = {
    'body':      {'offsetX':   0, 'offsetY':   0},
    'hair':      {'offsetX':   0, 'offsetY': -90},   # sits on top of head
    'hat':       {'offsetX':   0, 'offsetY':-115},   # above hair
    'glasses':   {'offsetX':   0, 'offsetY': -45},   # at eye level
    'accessory': {'offsetX':  85, 'offsetY':  30},   # beside body (hand area)
}

# ── Debug visualisation colours (RGBA) ────────────────────────────────────────
CATEGORY_COLORS: dict[str, tuple] = {
    'body':      (255,  70,  70, 200),
    'hair':      ( 60, 140, 255, 200),
    'hat':       (255, 200,  30, 200),
    'glasses':   ( 50, 210, 110, 200),
    'accessory': (200,  60, 240, 200),
    'unknown':   (170, 170, 170, 200),
}

# ═══════════════════════════════════════════════════════════════════════════════
#  Core image utilities
# ═══════════════════════════════════════════════════════════════════════════════

def _l1(a: tuple, b: tuple) -> int:
    """L1 (Manhattan) colour distance between two RGB triples."""
    return abs(int(a[0]) - int(b[0])) + abs(int(a[1]) - int(b[1])) + abs(int(a[2]) - int(b[2]))


def remove_background(img_rgba: Image.Image, tol: int = BG_EDGE_TOL) -> Image.Image:
    """
    BFS flood-fill from all four image edges.

    Each edge pixel seeds the queue with its own colour as the 'reference
    background colour'.  During BFS, any reachable pixel within `tol`
    (L1 distance) of the propagating reference colour is erased to
    transparent.  The reference colour propagates to neighbours so the
    algorithm naturally follows smooth/gradient backgrounds.
    """
    result = img_rgba.copy()
    px = result.load()
    iw, ih = result.size

    visited = bytearray(iw * ih)

    def idx(x: int, y: int) -> int:
        return y * iw + x

    def is_bg(x: int, y: int, ref: tuple) -> bool:
        p = px[x, y]
        if p[3] < 15:          # already transparent → treat as background
            return True
        return _l1(p[:3], ref) < tol

    # ── Seed from all four edges ──────────────────────────────────────────────
    q: deque = deque()
    for x in range(iw):
        for y_edge in (0, ih - 1):
            i = idx(x, y_edge)
            ref = px[x, y_edge][:3]
            if not visited[i] and is_bg(x, y_edge, ref):
                visited[i] = 1
                q.append((x, y_edge, ref))
    for y in range(ih):
        for x_edge in (0, iw - 1):
            i = idx(x_edge, y)
            ref = px[x_edge, y][:3]
            if not visited[i] and is_bg(x_edge, y, ref):
                visited[i] = 1
                q.append((x_edge, y, ref))

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
                    # Propagate parent reference so gradient BG is handled
                    q.append((nx, ny, ref))

    return result


# ═══════════════════════════════════════════════════════════════════════════════
#  Connected-component analysis
# ═══════════════════════════════════════════════════════════════════════════════

Blob = list[tuple[int, int]]   # list of (x, y) foreground pixel coordinates


def build_alpha_mask(img_rgba: Image.Image) -> tuple[bytearray, int, int]:
    """Return (flat bytearray, width, height); 1 = foreground, 0 = background."""
    iw, ih = img_rgba.size
    px = img_rgba.load()
    mask = bytearray(iw * ih)
    for y in range(ih):
        for x in range(iw):
            mask[y * iw + x] = 1 if px[x, y][3] > 30 else 0
    return mask, iw, ih


def connected_components(mask: bytearray, iw: int, ih: int) -> list[Blob]:
    """BFS-based connected-component labelling.  O(width × height)."""
    visited = bytearray(iw * ih)
    blobs: list[Blob] = []
    DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))

    for sy in range(ih):
        row_base = sy * iw
        for sx in range(iw):
            si = row_base + sx
            if not mask[si] or visited[si]:
                continue
            # BFS
            blob: Blob = []
            q: deque = deque()
            q.append((sx, sy))
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
    """Return (x0, y0, x1, y1) — x1/y1 are exclusive."""
    xs = [p[0] for p in blob]
    ys = [p[1] for p in blob]
    return min(xs), min(ys), max(xs) + 1, max(ys) + 1


def bbox_gap(a: tuple, b: tuple) -> float:
    """
    Minimum gap between two bounding boxes.
    Returns 0 when they touch or overlap; positive when separated.
    """
    ax0, ay0, ax1, ay1 = a
    bx0, by0, bx1, by1 = b
    dx = max(0, max(ax0, bx0) - min(ax1, bx1))
    dy = max(0, max(ay0, by0) - min(ay1, by1))
    return (dx * dx + dy * dy) ** 0.5


def merge_nearby(blobs: list[Blob], gap: int = MERGE_GAP) -> list[Blob]:
    """
    Union-Find merge: two blobs whose bounding boxes are ≤ `gap` pixels apart
    are combined into one part.  This groups multi-piece items (e.g. glasses
    lenses, accessories with separate sub-shapes).
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
            if bbox_gap(boxes[i], boxes[j]) <= gap:
                union(i, j)

    groups: dict[int, Blob] = {}
    for i, blob in enumerate(blobs):
        r = find(i)
        groups.setdefault(r, []).extend(blob)

    return list(groups.values())


# ═══════════════════════════════════════════════════════════════════════════════
#  Classification
# ═══════════════════════════════════════════════════════════════════════════════

def classify(parts: list[Blob], iw: int) -> dict[str, list[Blob]]:
    """
    Assign each merged blob to a category:

    body      — the SINGLE largest blob whose x-center is in the left zone.
    hair      — right-side blobs in the top Y-band.
    hat       — right-side blobs in the second Y-band.
    glasses   — right-side blobs in the third Y-band.
    accessory — right-side blobs in the bottom Y-band.

    Left-side blobs that are NOT the body (e.g. a small held accessory)
    are treated as accessories.
    """
    result: dict[str, list[Blob]] = {k: [] for k in ('body', 'hair', 'hat', 'glasses', 'accessory')}

    body_x_limit = iw * BODY_LEFT_RATIO

    left_blobs: list[Blob] = []
    right_blobs: list[Blob] = []

    for blob in parts:
        x0, y0, x1, y1 = bbox(blob)
        cx = (x0 + x1) / 2
        if cx < body_x_limit:
            left_blobs.append(blob)
        else:
            right_blobs.append(blob)

    # Body = largest left-zone blob; any other left-zone blobs are accessories
    if left_blobs:
        body_blob = max(left_blobs, key=len)
        result['body'].append(body_blob)
        for b in left_blobs:
            if b is not body_blob:
                result['accessory'].append(b)

    if not right_blobs:
        return result

    # Y-band classification within right-side content
    all_y = [coord for blob in right_blobs for _, coord in blob]
    y_min, y_max = min(all_y), max(all_y)
    y_range = max(y_max - y_min, 1)

    for blob in right_blobs:
        x0, y0, x1, y1 = bbox(blob)
        cy = (y0 + y1) / 2
        rel_y = (cy - y_min) / y_range   # 0.0 = top of right content

        assigned = 'accessory'            # fallback
        for cat, (lo, hi) in CATEGORY_BANDS.items():
            if lo <= rel_y < hi:
                assigned = cat
                break
        result[assigned].append(blob)

    return result


# ═══════════════════════════════════════════════════════════════════════════════
#  Canvas rendering & offset calculation
# ═══════════════════════════════════════════════════════════════════════════════

def render_part(blob: Blob, src: Image.Image, size: int = CANVAS_SIZE
                ) -> tuple[Image.Image, int, int]:
    """
    Crop the blob's bounding box from `src`, then center it on a
    size × size transparent canvas.

    Returns:
        canvas       — the CANVAS_SIZE × CANVAS_SIZE RGBA image
        offset_x     — horizontal offset from canvas center to content center
        offset_y     — vertical offset from canvas center to content center
    """
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    x0, y0, x1, y1 = bbox(blob)
    cropped = src.crop((x0, y0, x1, y1))
    cw, ch = cropped.size

    paste_x = (size - cw) // 2
    paste_y = (size - ch) // 2
    canvas.paste(cropped, (paste_x, paste_y), cropped)

    # Offset from canvas center (size//2, size//2) to content center
    content_cx = paste_x + cw // 2
    content_cy = paste_y + ch // 2
    offset_x = content_cx - size // 2
    offset_y = content_cy - size // 2

    return canvas, offset_x, offset_y


def make_body_anchor(categorised: dict[str, list[Blob]],
                     cleaned: Image.Image) -> tuple[int, int]:
    """
    Estimate the body's head center in image coordinates.
    Used to calibrate offsetY for overlay parts.
    Returns (head_cx, head_cy) in original image coordinates.
    """
    if not categorised['body']:
        return 0, 0
    body = categorised['body'][0]
    x0, y0, x1, y1 = bbox(body)
    cx = (x0 + x1) // 2
    content_h = y1 - y0
    # Head occupies the top ~22% of total character height
    head_cy = y0 + int(content_h * 0.22)
    return cx, head_cy


# ═══════════════════════════════════════════════════════════════════════════════
#  Debug visualisation
# ═══════════════════════════════════════════════════════════════════════════════

def make_debug_detection(src: Image.Image, all_parts: list[Blob]) -> Image.Image:
    """
    Draw every detected part's bounding box + index number over the source.
    Useful for verifying that the detection step found all objects.
    """
    debug = src.convert('RGBA').copy()
    overlay = Image.new('RGBA', debug.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    colors = [
        (255, 80, 80), (80, 160, 255), (80, 220, 80), (255, 200, 30),
        (200, 80, 255), (255, 130, 0), (0, 200, 200), (200, 200, 0),
    ]
    for i, blob in enumerate(all_parts):
        x0, y0, x1, y1 = bbox(blob)
        c = colors[i % len(colors)] + (180,)
        draw.rectangle([x0, y0, x1, y1], fill=c[:3] + (40,), outline=c[:3] + (255,), width=2)
        draw.text((x0 + 3, y0 + 2), str(i + 1), fill=(0, 0, 0, 255))
    return Image.alpha_composite(debug, overlay)


def make_debug_categories(src: Image.Image,
                           categorised: dict[str, list[Blob]]) -> Image.Image:
    """
    Draw bounding boxes colour-coded by category + category label.
    """
    debug = src.convert('RGBA').copy()
    overlay = Image.new('RGBA', debug.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    for cat, blobs in categorised.items():
        color = CATEGORY_COLORS.get(cat, CATEGORY_COLORS['unknown'])
        fill_color = color[:3] + (50,)
        line_color = color[:3] + (255,)
        for idx_b, blob in enumerate(blobs, start=1):
            x0, y0, x1, y1 = bbox(blob)
            draw.rectangle([x0, y0, x1, y1], fill=fill_color, outline=line_color, width=3)
            label = f'{cat[0].upper()}{idx_b}'
            # Label background for readability
            tw = len(label) * 7
            draw.rectangle([x0, y0, x0 + tw + 4, y0 + 16], fill=(0, 0, 0, 160))
            draw.text((x0 + 2, y0 + 1), label, fill=(255, 255, 255, 255))
    return Image.alpha_composite(debug, overlay)


def make_spritesheet_preview(categorised: dict[str, list[Blob]],
                              cleaned: Image.Image,
                              size: int = CANVAS_SIZE) -> Image.Image:
    """
    Create a single preview PNG showing all extracted parts on a grid.
    Columns = categories, rows = individual parts.
    """
    cats = ['body', 'hair', 'hat', 'glasses', 'accessory']
    thumb = 128   # thumbnail size per cell
    col_counts = [len(categorised[c]) for c in cats]
    max_rows = max(col_counts) if col_counts else 1
    cols = len(cats)

    sheet_w = cols * thumb + (cols + 1) * 8
    header  = 24
    sheet_h = max_rows * thumb + (max_rows + 1) * 8 + header

    sheet = Image.new('RGBA', (sheet_w, sheet_h), (240, 240, 240, 255))
    draw  = ImageDraw.Draw(sheet)

    cat_colors_solid = {
        'body':      (255, 150, 150),
        'hair':      (150, 190, 255),
        'hat':       (255, 220, 100),
        'glasses':   (100, 220, 140),
        'accessory': (210, 130, 255),
    }
    for col_i, cat in enumerate(cats):
        cx = col_i * (thumb + 8) + 8
        # Category header
        draw.rectangle([cx, 0, cx + thumb, header - 2],
                       fill=cat_colors_solid.get(cat, (200, 200, 200)))
        draw.text((cx + 4, 4), cat[:8], fill=(0, 0, 0, 255))

        blobs_sorted = sorted(categorised[cat],
                              key=lambda b: (bbox(b)[1], bbox(b)[0]))
        for row_i, blob in enumerate(blobs_sorted):
            cy = row_i * (thumb + 8) + 8 + header
            part_canvas, _, _ = render_part(blob, cleaned, size)
            thumb_img = part_canvas.resize((thumb, thumb), Image.LANCZOS)
            # Checkerboard background
            checker = Image.new('RGBA', (thumb, thumb), (255, 255, 255, 255))
            for ty in range(0, thumb, 8):
                for tx in range(0, thumb, 8):
                    if (tx // 8 + ty // 8) % 2:
                        checker.paste((200, 200, 200, 255), (tx, ty, tx + 8, ty + 8))
            checker.paste(thumb_img, (0, 0), thumb_img)
            sheet.paste(checker, (cx, cy))
            # Part number label
            draw.text((cx + 2, cy + 2), f'{row_i + 1}', fill=(0, 0, 0, 200))

    return sheet


# ═══════════════════════════════════════════════════════════════════════════════
#  File I/O helpers
# ═══════════════════════════════════════════════════════════════════════════════

def save_png(img: Image.Image, path: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, 'PNG')
    rel = os.path.relpath(path, BASE_DIR)
    print(f'    ✓  {rel}')


# ═══════════════════════════════════════════════════════════════════════════════
#  Main
# ═══════════════════════════════════════════════════════════════════════════════

def main(args: argparse.Namespace) -> None:
    canvas  = args.canvas
    gap     = args.gap
    tol     = args.tol

    # ── Step 1: Load ──────────────────────────────────────────────────────────
    if not os.path.exists(SRC_PATH):
        print(f'ERROR: source image not found:\n  {SRC_PATH}', file=sys.stderr)
        sys.exit(1)

    print(f'Loading {SRC_PATH}')
    src = Image.open(SRC_PATH).convert('RGBA')
    iw, ih = src.size
    print(f'Image size: {iw} × {ih} px')

    # ── Step 2: Remove background ─────────────────────────────────────────────
    print('\n[1/8] Removing background …')
    cleaned = remove_background(src, tol=tol)

    # ── Step 3: Build foreground mask ─────────────────────────────────────────
    print('[2/8] Building foreground mask …')
    mask, mw, mh = build_alpha_mask(cleaned)

    # ── Step 4: Connected components ─────────────────────────────────────────
    print('[3/8] Finding connected components …')
    raw_blobs = connected_components(mask, mw, mh)
    print(f'      raw blobs : {len(raw_blobs)}')
    raw_blobs = [b for b in raw_blobs if len(b) >= MIN_BLOB_AREA]
    print(f'      after area filter (≥{MIN_BLOB_AREA} px²) : {len(raw_blobs)}')

    # ── Step 5: Merge nearby blobs ────────────────────────────────────────────
    print('[4/8] Merging nearby blobs …')
    merged = merge_nearby(raw_blobs, gap=gap)
    print(f'      merged parts : {len(merged)}')

    # ── Step 6: Classify ──────────────────────────────────────────────────────
    print('[5/8] Classifying parts …')
    categorised = classify(merged, iw)
    for cat in ('body', 'hair', 'hat', 'glasses', 'accessory'):
        found    = len(categorised[cat])
        expected = EXPECTED_COUNTS.get(cat, 1)
        flag     = '' if found == expected else f'  ⚠ expected {expected}'
        print(f'      {cat:<12}: {found:>3}{flag}')

    total = sum(len(v) for v in categorised.values())
    print(f'      total        : {total}')

    # ── Step 7: Debug images ──────────────────────────────────────────────────
    print('[6/8] Saving debug images …')
    debug_dir = os.path.join(OUT_DIR, 'debug')

    debug_detection = make_debug_detection(src, merged)
    save_png(debug_detection, os.path.join(debug_dir, 'debug_detection.png'))

    debug_cats = make_debug_categories(src, categorised)
    save_png(debug_cats, os.path.join(debug_dir, 'debug_categories.png'))

    preview = make_spritesheet_preview(categorised, cleaned, size=canvas)
    save_png(preview, os.path.join(debug_dir, 'debug_preview.png'))

    # ── Step 8: Render & save parts ──────────────────────────────────────────
    print('[7/8] Rendering and saving parts …')
    offsets: dict[str, dict] = {}

    ORDER = ['body', 'hair', 'hat', 'glasses', 'accessory']

    for cat in ORDER:
        blobs = categorised[cat]
        if not blobs:
            continue

        # Sort: left→right, then top→bottom
        blobs_sorted = sorted(blobs, key=lambda b: (bbox(b)[1], bbox(b)[0]))

        cat_dir = os.path.join(OUT_DIR, cat)

        for i, blob in enumerate(blobs_sorted, start=1):
            fname  = f'{cat}_{i:02d}.png' if cat != 'body' else 'body_01.png'
            fpath  = os.path.join(cat_dir, fname)
            part_canvas, cx_offset, cy_offset = render_part(blob, cleaned, size=canvas)
            save_png(part_canvas, fpath)

            key = fname.replace('.png', '')
            default = DEFAULT_OFFSETS.get(cat, {'offsetX': 0, 'offsetY': 0})

            offsets[key] = {
                'category':          cat,
                # pixel offset of content center from canvas center
                'contentOffsetX':    cx_offset,
                'contentOffsetY':    cy_offset,
                # recommended layer offset when compositing on body
                'layerOffsetX':      default['offsetX'],
                'layerOffsetY':      default['offsetY'],
                'assetPath':         f'assets/character_parts/{cat}/{fname}',
                'canvasSize':        canvas,
            }

    # ── Step 9: JSON ──────────────────────────────────────────────────────────
    print('[8/8] Writing offsets.json …')
    json_path = os.path.join(OUT_DIR, 'offsets.json')
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(offsets, f, ensure_ascii=False, indent=2)
    print(f'    ✓  {os.path.relpath(json_path, BASE_DIR)}')

    # ── Done ──────────────────────────────────────────────────────────────────
    print()
    print('━' * 60)
    print(f'Done!  {total} parts → {os.path.relpath(OUT_DIR, BASE_DIR)}')
    print()
    print('NEXT STEPS:')
    print('  1. Open  assets/character_parts/debug/debug_categories.png')
    print('     Verify each part is in the correct colour band.')
    print()
    print('  2. If categories look wrong, tweak CATEGORY_BANDS in the script')
    print('     and re-run.  The bands define Y-fraction thresholds (0.0–1.0).')
    print()
    print('  3. Check  assets/character_parts/debug/debug_preview.png')
    print('     to see all extracted parts on one page.')
    print()
    print('  4. Fine-tune layerOffsetX / layerOffsetY in offsets.json to')
    print('     position hats/glasses/accessories on the character body.')
    print('━' * 60)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Split 남자아이.png sprite sheet')
    parser.add_argument('--canvas', type=int,   default=CANVAS_SIZE,
                        help=f'Output canvas size in px (default: {CANVAS_SIZE})')
    parser.add_argument('--gap',    type=int,   default=MERGE_GAP,
                        help=f'Blob merge gap in px (default: {MERGE_GAP})')
    parser.add_argument('--tol',    type=int,   default=BG_EDGE_TOL,
                        help=f'Background removal tolerance (default: {BG_EDGE_TOL})')
    parser.add_argument('--debug',  action='store_true',
                        help='(flag kept for compatibility; debug images always generated)')
    main(parser.parse_args())
