# v3: 2x2 건물(농경지/벌목장/훈련소/훈련도감) + 조선인 일꾼 4종 + 절벽/진흙 타일
import sys; sys.path.insert(0, '.')
from lib import *

def giwa_roof(img, pts_front, ridge_a, ridge_b, base_col=GIWA, rows=5, msae=True):
    poly(img, pts_front, base_col)
    eave = pts_front[:len(pts_front) - 2]
    n_e = len(eave)
    for r in range(1, rows):
        t = r / rows
        prev = None
        for i in range(n_e):
            ex, ey = eave[i]
            rx = ridge_a[0] + (ridge_b[0] - ridge_a[0]) * (i / (n_e - 1))
            ry = ridge_a[1] + (ridge_b[1] - ridge_a[1]) * (i / (n_e - 1))
            px = ex + (rx - ex) * t; py = ey + (ry - ey) * t - math.sin(t * math.pi) * 1.2
            if prev: line(img, prev, (px, py), shade(base_col, 0.8 if r % 2 else 1.14), 0.55)
            prev = (px, py)
    for i in range(n_e):
        ex, ey = eave[i]
        rx = ridge_a[0] + (ridge_b[0] - ridge_a[0]) * (i / (n_e - 1))
        ry = ridge_a[1] + (ridge_b[1] - ridge_a[1]) * (i / (n_e - 1))
        line(img, (ex, ey), (rx, ry), shade(base_col, 0.72), 0.5)
        if msae:
            ellipse(img, ex, ey, 0.9, 0.9, shade(base_col, 1.35))
            ellipse(img, ex, ey, 0.4, 0.4, shade(base_col, 0.7))
    line(img, ridge_a, ridge_b, RIDGE, 2.0)
    ellipse(img, ridge_a[0], ridge_a[1], 1.5, 1.8, (84, 92, 102, 255))
    ellipse(img, ridge_b[0], ridge_b[1], 1.5, 1.8, (84, 92, 102, 255))

# ---------- 조선인 일꾼 (백의·상투·망건·패랭이) ----------
SKIN = (230, 195, 154, 255)
WHITE = (238, 234, 224, 255)

def kman(img, cx, cy, jeogori=WHITE, headwear="sangtu"):
    ellipse(img, cx, cy, 5, 1.9, (0, 0, 0, 80))
    # 흰 바지
    line(img, (cx - 1.5, cy - 0.3), (cx - 1.8, cy - 3.6), (216, 211, 198, 255), 1.5)
    line(img, (cx + 1.5, cy - 0.3), (cx + 2.0, cy - 3.6), (216, 211, 198, 255), 1.5)
    ellipse(img, cx - 1.7, cy - 0.2, 1.1, 0.6, (60, 50, 40, 255))  # 짚신
    ellipse(img, cx + 1.9, cy - 0.2, 1.1, 0.6, (60, 50, 40, 255))
    # 저고리
    ellipse(img, cx, cy - 6.5, 3.6, 4.0, jeogori)
    ellipse(img, cx - 1.3, cy - 7.2, 1.8, 2.0, shade(jeogori, 1.12))
    # 동정·옷고름
    line(img, (cx - 0.4, cy - 9.6), (cx + 1.4, cy - 7.2), shade(jeogori, 0.8), 0.5)
    line(img, (cx + 0.9, cy - 7.4), (cx + 1.8, cy - 4.8), (168, 66, 52, 255), 0.7)
    # 머리
    ellipse(img, cx, cy - 11.8, 2.6, 2.6, SKIN)
    if headwear == "paeraengi":  # 패랭이 (넓은 챙 + 낮은 돔)
        ellipse(img, cx, cy - 12.4, 4.8, 1.5, THATCH)
        ellipse(img, cx, cy - 12.4, 4.8, 1.5, None, outline=shade(THATCH, 0.7), ow=1)
        ellipse(img, cx, cy - 13.6, 2.0, 1.2, shade(THATCH, 1.08))
        line(img, (cx - 1.2, cy - 11.4), (cx - 0.6, cy - 10.2), (70, 56, 40, 255), 0.5)
    elif headwear == "sugeon":  # 흰 머릿수건
        line(img, (cx - 2.5, cy - 12.8), (cx + 2.5, cy - 12.8), (225, 220, 208, 255), 1.4)
        ellipse(img, cx + 2.2, cy - 12.4, 0.8, 0.5, (200, 194, 180, 255))
    elif headwear == "band":  # 검은 머리띠
        line(img, (cx - 2.5, cy - 12.7), (cx + 2.5, cy - 12.7), (42, 38, 34, 255), 1.2)
        ellipse(img, cx, cy - 14.1, 1.1, 1.2, (40, 34, 30, 255))  # 상투
    else:  # 맨상투 + 망건
        line(img, (cx - 2.4, cy - 12.6), (cx + 2.4, cy - 12.6), (52, 44, 38, 255), 0.9)
        ellipse(img, cx, cy - 14.2, 1.1, 1.3, (40, 34, 30, 255))

