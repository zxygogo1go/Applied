# AutoDL Run Notes

This repository is for SwinIR inference. The Mac can be used only for editing code; run the model on AutoDL with a CUDA/PyTorch image.

## 1. Choose Runtime

On AutoDL, create an instance with a PyTorch image. CUDA GPU is recommended. The code also supports CPU, but inference will be slow.

Recommended baseline:

- Python 3.8 or newer
- PyTorch already installed in the AutoDL image
- CUDA available for GPU inference

Check the runtime:

```bash
python -c "import torch; print(torch.__version__); print('cuda:', torch.cuda.is_available())"
```

## 2. Clone And Install Dependencies

```bash
git clone <your-github-repo-url>
cd SwinIR-main
pip install -r requirements.txt
```

Do not reinstall `torch` unless the AutoDL image does not include it. If PyTorch is missing, install the CUDA-matched version from the official PyTorch command for your AutoDL image.

## 3. Run A Quick Test

The first run downloads the selected `.pth` model into `model_zoo/swinir`.

```bash
python main_test_swinir.py \
  --task classical_sr \
  --scale 2 \
  --training_patch_size 48 \
  --model_path model_zoo/swinir/001_classicalSR_DIV2K_s48w8_SwinIR-M_x2.pth \
  --folder_lq testsets/Set5/LR_bicubic/X2 \
  --folder_gt testsets/Set5/HR
```

Outputs are written under `results/`.

## 4. Real-World Super-Resolution

Use tiling if GPU memory is limited:

```bash
python main_test_swinir.py \
  --task real_sr \
  --scale 4 \
  --model_path model_zoo/swinir/003_realSR_BSRGAN_DFO_s64w8_SwinIR-M_x4_GAN.pth \
  --folder_lq testsets/RealSRSet+5images \
  --tile 400
```

Note: `--tile` must be followed by an integer, such as `400`.

## 5. Upload Your Own Images

Put low-quality images in a folder, for example:

```bash
mkdir -p inputs/my_images
```

Then run:

```bash
python main_test_swinir.py \
  --task real_sr \
  --scale 4 \
  --model_path model_zoo/swinir/003_realSR_BSRGAN_DFO_s64w8_SwinIR-M_x4_GAN.pth \
  --folder_lq inputs/my_images \
  --tile 400
```

## 6. Git Notes

Do not commit downloaded weights or generated outputs. They are ignored by `.gitignore`:

- `model_zoo/swinir/`
- `experiments/`
- `results/`
- `*.pth`
- `*.pt`
