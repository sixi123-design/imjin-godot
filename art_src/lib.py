# 아이소메트릭 스프라이트 생성 라이브러리 (4x 슈퍼샘플 → LANCZOS 다운스케일)
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, random, math

SS = 8  # supersample (4x 출력 x 2x AA)
def canvas(w, h):
    return Image.new("RGBA", (w*SS, h*SS), (0,0,0,0))

def P(pts):  # scale points
    return [(x*SS, y*SS) for x, y in pts]

def poly(img, pts, fill, outline=None, ow=1):
    d = ImageDraw.Draw(img)
    d.polygon(P(pts), fill=fill, outline=outline, width=ow*SS if outline else 0)

def line(img, a, b, fill, w=1):
    d = ImageDraw.Draw(img)
    d.line([P([a])[0], P([b])[0]], fill=fill, width=max(1,int(w*SS)))

def ellipse(img, cx, cy, rx, ry, fill, outline=None, ow=1):
    d = ImageDraw.Draw(img)
    d.ellipse([(cx-rx)*SS, (cy-ry)*SS, (cx+rx)*SS, (cy+ry)*SS], fill=fill,
              outline=outline, width=ow*SS if outline else 0)

def noise_region(img, mask_col_fn, amount=14, seed=1):
    """알파>0인 픽셀에 미세한 명도 노이즈"""
    rng = np.random.default_rng(seed)
    a = np.array(img).astype(np.int16)
    mask = a[:,:,3] > 0
    n = rng.integers(-amount, amount+1, size=a.shape[:2])
    for ch in range(3):
        a[:,:,ch] = np.clip(a[:,:,ch] + n*mask, 0, 255)
    return Image.fromarray(a.astype(np.uint8))

def outline_sprite(img, col=(28,22,16,235)):
    a = np.array(img)
    alpha = a[:,:,3] > 40
    from scipy.ndimage import binary_dilation
    dil = binary_dilation(alpha, iterations=4)  # 출력 2px
    edge = dil & ~alpha
    a[edge] = col
    return Image.fromarray(a)

def finish(img, w, h, outline=True):
    if outline:
        try:
            img = outline_sprite(img)
        except ImportError:
            pass
    return img.resize((w*4, h*4), Image.LANCZOS)

def shade(col, f):
    return tuple(min(255,max(0,int(c*f))) for c in col[:3]) + (col[3] if len(col)>3 else 255,)

def prism(img, cx, cy, hw, hh, z, top, dark=0.62, mid=0.82):
    """아이소 프리즘: cy가 바닥 다이아몬드 중심"""
    n=(cx,cy-hh); s=(cx,cy+hh); e=(cx+hw,cy); w=(cx-hw,cy)
    up=lambda p:(p[0],p[1]-z)
    poly(img,[w,s,up(s),up(w)], shade(top,dark))
    poly(img,[s,e,up(e),up(s)], shade(top,mid))
    poly(img,[up(n),up(e),up(s),up(w)], top)
    return n,s,e,w

# ---- 조선 팔레트 ----
GIWA   =(62,68,76,255)     # 기와 짙은 회색
GIWA_L =(84,92,102,255)
RIDGE  =(212,208,196,255)  # 용마루 백색 회
PILLAR =(122,59,42,255)    # 석간주 기둥
WALLW  =(236,229,210,255)  # 회벽
WOOD   =(106,74,48,255)
DANCH  =(63,122,94,255)    # 뇌록 단청
GRANITE=(168,164,150,255)
THATCH =(201,168,84,255)   # 초가
