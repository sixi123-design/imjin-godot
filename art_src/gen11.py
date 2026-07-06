# v8: 근접 유닛 무기 분리 — 무기 없는 스프라이트 재생성 (무기는 인게임에서 애니메이션으로 그림)
import sys; sys.path.insert(0, '.')
from lib import *

def base_man(img, cx, cy, body, r=3.6, skin=(230, 195, 154, 255)):
    ellipse(img, cx, cy, 5, 1.9, (0, 0, 0, 80))
    line(img, (cx - 1.4, cy - 0.3), (cx - 1.6, cy - 3.5), (52, 42, 32, 255), 1.3)
    line(img, (cx + 1.4, cy - 0.3), (cx + 1.8, cy - 3.5), (52, 42, 32, 255), 1.3)
    ellipse(img, cx, cy - 6.5, r, r + 0.4, body)
    ellipse(img, cx - r * 0.35, cy - 7.2, r * 0.5, r * 0.55, shade(body, 1.18))
    ellipse(img, cx, cy - 11.8, 2.6, 2.6, skin)

def jeonrip(img, cx, cy, col=(38, 34, 28, 255)):
    ellipse(img, cx, cy - 13.2, 4.0, 1.2, col)
    ellipse(img, cx, cy - 13.8, 2.0, 1.5, col)
    ellipse(img, cx + 1.2, cy - 14.3, 0.6, 0.6, (190, 60, 50, 255))

def spear():  # 창병 — 창 제거, 방패 유지
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    base_man(img, cx, cy, (63, 111, 208, 255))
    jeonrip(img, cx, cy)
    ellipse(img, cx - 3.4, cy - 6.5, 1.9, 2.6, (150, 116, 72, 255))
    ellipse(img, cx - 3.4, cy - 6.5, 1.0, 1.5, (190, 160, 60, 255))
    return finish(img, W, H)

def spear2():  # 갑사 — 장창 제거
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    base_man(img, cx, cy, (36, 58, 120, 255), r=4.0)
    for yy in (-5, -6.8, -8.6):
        for xx in (-2.4, -0.8, 0.8, 2.4):
            ellipse(img, cx + xx, cy + yy, 0.35, 0.35, (200, 170, 80, 255))
    poly(img, [(cx - 5.8, cy - 9.6), (cx - 3.4, cy - 10.4), (cx - 3.2, cy - 6.4), (cx - 5.4, cy - 5.8)], (52, 76, 140, 255))
    poly(img, [(cx + 3.4, cy - 10.4), (cx + 5.8, cy - 9.6), (cx + 5.4, cy - 5.8), (cx + 3.2, cy - 6.4)], (52, 76, 140, 255))
    ellipse(img, cx, cy - 13.4, 3.0, 2.2, (60, 60, 70, 255))
    line(img, (cx, cy - 15.4), (cx, cy - 17), (60, 60, 70, 255), 1.0)
    ellipse(img, cx, cy - 17.2, 0.7, 0.7, (200, 60, 50, 255))
    return finish(img, W, H)

def ashi():  # 아시가루 — 야리 제거
    W, H = 16, 20; cx, cy = 8, 18
    img = canvas(W, H)
    base_man(img, cx, cy, (176, 64, 46, 255))
    poly(img, [(cx - 4.6, cy - 12.2), (cx, cy - 16), (cx + 4.6, cy - 12.2)], (201, 168, 84, 255))
    line(img, (cx - 4.6, cy - 12.2), (cx + 4.6, cy - 12.2), (160, 130, 60, 255), 0.8)
    return finish(img, W, H)

