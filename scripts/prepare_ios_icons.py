#!/usr/bin/env python3
"""Generate iOS AppIcon and SplashLogo assets for diyavape.shop."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SRC = ROOT / "assets" / "icons" / "icon-source.png"
ASSETS = ROOT / "DiyaVape" / "Assets.xcassets"
THEME_PURPLE = (0x1A, 0x12, 0x30, 0xFF)

APP_ICON_SIZES = {
    "Icon-20@2x.png": 40,
    "Icon-20@3x.png": 60,
    "Icon-29@2x.png": 58,
    "Icon-29@3x.png": 87,
    "Icon-40@2x.png": 80,
    "Icon-40@3x.png": 120,
    "Icon-60@2x.png": 120,
    "Icon-60@3x.png": 180,
    "Icon-1024.png": 1024,
}

SPLASH_SIZES = {
    "splash-logo.png": 120,
    "splash-logo@2x.png": 240,
    "splash-logo@3x.png": 360,
}


def _load_source(path: Path) -> Image.Image:
    if not path.is_file():
        raise SystemExit(f"Missing source icon: {path}")
    image = Image.open(path).convert("RGBA")
    width, height = image.size
    if width != height:
        side = min(width, height)
        left = (width - side) // 2
        top = (height - side) // 2
        image = image.crop((left, top, left + side, top + side))
    return image


def _resize(image: Image.Image, size: int) -> Image.Image:
    return image.resize((size, size), Image.Resampling.LANCZOS)


def _composite_on_theme(source: Image.Image) -> Image.Image:
    base = Image.new("RGBA", source.size, THEME_PURPLE)
    base.paste(source, (0, 0), source)
    return base


def _write_png(path: Path, image: Image.Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)


def generate_icons(src: Path) -> None:
    source = _load_source(src)
    composited = _composite_on_theme(source)

    app_icon_dir = ASSETS / "AppIcon.appiconset"
    for filename, size in APP_ICON_SIZES.items():
        _write_png(app_icon_dir / filename, _resize(composited, size))
        print(f"[OK] AppIcon {filename} ({size}px)")

    splash_dir = ASSETS / "SplashLogo.imageset"
    for filename, size in SPLASH_SIZES.items():
        _write_png(splash_dir / filename, _resize(composited, size))
        print(f"[OK] SplashLogo {filename} ({size}px)")

    print(f"[OK] iOS assets -> {ASSETS.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", type=Path, default=DEFAULT_SRC)
    args = parser.parse_args()
    generate_icons(args.src)


if __name__ == "__main__":
    main()