def worker_build():
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    kman(img, cx, cy, WHITE, "sugeon")
    poly(img, [(cx - 3.2, cy - 8.6), (cx - 1.2, cy - 9.4), (cx - 0.8, cy - 4.4), (cx - 2.8, cy - 3.8)], (150, 110, 70, 220))  # 갈색 배자
    return finish(img, W, H)

def worker_farm():
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    kman(img, cx, cy, (226, 226, 210, 255), "paeraengi")
    return finish(img, W, H)

def worker_lumber():
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    kman(img, cx, cy, (212, 200, 178, 255), "band")
    poly(img, [(cx - 3.4, cy - 9.0), (cx + 3.4, cy - 9.0), (cx + 2.6, cy - 4.2), (cx - 2.6, cy - 4.2)], (140, 104, 66, 190))  # 등거리
    return finish(img, W, H)

def worker_mine():
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    poly(img, [(cx - 5.4, cy - 9.6), (cx - 2.6, cy - 10.6), (cx - 2.2, cy - 5.6), (cx - 5.0, cy - 4.8)], (124, 96, 56, 255))  # 소쿠리
    line(img, (cx - 5.0, cy - 8.4), (cx - 2.4, cy - 9.2), (92, 70, 40, 255), 0.6)
    kman(img, cx, cy, (196, 194, 190, 255), "band")
    ellipse(img, cx + 1.2, cy - 11.0, 0.8, 0.5, (88, 84, 80, 255))  # 검댕
    return finish(img, W, H)

# ---------- 2x2 건물 ----------
def farm():
    """농경지 2x2 — 마른 밭 4배미 + 이랑 + 새싹"""
    W, H = 64, 38; cx, cy = 32, 22
    img = canvas(W, H)
    hw, hh = 28.0, 14.0
    poly(img, [(cx, cy - hh), (cx + hw, cy), (cx, cy + hh), (cx - hw, cy)], (96, 74, 44, 255))
    rng = np.random.default_rng(4)
    for qx, qy in [(-0.5, -0.5), (0.5, -0.5), (-0.5, 0.5), (0.5, 0.5)]:
        qcx = cx + (qx - qy) * hw * 0.5
        qcy = cy + (qx + qy) * hh * 0.5
        poly(img, [(qcx, qcy - hh * 0.40), (qcx + hw * 0.40, qcy), (qcx, qcy + hh * 0.40), (qcx - hw * 0.40, qcy)], (118, 88, 52, 255))
        for k in range(4):
            t = (k + 0.7) / 4.4
            x0, y0 = qcx - hw * 0.36 * (1 - t), qcy + hh * 0.36 * t
            x1, y1 = qcx + hw * 0.36 * t, qcy - hh * 0.36 * (1 - t)
            line(img, (x0, y0), (x1, y1), (86, 64, 38, 255), 0.7)
            for m in range(4):
                u = m / 3.0 * 0.7 + 0.15
                gx = x0 + (x1 - x0) * u; gy = y0 + (y1 - y0) * u
                line(img, (gx, gy), (gx - 0.6, gy - 1.7), (110, 168, 78, 255), 0.5)
                line(img, (gx, gy), (gx + 0.6, gy - 1.7), (96, 150, 66, 255), 0.5)
    line(img, (cx - hw * 0.5, cy - hh * 0.5), (cx + hw * 0.5, cy + hh * 0.5), (84, 62, 36, 255), 1.0)
    line(img, (cx - hw * 0.5, cy + hh * 0.5), (cx + hw * 0.5, cy - hh * 0.5), (84, 62, 36, 255), 1.0)
    return finish(img, W, H)

