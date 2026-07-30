"""
Character sprite sheet splitter
Splits assets/images/before/이미지.png into individual transparent parts
Output: assets/character_parts/
"""
from __future__ import annotations
from PIL import Image, ImageDraw
from collections import deque
import os

# ── Paths ─────────────────────────────────────────────────────────────────────
SRC = r'C:\Users\User\OneDrive\바탕 화면\개발작업now\csa_frontend\assets\images\before\이미지.png'
OUT = r'C:\Users\User\OneDrive\바탕 화면\개발작업now\csa_frontend\assets\character_parts'
CANVAS = 512

# ── Band definitions ──────────────────────────────────────────────────────────
# (y_start, y_end, bg_rgb, tolerance)
# Boundaries tightened to avoid separator-line bleed between bands
BANDS = {
    'char':   (0,    636,  (249, 198, 118), 35),   # stop before orange→cream separator
    'heads':  (664,  906,  (250, 243, 215), 28),   # start AFTER the separator gradient
    'eyes':   (916,  1128, (244, 235, 199), 28),
    'noses':  (1142, 1348, (248, 242, 215), 28),
    'mouths': (1358, 1530, (243, 235, 202), 28),
}

# ── Core utilities ────────────────────────────────────────────────────────────

def color_dist(a: tuple, b: tuple) -> int:
    return abs(int(a[0]) - int(b[0])) + abs(int(a[1]) - int(b[1])) + abs(int(a[2]) - int(b[2]))


def remove_bg_bfs(img_rgba: Image.Image, bg_rgb: tuple, tol: int) -> Image.Image:
    """BFS flood-fill from all 4 edges; turns background pixels transparent."""
    result = img_rgba.copy()
    px = result.load()
    iw, ih = result.size

    visited = bytearray(iw * ih)  # flat bool array

    def idx(x, y): return y * iw + x
    def is_bg(x, y):
        p = px[x, y]
        return color_dist(p[:3], bg_rgb) < tol

    q = deque()
    # Seed from all 4 edges
    for x in range(iw):
        if is_bg(x, 0):      q.append((x, 0))
        if is_bg(x, ih - 1): q.append((x, ih - 1))
    for y in range(ih):
        if is_bg(0, y):      q.append((0, y))
        if is_bg(iw - 1, y): q.append((iw - 1, y))

    dirs = ((1, 0), (-1, 0), (0, 1), (0, -1))
    while q:
        x, y = q.popleft()
        i = idx(x, y)
        if visited[i]:
            continue
        visited[i] = 1
        if not is_bg(x, y):
            continue
        px[x, y] = (0, 0, 0, 0)
        for dx, dy in dirs:
            nx, ny = x + dx, y + dy
            if 0 <= nx < iw and 0 <= ny < ih and not visited[idx(nx, ny)]:
                q.append((nx, ny))
    return result


def center_on_canvas(part: Image.Image, canvas_size: int = CANVAS) -> Image.Image:
    """Paste the non-transparent bounding box centered on a square canvas."""
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    bbox = part.getbbox()
    if bbox is None:
        print('  [warn] empty image, skipping center')
        return canvas
    cropped = part.crop(bbox)
    cw, ch = cropped.size
    px_x = (canvas_size - cw) // 2
    px_y = (canvas_size - ch) // 2
    canvas.paste(cropped, (px_x, px_y), cropped)
    return canvas


def save(img: Image.Image, path: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, 'PNG')
    print(f'  OK {os.path.relpath(path, OUT)}')


def extract_slot(full_rgba: Image.Image,
                 x0: int, y0: int, x1: int, y1: int,
                 bg_rgb: tuple, tol: int,
                 out_path: str):
    """Crop slot → remove BG → center on canvas → save."""
    region = full_rgba.crop((x0, y0, x1, y1))
    cleaned = remove_bg_bfs(region, bg_rgb, tol)
    final   = center_on_canvas(cleaned)
    save(final, out_path)


# ── Mask-out circle (for removing head from body) ─────────────────────────────

