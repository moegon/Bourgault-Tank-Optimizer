#!/usr/bin/env bash
# Simple icon generation using ImageMagick and png2icns /icotool if available.
set -e
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT_DIR/assets"
mkdir -p "$ASSETS"
SVG="$ASSETS/icon.svg"
if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  echo "ImageMagick not found. Please install 'magick' or 'convert' to generate icons." >&2
  exit 0
fi
IM=magick
if ! command -v magick >/dev/null 2>&1; then
  IM=convert
fi
# Generate PNG sizes
sizes=(16 32 48 64 128 256 512 1024)
for s in "${sizes[@]}"; do
  $IM convert "$SVG" -resize ${s}x${s} "$ASSETS/icon-${s}.png"
done
# Copy a 512 -> icon.png for linux
cp "$ASSETS/icon-512.png" "$ASSETS/icon.png" || true
# Generate icns if iconutil available (mac)
if command -v iconutil >/dev/null 2>&1; then
  TMPDIR=$(mktemp -d)
  mkdir -p "$TMPDIR/icon.iconset"
  for s in 16 32 64 128 256 512; do
    cp "$ASSETS/icon-${s}.png" "$TMPDIR/icon.iconset/icon_${s}x${s}.png"
    cp "$ASSETS/icon-${s}.png" "$TMPDIR/icon.iconset/icon_${s}x${s}@2x.png" 2>/dev/null || true
  done
  iconutil -c icns "$TMPDIR/icon.iconset" -o "$ASSETS/icon.icns" || true
  rm -rf "$TMPDIR"
fi
# Generate .ico if convert supports it
if command -v $IM >/dev/null 2>&1; then
  $IM convert "$ASSETS/icon-16.png" "$ASSETS/icon-32.png" "$ASSETS/icon-48.png" "$ASSETS/icon-256.png" "$ASSETS/icon.ico" || true
fi

echo "Icons generated into $ASSETS (if ImageMagick available)."
