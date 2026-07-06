import sys; sys.path.insert(0,'.')
from lib import *

# ---------- 총통탑 (포루: 화강암 + 총안 + 총통) ----------
def ctower():
    W,H = 40,58; cx,cy = 20,50
    img = canvas(W,H)
    ellipse(img,cx,cy+1,14,6.5,(0,0,0,75))
    # 테이퍼 석축
    z = 26
    bw,tw = 13,9
    n=(cx,cy-6.5); s=(cx,cy+6.5); e=(cx+bw,cy); w=(cx-bw,cy)
    sT=(cx,cy+4.5-z); eT=(cx+tw,cy-z); wT=(cx-tw,cy-z); nT=(cx,cy-4.5-z)
    poly(img,[w,s,sT,wT], shade(GRANITE,0.62))
    poly(img,[s,e,eT,sT], shade(GRANITE,0.82))
    poly(img,[nT,eT,sT,wT], GRANITE)
    # 줄눈
    for k in (0.33,0.66):
        line(img,(cx-bw+(bw-tw)*k, cy-z*k),(cx, cy+6.5-(6.5-4.5)*k-z*k),(120,116,104,200),0.7)
        line(img,(cx, cy+6.5-2*k-z*k),(cx+bw-(bw-tw)*k, cy-z*k),(146,142,128,200),0.7)
    # 총안 (검은 구멍)
    poly(img,[(cx+4,cy-10),(cx+7,cy-11.5),(cx+7,cy-15),(cx+4,cy-13.5)],(24,20,16,255))
    # 여장
    ty = cy - z
    for off in (-6,0,6):
        prism(img,cx+off,ty,2.6,1.3,4,(186,182,168,255))
    # 총통 포신 (우하단 방향)
    line(img,(cx+1,ty-3),(cx+11,ty+2),(34,34,40,255),2.6)
    line(img,(cx+7,ty+0.2),(cx+9,ty+1.2),(180,150,60,255),2.8)
    ellipse(img,cx+11,ty+2,1.6,1.2,(16,16,18,255))
    return finish(img,W,H)
ctower().save("ctower.png")

# ---------- 훈련소 (조선 군막 + 홍기) ----------
def barracks():
    W,H = 44,46; cx,cy = 22,38
    img = canvas(W,H)
    ellipse(img,cx,cy+1,16,7.5,(0,0,0,70))
    ellipse(img,cx,cy,14,7,(122,98,62,160))
    # 군막 (팔각 천막)
    apex=(cx,cy-21)
    poly(img,[(cx-12,cy-1),(cx-6,cy+5),(cx+6,cy+5),(cx+12,cy-1),apex],(214,200,172,255))
    poly(img,[(cx-12,cy-1),(cx-6,cy+5),(cx,cy+5.2),apex],(176,162,136,255))
    # 붉은 상단 띠 + 골조 라인
    for t in (0.25,0.62):
        a=(cx-12+(12)*t*1.0, cy-1-(20)*t)
        b=(cx+12-(12)*t*1.0, cy-1-(20)*t)
    poly(img,[(cx-4.5,cy-13.5),(cx+4.5,cy-13.5),apex],(150,40,34,255))
    for dx in (-12,-6,6,12):
        y0 = cy-1 if abs(dx)==12 else cy+5
        line(img,(cx+dx,y0),apex,(150,132,104,255),0.7)
    # 입구
    poly(img,[(cx-2.5,cy+5),(cx+2.5,cy+5),(cx,cy-4)],(52,36,22,255))
    # 깃대 + 홍기(제비꼬리)
    px = cx+13
    line(img,(px,cy-2),(px,cy-26),WOOD,1.1)
    poly(img,[(px,cy-26),(px+9,cy-24.5),(px+5.5,cy-22.8),(px+9,cy-21),(px,cy-19.5)],(178,32,28,255))
    return finish(img,W,H)
barracks().save("barracks.png")