def sam():  # 사무라이 — 카타나 제거
    W, H = 20, 24; cx, cy = 10, 22
    img = canvas(W, H)
    ellipse(img, cx, cy, 6.2, 2.3, (0, 0, 0, 90))
    line(img, (cx - 1.8, cy - 0.3), (cx - 2.1, cy - 4), (40, 32, 26, 255), 1.7)
    line(img, (cx + 1.8, cy - 0.3), (cx + 2.2, cy - 4), (40, 32, 26, 255), 1.7)
    ellipse(img, cx, cy - 8, 4.8, 5.0, (110, 20, 20, 255))
    for k in range(3):
        line(img, (cx - 4.2, cy - 6.2 - k * 1.8), (cx + 4.2, cy - 6.2 - k * 1.8), (150, 32, 28, 255), 0.7)
    poly(img, [(cx - 6.6, cy - 11), (cx - 3.8, cy - 11.6), (cx - 3.6, cy - 7), (cx - 6.2, cy - 6.6)], (138, 26, 26, 255))
    poly(img, [(cx + 3.8, cy - 11.6), (cx + 6.6, cy - 11), (cx + 6.2, cy - 6.6), (cx + 3.6, cy - 7)], (138, 26, 26, 255))
    ellipse(img, cx, cy - 14.5, 2.8, 2.8, (230, 195, 154, 255))
    ellipse(img, cx, cy - 16, 3.4, 2.0, (28, 26, 32, 255))
    ellipse(img, cx, cy - 16.8, 2.4, 1.4, (28, 26, 32, 255))
    d = ImageDraw.Draw(img)
    d.arc([(cx - 2.6) * SS, (cy - 20.5) * SS, (cx - 0.2) * SS, (cy - 16.5) * SS], 180, 330, fill=(212, 167, 44, 255), width=int(0.8 * SS))
    d.arc([(cx + 0.2) * SS, (cy - 20.5) * SS, (cx + 2.6) * SS, (cy - 16.5) * SS], 210, 360, fill=(212, 167, 44, 255), width=int(0.8 * SS))
    return finish(img, W, H)

SKIN = (226, 188, 148, 255)
def lord():  # 왜장 — 대태도 제거 (사시모노 유지)
    W, H = 18, 24; cx, cy = 9, 22
    img = canvas(W, H)
    ellipse(img, cx, cy, 6, 2.2, (0, 0, 0, 90))
    line(img, (cx - 3.4, cy - 4), (cx - 3.4, cy - 19), (70, 54, 36, 255), 0.9)
    poly(img, [(cx - 3.4, cy - 19), (cx + 1.6, cy - 18.4), (cx + 1.6, cy - 13.6), (cx - 3.4, cy - 14.2)], (24, 22, 26, 255))
    ellipse(img, cx - 0.9, cy - 16.2, 1.1, 1.1, (196, 160, 60, 255))
    line(img, (cx - 1.6, cy - 0.3), (cx - 1.9, cy - 4.0), (30, 26, 24, 255), 1.6)
    line(img, (cx + 1.6, cy - 0.3), (cx + 2.0, cy - 4.0), (30, 26, 24, 255), 1.6)
    ellipse(img, cx, cy - 7.2, 4.4, 4.8, (58, 24, 22, 255))
    for yy in (-5.4, -7.0, -8.6):
        line(img, (cx - 3.8, cy + yy), (cx + 3.8, cy + yy), (120, 34, 30, 255), 0.7)
    ellipse(img, cx - 1.6, cy - 8.2, 2.0, 2.2, (84, 34, 30, 255))
    ellipse(img, cx - 4.2, cy - 9.2, 1.7, 2.2, (44, 20, 18, 255))
    ellipse(img, cx + 4.2, cy - 9.2, 1.7, 2.2, (44, 20, 18, 255))
    ellipse(img, cx, cy - 13.2, 2.7, 2.7, SKIN)
    poly(img, [(cx - 2.2, cy - 12.6), (cx + 2.2, cy - 12.6), (cx + 1.6, cy - 10.8), (cx - 1.6, cy - 10.8)], (52, 40, 34, 255))
    ellipse(img, cx, cy - 14.6, 3.1, 1.9, (30, 28, 32, 255))
    poly(img, [(cx - 3.1, cy - 14.4), (cx + 3.1, cy - 14.4), (cx + 3.8, cy - 13.2), (cx - 3.8, cy - 13.2)], (38, 36, 42, 255))
    line(img, (cx - 2.2, cy - 15.6), (cx - 3.4, cy - 18.6), (208, 172, 60, 255), 1.0)
    line(img, (cx + 2.2, cy - 15.6), (cx + 3.4, cy - 18.6), (208, 172, 60, 255), 1.0)
    return finish(img, W, H)

spear().save("u_spear.png")
spear2().save("u_spear2.png")
ashi().save("u_ashi.png")
sam().save("u_sam.png")
lord().save("u_lord.png")
print("gen11 ok: weaponless melee sprites")
