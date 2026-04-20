from PIL import Image, ImageDraw
import math

SIZE = 1024
img = Image.new("RGB", (SIZE, SIZE), (20, 110, 50))
draw = ImageDraw.Draw(img)

cx, cy = SIZE // 2, SIZE // 2

# --- field lines background (subtle) ---
line_color = (18, 100, 45)
# center circle
for r in range(180, 185):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=line_color, width=2)
# center line
draw.rectangle([0, cy - 3, SIZE, cy + 3], fill=line_color)
# outer border
draw.rectangle([40, 40, SIZE - 40, SIZE - 40], outline=line_color, width=6)

# --- football ---
ball_cx, ball_cy = cx, cy - 20
ball_r = 310

# Shadow
shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.ellipse([ball_cx - ball_r + 18, ball_cy - ball_r + 18,
            ball_cx + ball_r + 18, ball_cy + ball_r + 18],
           fill=(0, 0, 0, 60))
img.paste(Image.alpha_composite(Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0)), shadow).convert("RGB"),
          mask=shadow.split()[3])

# White ball base
draw.ellipse([ball_cx - ball_r, ball_cy - ball_r,
              ball_cx + ball_r, ball_cy + ball_r],
             fill="white", outline=(30, 30, 30), width=10)

# --- pentagon pattern on ball ---
# Classic soccer ball: 1 central pentagon + 5 pentagons + 6 hexagons
# Simplified: draw the characteristic seam lines

def pt(cx, cy, r, angle_deg):
    a = math.radians(angle_deg - 90)
    return (cx + r * math.cos(a), cy + r * math.sin(a))

def draw_poly(draw, pts, fill, outline, width):
    draw.polygon(pts, fill=fill, outline=outline)
    for i in range(len(pts)):
        p1 = pts[i]
        p2 = pts[(i + 1) % len(pts)]
        draw.line([p1, p2], fill=outline, width=width)

seam = (30, 30, 30)
lw = 10

# Central pentagon (black)
pent_r = ball_r * 0.22
center_pent = [pt(ball_cx, ball_cy, pent_r, 72 * i) for i in range(5)]
draw_poly(draw, center_pent, seam, seam, lw)

# 5 outer pentagons
outer_r = ball_r * 0.62
inner_hex_r = ball_r * 0.44

for i in range(5):
    angle = 72 * i
    # center of outer pentagon
    ocx = ball_cx + outer_r * math.cos(math.radians(angle - 90))
    ocy = ball_cy + outer_r * math.sin(math.radians(angle - 90))
    pent_pts = [pt(ocx, ocy, ball_r * 0.20, 72 * j + angle) for j in range(5)]
    draw_poly(draw, pent_pts, seam, seam, lw)

# Clip to ball circle
mask = Image.new("L", (SIZE, SIZE), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.ellipse([ball_cx - ball_r, ball_cy - ball_r,
                   ball_cx + ball_r, ball_cy + ball_r], fill=255)

# Apply ball border again clean
draw.ellipse([ball_cx - ball_r, ball_cy - ball_r,
              ball_cx + ball_r, ball_cy + ball_r],
             outline=(20, 20, 20), width=12)

out_path = "FussballApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
img.save(out_path)
print(f"Icon saved: {out_path}  ({SIZE}x{SIZE})")
