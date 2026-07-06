# 석벽(개축) 오토타일 16종 (wall2_0..wall2_15) + 성문 (gate_x/gate_y/gate)
# 마스크 비트: 1=+x(화면 SE) 2=+y(화면 SW) 4=-x(화면 NW) 8=-y(화면 NE)
import sys; sys.path.insert(0, '.')
from lib import *

XV = (14.0, 7.0)    # 그리드 +x 방향 (화면 우하)
YV = (-14.0, 7.0)   # 그리드 +y 방향 (화면 좌하)
TH = 0.28           # 벽 반두께 (타일 반축 비율)
Z = 21              # 벽 높이


def V(a, s):
    return (a[0] * s, a[1] * s)


def ADD(a, b):
    return (a[0] + b[0], a[1] + b[1])


def up(p, z):
    return (p[0], p[1] - z)


def giwa_roof(img, pts_front, ridge_a, ridge_b, base_col=GIWA, rows=5, msae=True):
    # gen3.giwa_roof 동일 (gen3는 import 시 전체 재생성 부작용이 있어 복사)
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
    line(img, (ridge_a[0], ridge_a[1] + 0.8), (ridge_b[0], ridge_b[1] + 0.8), shade(RIDGE, 0.8), 0.8)
    ellipse(img, ridge_a[0], ridge_a[1], 1.5, 1.8, (84, 92, 102, 255))
    ellipse(img, ridge_b[0], ridge_b[1], 1.5, 1.8, (84, 92, 102, 255))


def battlement(img, x, y):
    """여장(살받이) + 총안 — gen3 wall 상단과 동일 스타일"""
    prism(img, x, y, 3.2, 1.6, 4.5, (190, 186, 172, 255))
    poly(img, [(x - 1, y - 2.2), (x + 1, y - 3.2), (x + 1, y - 1), (x - 1, y)], (60, 56, 50, 255))


def arm(img, cx, cy, dirv, axis_x):
    """허브(타일 중심)→타일 경계까지 뻗는 벽체. axis_x: x축 벽인가(음영용)"""
    hv = V(YV if axis_x else XV, TH)          # 반두께 벡터 (+h 면이 화면 아래쪽=보이는 면)
    O = (cx, cy); T = (cx + dirv[0], cy + dirv[1])
    Oh, Om = ADD(O, hv), ADD(O, V(hv, -1))
    Th, Tm = ADD(T, hv), ADD(T, V(hv, -1))
    front = shade(GRANITE, 0.62 if axis_x else 0.82)
    # 보이는 긴 면
    poly(img, [Oh, Th, up(Th, Z), up(Oh, Z)], front)
    # 앞쪽(화면 아래) 끝단 마감면
    if dirv[1] > 0:
        poly(img, [Th, Tm, up(Tm, Z), up(Th, Z)], shade(GRANITE, 0.82 if axis_x else 0.62))
    # 상판
    poly(img, [up(Oh, Z), up(Th, Z), up(Tm, Z), up(Om, Z)], GRANITE)
    # 석축 줄눈 (보이는 긴 면 위, 바닥에서 6/12/17 높이)
    for yy in (6, 12, 17):
        a = up(ADD(O, ADD(hv, V(dirv, 0.08))), yy)
        b = up(ADD(T, ADD(hv, V(dirv, -0.04))), yy)
        line(img, a, b, shade(GRANITE, 0.52 if axis_x else 0.70), 0.45)


def wall_variant(mask):
    W, H = 36, 46; cx, cy = 18, 38
    img = canvas(W, H)
    ellipse(img, cx, cy + 1, 15, 7, (0, 0, 0, 70))
    if mask == 0:  # 독립 돈대
        prism(img, cx, cy, 10, 5, Z, GRANITE)
        rng = np.random.default_rng(3)
        for r in range(4):
            yy = cy - 4 - r * 5
            for c_ in range(3):
                x0 = cx - 9 + ((r % 2) * 2.5) + c_ * 5.2
                if x0 > cx + 6: continue
                line(img, (x0, yy), (x0 + 3.6, yy + 1.8), shade(GRANITE, 0.55 * rng.uniform(0.9, 1.1)), 0.45)
        for off in (-5.5, 0, 5.5):
            battlement(img, cx + off, cy - Z)
        return finish(img, W, H)
    dirs = [(XV, True), (YV, False), (V(XV, -1), True), (V(YV, -1), False)]
    back = [i for i in range(4) if (mask >> i) & 1 and dirs[i][0][1] < 0]
    frnt = [i for i in range(4) if (mask >> i) & 1 and dirs[i][0][1] > 0]
    for i in back:
        arm(img, cx, cy, dirs[i][0], dirs[i][1])
    prism(img, cx, cy, 6.5, 3.25, Z, GRANITE)  # 허브
    for i in frnt:
        arm(img, cx, cy, dirs[i][0], dirs[i][1])
    # 여장: 허브 + 각 팔 0.45/0.9 지점
    battlement(img, cx, cy - Z)
    for i in back + frnt:
        for t in (0.45, 0.9):
            p = V(dirs[i][0], t)
            battlement(img, cx + p[0], cy + p[1] - Z)
    img = noise_region(img, None, amount=9, seed=mask + 11)
    # 이끼
    rng = np.random.default_rng(mask + 5)
    for i in range(4):
        ellipse(img, cx + rng.uniform(-10, 10), cy + rng.uniform(-3, 3), 1.1, 0.7, (96, 120, 60, 150))
    return finish(img, W, H)