def mask_circle(img_rgba: Image.Image, cx: float, cy: float, r: float) -> Image.Image:
    """Make a circular area fully transparent (erase head from body)."""
    result = img_rgba.copy()
    px = result.load()
    iw, ih = img_rgba.size
    r2 = r * r
    iy0 = max(0, int(cy - r) - 2)
    iy1 = min(ih, int(cy + r) + 2)
    ix0 = max(0, int(cx - r) - 2)
    ix1 = min(iw, int(cx + r) + 2)
    for y in range(iy0, iy1):
        for x in range(ix0, ix1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r2:
                px[x, y] = (0, 0, 0, 0)
    return result


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f'Loading {SRC}')
    img = Image.open(SRC).convert('RGBA')
    iw, ih = img.size
    print(f'Image size: {iw}×{ih}')

    # ── 1. Body — extract full character zone, then erase head area ──────────
    print('\n[base]')
    char_y0, char_y1, char_bg, char_tol = BANDS['char']
    char_region = img.crop((0, char_y0, iw, char_y1))
    body_cleaned = remove_bg_bfs(char_region, char_bg, char_tol)

    # Detect content bounding box to estimate head position
    bbox = body_cleaned.getbbox()
    if bbox:
        bx0, by0, bx1, by1 = bbox
        content_cx = (bx0 + bx1) / 2
        content_h  = by1 - by0
        # Head occupies roughly top 30% of character height
        head_cy = by0 + content_h * 0.18   # center-y of head within region
        head_r  = content_h * 0.18          # head radius (tighter — preserves ears/neck)

        body_no_head = mask_circle(body_cleaned, content_cx, head_cy, head_r)
        body_final = center_on_canvas(body_no_head)
        save(body_final, os.path.join(OUT, 'base', 'body.png'))
    else:
        print('  [warn] could not detect character bounding box')

    # ── 2. Heads (4 heads in row, take first 2) ──────────────────────────────
    hy0, hy1, h_bg, h_tol = BANDS['heads']
    slot_w = iw // 4  # 256 per slot
    for i in range(2):
        extract_slot(
            img,
            x0=i * slot_w, y0=hy0,
            x1=(i + 1) * slot_w, y1=hy1,
            bg_rgb=h_bg, tol=h_tol,
            out_path=os.path.join(OUT, 'base', f'head_0{i+1}.png'),
        )

    # ── 3. Eyes (4 eye-sets in row, take first 3) ───────────────────────────
    print('\n[eyes]')
    ey0, ey1, e_bg, e_tol = BANDS['eyes']
    for i in range(3):
        extract_slot(
            img,
            x0=i * slot_w, y0=ey0,
            x1=(i + 1) * slot_w, y1=ey1,
            bg_rgb=e_bg, tol=e_tol,
            out_path=os.path.join(OUT, 'eyes', f'eyes_0{i+1}.png'),
        )

    # ── 4. Noses (4-column layout like other rows, take first 2) ─────────────
    print('\n[nose]')
    ny0, ny1, n_bg, n_tol = BANDS['noses']
    for i in range(2):
        extract_slot(
            img,
            x0=i * slot_w, y0=ny0,
            x1=(i + 1) * slot_w, y1=ny1,
            bg_rgb=n_bg, tol=n_tol,
            out_path=os.path.join(OUT, 'nose', f'nose_0{i+1}.png'),
        )

    # ── 5. Mouths (4 mouths in row, take first 3) ───────────────────────────
    print('\n[mouth]')
    my0, my1, m_bg, m_tol = BANDS['mouths']
    for i in range(3):
        extract_slot(
            img,
            x0=i * slot_w, y0=my0,
            x1=(i + 1) * slot_w, y1=my1,
            bg_rgb=m_bg, tol=m_tol,
            out_path=os.path.join(OUT, 'mouth', f'mouth_0{i+1}.png'),
        )

    print('\nDone! Output folder:', OUT)


if __name__ == '__main__':
    main()
