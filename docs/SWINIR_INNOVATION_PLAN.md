# SwinIR Innovation Plan

## Baseline First

Do not change the model until a baseline run exists. Keep at least one unchanged run for comparison:

```text
KAIR-master/superresolution/swinir_sr_classical_x2_autodl_1gpu/
KAIR-master/superresolution/swinir_sr_realworld_x4_psnr_autodl_1gpu/
```

## Where To Change Things

For training experiments, edit the KAIR copy:

```text
KAIR-master/models/network_swinir.py
```

The compact root copy:

```text
models/network_swinir.py
```

is mainly for lightweight pretrained inference. Keep it unchanged until a trained innovation is ready to test outside KAIR.

## Safe Experiment Pattern

1. Copy a config in `configs/swinir_autodl/`.
2. Rename the top-level `task`, for example:

```text
swinir_sr_realworld_x4_psnr_myidea_v1
```

3. Change exactly one idea at a time.
4. Record the idea, data, checkpoint, and metric in `docs/EXPERIMENT_LOG.md`.

## Good First Innovation Targets

For remote sensing super-resolution, the most practical first changes are:

- Input adaptation: support 1-channel, RGB, or multispectral channels.
- Degradation adaptation: replace generic BSRGAN degradation with remote-sensing-specific blur, downsampling, noise, and compression.
- Lightweight attention: reduce memory while preserving large-context modeling.
- Edge/detail loss: add a controlled edge or frequency loss after baseline training works.
- Window strategy: test larger windows or shifted-window variants for large spatial structures.

## Files Usually Involved

- Network structure: `KAIR-master/models/network_swinir.py`
- Losses: `KAIR-master/models/loss.py`, `KAIR-master/models/model_plain.py`
- Dataset/degradation: `KAIR-master/data/dataset_blindsr.py`, `KAIR-master/utils/utils_blindsr.py`
- Experiment config: `configs/swinir_autodl/*.json`

## Rule Of Thumb

If a change alters tensor shapes or module names, old weights may not load strictly. Start from scratch or set up a careful partial-load path, then compare against the unchanged baseline.