def gate():
    """성문 (x축 벽 방향). 석축 홍예문 + 문루"""
    W, H = 40, 60; cx, cy = 20, 50
    img = canvas(W, H)
    ellipse(img, cx, cy + 1, 16, 7.5, (0, 0, 0, 75))
    # 좌우 벽 스텁 (타일 경계 접속)
    arm(img, cx, cy, V(XV, -1), True)
    arm(img, cx, cy, XV, True)
    # 중앙 육축(陸築)
    Z2 = 28
    h2 = V(YV, 0.40)
    O1 = ADD((cx, cy), V(XV, -0.46)); O2 = ADD((cx, cy), V(XV, 0.46))
    P1, P2 = ADD(O1, h2), ADD(O2, h2)
    Q1, Q2 = ADD(O1, V(h2, -1)), ADD(O2, V(h2, -1))
    poly(img, [P1, P2, up(P2, Z2), up(P1, Z2)], shade(GRANITE, 0.62))   # 앞면
    poly(img, [P2, Q2, up(Q2, Z2), up(P2, Z2)], shade(GRANITE, 0.82))   # 우측면
    poly(img, [up(P1, Z2), up(P2, Z2), up(Q2, Z2), up(Q1, Z2)], GRANITE)
    # 줄눈
    for k in range(1, 6):
        yy = k * 4.5
        line(img, up(ADD(P1, V(XV, 0.04)), yy), up(ADD(P2, V(XV, -0.04)), yy), shade(GRANITE, 0.5), 0.45)
    # 홍예(아치) 개구부
    def L(a, b, t):
        return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
    a0, a1 = L(P1, P2, 0.30), L(P1, P2, 0.74)
    am = L(a0, a1, 0.5)
    poly(img, [a0, a1, up(a1, 11), up(am, 16.5), up(a0, 11)], (22, 17, 12, 255))
    # 목재 대문 (반개방)
    d0, d1 = L(a0, a1, 0.12), L(a0, a1, 0.5)
    poly(img, [d0, d1, up(d1, 10), up(d0, 12)], shade(WOOD, 0.9))
    for t in (0.3, 0.7):
        line(img, up(L(d0, d1, t), 0), up(L(d0, d1, t), 11), shade(WOOD, 0.6), 0.5)
    ellipse(img, L(d0, d1, 0.5)[0], L(d0, d1, 0.5)[1] - 6, 0.8, 0.8, (170, 140, 60, 255))
    # 상단 여장
    ty = cy - Z2
    for off in (-8.5, 8.5):
        battlement(img, cx + off * 0.9, ty + off * 0.45)
    # 문루: 단(壇) + 기둥 + 단청 + 기와 모임지붕
    prism(img, cx, ty, 9.0, 4.5, 2, (158, 132, 90, 255))
    py = ty - 2
    for dx, dy in [(-7, 0), (7, 0), (0, -3.5), (0, 3.5)]:
        line(img, (cx + dx, py + dy), (cx + dx, py + dy - 8), PILLAR, 1.6)
    line(img, (cx - 8, py + 1), (cx, py + 4.5), DANCH, 1.4)
    line(img, (cx, py + 4.5), (cx + 8, py + 1), shade(DANCH, 1.15), 1.4)
    ry = py - 8
    front = [(cx - 14, ry), (cx, ry + 6.5), (cx + 14, ry), (cx + 1.2, ry - 8.5), (cx - 1.2, ry - 8.5)]
    giwa_roof(img, front, (cx - 1.2, ry - 8.5), (cx + 1.2, ry - 8.5), rows=4)
    # 깃발
    line(img, (cx, ry - 8.5), (cx, ry - 14), (74, 52, 32, 255), 0.9)
    poly(img, [(cx, ry - 14), (cx + 6, ry - 13), (cx + 6, ry - 9.5), (cx, ry - 10.5)], (36, 86, 160, 255))
    img = noise_region(img, None, amount=8, seed=42)
    return img, W, H


for m in range(16):
    wall_variant(m).save("wall2_%d.png" % m)
print("wall2_0..15")
g, W, H = gate()
finish(g.copy(), W, H).save("gate_x.png")
finish(g.copy(), W, H).save("gate.png")  # 건설 미리보기용
finish(g.transpose(Image.FLIP_LEFT_RIGHT), W, H).save("gate_y.png")
print("gate_x / gate_y / gate")
