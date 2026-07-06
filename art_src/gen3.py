# 디테일 업그레이드: 기와골/막새/깃발 — 참고: 임진록2, 한옥 디오라마
import sys; sys.path.insert(0,'.')
from lib import *

def giwa_roof(img, pts_front, ridge_a, ridge_b, base_col=GIWA, rows=6, msae=True):
    """pts_front: 앞면 외곽(시계), ridge_a/b: 용마루 양끝. 기와골 + 백색 용마루 + 막새"""
    poly(img, pts_front, base_col)
    # 기와 열 (처마→용마루 방향 곡선들)
    eave = pts_front[:len(pts_front)-2]  # 앞 처마 라인 점들
    n_e = len(eave)
    for r in range(1, rows):
        t = r / rows
        prev=None
        for i in range(n_e):
            ex,ey = eave[i]
            # 처마 점 → 용마루 보간
            rx = ridge_a[0] + (ridge_b[0]-ridge_a[0]) * (i/(n_e-1))
            ry = ridge_a[1] + (ridge_b[1]-ridge_a[1]) * (i/(n_e-1))
            px = ex + (rx-ex)*t; py = ey + (ry-ey)*t - math.sin(t*math.pi)*1.2
            if prev: line(img, prev, (px,py), shade(base_col, 0.8 if r%2 else 1.14), 0.55)
            prev=(px,py)
    # 세로 기와골
    for i in range(n_e):
        ex,ey=eave[i]
        rx = ridge_a[0] + (ridge_b[0]-ridge_a[0]) * (i/(n_e-1))
        ry = ridge_a[1] + (ridge_b[1]-ridge_a[1]) * (i/(n_e-1))
        line(img,(ex,ey),(rx,ry),shade(base_col,0.72),0.5)
        if msae:
            ellipse(img,ex,ey,0.9,0.9,shade(base_col,1.35))  # 수막새
            ellipse(img,ex,ey,0.4,0.4,shade(base_col,0.7))
    # 백색 용마루 + 취두
    line(img,ridge_a,ridge_b,RIDGE,2.0)
    line(img,(ridge_a[0],ridge_a[1]+0.8),(ridge_b[0],ridge_b[1]+0.8),shade(RIDGE,0.8),0.8)
    ellipse(img,ridge_a[0],ridge_a[1],1.5,1.8,(84,92,102,255))
    ellipse(img,ridge_b[0],ridge_b[1],1.5,1.8,(84,92,102,255))

def banner(img, x, y, h, col=(40,80,160,255), tail=True):
    line(img,(x,y),(x,y-h),(74,52,32,255),1.1)
    ellipse(img,x,y-h,0.9,0.9,(190,160,60,255))
    pts=[(x,y-h+0.5),(x+7,y-h+2),(x+7,y-h+9),(x,y-h+7.5)]
    if tail: pts=[(x,y-h+0.5),(x+7.5,y-h+2),(x+5,y-h+4.7),(x+7.5,y-h+7.5),(x,y-h+8.5)]
    poly(img,pts,col)
    line(img,(x+0.5,y-h+1.5),(x+0.5,y-h+7.6),shade(col,1.4),0.6)

