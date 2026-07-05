#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$ROOT_DIR/KAIR-master"

python main_train_psnr.py \
  --opt ../configs/swinir_autodl/train_swinir_sr_classical_x2_single_gpu.json
