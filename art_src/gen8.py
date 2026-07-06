# v4: 왜장(u_lord) + 폭탄병(u_bomber) + 공방(smith)
import sys; sys.path.insert(0, '.')
from lib import *

SKIN = (226, 188, 148, 255)

def lord():
    """왜장 — 뿔 카부토·마에다테·사시모노 깃발. 인게임에서 2배 스케일로 그림"""
    W, H = 18, 24; cx, cy = 9, 22
    img = canvas(W, H)
    ellipse(img, cx, cy, 6, 2.2, (0, 0, 0, 90))
    # 사시모노 (등 뒤 깃발)
    line(img, (cx - 3.4, cy - 4), (cx - 3.4, cy - 19), (70, 54, 36, 255), 0.9)
    poly(img, [(cx - 3.4, cy - 19), (cx + 1.6, cy - 18.4), (cx + 1.6, cy - 13.6), (cx - 3.4, cy - 14.2)], (24, 22, 26, 255))
    ellipse(img, cx - 0.9, cy - 16.2, 1.1, 1.1, (196, 160, 60, 255))  # 문양
    # 다리
    line(img, (cx - 1.6, cy - 0.3), (cx - 1.9, cy - 4.0), (30, 26, 24, 255), 1.6)
    line(img, (cx + 1.6, cy - 0.3), (cx + 2.0, cy - 4.0), (30, 26, 24, 255), 1.6)
    # 갑옷 몸통 (흑적 오도시)
    ellipse(img, cx, cy - 7.2, 4.4, 4.8, (58, 24, 22, 255))
    for yy in (-5.4, -7.0, -8.6):
        line(img, (cx - 3.8, cy + yy), (cx + 3.8, cy + yy), (120, 34, 30, 255), 0.7)
    ellipse(img, cx - 1.6, cy - 8.2, 2.0, 2.2, (84, 34, 30, 255))
    # 어깨 소데
    ellipse(img, cx - 4.2, cy - 9.2, 1.7, 2.2, (44, 20, 18, 255))
    ellipse(img, cx + 4.2, cy - 9.2, 1.7, 2.2, (44, 20, 18, 255))
    # 머리 + 멘구(면갑)
    ellipse(img, cx, cy - 13.2, 2.7, 2.7, SKIN)
    poly(img, [(cx - 2.2, cy - 12.6), (cx + 2.2, cy - 12.6), (cx + 1.6, cy - 10.8), (cx - 1.6, cy - 10.8)], (52, 40, 34, 255))
    # 카부토 + 뿔 마에다테(금 초승달)
    ellipse(img, cx, cy - 14.6, 3.1, 1.9, (30, 28, 32, 255))
    poly(img, [(cx - 3.1, cy - 14.4), (cx + 3.1, cy - 14.4), (cx + 3.8, cy - 13.2), (cx - 3.8, cy - 13.2)], (38, 36, 42, 255))
    line(img, (cx - 2.2, cy - 15.6), (cx - 3.4, cy - 18.6), (208, 172, 60, 255), 1.0)
    line(img, (cx + 2.2, cy - 15.6), (cx + 3.4, cy - 18.6), (208, 172, 60, 255), 1.0)
    # 대태도
    line(img, (cx + 3.6, cy - 2.5), (cx + 7.4, cy - 13.5), (190, 196, 206, 255), 1.1)
    line(img, (cx + 3.4, cy - 2.0), (cx + 4.4, cy - 4.6), (90, 60, 30, 255), 1.3)
    return finish(img, W, H)