# ---------- 행궁 v2 (100x92) ----------
def hq():
    W,H = 100,92; cx,cy = 50,72
    img = canvas(W,H)
    ellipse(img,cx,cy+3,36,15,(0,0,0,85))
    # 2단 화강암 기단 (블록 질감)
    prism(img,cx,cy,34,17,8,(164,160,148,255))
    for k in range(4):
        line(img,(cx-34+k*5,cy+8-8+k*1.2),(cx-30+k*5,cy+10-8+k*1.2),(120,116,104,150),0.5)
    prism(img,cx,cy-8,29,14.5,6,(180,176,164,255))
    # 계단 (전면)
    for st in range(3):
        poly(img,[(cx+10+st*2.4,cy+6-st*2.2),(cx+17+st*2.4,cy+2.5-st*2.2),(cx+19.4+st*2.4,cy+3.7-st*2.2),(cx+12.4+st*2.4,cy+7.2-st*2.2)],(150,146,134,255))
    base_y = cy-14
    # 본전 (회벽 + 창방/평방 목부재)
    z = 18
    prism(img,cx,base_y,23,11.5,z,WALLW,dark=0.76,mid=0.93)
    line(img,(cx-23,base_y-z+1),(cx,base_y+11.5-z+1),(106,74,48,255),1.3)
    line(img,(cx,base_y+11.5-z+1),(cx+23,base_y-z+1),(120,86,56,255),1.3)
    # 석간주 기둥
    for t in (0.06,0.34,0.62,0.9):
        x0 = cx + t*23; y0 = base_y + 11.5*(1-t)
        line(img,(x0,y0),(x0,y0-z),PILLAR,1.8)
        line(img,(x0-0.6,y0),(x0-0.6,y0-z),shade(PILLAR,1.25),0.5)
        x1 = cx - 23 + t*23; y1 = base_y + t*11.5
        line(img,(x1,y1),(x1,y1-z),shade(PILLAR,0.78),1.8)
    # 문/창 (세살문)
    poly(img,[(cx+8.5,base_y+8),(cx+15.5,base_y+4.5),(cx+15.5,base_y-8),(cx+8.5,base_y-4.5)],(64,42,24,255))
    for gx_ in range(3):
        line(img,(cx+9.5+gx_*2.2,base_y+7-gx_*1.1),(cx+9.5+gx_*2.2,base_y-4.5-gx_*1.1),(140,104,62,255),0.5)
    # 단청 (뇌록 + 주홍 세부)
    ty = base_y - z
    line(img,(cx-23,ty+0.5),(cx,ty+12),DANCH,2.6)
    line(img,(cx,ty+12),(cx+23,ty+0.5),shade(DANCH,1.15),2.6)
    line(img,(cx-23,ty+1.8),(cx,ty+13.3),(150,60,40,255),0.8)
    line(img,(cx,ty+13.3),(cx+23,ty+1.8),(170,70,45,255),0.8)
    # 1단 팔작지붕 (기와골 포함)
    ev = ty - 1
    front=[(cx-30,ev),(cx-20,ev+8),(cx,ev+13),(cx+20,ev+8),(cx+30,ev),(cx+12,ev-14),(cx-12,ev-14)]
    giwa_roof(img,front,(cx-12,ev-14),(cx+12,ev-14),rows=6)
    # 상층
    ev2y = ev-13
    prism(img,cx,ev2y+1,11,5.5,8,WALLW,dark=0.76,mid=0.93)
    line(img,(cx-11,ev2y+1),(cx-11,ev2y-7),shade(PILLAR,0.85),1.4)
    line(img,(cx+11,ev2y+1),(cx+11,ev2y-7),PILLAR,1.4)
    ty2 = ev2y-7
    line(img,(cx-11,ty2+0.5),(cx,ty2+6),DANCH,1.8)
    line(img,(cx,ty2+6),(cx+11,ty2+0.5),shade(DANCH,1.15),1.8)
    ev3 = ty2-1
    front2=[(cx-17,ev3),(cx-11,ev3+5),(cx,ev3+8),(cx+11,ev3+5),(cx+17,ev3),(cx+6,ev3-9),(cx-6,ev3-9)]
    giwa_roof(img,front2,(cx-6,ev3-9),(cx+6,ev3-9),rows=4)
    # 양측 청기 (임진록풍)
    banner(img,cx-30,cy-4,30)
    banner(img,cx+27,cy+8,28)
    return finish(img,W,H)
hq().save("hq.png"); print("hq")