def lumber():
    """벌목장 2x2 — 초가 헛간 + 통나무 더미 + 그루터기"""
    W, H = 64, 54; cx, cy = 32, 46
    img = canvas(W, H)
    hw, hh = 28.0, 14.0
    ellipse(img, cx, cy - hh * 0.5, hw * 0.9, hh * 0.8, (86, 70, 44, 130))
    # 그루터기들 (앞쪽)
    rng = np.random.default_rng(11)
    for gx, gy in [(-14, -2), (-6, 3), (4, 5)]:
        ellipse(img, cx + gx, cy - 7 + gy, 2.6, 1.4, (169, 124, 74, 255))
        ellipse(img, cx + gx, cy - 7 + gy, 2.6, 1.4, None, outline=(124, 83, 38, 255), ow=1)
        ellipse(img, cx + gx, cy - 7 + gy, 1.0, 0.55, (201, 160, 106, 255))
    # 통나무 더미 (우측, 3+2 피라미드)
    ox, oy = cx + 14, cy - 9
    for i, (lx, ly) in enumerate([(-3.2, 0), (0, 0), (3.2, 0), (-1.6, -2.4), (1.6, -2.4)]):
        line(img, (ox + lx - 4, oy + ly + 2), (ox + lx + 4, oy + ly - 2), (124, 90, 52, 255), 2.6)
        ellipse(img, ox + lx + 4, oy + ly - 2, 1.3, 1.3, (196, 156, 100, 255))
        ellipse(img, ox + lx + 4, oy + ly - 2, 0.5, 0.5, (140, 104, 62, 255))
    # 초가 헛간 (뒤쪽)
    bx, by = cx - 10, cy - 20
    prism(img, bx, by, 10, 5, 7, (222, 214, 192, 255))
    ty = by - 7
    poly(img, [(bx - 13, ty), (bx, ty + 6.5), (bx + 13, ty), (bx, ty - 8)], THATCH)
    for k in range(4):
        t = (k + 1) / 5
        line(img, (bx - 13 * (1 - t), ty - 8 * t), (bx + 13 * (1 - t), ty - 8 * t), shade(THATCH, 0.78 if k % 2 else 0.95), 0.5)
    poly(img, [(bx - 2.2, by - 4.8), (bx + 2.2, by - 4.8), (bx + 2.2, by + 1), (bx - 2.2, by + 1)], (58, 40, 26, 255))
    # 톱질대 + 도끼
    line(img, (cx + 2, cy - 16), (cx + 9, cy - 19.5), (150, 112, 66, 255), 1.4)
    line(img, (cx + 3.5, cy - 15.6), (cx + 3.5, cy - 12.6), (110, 80, 46, 255), 1.0)
    line(img, (cx + 7.5, cy - 17.6), (cx + 7.5, cy - 14.6), (110, 80, 46, 255), 1.0)
    return finish(img, W, H)

