# v5: 재화 아이콘 3종 + 목책 단일 스프라이트 (석벽 단일은 art_backup의 구 wall.png 재사용)
import sys; sys.path.insert(0, '.')
from lib import *

def icon_food():
    """볏단 (황금 곡식)"""
    W, H = 12, 12; cx = 6.0
    img = canvas(W, H)
    for i, dx in enumerate((-2.6, 0, 2.6)):
        line(img, (cx + dx, 10.5), (cx + dx * 0.4, 4.2), shade(THATCH, 0.9 + 0.12 * (i % 2)), 1.5)
    ellipse(img, cx, 8.2, 3.4, 1.5, (150, 116, 60, 255))  # 묶음 끈
    for dx in (-2.2, 0, 2.2):
        ellipse(img, cx + dx * 0.5, 3.4, 1.15, 1.9, (238, 200, 92, 255))
        ellipse(img, cx + dx * 0.5, 2.6, 0.6, 1.0, (255, 228, 130, 255))
    return finish(img, W, H)

def icon_wood():
    """통나무"""
    W, H = 12, 12
    img = canvas(W, H)
    line(img, (2.0, 8.6), (9.4, 4.4), (124, 90, 52, 255), 4.2)
    line(img, (2.4, 7.2), (8.8, 3.6), (150, 112, 66, 255), 1.2)
    ellipse(img, 9.6, 4.3, 2.0, 2.0, (201, 160, 106, 255))
    ellipse(img, 9.6, 4.3, 1.0, 1.0, (150, 112, 62, 255))
    ellipse(img, 9.6, 4.3, 0.4, 0.4, (110, 80, 46, 255))
    return finish(img, W, H)

def icon_iron():
    """철괴"""
    W, H = 12, 12
    img = canvas(W, H)
    poly(img, [(1.6, 9.2), (3.4, 5.4), (8.8, 5.4), (10.6, 9.2)], (118, 124, 138, 255))
    poly(img, [(3.4, 5.4), (8.8, 5.4), (10.6, 9.2), (6.0, 9.2)], (96, 102, 116, 255))
    line(img, (3.2, 6.4), (5.6, 6.4), (190, 198, 214, 255), 0.9)
    poly(img, [(4.0, 5.4), (5.2, 3.2), (9.4, 3.2), (8.8, 5.4)], (140, 146, 160, 255))
    return finish(img, W, H)

def wall_single():
    """목책 단일 이미지 — 어느 방향으로 늘어놔도 어색하지 않은 밀집 말뚝 블록"""
    W, H = 36, 46; cx, cy = 18, 38
    img = canvas(W, H)
    ellipse(img, cx, cy + 1, 14, 6.5, (0, 0, 0, 60))
    PALI = (128, 96, 60, 255)
    rng = np.random.default_rng(8)
    Z = 16
    # 뒤판 (틈 메움)
    poly(img, [(cx - 12, cy - 2), (cx + 12, cy - 2), (cx + 12, cy - Z + 3), (cx - 12, cy - Z + 3)], shade(PALI, 0.45))
    # 결속대 2줄
    for zt in (0.42, 0.75):
        line(img, (cx - 12.5, cy - Z * zt), (cx + 12.5, cy - Z * zt), shade(PALI, 0.6), 0.9)
    # 말뚝: 다이아 배치 2겹 (앞줄이 아래)
    pts = []
    for k in range(5):
        t = (k + 0.5) / 5.0
        pts.append((cx - 12 + 24 * t, cy - 6 - 2 * abs(t - 0.5) * 2, 0.86))  # 뒷줄
    for k in range(5):
        t = (k + 0.5) / 5.0
        pts.append((cx - 12 + 24 * t, cy - 1 + 3 * (1 - abs(t - 0.5) * 2), 1.05))  # 앞줄
    for x, y, f in pts:
        h = Z + rng.uniform(-1.5, 1.5)
        line(img, (x, y), (x, y - h + 1.2), shade(PALI, f * rng.uniform(0.9, 1.06)), 1.7)
        line(img, (x - 0.55, y), (x - 0.55, y - h + 1.4), shade(PALI, f * 1.2), 0.6)
        poly(img, [(x - 0.95, y - h + 1.6), (x + 0.95, y - h + 1.6), (x, y - h - 1.4)], shade(PALI, f * 1.08))
    img = noise_region(img, None, amount=8, seed=15)
    return finish(img, W, H)

icon_food().save("icon_food.png")
icon_wood().save("icon_wood.png")
icon_iron().save("icon_iron.png")
wall_single().save("wall.png")
print("gen9 ok")