# ---------- 민가 v2 (48x42) ----------
def house():
    W,H = 48,42; cx,cy = 24,34
    img = canvas(W,H)
    ellipse(img,cx,cy+1,17,8,(0,0,0,75))
    z=11
    prism(img,cx,cy,13,6.5,z,WALLW,dark=0.74,mid=0.92)
    line(img,(cx-13,cy),(cx-13,cy-z),WOOD,1.1)
    line(img,(cx-6.5,cy+3.2),(cx-6.5,cy+3.2-z),shade(WOOD,0.85),1)
    line(img,(cx,cy+6.5),(cx,cy+6.5-z),WOOD,1.2)
    line(img,(cx+13,cy),(cx+13,cy-z),WOOD,1.1)
    # 툇마루
    poly(img,[(cx+2,cy+7.5),(cx+13.5,cy+1.5),(cx+15.5,cy+2.5),(cx+4,cy+8.6)],(150,116,72,255))
    # 문/창호
    poly(img,[(cx+5,cy+3.6),(cx+9.5,cy+1.3),(cx+9.5,cy-5.5),(cx+5,cy-3.2)],(74,46,26,255))
    line(img,(cx+7.2,cy+2.5),(cx+7.2,cy-4.3),(150,116,72,255),0.5)
    poly(img,[(cx-11,cy+1),(cx-7.5,cy+2.8),(cx-7.5,cy-1.8),(cx-11,cy-3.6)],(226,216,192,255))
    line(img,(cx-9.2,cy+1.9),(cx-9.2,cy-2.7),(150,116,72,255),0.6)
    # 초가지붕 (짚 織 텍스처)
    ty = cy - z
    d=ImageDraw.Draw(img)
    roof=[(cx-19,ty+2.5),(cx-11,ty-9),(cx-4,ty-11.5),(cx+4,ty-11.5),(cx+11,ty-9),(cx+19,ty+2.5),(cx+11,ty+8),(cx,ty+10.5),(cx-11,ty+8)]
    poly(img,roof,THATCH)
    poly(img,[(cx-19,ty+2.5),(cx-11,ty-9),(cx-4,ty-11.5),(cx,ty-11.5),(cx,ty+10.5),(cx-11,ty+8)],shade(THATCH,0.84))
    for k in range(7):  # 짚 결 가로줄
        t=k/6.0
        yy = ty-10+t*17
        wdt = 18*(1-abs(t-0.55)*0.5)
        line(img,(cx-wdt,yy+ (2.5 if k>3 else 0)*t),(cx+wdt,yy+(2.5 if k>3 else 0)*t),shade(THATCH,0.72 if k%2 else 0.9),0.5)
    for k in range(9):  # 세로 결
        xx = cx-16+k*4
        line(img,(xx,ty+6-abs(xx-cx)*0.28),(xx+1.5,ty-9+abs(xx-cx)*0.22),shade(THATCH,0.66),0.4)
    poly(img,[(cx-5,ty-12.2),(cx+5,ty-12.2),(cx+5,ty-10),(cx-5,ty-10)],shade(THATCH,0.58))
    line(img,(cx-5,ty-11),(cx+5,ty-11),(150,116,60,255),0.6)
    return finish(img,W,H)
house().save("house.png"); print("house")

# ---------- 성벽 v2 ----------
def wall():
    W,H = 36,46; cx,cy = 18,38
    img = canvas(W,H)
    ellipse(img,cx,cy+1,15,7,(0,0,0,70))
    z = 21
    prism(img,cx,cy,14,7,z,GRANITE)
    rng = np.random.default_rng(7)
    # 불규칙 화강암 블록 (양면)
    for face in (0,1):
        for r in range(4):
            yy = -3 - r*5
            off = (r%2)*3.5
            for c_ in range(3):
                bx = 2+off+c_*4.6
                if bx>13: continue
                x0 = cx-14+bx if face==0 else cx+bx
                sl = 0.5 if face==0 else -0.5
                col = shade(GRANITE, (0.62 if face==0 else 0.82)*rng.uniform(0.92,1.08))
                poly(img,[(x0,cy+yy+bx*sl*0),(x0+4,cy+yy),(x0+4,cy+yy+4.4),(x0,cy+yy+4.4)],col)
        # 이끼
    for i in range(5):
        mx=cx+rng.uniform(-12,12); my=cy+rng.uniform(-4,4)
        ellipse(img,mx,my,1.2,0.8,(96,120,60,160))
    ty = cy - z
    for off in (-9,0,9):
        prism(img,cx+off,ty,3.6,1.8,5,(190,186,172,255))
        poly(img,[(cx+off-1,ty-2.2),(cx+off+1,ty-3.2),(cx+off+1,ty-1),(cx+off-1,ty)],(60,56,50,255))  # 총안
    return finish(img,W,H)
