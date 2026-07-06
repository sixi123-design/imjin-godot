import sys; sys.path.insert(0,'.')
from lib import *

def giwa_roof(img, pts_front, ridge_a, ridge_b, base_col=GIWA, rows=6, msae=True):
    poly(img, pts_front, base_col)
    eave = pts_front[:len(pts_front)-2]
    n_e = len(eave)
    for r in range(1, rows):
        t = r / rows
        prev=None
        for i in range(n_e):
            ex,ey = eave[i]
            rx = ridge_a[0] + (ridge_b[0]-ridge_a[0]) * (i/(n_e-1))
            ry = ridge_a[1] + (ridge_b[1]-ridge_a[1]) * (i/(n_e-1))
            px = ex + (rx-ex)*t; py = ey + (ry-ey)*t - math.sin(t*math.pi)*1.2
            if prev: line(img, prev, (px,py), shade(base_col, 0.8 if r%2 else 1.14), 0.55)
            prev=(px,py)
    for i in range(n_e):
        ex,ey=eave[i]
        rx = ridge_a[0] + (ridge_b[0]-ridge_a[0]) * (i/(n_e-1))
        ry = ridge_a[1] + (ridge_b[1]-ridge_a[1]) * (i/(n_e-1))
        line(img,(ex,ey),(rx,ry),shade(base_col,0.72),0.5)
        if msae:
            ellipse(img,ex,ey,0.9,0.9,shade(base_col,1.35))
            ellipse(img,ex,ey,0.4,0.4,shade(base_col,0.7))
    line(img,ridge_a,ridge_b,RIDGE,2.0)
    ellipse(img,ridge_a[0],ridge_a[1],1.5,1.8,(84,92,102,255))
    ellipse(img,ridge_b[0],ridge_b[1],1.5,1.8,(84,92,102,255))

def banner(img, x, y, h, col=(40,80,160,255)):
    line(img,(x,y),(x,y-h),(74,52,32,255),1.1)
    ellipse(img,x,y-h,0.9,0.9,(190,160,60,255))
    poly(img,[(x,y-h+0.5),(x+7.5,y-h+2),(x+5,y-h+4.7),(x+7.5,y-h+7.5),(x,y-h+8.5)],col)

# ---- 기와집 ----
def house2():
    W,H=48,44; cx,cy=24,36
    img=canvas(W,H)
    ellipse(img,cx,cy+1,17,8,(0,0,0,75))
    prism(img,cx,cy,13.5,6.8,3,(160,156,144,255))  # 낮은 석축
    by=cy-3; z=11
    prism(img,cx,by,12.5,6.3,z,WALLW,dark=0.75,mid=0.93)
    for dx,dy in [(-12.5,0),(-6,3.1),(0,6.3),(6,3.1),(12.5,0)]:
        line(img,(cx+dx,by+dy),(cx+dx,by+dy-z),WOOD,1.1)
    poly(img,[(cx+5,by+3.4),(cx+9.5,by+1.1),(cx+9.5,by-5.7),(cx+5,by-3.4)],(74,46,26,255))
    line(img,(cx+7.2,by+2.3),(cx+7.2,by-4.5),(150,116,72,255),0.5)
    poly(img,[(cx-10.5,by+1),(cx-7,by+2.8),(cx-7,by-1.8),(cx-10.5,by-3.6)],(226,216,192,255))
    ty=by-z
    line(img,(cx-12.5,ty+0.5),(cx,ty+6.8),DANCH,1.6)
    line(img,(cx,ty+6.8),(cx+12.5,ty+0.5),shade(DANCH,1.15),1.6)
    ev=ty-0.5
    front=[(cx-18,ev+1),(cx-11,ev+7),(cx,ev+10),(cx+11,ev+7),(cx+18,ev+1),(cx+7,ev-9),(cx-7,ev-9)]
    giwa_roof(img,front,(cx-7,ev-9),(cx+7,ev-9),rows=5)
    return finish(img,W,H)
house2().save("house2.png")