def barracks():
    """훈련소 2x2 — 마당 + 초가 병영 + 과녁 + 무기거치대 + 적기"""
    W, H = 64, 60; cx, cy = 32, 50
    img = canvas(W, H)
    hw, hh = 28.0, 14.0
    poly(img, [(cx, cy - hh), (cx + hw, cy), (cx, cy + hh), (cx - hw, cy)], (150, 128, 94, 255))
    poly(img, [(cx, cy - hh + 1.2), (cx + hw - 2.4, cy), (cx, cy + hh - 1.2), (cx - hw + 2.4, cy)], (168, 146, 108, 255))
    # 병영 건물 (뒤 중앙)
    bx, by = cx + 6, cy - 17
    prism(img, bx, by, 12, 6, 8, (225, 216, 194, 255))
    for px_, py_ in [(-9, 2), (0, 5), (9, 2)]:
        line(img, (bx + px_, by + py_), (bx + px_, by + py_ - 8), PILLAR, 1.2)
    ty = by - 8
    poly(img, [(bx - 15, ty), (bx, ty + 7.5), (bx + 15, ty), (bx, ty - 9)], THATCH)
    for k in range(5):
        t = (k + 0.8) / 5.5
        line(img, (bx - 15 * (1 - t), ty - 9 * t), (bx + 15 * (1 - t), ty - 9 * t), shade(THATCH, 0.76 if k % 2 else 0.96), 0.55)
    poly(img, [(bx - 2.4, by - 5.2), (bx + 2.4, by - 5.2), (bx + 2.4, by + 1.4), (bx - 2.4, by + 1.4)], (52, 36, 22, 255))
    # 과녁 (좌측 앞)
    tx2, ty2 = cx - 16, cy - 9
    line(img, (tx2, ty2), (tx2, ty2 - 6.5), (110, 80, 46, 255), 1.1)
    ellipse(img, tx2, ty2 - 8, 3.0, 3.4, (216, 200, 160, 255))
    ellipse(img, tx2, ty2 - 8, 1.9, 2.2, (190, 90, 60, 255))
    ellipse(img, tx2, ty2 - 8, 0.8, 1.0, (60, 48, 36, 255))
    # 무기 거치대 (창 3자루)
    rx2, ry2 = cx - 5, cy - 6
    line(img, (rx2 - 4, ry2), (rx2 + 4, ry2 - 2), (124, 90, 52, 255), 1.0)
    for i, sx in enumerate([-2.6, 0, 2.6]):
        line(img, (rx2 + sx, ry2 - i * 0.6), (rx2 + sx + 1.6, ry2 - 11 - i * 0.6), (138, 106, 68, 255), 0.8)
        poly(img, [(rx2 + sx + 1.6, ry2 - 11 - i * 0.6), (rx2 + sx + 2.6, ry2 - 13.4 - i * 0.6), (rx2 + sx + 0.8, ry2 - 12 - i * 0.6)], (200, 204, 212, 255))
    # 깃대 + 적기
    fx2, fy2 = cx + 22, cy - 6
    line(img, (fx2, fy2), (fx2, fy2 - 17), (90, 66, 40, 255), 1.1)
    poly(img, [(fx2, fy2 - 17), (fx2 + 7, fy2 - 15.8), (fx2 + 7, fy2 - 11.6), (fx2, fy2 - 12.4)], (179, 32, 32, 255))
    return finish(img, W, H)

def barracks2():
    """훈련도감 2x2 — 기와 관아 + 단청 + 연무 허수아비 + 쌍기"""
    W, H = 64, 60; cx, cy = 32, 50
    img = canvas(W, H)
    hw, hh = 28.0, 14.0
    poly(img, [(cx, cy - hh), (cx + hw, cy), (cx, cy + hh), (cx - hw, cy)], (152, 148, 138, 255))
    poly(img, [(cx, cy - hh + 1.2), (cx + hw - 2.4, cy), (cx, cy + hh - 1.2), (cx - hw + 2.4, cy)], (170, 166, 154, 255))
    # 관아 본채
    bx, by = cx + 5, cy - 16
    prism(img, bx, by, 13, 6.5, 3, (150, 146, 134, 255))
    by2 = by - 3
    prism(img, bx, by2, 11.5, 5.8, 9, WALLW)
    for px_, py_ in [(-9.5, 2), (0, 5.4), (9.5, 2)]:
        line(img, (bx + px_, by2 + py_), (bx + px_, by2 + py_ - 9), PILLAR, 1.6)
    line(img, (bx - 11, by2 - 7.5), (bx, by2 - 3.2), DANCH, 1.3)
    line(img, (bx, by2 - 3.2), (bx + 11, by2 - 7.5), shade(DANCH, 1.15), 1.3)
    poly(img, [(bx - 2.2, by2 - 5.6), (bx + 2.2, by2 - 5.6), (bx + 2.2, by2 + 1), (bx - 2.2, by2 + 1)], (48, 32, 20, 255))
    ry = by2 - 9
    front = [(bx - 16, ry), (bx, ry + 8), (bx + 16, ry), (bx + 1.4, ry - 9.5), (bx - 1.4, ry - 9.5)]
    giwa_roof(img, front, (bx - 1.4, ry - 9.5), (bx + 1.4, ry - 9.5), rows=5)
    # 연무 허수아비 (짚 인형 + 목봉)
    sx2, sy2 = cx - 15, cy - 8
    line(img, (sx2, sy2), (sx2, sy2 - 7), (110, 80, 46, 255), 1.1)
    ellipse(img, sx2, sy2 - 8.5, 2.0, 2.6, THATCH)
    ellipse(img, sx2, sy2 - 11.4, 1.3, 1.3, shade(THATCH, 0.85))
    line(img, (sx2 - 2.8, sy2 - 9.5), (sx2 + 2.8, sy2 - 8.2), (124, 90, 52, 255), 0.9)
    # 쌍기 (청·홍)
    for fx2, col in [(cx + 22, (36, 86, 160, 255)), (cx - 22, (179, 32, 32, 255))]:
        fy2 = cy - 5
        line(img, (fx2, fy2), (fx2, fy2 - 16), (90, 66, 40, 255), 1.0)
        poly(img, [(fx2, fy2 - 16), (fx2 + 6, fy2 - 14.9), (fx2 + 6, fy2 - 11.2), (fx2, fy2 - 12)], col)
    return finish(img, W, H)