wall().save("wall.png"); print("wall")

# ---------- 궁수탑 v2 (44x62) ----------
def atower():
    W,H = 44,62; cx,cy = 22,52
    img = canvas(W,H)
    ellipse(img,cx,cy+1,14,6.5,(0,0,0,75))
    prism(img,cx,cy,12,6,5,GRANITE)
    by = cy-5; z=19
    for dx,dy in [(-9,0),(9,0),(0,-4.5),(0,4.5)]:
        line(img,(cx+dx,by+dy),(cx+dx,by+dy-z),WOOD,1.7)
        line(img,(cx+dx-0.6,by+dy),(cx+dx-0.6,by+dy-z),shade(WOOD,1.3),0.5)
    line(img,(cx-9,by),(cx+9,by-z),shade(WOOD,0.8),1)
    line(img,(cx+9,by),(cx-9,by-z),shade(WOOD,0.8),1)
    py = by-z
    prism(img,cx,py,11,5.5,3.5,(158,132,90,255))
    py2 = py-3.5
    for dx in (-9,-4.5,0,4.5,9):
        line(img,(cx+dx,py2+5-abs(dx)*0.3),(cx+dx,py2-2.5-abs(dx)*0.3),WOOD,0.9)
    line(img,(cx-9,py2+2.2),(cx,py2+6.8),(140,104,62,255),0.8)
    line(img,(cx,py2+6.8),(cx+9,py2+2.2),(140,104,62,255),0.8)
    # 단청 띠
    line(img,(cx-11,py+1),(cx,py+6.5),DANCH,1.6)
    line(img,(cx,py+6.5),(cx+11,py+1),shade(DANCH,1.15),1.6)
    # 기와 모임지붕 (기와골)
    ry = py2-4.5
    front=[(cx-15,ry),(cx,ry+7),(cx+15,ry),(cx+1.2,ry-10),(cx-1.2,ry-10)]
    giwa_roof(img,front,(cx-1.2,ry-10),(cx+1.2,ry-10),rows=4)
    # 홍등
    line(img,(cx+11,py2+1),(cx+11,py2+4),(74,52,32,255),0.7)
    ellipse(img,cx+11,py2+6,1.8,2.2,(200,70,40,255))
    ellipse(img,cx+10.4,py2+5.4,0.6,0.9,(255,160,80,255))
    return finish(img,W,H)
atower().save("atower.png"); print("atower")

