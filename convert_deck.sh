#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/Users/carlosrodriguezsilva/Desktop/Desarrollos/PolyMem-Circular"
HTML_FILE="$PROJECT_DIR/index.html"
FILE_URL="file://$HTML_FILE"
OUT_DIR="$PROJECT_DIR/exports"
PDF_OUT="$OUT_DIR/polymem-circular.pdf"
IMG_DIR="$OUT_DIR/slide-images"
mkdir -p "$OUT_DIR" "$IMG_DIR"

CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME_BIN" ]; then
  CHROME_BIN="/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
fi

COUNT=$(rg -o 'class="slide' "$HTML_FILE" | wc -l | tr -d ' ')

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
