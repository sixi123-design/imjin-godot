# 목책(기본 성벽) 오토타일 16종 wall_0..15 + 논 2x2 + 일꾼 작업별 4종 + 철광맥 타일
# 마스크 비트: 1=+x(화면 SE) 2=+y(화면 SW) 4=-x(화면 NW) 8=-y(화면 NE)
import sys; sys.path.insert(0, '.')
from lib import *

XV = (14.0, 7.0)
YV = (-14.0, 7.0)
PALI = (128, 96, 60, 255)   # 목책 원목
Z = 16


def V(a, s):
    return (a[0] * s, a[1] * s)


def ADD(a, b):
    return (a[0] + b[0], a[1] + b[1])


def stake(img, x, y, h, col):
    """끝이 뾰족한 통나무 말뚝"""
    line(img, (x, y), (x, y - h + 1.2), col, 1.7)
    line(img, (x - 0.55, y), (x - 0.55, y - h + 1.4), shade(col, 1.22), 0.6)
    poly(img, [(x - 0.95, y - h + 1.6), (x + 0.95, y - h + 1.6), (x, y - h - 1.4)], shade(col, 1.1))
    poly(img, [(x, y - h + 1.2), (x + 0.95, y - h + 1.6), (x, y - h - 1.4)], shade(col, 0.8))


def arm_wood(img, cx, cy, dirv, axis_x, seed):
    rng = np.random.default_rng(seed)
    f = 0.82 if axis_x else 1.0
    hv = V(YV if axis_x else XV, 0.10)
    O = (cx, cy); T = (cx + dirv[0], cy + dirv[1])
    # 말뚝 뒤 배경 판재 (틈 메움)
    poly(img, [ADD(O, hv), ADD(T, hv), up_(ADD(T, hv), Z - 4), up_(ADD(O, hv), Z - 4)], shade(PALI, 0.45 * f))
    # 가로 결속대 2줄
    for zt in (0.42, 0.78):
        line(img, up_(O, Z * zt), up_(T, Z * zt), shade(PALI, 0.62 * f), 0.8)
    # 말뚝 열
    n = 6
    for k in range(n):
        t = (k + 0.6) / n
        p = ADD(O, V(dirv, t))
        h = Z + rng.uniform(-1.4, 1.6)
        stake(img, p[0], p[1], h, shade(PALI, f * (0.88 if k % 2 else 1.04)))


def up_(p, z):
    return (p[0], p[1] - z)


def wall_variant(mask):
    W, H = 36, 46; cx, cy = 18, 38
    img = canvas(W, H)
    ellipse(img, cx, cy + 1, 14, 6.5, (0, 0, 0, 60))
    if mask == 0:  # 독립 말뚝 무리
        for dx, dy, h in ((-3.5, 1, Z - 2), (0, -1, Z + 1), (3.5, 1.5, Z - 1), (1.5, 2.5, Z - 4)):
            stake(img, cx + dx, cy + dy, h, shade(PALI, 0.95 + dx * 0.02))
        line(img, up_((cx - 5, cy), Z * 0.5), up_((cx + 5, cy + 1.5), Z * 0.5), shade(PALI, 0.6), 0.8)
        return finish(img, W, H)
    dirs = [(XV, True), (YV, False), (V(XV, -1), True), (V(YV, -1), False)]
    back = [i for i in range(4) if (mask >> i) & 1 and dirs[i][0][1] < 0]
    frnt = [i for i in range(4) if (mask >> i) & 1 and dirs[i][0][1] > 0]
    for i in back:
        arm_wood(img, cx, cy, dirs[i][0], dirs[i][1], mask * 4 + i)
    # 허브: 굵은 기둥
    stake(img, cx, cy, Z + 3, shade(PALI, 1.08))
    for i in frnt:
        arm_wood(img, cx, cy, dirs[i][0], dirs[i][1], mask * 4 + i)
    img = noise_region(img, None, amount=8, seed=mask + 31)
    return finish(img, W, H)


