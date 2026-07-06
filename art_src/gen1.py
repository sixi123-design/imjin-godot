# 핵심 스프라이트 1차: 행궁, 성벽, 민가, 궁수탑, 잔디타일
import sys; sys.path.insert(0,'.')
from lib import *

# ---------- 잔디 타일 28x14 ----------
def tile(base, seed, speckle):
    img = canvas(28,14)
    poly(img, [(14,0),(28,7),(14,14),(0,7)], base)
    rng = np.random.default_rng(seed)
    d = ImageDraw.Draw(img)
    for i in range(speckle):
        x = rng.uniform(3,25); y = rng.uniform(2,12)
        # 다이아몬드 내부만
        if abs(x-14)/14 + abs(y-7)/7 > 0.95: continue
        c = shade(base, rng.uniform(0.75,1.3))
        d.point([(int(x*SS),int(y*SS))], fill=c)
        d.rectangle([x*SS,y*SS,x*SS+SS,y*SS+SS], fill=c)
    return finish(img,28,14,outline=False)

tile((74,106,52,255), 1, 90).save("tile_g0.png")
tile((68,99,48,255), 2, 90).save("tile_g1.png")
tile((80,112,57,255), 3, 90).save("tile_g2.png")
tile((122,98,62,255), 4, 70).save("tile_dirt.png")
tile((150,142,120,255), 5, 60).save("tile_court.png")

# ---------- 성벽 (조선 성곽: 화강암 + 여장) ----------
def wall():
    W,H = 36,44; cx,cy = 18,36
    img = canvas(W,H)
    ellipse(img,cx,cy+1,15,7,(0,0,0,70))
    z = 20
    prism(img,cx,cy,14,7,z,GRANITE)
    # 화강암 블록 줄눈 (백색 회 줄눈이 조선 성곽 특징)
    for r in range(3):
        y = cy-3-r*6
        line(img,(cx-14+r%2, y-7*(0)), (cx, y+7-7), (120,116,104,255), 0.8)
    # 좌우면 블록 라인
    for k in range(1,3):
        yy = cy - k*6.2
        line(img,(cx-14, cy-0- k*6.2+0), (cx, cy+7- k*6.2), (128,124,112,200), 0.7)
        line(img,(cx, cy+7- k*6.2), (cx+14, cy- k*6.2), (150,146,132,200), 0.7)
    # 세로 줄눈
    for xx,y0 in [(-9,3),(-4.5,6),(9,3),(4.5,6)]:
        line(img,(cx+xx, cy+y0-6.2), (cx+xx, cy+y0-12.4), (128,124,112,180), 0.7)
    # 여장 (총안 뚫린 낮은 담)
    ty = cy - z
    for off in (-9,0,9):
        prism(img,cx+off,ty,3.6,1.8,5,(186,182,168,255))
    return finish(img,W,H)
wall().save("wall.png")

# ---------- 민가 (초가집) ----------
def house():
    W,H = 44,40; cx,cy = 22,32
    img = canvas(W,H)
    ellipse(img,cx,cy+1,16,7.5,(0,0,0,70))
    z = 11
    # 회벽 몸체
    prism(img,cx,cy,12,6,z,WALLW,dark=0.72,mid=0.9)
    # 나무 기둥/인방
    line(img,(cx-12,cy),(cx-12,cy-z),WOOD,1)
    line(img,(cx,cy+6),(cx,cy+6-z),WOOD,1.2)
    line(img,(cx+12,cy),(cx+12,cy-z),WOOD,1)
    # 문
    poly(img,[(cx+4.5,cy+3.5),(cx+9,cy+1.2),(cx+9,cy-6),(cx+4.5,cy-3.5)],(74,46,26,255))
    # 초가지붕: 둥근 우진각 (부드러운 곡선)
    ty = cy - z
    d = ImageDraw.Draw(img)
    roof = [(cx-17,ty+2),(cx-10,ty-9),(cx-4,ty-11),(cx+4,ty-11),(cx+10,ty-9),(cx+17,ty+2),
            (cx+10,ty+7),(cx,ty+9.5),(cx-10,ty+7)]
    poly(img,roof,THATCH)
    poly(img,[(cx-17,ty+2),(cx-10,ty-9),(cx-4,ty-11),(cx,ty-11),(cx,ty+9.5),(cx-10,ty+7)],shade(THATCH,0.82))
    # 짚 결
    for k in range(5):
        t=k/4.0
        x0=cx-15+t*4; x1=cx-9+t*4
        line(img,(cx-15+t*7.5, ty+1-t*0.5),(cx-8+t*6, ty-8+t*1.5),shade(THATCH,0.68),0.6)
        line(img,(cx+15-t*7.5, ty+1-t*0.5),(cx+8-t*6, ty-8+t*1.5),shade(THATCH,0.75),0.6)
    # 용마루 짚 다발
    poly(img,[(cx-5,ty-11.6),(cx+5,ty-11.6),(cx+5,ty-9.8),(cx-5,ty-9.8)],shade(THATCH,0.6))
    return finish(img,W,H)
house().save("house.png")