# ---- 논 (물댄 농지) ----
def farm2():
    W,H=32,18; cx,cy=16,9
    img=canvas(W,H)
    poly(img,[(cx,cy-7.5),(cx+15,cy),(cx,cy+7.5),(cx-15,cy)],(72,102,118,255))
    poly(img,[(cx,cy-6.6),(cx+13.6,cy),(cx,cy+6.6),(cx-13.6,cy)],(88,124,138,255))
    # 물 반짝
    rng=np.random.default_rng(3)
    for i in range(10):
        x=rng.uniform(-11,11); y=rng.uniform(-5,5)
        if abs(x)/13.6+abs(y)/6.6>0.9: continue
        line(img,(cx+x,cy+y),(cx+x+1.6,cy+y-0.5),(200,224,232,190),0.5)
    # 모 줄
    for k in range(4):
        t=(k+0.9)/4.8
        x0,y0=cx-13.6*(1-t), cy+6.6*t
        x1,y1=cx+13.6*t, cy-6.6*(1-t)
        for m in range(6):
            u=m/5.0*0.8+0.1
            gx=x0+(x1-x0)*u; gy=y0+(y1-y0)*u
            line(img,(gx,gy),(gx-0.9,gy-2.3),(96,160,72,255),0.55)
            line(img,(gx,gy),(gx+0.9,gy-2.3),(88,148,64,255),0.55)
    # 논둑
    prev=None
    for p in [(cx,cy-7.5),(cx+15,cy),(cx,cy+7.5),(cx-15,cy),(cx,cy-7.5)]:
        if prev: line(img,prev,p,(122,96,58,255),1.2)
        prev=p
    return finish(img,32,18,outline=False)
farm2().save("farm2.png")

# ---- 수성 망루 (석축+기와 2층) ----
def atower2():
    W,H=44,66; cx,cy=22,56
    img=canvas(W,H)
    ellipse(img,cx,cy+1,15,7,(0,0,0,80))
    prism(img,cx,cy,13,6.5,12,GRANITE)   # 높은 석축
    for k in (0.4,0.75):
        line(img,(cx-13,cy-12*k),(cx,cy+6.5-12*k),(120,116,104,190),0.6)
        line(img,(cx,cy+6.5-12*k),(cx+13,cy-12*k),(146,142,128,190),0.6)
    by=cy-12; z=13
    prism(img,cx,by,10,5,z,WALLW,dark=0.76,mid=0.93)
    for t in (0.1,0.5,0.9):
        x0=cx+t*10; y0=by+5*(1-t)
        line(img,(x0,y0),(x0,y0-z),PILLAR,1.4)
        x1=cx-10+t*10; y1=by+t*5
        line(img,(x1,y1),(x1,y1-z),shade(PILLAR,0.8),1.4)
    # 전안(화살창)
    poly(img,[(cx+3,by-3),(cx+6,by-4.5),(cx+6,by-8.5),(cx+3,by-7)],(40,30,20,255))
    ty=by-z
    line(img,(cx-10,ty+0.5),(cx,ty+5.5),DANCH,1.7)
    line(img,(cx,ty+5.5),(cx+10,ty+0.5),shade(DANCH,1.15),1.7)
    ev=ty-0.5
    front=[(cx-15,ev),(cx-9,ev+5),(cx,ev+7.5),(cx+9,ev+5),(cx+15,ev),(cx+1.5,ev-10),(cx-1.5,ev-10)]
    giwa_roof(img,front,(cx-1.5,ev-10),(cx+1.5,ev-10),rows=4)
    banner(img,cx+14,cy-14,16)
    return finish(img,W,H)
atower2().save("atower2.png")

# ---- 훈련도감 (관아) ----
def barracks2():
    W,H=48,50; cx,cy=24,40
    img=canvas(W,H)
    ellipse(img,cx,cy+1,17,8,(0,0,0,75))
    prism(img,cx,cy,14,7,4,(160,156,144,255))
    by=cy-4; z=12
    prism(img,cx,by,13,6.5,z,WALLW,dark=0.75,mid=0.93)
    for t in (0.06,0.5,0.94):
        x0=cx+t*13; y0=by+6.5*(1-t)
        line(img,(x0,y0),(x0,y0-z),PILLAR,1.5)
        x1=cx-13+t*13; y1=by+t*6.5
        line(img,(x1,y1),(x1,y1-z),shade(PILLAR,0.8),1.5)
    poly(img,[(cx+4.5,by+4),(cx+9.5,by+1.5),(cx+9.5,by-5.5),(cx+4.5,by-3)],(64,42,24,255))
    ty=by-z
    line(img,(cx-13,ty+0.5),(cx,ty+7),DANCH,1.9)
    line(img,(cx,ty+7),(cx+13,ty+0.5),shade(DANCH,1.15),1.9)
    ev=ty-0.5
    front=[(cx-19,ev+1),(cx-11,ev+7),(cx,ev+10.5),(cx+11,ev+7),(cx+19,ev+1),(cx+8,ev-9),(cx-8,ev-9)]
    giwa_roof(img,front,(cx-8,ev-9),(cx+8,ev-9),rows=5)
    # 병기 거치대 + 쌍기
    line(img,(cx-13,cy+3),(cx-7,cy+6.5),WOOD,1)
    for k in range(4):
        line(img,(cx-12+k*1.6,cy+3.5+k*0.8),(cx-10+k*1.6,cy-3.5+k*0.8),(150,150,160,255),0.7)
    banner(img,cx+15,cy-2,24,(40,80,160,255))
    banner(img,cx+18.5,cy+2,20,(170,40,34,255))
    return finish(img,W,H)
