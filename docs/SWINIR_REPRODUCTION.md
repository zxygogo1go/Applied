# SwinIR Reproduction Notes

## Goal

First reproduce SwinIR behavior with official code and known settings. Do not start model innovation until these checks pass:

1. Official pretrained inference runs.
2. KAIR training starts and saves checkpoints.
3. Validation images are produced under the expected experiment folder.
4. A baseline PSNR/log record exists for comparison.

## Environment On AutoDL

Use an AutoDL image with PyTorch and CUDA already installed. Then install KAIR extras:

```bash
cd KAIR-master
pip install -r requirement.txt
```

Check the environment:

```bash
bash ../scripts/swinir/check_env.sh
```

## Stage 1: Pretrained Inference Smoke Test

Run from the project root:

```bash
bash scripts/swinir/test_official_real_sr.sh
```

This uses the compact official `main_test_swinir.py` and downloads the official real-world x4 SwinIR weight into `model_zoo/swinir/` if needed.

Output:

```text
results/swinir_real_sr_x4/
```

## Stage 2: KAIR Classical SR Training Smoke Test

Prepare HR training images:

```bash
mkdir -p KAIR-master/trainsets/trainH
```

Put DIV2K/Flickr2K HR images, or a small private smoke-test subset, into `KAIR-master/trainsets/trainH`.

Run:

```bash
bash scripts/swinir/train_classical_x2_single_gpu.sh
```

This uses:

```text
configs/swinir_autodl/train_swinir_sr_classical_x2_single_gpu.json
```

Output:

```text
KAIR-master/superresolution/swinir_sr_classical_x2_autodl_1gpu/
```

## Stage 3: Real-World SR PSNR Training

Prepare HR training images in the same folder:

```text
KAIR-master/trainsets/trainH
```

Run:

```bash
bash scripts/swinir/train_realworld_x4_psnr_single_gpu.sh
```

This uses BSRGAN-style on-the-fly degradation from `dataset_blindsr.py`.

Output:

```text
KAIR-master/superresolution/swinir_sr_realworld_x4_psnr_autodl_1gpu/
```

## Stage 4: Real-World SR GAN Training

GAN training should start from a PSNR-oriented generator checkpoint. KAIR's training entry auto-resumes from the current task output folder, so copy a PSNR checkpoint into the GAN task's `models/` folder using a name like `0_G.pth`.

Example:

```bash
bash scripts/swinir/prepare_gan_from_psnr.sh \
  KAIR-master/superresolution/swinir_sr_realworld_x4_psnr_autodl_1gpu/models/5000_G.pth
```

Then run:

```bash
bash scripts/swinir/train_realworld_x4_gan_single_gpu.sh
```

## Notes

- The official KAIR configs target 8 GPUs. The configs in `configs/swinir_autodl/` are single-GPU friendly.
- Full paper-level reproduction needs the full training datasets and long training schedules.
- A small subset is only a pipeline smoke test; it is not a meaningful model-quality reproduction.
- KAIR does not stop at a fixed iteration by default. Stop manually after the needed checkpoint, or add a stopping condition later.