def farm2():
    """논 2x2 (풋프린트 2타일 = 하프폭 28) — 물 댄 4배미 + 논둑"""
    W, H = 64, 38; cx, cy = 32, 22
    img = canvas(W, H)
    hw, hh = 28.0, 14.0
    poly(img, [(cx, cy - hh), (cx + hw, cy), (cx, cy + hh), (cx - hw, cy)], (96, 78, 50, 255))  # 논둑 흙
    # 4배미 (각 1타일)
    quads = [(-0.5, -0.5), (0.5, -0.5), (-0.5, 0.5), (0.5, 0.5)]
    rng = np.random.default_rng(9)
    for qx, qy in quads:
        qcx = cx + (qx - qy) * hw * 0.5
        qcy = cy + (qx + qy) * hh * 0.5
        p = [(qcx, qcy - hh * 0.40), (qcx + hw * 0.40, qcy), (qcx, qcy + hh * 0.40), (qcx - hw * 0.40, qcy)]
        poly(img, p, (72, 102, 118, 255))
        poly(img, [(qcx, qcy - hh * 0.34), (qcx + hw * 0.34, qcy), (qcx, qcy + hh * 0.34), (qcx - hw * 0.34, qcy)], (88, 124, 138, 255))
        # 물 반짝
        for i in range(5):
            x = rng.uniform(-hw * 0.22, hw * 0.22); y = rng.uniform(-hh * 0.22, hh * 0.22)
            line(img, (qcx + x, qcy + y), (qcx + x + 1.6, qcy + y - 0.5), (200, 224, 232, 190), 0.5)
        # 모 줄 (다이아 축 평행)
        for k in range(3):
            t = (k + 0.9) / 3.8
            x0, y0 = qcx - hw * 0.34 * (1 - t), qcy + hh * 0.34 * t
            x1, y1 = qcx + hw * 0.34 * t, qcy - hh * 0.34 * (1 - t)
            for m in range(5):
                u = m / 4.0 * 0.8 + 0.1
                gx = x0 + (x1 - x0) * u; gy = y0 + (y1 - y0) * u
                line(img, (gx, gy), (gx - 0.9, gy - 2.3), (96, 160, 72, 255), 0.55)
                line(img, (gx, gy), (gx + 0.9, gy - 2.3), (88, 148, 64, 255), 0.55)
    # 논둑 선
    line(img, (cx - hw * 0.5, cy - hh * 0.5), (cx + hw * 0.5, cy + hh * 0.5), (110, 90, 58, 255), 1.0)
    line(img, (cx - hw * 0.5, cy + hh * 0.5), (cx + hw * 0.5, cy - hh * 0.5), (110, 90, 58, 255), 1.0)
    # 허수아비
    sx, sy = cx + hw * 0.42, cy - 1
    line(img, (sx, sy), (sx, sy - 6), (90, 66, 40, 255), 0.8)
    line(img, (sx - 2, sy - 4.4), (sx + 2, sy - 4.4), (90, 66, 40, 255), 0.7)
    ellipse(img, sx, sy - 6.8, 1.1, 1.1, THATCH)
    return finish(img, W, H)


# ---------- 일꾼 4종 (genunits.py base_man 스타일) ----------
def base_man(img, cx, cy, body, r=3.6, skin=(230, 195, 154, 255)):
    ellipse(img, cx, cy, 5, 1.9, (0, 0, 0, 80))
    line(img, (cx - 1.4, cy - 0.3), (cx - 1.6, cy - 3.5), (52, 42, 32, 255), 1.3)
    line(img, (cx + 1.4, cy - 0.3), (cx + 1.8, cy - 3.5), (52, 42, 32, 255), 1.3)
    ellipse(img, cx, cy - 6.5, r, r + 0.4, body)
    ellipse(img, cx - r * 0.35, cy - 7.2, r * 0.5, r * 0.55, shade(body, 1.18))
    ellipse(img, cx, cy - 11.8, 2.6, 2.6, skin)


def worker_build():  # 머릿수건 + 상투 (기존 u_worker와 동일 컨셉)
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    base_man(img, cx, cy, (232, 226, 210, 255))
    line(img, (cx - 2.4, cy - 12.6), (cx + 2.4, cy - 12.6), (90, 70, 50, 255), 1.1)
    ellipse(img, cx, cy - 14, 1.2, 1.0, (60, 48, 36, 255))
    return finish(img, W, H)


