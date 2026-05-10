#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/Users/carlosrodriguezsilva/Desktop/Desarrollos/PolyMem-Circular"
HTML_FILE="$PROJECT_DIR/index.html"
FILE_URL="file://$HTML_FILE"
OUT_DIR="$PROJECT_DIR/exports"
PDF_OUT="$OUT_DIR/polymem-circular.pdf"
IMG_DIR="$OUT_DIR/slide-images"
mkdir -p "$OUT_DIR" "$IMG_DIR"
rm -f "$IMG_DIR"/slide-*.png

CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME_BIN" ]; then
  CHROME_BIN="/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
fi

COUNT=$(python3 - "$HTML_FILE" <<'PY'
import re, sys
html = open(sys.argv[1], encoding="utf-8").read()
sections = re.findall(r'<section class="slide[^"]*"[^>]*>', html)
print(sum('data-skip="1"' not in s for s in sections))
PY
)

"$CHROME_BIN" \
  --headless \
  --no-sandbox \
  --disable-gpu \
  --print-to-pdf="$PDF_OUT" \
  "$FILE_URL?hidectrls=1"

echo "PDF generado: $PDF_OUT"

for i in $(seq 1 "$COUNT"); do
  printf -v idx "%02d" "$i"
  "$CHROME_BIN" \
    --headless \
    --no-sandbox \
    --disable-gpu \
    --force-device-scale-factor=2 \
    --window-size=1920,1080 \
    --screenshot="$IMG_DIR/slide-${idx}.png" \
    "$FILE_URL?slide=$i&hidectrls=1"
done

echo "Fotos por slide en: $IMG_DIR"

python3 - "$IMG_DIR" "$PDF_OUT" <<'PY'
from pathlib import Path
import sys
from PIL import Image

img_dir = Path(sys.argv[1])
pdf_out = Path(sys.argv[2])
pages = []
for path in sorted(img_dir.glob("slide-*.png")):
    image = Image.open(path).convert("RGB")
    pages.append(image)

if not pages:
    raise SystemExit("No slide images found for PDF export")

pages[0].save(pdf_out, save_all=True, append_images=pages[1:], resolution=144)
print(f"PDF 16:9 generado desde capturas: {pdf_out}")
PY
