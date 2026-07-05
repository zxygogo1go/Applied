#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

MODEL_PATH="${1:-}"
FOLDER_LQ="${2:-testsets/remote/LR_bicubic/X4}"
FOLDER_GT="${3:-testsets/remote/HR}"

if [ -z "$MODEL_PATH" ] || [ ! -f "$MODEL_PATH" ]; then
  echo "Usage: $0 <model_path> [folder_lq] [folder_gt]" >&2
  echo "Example: $0 KAIR-master/superresolution/rs_swinir_lightweight_x4/models/100000_G.pth" >&2
  exit 1
fi

cd "$ROOT_DIR"

python main_test_swinir.py \
  --task lightweight_sr \
  --scale 4 \
  --model_path "$MODEL_PATH" \
  --folder_lq "$FOLDER_LQ" \
  --folder_gt "$FOLDER_GT" \
  --rs_module \
  --tile 400