def worker_farm():  # 삿갓 + 녹빛 무명옷
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    base_man(img, cx, cy, (206, 210, 178, 255))
    poly(img, [(cx - 4.8, cy - 11.9), (cx, cy - 15.8), (cx + 4.8, cy - 11.9)], THATCH)
    line(img, (cx - 4.8, cy - 11.9), (cx + 4.8, cy - 11.9), shade(THATCH, 0.75), 0.8)
    line(img, (cx, cy - 11.9), (cx, cy - 10.6), (70, 56, 40, 255), 0.6)  # 턱끈
    return finish(img, W, H)


def worker_lumber():  # 갈색 배자 + 짙은 머릿수건
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    base_man(img, cx, cy, (152, 116, 72, 255))
    line(img, (cx - 2.4, cy - 12.6), (cx + 2.4, cy - 12.6), (52, 66, 44, 255), 1.1)
    ellipse(img, cx, cy - 14, 1.2, 1.0, (44, 54, 38, 255))
    line(img, (cx - 3.2, cy - 8.8), (cx + 3.2, cy - 4.6), (106, 74, 48, 255), 0.9)  # 어깨끈
    return finish(img, W, H)


def worker_mine():  # 잿빛 옷 + 검은 띠 + 등짐 소쿠리
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    poly(img, [(cx - 5.4, cy - 9.6), (cx - 2.6, cy - 10.6), (cx - 2.2, cy - 5.6), (cx - 5.0, cy - 4.8)], (124, 96, 56, 255))  # 소쿠리
    line(img, (cx - 5.0, cy - 8.4), (cx - 2.4, cy - 9.2), (92, 70, 40, 255), 0.6)
    base_man(img, cx, cy, (148, 148, 152, 255))
    line(img, (cx - 2.4, cy - 12.8), (cx + 2.4, cy - 12.8), (40, 38, 36, 255), 1.2)
    ellipse(img, cx + 1.2, cy - 11.0, 0.8, 0.5, (70, 66, 62, 255))  # 검댕
    return finish(img, W, H)


def tile_ore():
    """철 광맥 노두 타일 — 여기에만 철광 건설 가능"""
    W, H = 28, 14; cx, cy = 14, 7
    img = canvas(W, H)
    poly(img, [(cx, 0.3), (W - 0.3, cy), (cx, H - 0.3), (0.3, cy)], (104, 96, 84, 255))
    rng = np.random.default_rng(17)
    # 암반 균열
    for i in range(4):
        x = rng.uniform(4, 24); y = rng.uniform(2.5, 11)
        line(img, (x, y), (x + rng.uniform(-4, 4), y + rng.uniform(-2, 2)), (78, 72, 62, 255), 0.5)
    # 철광 덩어리 + 녹 반점
    for i in range(6):
        t = rng.uniform(0.25, 0.75); s = rng.uniform(0.55, 0.85)
        x = 4 + t * 20; y = cy + (rng.uniform(-1, 1)) * (1 - abs(t - 0.5) * 2) * 4.5
        r = rng.uniform(1.0, 1.9)
        poly(img, [(x - r, y), (x - r * 0.3, y - r * s), (x + r, y - r * 0.2), (x + r * 0.5, y + r * s * 0.8), (x - r * 0.4, y + r * 0.7)], (56, 54, 60, 255))
        line(img, (x - r * 0.4, y - r * 0.3), (x + r * 0.4, y - r * 0.1), (96, 98, 110, 255), 0.5)
        ellipse(img, x + r * 0.4, y + r * 0.3, 0.5, 0.35, (146, 88, 46, 255))
    img = noise_region(img, None, amount=7, seed=23)
    return img.resize((W * 4, H * 4), Image.LANCZOS)  # 지형 타일: 아웃라인 없음


for m in range(16):
    wall_variant(m).save("wall_%d.png" % m)
print("wall_0..15 (목책)")
farm2().save("farm2.png")
worker_build().save("u_worker.png")
worker_farm().save("u_worker_farm.png")
worker_lumber().save("u_worker_lumber.png")
worker_mine().save("u_worker_mine.png")
tile_ore().save("tile_ore.png")
print("farm2(2x2) / u_worker x4 / tile_ore")