# ---------- 농경지 (이랑 + 모) ----------
def farm():
    W,H = 32,18; cx,cy = 16,9
    img = canvas(W,H)
    poly(img,[(cx,cy-7.5),(cx+15,cy),(cx,cy+7.5),(cx-15,cy)],(110,82,48,255))
    # 이랑 (다이아 축 평행)
    for k in range(4):
        t=(k+1)/5.0
        a=(cx-15+15*t, cy-7.5*t*1.0+7.5*t-7.5*t)  # placeholder
    for k in range(4):
        t=(k+1)/5.0
        p0=(cx-15*(1-t), cy-7.5*t)
        p1=(cx+15*t, cy-7.5*(1-t)*1.0+7.5*(1-t)-7.5*(1-t))
    # 단순: 좌상→우하 평행 이랑
    for k in range(4):
        t=(k+0.8)/4.6
        a=(cx-15+30*t*0.5- (7.5*t)*0 , 0)
    d=ImageDraw.Draw(img)
    for k in range(4):
        t=(k+0.9)/4.8
        x0,y0 = cx-15*(1-t), cy+7.5*t
        x1,y1 = cx+15*t,     cy-7.5*(1-t)
        line(img,( (x0+ (x1-x0)*0.06),(y0+(y1-y0)*0.06) ),( (x0+(x1-x0)*0.94),(y0+(y1-y0)*0.94) ),(78,58,34,255),0.9)
        for m in range(6):
            u=m/5.0*0.82+0.09
            gx=x0+(x1-x0)*u; gy=y0+(y1-y0)*u
            line(img,(gx,gy-0.4),(gx-1.1,gy-2.6),(96,150,66,255),0.6)
            line(img,(gx,gy-0.4),(gx+1.1,gy-2.6),(88,140,60,255),0.6)
    return finish(img,32,18,outline=False)
farm().save("farm.png")

# ---------- 벌목장 ----------
def lumber():
    W,H = 36,30; cx,cy = 18,22
    img = canvas(W,H)
    ellipse(img,cx,cy,14,7,(122,98,62,170))
    def log(x,y,r=3.4):
        ellipse(img,x,y,r,r,(150,110,66,255))
        ellipse(img,x,y,r,r,None,outline=(110,74,38,255),ow=1)
        ellipse(img,x,y,r*0.45,r*0.45,None,outline=(196,160,110,255),ow=1)
    # 옆으로 누운 통나무 몸통
    poly(img,[(cx-13,cy+2),(cx-3,cy-3),(cx-3,cy+3),(cx-13,cy+8)],(128,92,52,255))
    log(cx-3,cy)
    poly(img,[(cx-12,cy-3),(cx-2,cy-8),(cx-2,cy-2),(cx-12,cy+3)],(140,102,58,255))
    log(cx-2,cy-5)
    # 그루터기 + 도끼
    ellipse(img,cx+8,cy-1,3.4,2.2,(150,110,66,255))
    poly(img,[(cx+4.8,cy-1),(cx+11.2,cy-1),(cx+11.2,cy+4),(cx+4.8,cy+4)],(112,78,42,255))
    ellipse(img,cx+8,cy-1,3.4,2.2,(168,128,80,255))
    line(img,(cx+8,cy-2),(cx+12,cy-11),(90,62,34,255),1.2)
    poly(img,[(cx+12,cy-13),(cx+16,cy-11.4),(cx+13.4,cy-8.8)],(196,200,208,255))
    return finish(img,W,H)
lumber().save("lumber.png")

