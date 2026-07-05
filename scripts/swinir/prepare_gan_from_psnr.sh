#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 path/to/psnr_checkpoint_G.pth"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_CKPT="$1"
GAN_MODEL_DIR="$ROOT_DIR/KAIR-master/superresolution/swinir_sr_realworld_x4_gan_autodl_1gpu/models"

mkdir -p "$GAN_MODEL_DIR"
cp "$SRC_CKPT" "$GAN_MODEL_DIR/0_G.pth"

echo "Prepared GAN initialization checkpoint:"
echo "$GAN_MODEL_DIR/0_G.pth"
