# 일꾼 도구 스프라이트 4종 (망치/괭이/도끼/곡괭이)
# 손잡이 끝(grip)이 (GX, GY)에 오도록 그린다 — main.gd의 TOOL_ANCH와 일치해야 함
# 자루는 +X 방향으로 뻗는다. 게임에서는 이 스프라이트를 grip 기준으로 회전시킨다.
#
# 주의: 이 스크립트는 art/tool_*.png 를 새로 만든다. 다른 아트는 건드리지 않는다.
from PIL import Image, ImageDraw
import os

SS = 8                     # 슈퍼샘플 배율
W, H = 50, 24              # 출력 크기 (날이 잘리지 않도록 여유)
GX, GY = 5, 12             # grip(손잡이 끝) 위치

WOOD = (138, 106, 68, 255)
WOOD_D = (96, 72, 45, 255)
STEEL = (154, 160, 168, 255)
STEEL_L = (196, 201, 208, 255)
STEEL_D = (106, 112, 134, 255)
IRON = (126, 124, 114, 255)
IRON_D = (84, 82, 74, 255)
LINE = (43, 33, 24, 255)   # 외곽선


def canvas():
    return Image.new("RGBA", (W * SS, H * SS), (0, 0, 0, 0))


def P(pts):
    return [(x * SS, y * SS) for x, y in pts]


def poly(d, pts, fill, outline=LINE, ow=1):
    d.polygon(P(pts), fill=fill, outline=outline, width=ow * SS)


def bar(d, x0, y0, x1, y1, fill, outline=LINE):
    poly(d, [(x0, y0), (x1, y0), (x1, y1), (x0, y1)], fill, outline)


def handle(d, length=27, thick=2.8):
    """grip에서 +X로 뻗는 나무 자루"""
    y0 = GY - thick / 2.0
    y1 = GY + thick / 2.0
    bar(d, GX, y0, GX + length, y1, WOOD)
    # 아래쪽 그림자 면
    d.rectangle([int((GX + 1) * SS), int((y1 - 0.9) * SS),
                 int((GX + length - 1) * SS), int((y1 - 0.2) * SS)], fill=WOOD_D)


def save(img, name):
    out = img.resize((W, H), Image.LANCZOS)
    path = os.path.join("..", "art", name)
    out.save(path)
    print("wrote", path)


def hammer():
    # 망치: 자루 끝에 세로로 선 쇳덩이 (실루엣 = 굵은 T)
    img = canvas()
    d = ImageDraw.Draw(img)
    handle(d, 28)
    hx = GX + 28
    bar(d, hx - 1, GY - 6, hx + 7, GY + 6, IRON)
    bar(d, hx + 3, GY - 5, hx + 6, GY + 5, IRON_D)   # 타격면 쪽 음영
    save(img, "tool_hammer.png")


def hoe():
    # 괭이: 자루 끝에서 아래로 직각으로 꺾인 넓적한 날 (실루엣 = ㄱ 뒤집은 꼴)
    img = canvas()
    d = ImageDraw.Draw(img)
    handle(d, 30)
    hx = GX + 30
    poly(d, [(hx - 1, GY - 2), (hx + 4, GY - 2), (hx + 4, GY + 3),
             (hx + 4, GY + 10), (hx - 3, GY + 10), (hx - 2, GY + 3)], STEEL)
    poly(d, [(hx - 2, GY + 6), (hx + 4, GY + 6), (hx + 4, GY + 10), (hx - 3, GY + 10)], STEEL_D)
    save(img, "tool_hoe.png")


def axe():
    # 도끼: 바깥으로 부챗살처럼 퍼지는 쐐기날. 날끝(오른쪽)이 직선
    img = canvas()
    d = ImageDraw.Draw(img)
    handle(d, 28)
    hx = GX + 28
    poly(d, [(hx - 1, GY - 3), (hx + 4, GY - 9), (hx + 9, GY - 8),
             (hx + 9, GY + 8), (hx + 4, GY + 9), (hx - 1, GY + 3)], STEEL)
    poly(d, [(hx + 6, GY - 8), (hx + 9, GY - 8), (hx + 9, GY + 8), (hx + 6, GY + 8)], STEEL_L)
    save(img, "tool_axe.png")


def pick():
    # 곡괭이: 자루 끝에 위아래로 벌어진 두 갈래 뿔. 두껍게 해서 형태가 읽히도록
    img = canvas()
    d = ImageDraw.Draw(img)
    handle(d, 27)
    hx = GX + 27
    bar(d, hx - 1, GY - 3, hx + 3, GY + 3, IRON)      # 자루와 머리 이음쇠
    poly(d, [(hx + 1, GY - 3), (hx + 12, GY - 9), (hx + 13, GY - 6), (hx + 3, GY), (hx + 1, GY)], STEEL_D)
    poly(d, [(hx + 1, GY + 3), (hx + 12, GY + 9), (hx + 13, GY + 6), (hx + 3, GY), (hx + 1, GY)], STEEL)
    save(img, "tool_pick.png")


if __name__ == "__main__":
    hammer()
    hoe()
    axe()
    pick()