# ---------- 철광 ----------
def mine():
    W,H = 36,32; cx,cy = 18,24
    img = canvas(W,H)
    ellipse(img,cx,cy,15,7,(0,0,0,60))
    # 바위 무더기
    poly(img,[(cx-14,cy+3),(cx-10,cy-8),(cx-2,cy-13),(cx+7,cy-10),(cx+13,cy-2),(cx+11,cy+4),(cx,cy+7),(cx-9,cy+6)],(142,138,126,255))
    poly(img,[(cx-14,cy+3),(cx-10,cy-8),(cx-2,cy-13),(cx-1,cy+7),(cx-9,cy+6)],(112,108,98,255))
    line(img,(cx-6,cy-10),(cx-9,cy-1),(96,92,84,255),0.8)
    line(img,(cx+4,cy-11),(cx+8,cy-3),(120,116,106,255),0.8)
    # 갱도 입구 (목재 프레임)
    poly(img,[(cx-1,cy+6),(cx+7,cy+2),(cx+7,cy-6),(cx-1,cy-2)],(20,17,13,255))
    line(img,(cx-1.6,cy+6.8),(cx-1.6,cy-2.8),WOOD,1.4)
    line(img,(cx+7.6,cy+2.6),(cx+7.6,cy-6.6),WOOD,1.4)
    line(img,(cx-2.4,cy-2.4),(cx+8.4,cy-7),WOOD,1.3)
    # 철광석 반짝임
    for dx,dy in [(-7,2),(5,-9),(-3,-6)]:
        ellipse(img,cx+dx,cy+dy,1.3,1.0,(74,80,100,255))
        ellipse(img,cx+dx-0.4,cy+dy-0.4,0.5,0.4,(150,160,190,255))
    return finish(img,W,H)
mine().save("mine.png")

# ---------- 건설 현장 ----------
def site():
    W,H = 36,28; cx,cy = 18,20
    img = canvas(W,H)
    ellipse(img,cx,cy,14,7,(112,90,56,200))
    # 목재 골조
    for dx,dy in [(-10,0),(10,0),(0,-5),(0,5)]:
        line(img,(cx+dx,cy+dy),(cx+dx,cy+dy-11),WOOD,1.3)
    line(img,(cx-10,cy-11),(cx,cy+5-11),(150,120,80,255),1)
    line(img,(cx,cy+5-11),(cx+10,cy-11),(150,120,80,255),1)
    line(img,(cx-10,cy-5.5),(cx,cy-0.5),(150,120,80,255),0.8)
    line(img,(cx,cy-0.5),(cx+10,cy-5.5),(150,120,80,255),0.8)
    # 자재 더미
    for i,(dx,dy) in enumerate([(-5,3),(-1,4.5),(3,3)]):
        ellipse(img,cx+dx,cy+dy,2.6,2.6,(150,110,66,255))
        ellipse(img,cx+dx,cy+dy,1.1,1.1,None,outline=(196,160,110,255),ow=1)
    return finish(img,W,H)
site().save("site.png")

# ---------- 소나무 ----------
def pine():
    W,H = 30,42; cx,cy = 15,38
    img = canvas(W,H)
    ellipse(img,cx,cy,9,3.5,(0,0,0,70))
    # 붉은빛 굽은 줄기 (조선 소나무)
    line(img,(cx,cy),(cx+1.5,cy-9),(146,90,58,255),2.2)
    line(img,(cx+1.5,cy-9),(cx-1,cy-17),(146,90,58,255),1.8)
    # 층진 수관 (녹운형)
    for i,(dx,dy,rx,ry,c) in enumerate([
        (0,-16,9,4.5,(38,72,34,255)),
        (-3,-21,7,3.6,(46,86,40,255)),
        (2,-25,6,3.2,(52,96,46,255)),
        (-1,-29,4.5,2.6,(60,108,52,255))]):
        ellipse(img,cx+dx,cy+dy,rx,ry,c)
        ellipse(img,cx+dx-rx*0.3,cy+dy-ry*0.4,rx*0.45,ry*0.45,shade(c,1.25))
    return finish(img,W,H)
pine().save("pine.png")

def tree():
    W,H = 28,36; cx,cy = 14,32
    img = canvas(W,H)
    ellipse(img,cx,cy,9,3.5,(0,0,0,70))
    line(img,(cx,cy),(cx,cy-9),(96,66,40,255),2.4)
    ellipse(img,cx,cy-16,9.5,8.5,(44,80,32,255))
    ellipse(img,cx-3,cy-19,5.5,5,(56,100,42,255))
    ellipse(img,cx-4.5,cy-21,2.6,2.4,(74,128,56,255))
    return finish(img,28,36)
tree().save("tree.png")
print("GEN2 DONE")
