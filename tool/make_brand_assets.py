"""Builds the app's brand images from the master logo.

    python tool/make_brand_assets.py path/to/logo.jpg

Writes to assets/brand/:
  logo_full.png        whole logo with the "AL NOOR QURAN" wordmark (splash, onboarding)
  logo_mark.png        emblem only, filling most of the square (iOS / legacy Android icon)
  icon_foreground.png  emblem inside the adaptive-icon safe zone (Android 8+, Android 12 splash)

and store/play_store_icon_512.png for the Play Console listing.

Then run: dart run flutter_launcher_icons && dart run flutter_native_splash:create
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "brand"
SIZE = 1024
# Emblem (crescent, النور, Quran on its stand) without the wordmark, in master pixels.
EMBLEM_BOX = (130, 60, 890, 820)


def edge_colour(master: Image.Image) -> tuple:
    """Median colour along the emblem crop's border, i.e. the logo's background."""
    emblem = master.crop(EMBLEM_BOX)
    w, h = emblem.size
    px = [emblem.getpixel((x, y)) for x in range(0, w, 4) for y in (2, h - 3)]
    px += [emblem.getpixel((x, y)) for y in range(0, h, 4) for x in (2, w - 3)]
    return tuple(sorted(c[i] for c in px)[len(px) // 2] for i in range(3))


def backdrop(master: Image.Image) -> Image.Image:
    """Logo background colour with a faint centre glow, to extend the canvas seamlessly."""
    base = edge_colour(master)
    lift = tuple(min(255, round(c * 1.35) + 4) for c in base)
    glow = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(glow).ellipse((SIZE * 0.2, SIZE * 0.2, SIZE * 0.8, SIZE * 0.8), fill=255)
    glow = glow.filter(ImageFilter.GaussianBlur(170))
    return Image.composite(Image.new("RGB", (SIZE, SIZE), lift), Image.new("RGB", (SIZE, SIZE), base), glow)


def placed(master: Image.Image, fill: float) -> Image.Image:
    """Emblem scaled to `fill` of the canvas width, blended onto the backdrop."""
    emblem = master.crop(EMBLEM_BOX)
    side = round(SIZE * fill)
    emblem = emblem.resize((side, side), Image.LANCZOS)
    mask = Image.new("L", (side, side), 0)
    # The crop's straight edges must fade out completely or a square seam shows.
    ImageDraw.Draw(mask).ellipse((0, 0, side - 1, side - 1), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(side * 0.025))
    canvas = backdrop(master)
    offset = ((SIZE - side) // 2, (SIZE - side) // 2)
    canvas.paste(emblem, offset, mask)
    return canvas


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    master = Image.open(sys.argv[1]).convert("RGB")
    if master.size != (SIZE, SIZE):
        master = master.resize((SIZE, SIZE), Image.LANCZOS)
    OUT.mkdir(parents=True, exist_ok=True)
    save = dict(optimize=True)
    master.save(OUT / "logo_full.png", **save)
    placed(master, 0.92).save(OUT / "logo_mark.png", **save)
    # Android masks the adaptive icon to a 66dp circle of the 108dp layer; keep the emblem inside it.
    placed(master, 0.64).save(OUT / "icon_foreground.png", **save)
    store = OUT.parent.parent / "store"
    store.mkdir(exist_ok=True)
    placed(master, 0.92).resize((512, 512), Image.LANCZOS).save(store / "play_store_icon_512.png", **save)
    print("Wrote", ", ".join(p.name for p in sorted(OUT.glob("*.png"))))


if __name__ == "__main__":
    main()