def bomber():
    """폭탄병 — 화약통을 안고 달리는 아시가루, 불붙은 도화선"""
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    ellipse(img, cx, cy, 5, 1.9, (0, 0, 0, 80))
    line(img, (cx - 1.4, cy - 0.3), (cx - 1.6, cy - 3.5), (52, 42, 32, 255), 1.3)
    line(img, (cx + 1.4, cy - 0.3), (cx + 1.8, cy - 3.5), (52, 42, 32, 255), 1.3)
    ellipse(img, cx, cy - 6.5, 3.4, 3.8, (140, 78, 54, 255))
    # 폭탄 (검은 구 + 도화선 + 불꽃)
    ellipse(img, cx + 2.6, cy - 7.6, 2.6, 2.6, (28, 26, 30, 255))
    ellipse(img, cx + 1.8, cy - 8.4, 0.9, 0.9, (74, 74, 84, 255))
    line(img, (cx + 3.8, cy - 9.6), (cx + 4.8, cy - 11.6), (150, 120, 70, 255), 0.6)
    ellipse(img, cx + 4.9, cy - 12.1, 0.85, 0.85, (255, 170, 60, 255))
    ellipse(img, cx + 4.9, cy - 12.1, 0.4, 0.4, (255, 240, 160, 255))
    # 머리 + 짚 하치마키
    ellipse(img, cx, cy - 11.6, 2.5, 2.5, SKIN)
    line(img, (cx - 2.4, cy - 12.4), (cx + 2.4, cy - 12.4), (176, 64, 46, 255), 1.0)
    return finish(img, W, H)

def smith():
    """공방(대장간) 1x1 — 화덕·모루·기와지붕"""
    W, H = 36, 40; cx, cy = 18, 32
    img = canvas(W, H)
    ellipse(img, cx, cy + 1, 14, 6.5, (0, 0, 0, 70))
    prism(img, cx, cy, 12, 6, 7, (150, 146, 134, 255))
    # 화덕 (앞쪽, 주황 불빛)
    fx, fy = cx - 6, cy + 1
    prism(img, fx, fy, 3.5, 1.8, 4, (108, 100, 92, 255))
    poly(img, [(fx - 1.6, fy - 2.2), (fx + 1.6, fy - 2.2), (fx + 1.1, fy - 0.4), (fx - 1.1, fy - 0.4)], (255, 130, 40, 255))
    ellipse(img, fx, fy - 1.4, 0.8, 0.6, (255, 220, 120, 255))
    # 모루 + 망치
    ax, ay = cx + 5, cy + 2
    poly(img, [(ax - 2.4, ay - 2.6), (ax + 2.8, ay - 2.6), (ax + 1.8, ay - 1.2), (ax - 1.6, ay - 1.2)], (74, 78, 90, 255))
    line(img, (ax, ay - 1.2), (ax, ay), (60, 62, 72, 255), 1.6)
    line(img, (ax + 2.2, ay - 4.2), (ax + 4.2, ay - 5.6), (140, 104, 62, 255), 0.8)
    # 기둥 + 기와 맞배지붕
    zt = cy - 7
    for dx in (-10, 10):
        line(img, (cx + dx, zt + 3), (cx + dx, zt - 5), PILLAR, 1.5)
    ry = zt - 5
    poly(img, [(cx - 13, ry), (cx, ry + 6), (cx + 13, ry), (cx + 1.2, ry - 7.5), (cx - 1.2, ry - 7.5)], GIWA)
    for k in range(4):
        t = (k + 1) / 5
        line(img, (cx - 13 * (1 - t), ry - 7.5 * t), (cx + 13 * (1 - t), ry - 7.5 * t), shade(GIWA, 0.8 if k % 2 else 1.15), 0.5)
    line(img, (cx - 1.2, ry - 7.5), (cx + 1.2, ry - 7.5), RIDGE, 1.8)
    # 연기 구멍 + 걸린 연장
    ellipse(img, cx + 3, ry - 6.2, 1.0, 0.6, (40, 38, 42, 255))
    line(img, (cx + 11, zt - 1), (cx + 11, zt + 2), (120, 90, 50, 255), 0.6)
    poly(img, [(cx + 10.4, zt + 2), (cx + 11.6, zt + 2), (cx + 11, zt + 3.4)], (150, 150, 160, 255))
    img = noise_region(img, None, amount=7, seed=77)
    return finish(img, W, H)

lord().save("u_lord.png")
bomber().save("u_bomber.png")
smith().save("smith.png")
print("gen8 ok: u_lord u_bomber smith")
