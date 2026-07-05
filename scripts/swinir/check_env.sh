#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$ROOT_DIR/KAIR-master"

python - <<'PY'
import importlib.util
import torch

mods = ["cv2", "numpy", "requests", "timm", "torchvision", "skimage", "PIL"]
print("python environment check")
print("torch:", torch.__version__)
print("cuda:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("gpu:", torch.cuda.get_device_name(0))

for mod in mods:
    status = "OK" if importlib.util.find_spec(mod) else "MISSING"
    print(f"{mod}: {status}")
PY