barracks2().save("barracks2.png")

# ---- 편전수 ----
def base_man(img, cx, cy, body, r=3.6, skin=(230,195,154,255)):
    ellipse(img,cx,cy,5,1.9,(0,0,0,80))
    line(img,(cx-1.4,cy-0.3),(cx-1.6,cy-3.5),(52,42,32,255),1.3)
    line(img,(cx+1.4,cy-0.3),(cx+1.8,cy-3.5),(52,42,32,255),1.3)
    ellipse(img,cx,cy-6.5,r,r+0.4,body)
    ellipse(img,cx-r*0.35,cy-7.2,r*0.5,r*0.55,shade(body,1.18))
    ellipse(img,cx,cy-11.8,2.6,2.6,skin)

def jeonrip(img,cx,cy,col=(38,34,28,255)):
    ellipse(img,cx,cy-13.2,4.0,1.2,col)
    ellipse(img,cx,cy-13.8,2.0,1.5,col)
    ellipse(img,cx+1.2,cy-14.3,0.6,0.6,(190,60,50,255))

def archer2():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(26,96,108,255))
    # 홍색 소매띠
    line(img,(cx-3.4,cy-6),(cx+3.4,cy-6),(170,40,34,255),0.9)
    jeonrip(img,cx,cy,(50,40,28,255))
    d=ImageDraw.Draw(img)
    d.arc([ (cx+3.0)*SS,(cy-13)*SS,(cx+8.2)*SS,(cy-3)*SS ], -70, 70, fill=(94,60,26,255), width=int(1.3*SS))
    line(img,(cx+5.8,cy-12.3),(cx+5.8,cy-3.7),(216,208,184,255),0.6)
    # 통아(화살대롱) + 깃털 3
    poly(img,[(cx-3.8,cy-9.4),(cx-1.6,cy-10.2),(cx-1.2,cy-5.2),(cx-3.4,cy-4.4)],(90,60,32,255))
    for k in range(3):
        line(img,(cx-3.2+k*0.9,cy-9.8),(cx-2.9+k*0.9,cy-11.6),(200,60,50,255) if k==1 else (150,150,160,255),0.7)
    return finish(img,W,H)
archer2().save("u_archer2.png")

def spear2():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(36,58,120,255),r=4.0)
    # 두정갑 리벳
    rng=np.random.default_rng(5)
    for yy in (-5,-6.8,-8.6):
        for xx in (-2.4,-0.8,0.8,2.4):
            ellipse(img,cx+xx,cy+yy,0.35,0.35,(200,170,80,255))
    # 어깨 방호
    poly(img,[(cx-5.8,cy-9.6),(cx-3.4,cy-10.4),(cx-3.2,cy-6.4),(cx-5.4,cy-5.8)],(52,76,140,255))
    poly(img,[(cx+3.4,cy-10.4),(cx+5.8,cy-9.6),(cx+5.4,cy-5.8),(cx+3.2,cy-6.4)],(52,76,140,255))
    # 첨주(투구)
    ellipse(img,cx,cy-13.4,3.0,2.2,(60,60,70,255))
    line(img,(cx,cy-15.4),(cx,cy-17),(60,60,70,255),1.0)
    ellipse(img,cx,cy-17.2,0.7,0.7,(200,60,50,255))
    # 장창
    line(img,(cx+3.4,cy-1),(cx+7.2,cy-16.5),(120,90,56,255),1.2)
    poly(img,[(cx+7.2,cy-16.5),(cx+9,cy-19.8),(cx+5.9,cy-17.9)],(210,214,222,255))
    line(img,(cx+6.9,cy-15.8),(cx+7.9,cy-16.6),(170,40,34,255),0.8)
    return finish(img,W,H)
spear2().save("u_spear2.png")
print("GEN4 DONE")