# ---------- 지형 타일 ----------
def tile_mud():
    """진흙 바닥 — 이동 가능 · 건설 불가"""
    W, H = 28, 14; cx, cy = 14, 7
    img = canvas(W, H)
    poly(img, [(cx, 0.3), (W - 0.3, cy), (cx, H - 0.3), (0.3, cy)], (98, 78, 54, 255))
    rng = np.random.default_rng(29)
    for i in range(6):
        t = rng.uniform(0.2, 0.8); s = rng.uniform(0.5, 1.0)
        x = 3 + t * 22; y = cy + rng.uniform(-0.9, 0.9) * (1 - abs(t - 0.5) * 2) * 5
        ellipse(img, x, y, rng.uniform(1.6, 3.2), rng.uniform(0.8, 1.4), (70, 54, 38, 255))
        line(img, (x - 1.2, y - 0.3), (x + 0.8, y - 0.5), (128, 108, 82, 200), 0.4)
    for i in range(5):  # 발자국
        x = rng.uniform(5, 23); y = cy + rng.uniform(-0.8, 0.8) * (1 - abs(x - 14) / 14) * 5.5
        ellipse(img, x, y, 0.55, 0.35, (62, 48, 34, 255))
        ellipse(img, x + 1.1, y + 0.5, 0.55, 0.35, (62, 48, 34, 255))
    img = noise_region(img, None, amount=6, seed=31)
    return img.resize((W * 4, H * 4), Image.LANCZOS)

def tile_cliff():
    """절벽 바위 — 이동·건설 불가 (발밑 앵커 56,76 / 깊이정렬 드로잉)"""
    W, H = 28, 26; cx, cy = 14, 19
    img = canvas(W, H)
    z = 11
    prism(img, cx, cy, 14, 7, z, (128, 120, 106, 255))
    rng = np.random.default_rng(41)
    # 균열·바위결
    for i in range(5):
        x0 = rng.uniform(2, 12)
        line(img, (cx - 14 + x0, cy - rng.uniform(2, 8)), (cx - 14 + x0 + rng.uniform(2, 5), cy - rng.uniform(2, 9)), (86, 80, 70, 255), 0.5)
        x1 = rng.uniform(1, 11)
        line(img, (cx + x1, cy - rng.uniform(2, 8)), (cx + x1 + rng.uniform(2, 5), cy - rng.uniform(3, 9)), (104, 97, 86, 255), 0.5)
    # 상단 풀
    for i in range(6):
        gx = cx + rng.uniform(-10, 10)
        gy = cy - z + rng.uniform(-3, 3) * (1 - abs(gx - cx) / 14)
        line(img, (gx, gy), (gx - 0.6, gy - 1.6), (96, 130, 62, 255), 0.5)
        line(img, (gx, gy), (gx + 0.6, gy - 1.5), (84, 116, 54, 255), 0.5)
    # 낙석
    ellipse(img, cx - 9, cy + 3.5, 1.5, 0.9, (110, 103, 92, 255))
    ellipse(img, cx + 7, cy + 4.5, 1.1, 0.7, (118, 110, 98, 255))
    img = noise_region(img, None, amount=9, seed=43)
    return finish(img, W, H)

worker_build().save("u_worker.png")
worker_farm().save("u_worker_farm.png")
worker_lumber().save("u_worker_lumber.png")
worker_mine().save("u_worker_mine.png")
farm().save("farm.png")
lumber().save("lumber.png")
barracks().save("barracks.png")
barracks2().save("barracks2.png")
tile_mud().save("tile_mud.png")
tile_cliff().save("tile_cliff.png")
print("gen7 ok: workers x4(korean), farm/lumber/barracks/barracks2 2x2, tile_mud, tile_cliff")
