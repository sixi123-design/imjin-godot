# v7: 대완구 (강데미지·긴 쿨다운 공성 타워)
import sys; sys.path.insert(0, '.')
from lib import *

def btower():
    W, H = 44, 56; cx, cy = 22, 46
    img = canvas(W, H)
    ellipse(img, cx, cy + 1, 15, 7, (0, 0, 0, 75))
    # 석축 기단
    prism(img, cx, cy, 14, 7, 6, GRANITE)
    for k in range(1, 3):
        line(img, (cx - 14 + k, cy - k * 2.2), (cx - 1, cy + 6 - k * 2.2), shade(GRANITE, 0.5), 0.45)
    # 목재 받침틀
    by = cy - 6
    for dx, dy in [(-8, 1), (8, 1), (0, -4)]:
        line(img, (cx + dx, by + dy), (cx + dx * 0.55, by + dy - 6), (106, 74, 48, 255), 1.8)
    line(img, (cx - 9, by - 4), (cx + 9, by - 4), shade((106, 74, 48, 255), 1.15), 1.4)
    # 대완구 몸통 (청동 대접 모양, 위로 벌어짐 · 45도 거치)
    mx, my = cx + 1, by - 8
    BRONZE = (118, 104, 66, 255)
    poly(img, [(mx - 7.5, my + 5), (mx + 6.5, my + 7.5), (mx + 9.5, my - 5.5), (mx - 10.5, my - 8.5)], BRONZE)
    poly(img, [(mx - 10.5, my - 8.5), (mx + 9.5, my - 5.5), (mx + 8, my - 9), (mx - 9, my - 12)], shade(BRONZE, 1.25))
    ellipse(img, mx - 0.5, my - 10.2, 8.6, 3.1, (32, 28, 24, 255))  # 포구
    ellipse(img, mx - 0.5, my - 10.2, 8.6, 3.1, None, outline=shade(BRONZE, 1.45), ow=1)
    for t in (0.3, 0.62):  # 보강 띠
        yy = my + 6 - t * 14
        line(img, (mx - 8.5 - t * 2, yy - t * 1.5), (mx + 7.5 + t * 2, yy + 2 - t * 1.5), shade(BRONZE, 0.72), 1.1)
    # 비격진천뢰 (포구 안 + 예비탄 2발)
    ellipse(img, mx - 0.5, my - 9.6, 4.6, 2.0, (20, 18, 16, 255))
    for bx2, by2 in [(cx - 11, cy - 1), (cx - 7.5, cy + 1.5)]:
        ellipse(img, bx2, by2, 2.6, 2.6, (30, 28, 32, 255))
        ellipse(img, bx2 - 0.8, by2 - 0.9, 0.9, 0.9, (80, 80, 92, 255))
        line(img, (bx2, by2 - 2.6), (bx2 + 1, by2 - 4), (150, 120, 70, 255), 0.6)
    # 홍색 깃발
    line(img, (cx + 12, cy - 3), (cx + 12, cy - 17), (90, 66, 40, 255), 1.0)
    poly(img, [(cx + 12, cy - 17), (cx + 18, cy - 15.8), (cx + 18, cy - 11.8), (cx + 12, cy - 12.8)], (179, 32, 32, 255))
    img = noise_region(img, None, amount=8, seed=99)
    return finish(img, W, H)

btower().save("btower.png")
print("btower ok")
