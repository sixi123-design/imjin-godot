# 유닛 스프라이트 (오른쪽 바라봄, 발밑 앵커, 그림자 포함)
import sys; sys.path.insert(0,'.')
from lib import *

def base_man(img, cx, cy, body, r=3.6, skin=(230,195,154,255)):
    ellipse(img,cx,cy,5,1.9,(0,0,0,80))
    # 다리
    line(img,(cx-1.4,cy-0.3),(cx-1.6,cy-3.5),(52,42,32,255),1.3)
    line(img,(cx+1.4,cy-0.3),(cx+1.8,cy-3.5),(52,42,32,255),1.3)
    # 몸통
    ellipse(img,cx,cy-6.5,r,r+0.4,body)
    ellipse(img,cx-r*0.35,cy-7.2,r*0.5,r*0.55,shade(body,1.18))
    # 머리
    ellipse(img,cx,cy-11.8,2.6,2.6,skin)

def jeonrip(img,cx,cy):  # 조선 전립
    ellipse(img,cx,cy-13.2,4.0,1.2,(38,34,28,255))
    ellipse(img,cx,cy-13.8,2.0,1.5,(38,34,28,255))
    ellipse(img,cx+1.2,cy-14.3,0.6,0.6,(190,60,50,255))  # 상모

def worker():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(232,226,210,255))
    line(img,(cx-2.4,cy-12.6),(cx+2.4,cy-12.6),(90,70,50,255),1.1)  # 머릿수건
    ellipse(img,cx,cy-14,1.2,1.0,(60,48,36,255))  # 상투
    return finish(img,W,H)
worker().save("u_worker.png")

def archer():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(47,140,152,255))
    jeonrip(img,cx,cy)
    # 활 (오른손)
    d=ImageDraw.Draw(img)
    d.arc([ (cx+3.2)*SS,(cy-12.5)*SS,(cx+7.8)*SS,(cy-3.5)*SS ], -65, 65, fill=(124,83,38,255), width=int(1.2*SS))
    line(img,(cx+5.6,cy-11.7),(cx+5.6,cy-4.2),(216,208,184,255),0.6)
    # 화살통
    poly(img,[(cx-3.6,cy-9),(cx-1.8,cy-9.8),(cx-1.4,cy-5.4),(cx-3.2,cy-4.6)],(112,78,42,255))
    line(img,(cx-3.0,cy-9.6),(cx-2.6,cy-11),(150,150,160,255),0.7)
    line(img,(cx-2.2,cy-9.9),(cx-1.9,cy-11.3),(150,150,160,255),0.7)
    return finish(img,W,H)
archer().save("u_archer.png")

def spear():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(63,111,208,255))
    jeonrip(img,cx,cy)
    line(img,(cx+3.2,cy-1.5),(cx+6.8,cy-15.5),(138,106,68,255),1.1)
    poly(img,[(cx+6.8,cy-15.5),(cx+8.4,cy-18.6),(cx+5.6,cy-16.8)],(200,204,212,255))
    # 방패
    ellipse(img,cx-3.4,cy-6.5,1.9,2.6,(150,116,72,255))
    ellipse(img,cx-3.4,cy-6.5,1.0,1.5,(190,160,60,255))
    return finish(img,W,H)
spear().save("u_spear.png")

def ashi():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(176,64,46,255))
    # 진가사(삿갓)
    poly(img,[(cx-4.6,cy-12.2),(cx,cy-16),(cx+4.6,cy-12.2)],(201,168,84,255))
    line(img,(cx-4.6,cy-12.2),(cx+4.6,cy-12.2),(160,130,60,255),0.8)
    line(img,(cx+3.0,cy-1.5),(cx+6.4,cy-15),(107,74,38,255),1.0)
    poly(img,[(cx+6.4,cy-15),(cx+7.6,cy-17.6),(cx+5.4,cy-16)],(200,204,212,255))
    return finish(img,W,H)
ashi().save("u_ashi.png")

def gun():
    W,H=16,20; cx,cy=8,18
    img=canvas(W,H)
    base_man(img,cx,cy,(124,74,148,255))
    ellipse(img,cx,cy-13,2.8,1.4,(42,34,38,255))  # 진립
    # 조총 (수평)
    line(img,(cx-2.5,cy-6),(cx+7.5,cy-7.6),(74,58,42,255),1.6)
    line(img,(cx+4,cy-7),(cx+8.6,cy-7.9),(38,38,44,255),1.0)
    ellipse(img,cx+1.5,cy-6.3,0.9,0.9,(60,48,36,255))
    return finish(img,W,H)
gun().save("u_gun.png")

def sam():
    W,H=20,24; cx,cy=10,22
    img=canvas(W,H)
    ellipse(img,cx,cy,6.2,2.3,(0,0,0,90))
    line(img,(cx-1.8,cy-0.3),(cx-2.1,cy-4),(40,32,26,255),1.7)
    line(img,(cx+1.8,cy-0.3),(cx+2.2,cy-4),(40,32,26,255),1.7)
    # 갑주 몸통 (오도시 가로줄)
    ellipse(img,cx,cy-8,4.8,5.0,(110,20,20,255))
    for k in range(3):
        line(img,(cx-4.2,cy-6.2-k*1.8),(cx+4.2,cy-6.2-k*1.8),(150,32,28,255),0.7)
    # 어깨 소데
    poly(img,[(cx-6.6,cy-11),(cx-3.8,cy-11.6),(cx-3.6,cy-7),(cx-6.2,cy-6.6)],(138,26,26,255))
    poly(img,[(cx+3.8,cy-11.6),(cx+6.6,cy-11),(cx+6.2,cy-6.6),(cx+3.6,cy-7)],(138,26,26,255))
    ellipse(img,cx,cy-14.5,2.8,2.8,(230,195,154,255))
    # 카부토 + 금 마에다테
    ellipse(img,cx,cy-16,3.4,2.0,(28,26,32,255))
    ellipse(img,cx,cy-16.8,2.4,1.4,(28,26,32,255))
    d=ImageDraw.Draw(img)
    d.arc([(cx-2.6)*SS,(cy-20.5)*SS,(cx-0.2)*SS,(cy-16.5)*SS], 180, 330, fill=(212,167,44,255), width=int(0.8*SS))
    d.arc([(cx+0.2)*SS,(cy-20.5)*SS,(cx+2.6)*SS,(cy-16.5)*SS], 210, 360, fill=(212,167,44,255), width=int(0.8*SS))
    # 카타나
    line(img,(cx+3.5,cy-4),(cx+9.5,cy-12),(200,204,212,255),1.1)
    line(img,(cx+3.0,cy-3.2),(cx+4.6,cy-5.4),(90,60,30,255),1.4)
    return finish(img,W,H)
sam().save("u_sam.png")
print("UNITS DONE")