# ---------- 행궁 (팔작지붕 2단 + 단청 + 백색 용마루) ----------
def hq():
    W,H = 88,84; cx,cy = 44,68
    img = canvas(W,H)
    ellipse(img,cx,cy+2,32,14,(0,0,0,80))
    # 2단 석축 기단
    prism(img,cx,cy,30,15,7,(158,154,142,255))
    prism(img,cx,cy-7,26,13,5,(174,170,158,255))
    base_y = cy-12
    # 본전 몸체 (회벽)
    z = 16
    prism(img,cx,base_y,21,10.5,z,WALLW,dark=0.74,mid=0.92)
    # 석간주 기둥 (전면 두 면)
    for t in (0.08,0.36,0.64,0.92):
        # 우측면 (남동)
        x0 = cx + t*21; y0 = base_y + 10.5*(1-t)
        line(img,(x0,y0),(x0,y0-z),PILLAR,1.6)
        # 좌측면 (남서)
        x1 = cx - 21 + t*21; y1 = base_y + t*10.5
        line(img,(x1,y1),(x1,y1-z),shade(PILLAR,0.8),1.6)
    # 문 (우측면 중앙)
    poly(img,[(cx+8,base_y+7),(cx+14,base_y+4),(cx+14,base_y-7),(cx+8,base_y-4)],(58,38,22,255))
    # 단청 뇌록 띠 (처마 밑) — 조선의 시그니처
    ty = base_y - z
    line(img,(cx-21,ty+0.5),(cx,ty+11),DANCH,2.2)
    line(img,(cx,ty+11),(cx+21,ty+0.5),shade(DANCH,1.15),2.2)
    # 1단 팔작지붕 (완만한 곡선 + 백색 용마루)
    ev = ty - 1
    r1,r2 = (cx-11,ev-13),(cx+11,ev-13)
    poly(img,[(cx-27,ev),(cx-19,ev+7),(cx,ev+11.5),(cx+19,ev+7),(cx+27,ev),r2,r1],GIWA)
    poly(img,[(cx-27,ev),(cx-19,ev+7),(cx,ev+11.5),(cx,ev+11.5),r1],shade(GIWA,0.8))
    # 기와골
    for t in (0.25,0.5,0.75):
        xx = cx-27+t*(27-11)+0; 
        line(img,(cx-27+t*16, ev+ t*(-13)*0+2-t*2),( r1[0]-t*0, r1[1]+3),shade(GIWA,0.72),0.5)
        line(img,(cx+27-t*16, ev+2-t*2),( r2[0], r2[1]+3),shade(GIWA_L,0.9),0.5)
    # 백색 내림마루/용마루
    line(img,r1,r2,RIDGE,1.8)
    line(img,(cx-27,ev),r1,RIDGE,1.2)
    line(img,(cx+27,ev),r2,RIDGE,1.2)
    # 2단 (상층)
    ev2y = ev-12
    prism(img,cx,ev2y+1,10,5,7,WALLW,dark=0.74,mid=0.92)
    line(img,(cx-10,ev2y+1),(cx-10,ev2y-6),shade(PILLAR,0.85),1.2)
    line(img,(cx+10,ev2y+1),(cx+10,ev2y-6),PILLAR,1.2)
    ty2 = ev2y - 6
    line(img,(cx-10,ty2+0.5),(cx,ty2+5.5),DANCH,1.6)
    line(img,(cx,ty2+5.5),(cx+10,ty2+0.5),shade(DANCH,1.15),1.6)
    ev3 = ty2 - 1
    r3,r4 = (cx-5.5,ev3-8),(cx+5.5,ev3-8)
    poly(img,[(cx-15,ev3),(cx-10,ev3+4.5),(cx,ev3+7),(cx+10,ev3+4.5),(cx+15,ev3),r4,r3],GIWA)
    poly(img,[(cx-15,ev3),(cx-10,ev3+4.5),(cx,ev3+7),r3],shade(GIWA,0.8))
    line(img,r3,r4,RIDGE,1.6)
    line(img,(cx-15,ev3),r3,RIDGE,1.0)
    line(img,(cx+15,ev3),r4,RIDGE,1.0)
    return finish(img,W,H)
hq().save("hq.png")

# ---------- 궁수탑 (망루) ----------
def atower():
    W,H = 40,56; cx,cy = 20,48
    img = canvas(W,H)
    ellipse(img,cx,cy+1,13,6,(0,0,0,70))
    # 석축 낮은 기단
    prism(img,cx,cy,11,5.5,4,(160,156,144,255))
    by = cy-4
    z = 18
    # 목재 기둥 4개
    for dx,dy in [(-8,0),(8,0),(0,-4),(0,4)]:
        line(img,(cx+dx,by+dy),(cx+dx,by+dy-z),WOOD,1.6)
    line(img,(cx-8,by),(cx+8,by-z),shade(WOOD,0.85),0.9)
    line(img,(cx+8,by),(cx-8,by-z),shade(WOOD,0.85),0.9)
    # 마루 + 난간
    py = by - z
    prism(img,cx,py,10,5,3,(154,128,88,255))
    for dx in (-8,-4,0,4,8):
        line(img,(cx+dx,py+4-abs(dx)*0.25),(cx+dx,py-2-abs(dx)*0.25),WOOD,0.8)
    # 기와 모임지붕 + 백색 마루
    ry = py - 5
    apex = (cx, ry-9)
    poly(img,[(cx-13,ry),(cx,ry+6),(cx+13,ry),apex],GIWA)
    poly(img,[(cx-13,ry),(cx,ry+6),apex],shade(GIWA,0.8))
    line(img,(cx-13,ry),apex,RIDGE,1.0)
    line(img,(cx+13,ry),apex,RIDGE,1.0)
    line(img,(cx,ry+6),apex,shade(RIDGE,0.9),0.8)
    # 단청 띠
    line(img,(cx-10,py-2.5),(cx,py+2.5),DANCH,1.2)
    line(img,(cx,py+2.5),(cx+10,py-2.5),shade(DANCH,1.15),1.2)
    return finish(img,W,H)
atower().save("atower.png")
print("GEN1 DONE")
