# RS-SwinIR Lightweight Remote-Sensing SR

This branch adds a lightweight remote-sensing variant on top of SwinIR-S. It avoids large diffusion models and API calls. The main change is an optional Spectral-Spatial Frequency Refinement block after SwinIR reconstruction, plus edge and spectral-angle training losses.

## What Changed

- `RemoteSensingRefinement` in `models/network_swinir.py` and `KAIR-master/models/network_swinir.py`
  - Upsamples the LR reference to the SR size.
  - Separates low-frequency and high-frequency components with average pooling.
  - Applies a gated residual correction to preserve remote-sensing edges and color/spectral consistency.
- `EdgeLoss` and `SAMLoss` in `KAIR-master/models/loss.py`
  - `EdgeLoss` uses Sobel gradients.
  - `SAMLoss` minimizes spectral angle between output and GT channels.
- `ModelPlain` logs `G_main_loss`, `G_edge_loss`, `G_sam_loss`, and total `G_loss`.

## Data Layout

Default x4 training config:

```text
SwinIR-main/KAIR-master/trainsets/remote/trainH
SwinIR-main/testsets/remote/HR
SwinIR-main/testsets/remote/LR_bicubic/X4
```

For training, `dataroot_L` is `null`, so KAIR generates bicubic LR patches online from HR images. If you have paired LR/HR remote-sensing data, set `dataroot_L` in `configs/swinir_autodl/train_rs_swinir_lightweight_x4_single_gpu.json`.

## Train

```bash
cd SwinIR-main
bash scripts/swinir/train_rs_lightweight_x4_single_gpu.sh
```

The config is:

```text
configs/swinir_autodl/train_rs_swinir_lightweight_x4_single_gpu.json
```

Useful knobs:

- `rs_module_scale`: residual strength of the refinement block, default `0.1`
- `rs_module_hidden`: hidden channels, default `16`
- `G_edge_loss_weight`: default `0.05`
- `G_sam_loss_weight`: default `0.1`

## Test

```bash
cd SwinIR-main
bash scripts/swinir/test_rs_lightweight_x4.sh \
  KAIR-master/superresolution/rs_swinir_lightweight_x4/models/100000_G.pth \
  testsets/remote/LR_bicubic/X4 \
  testsets/remote/HR
```

The script enables `--rs_module`. Use a checkpoint trained with the same module enabled.

## Suggested Ablations

Use the same data split and training schedule:

- SwinIR-S baseline
- SwinIR-S + EdgeLoss
- SwinIR-S + EdgeLoss + SAMLoss
- RS-SwinIR-S with refinement block only
- RS-SwinIR-S with refinement block + EdgeLoss + SAMLoss

For a paper, report PSNR, SSIM, SAM, ERGAS, and visual crops around roads, buildings, farmland boundaries, and small high-contrast structures.
