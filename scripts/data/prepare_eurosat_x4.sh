#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

DATA_DIR="${1:-$ROOT_DIR/data/raw/eurosat}"
ZIP_PATH="$DATA_DIR/EuroSAT_RGB.zip"
URL="https://zenodo.org/records/7711810/files/EuroSAT_RGB.zip?download=1"

mkdir -p "$DATA_DIR"
cd "$ROOT_DIR"

if [ ! -f "$ZIP_PATH" ]; then
  echo "Downloading EuroSAT RGB to $ZIP_PATH"
  curl -L "$URL" -o "$ZIP_PATH"
fi

if [ ! -d "$DATA_DIR/2750" ] && [ ! -d "$DATA_DIR/EuroSAT_RGB" ]; then
  echo "Extracting EuroSAT RGB"
  python -m zipfile -e "$ZIP_PATH" "$DATA_DIR"
fi

SOURCE_DIR=""
if [ -d "$DATA_DIR/2750" ]; then
  SOURCE_DIR="$DATA_DIR/2750"
elif [ -d "$DATA_DIR/EuroSAT_RGB" ]; then
  SOURCE_DIR="$DATA_DIR/EuroSAT_RGB"
else
  echo "Could not find extracted EuroSAT image folder under $DATA_DIR" >&2
  exit 1
fi

python scripts/data/prepare_sr_from_image_folder.py \
  --source "$SOURCE_DIR" \
  --train-hr KAIR-master/trainsets/remote/trainH \
  --test-hr testsets/remote/HR \
  --test-lr testsets/remote/LR_bicubic/X4 \
  --scale 4 \
  --test-ratio "${TEST_RATIO:-0.1}" \
  --seed "${SEED:-42}" \
  --limit "${LIMIT:-0}" \
  --min-size 32 \
  --clear-output