# ---------- 총통탑 v2 (44x64) ----------
def ctower():
    W,H = 44,64; cx,cy = 22,54
    img = canvas(W,H)
    ellipse(img,cx,cy+1,15,7,(0,0,0,80))
    z=28; bw,tw=14,9.5
    s=(cx,cy+7); e=(cx+bw,cy); w=(cx-bw,cy)
    sT=(cx,cy+4.8-z); eT=(cx+tw,cy-z); wT=(cx-tw,cy-z); nT=(cx,cy-4.8-z)
    poly(img,[w,s,sT,wT],shade(GRANITE,0.62))
    poly(img,[s,e,eT,sT],shade(GRANITE,0.84))
    poly(img,[nT,eT,sT,wT],GRANITE)
    rng=np.random.default_rng(11)
    for k in range(5):
        t=(k+1)/6.0
        line(img,(cx-bw+(bw-tw)*t,cy-z*t),(cx,cy+7-2.2*t-z*t),(118,114,102,190),0.6)
        line(img,(cx,cy+7-2.2*t-z*t),(cx+bw-(bw-tw)*t,cy-z*t),(146,142,128,190),0.6)
    for k in range(6):
        t=k/6.0+0.08
        xx = cx+2+ (bw-3)*(1-t)*0.8
        line(img,(cx+1+(bw-2.5)*(1-t*0.9)*0.85, cy+3.5-z*t),(cx+1+(bw-2.5)*(1-t*0.9)*0.85, cy-2+3.5-z*t),(150,146,132,160),0.5)
    # 총안 2개
    for oy,ox in ((-12,5),(-20,3.5)):
        poly(img,[(cx+ox,cy+oy),(cx+ox+3,cy+oy-1.5),(cx+ox+3,cy+oy-5),(cx+ox,cy+oy-3.5)],(24,20,16,255))
    ty=cy-z
    for off in (-6.5,0,6.5):
        prism(img,cx+off,ty,2.8,1.4,4.5,(192,188,174,255))
    # 천자총통 (포가 포함)
    poly(img,[(cx-2,ty+1),(cx+4,ty+4),(cx+4,ty+6),(cx-2,ty+3)],(90,64,40,255))
    line(img,(cx,ty-2.5),(cx+12,ty+3),(30,30,36,255),3.2)
    line(img,(cx+3,ty-1),(cx+5,ty),(190,160,60,255),3.4)
    line(img,(cx+8,ty+1.3),(cx+9.5,ty+2),(190,160,60,255),3.2)
    ellipse(img,cx+12,ty+3,1.8,1.4,(14,14,16,255))
    banner(img,cx-11,ty+6,14,(170,40,34,255))
    return finish(img,W,H)
ctower().save("ctower.png"); print("ctower")

# ---------- 훈련소 v2 ----------
def barracks():
    W,H = 48,52; cx,cy = 24,42
    img = canvas(W,H)
    ellipse(img,cx,cy+1,17,8,(0,0,0,75))
    ellipse(img,cx,cy,15,7.5,(122,98,62,170))
    apex=(cx,cy-23)
    poly(img,[(cx-13,cy-1),(cx-6.5,cy+5.5),(cx+6.5,cy+5.5),(cx+13,cy-1),apex],(220,206,178,255))
    poly(img,[(cx-13,cy-1),(cx-6.5,cy+5.5),(cx,cy+5.7),apex],(182,168,142,255))
    # 천 재봉선 + 하단 청색 띠 (임진록풍)
    for dx in (-13,-6.5,6.5,13):
        y0 = cy-1 if abs(dx)>7 else cy+5.5
        line(img,(cx+dx,y0),apex,(160,142,112,255),0.7)
    for pth,cl in [([(cx-13,cy-1),(cx-6.5,cy+5.5),(cx+6.5,cy+5.5),(cx+13,cy-1)],(50,90,150,255))]:
        prev=None
        for p_ in pth:
            if prev: line(img,prev,p_,cl,1.6)
            prev=p_
    poly(img,[(cx-4.5,cy-15),(cx+4.5,cy-15),apex],(160,44,36,255))
    ellipse(img,cx,cy-23,1.1,1.1,(190,160,60,255))
    poly(img,[(cx-2.8,cy+5.5),(cx+2.8,cy+5.5),(cx,cy-4.5)],(52,36,22,255))
    # 무기 거치대
    line(img,(cx-12,cy+3),(cx-7,cy+6),(WOOD),1)
    for k in range(3):
        line(img,(cx-11+k*1.8,cy+3.5+k*0.8),(cx-9+k*1.8,cy-3+k*0.8),(150,150,160,255),0.7)
    banner(img,cx+14,cy-1,26,(40,80,160,255))
    return finish(img,W,H)
barracks().save("barracks.png"); print("barracks")
print("GEN3 DONE")
