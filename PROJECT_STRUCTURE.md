# Project Structure

This workspace is organized around one goal: reproduce SwinIR first, then make controlled model changes.

## What Each Area Is For

```text
.
├── main_test_swinir.py              # Compact official SwinIR inference entry
├── models/network_swinir.py         # Compact SwinIR network used by main_test_swinir.py
├── testsets/                        # Small sample test images
├── model_zoo/                       # Inference weights are downloaded here
├── KAIR-master/                     # Full KAIR training framework
├── configs/swinir_autodl/           # Project-owned AutoDL single-GPU SwinIR configs
├── scripts/swinir/                  # Reproduction commands for AutoDL
└── docs/                            # Reproduction notes and innovation map
```

## Recommended Workflow

1. Use the compact root SwinIR code to confirm official pretrained inference.
2. Use `KAIR-master` to reproduce SwinIR training with the configs in `configs/swinir_autodl`.
3. After the baseline is stable, copy a config and rename the `task` before changing model code.
4. Put model innovations in `KAIR-master/models/network_swinir.py` first, because KAIR is the training path.

## Important Rule

Keep upstream code and project workflow separate:

- Upstream KAIR source stays in `KAIR-master/`.
- Your runnable experiment commands live in `scripts/swinir/`.
- Your project-specific configs live in `configs/swinir_autodl/`.
- Your notes and decisions live in `docs/`.

This keeps later model changes auditable instead of turning the repo into a fog bank with a GPU bill.
