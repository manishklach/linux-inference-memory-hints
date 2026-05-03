# Running a v4 (Reclaim Bias) Experiment

This guide explains how to validate the Milestone 3 (Patch v4) implementation, which introduces a best-effort reclaim bias.

## 1. Patch Application
The v4 suite builds on previous milestones. Apply them in sequence to a clean 6.6+ kernel tree:

```bash
git am patches/v2/*.patch  # Milestone 1: API Acceptance
git am patches/v3/*.patch  # Milestone 2: VMA Metadata
git am patches/v4/*.patch  # Milestone 3: Reclaim Bias
```

## 2. Kernel Build & Boot
Ensure the following are enabled in your `.config`:
- `CONFIG_DEBUG_FS=y`
- `CONFIG_LRU_GEN=y`

Build and boot:
```bash
make -j$(nproc)
sudo make modules_install install
sudo reboot
```

## 3. Verification Pipeline
Once booted, run the automated verification script:

```bash
sudo ./tools/verify_semantic_pipeline.sh
```

This script confirms:
1. **UAPI Support**: `madvise` accepts the new constants.
2. **Metadata Recording**: Hints are being stored at the VMA level.
3. **Observability**: Reclaim counters are accessible via `debugfs`.

## 4. Running a Comparative Benchmark
To measure the impact of the reclaim bias, run the full experiment suite with the requirement check enabled:

```bash
sudo ./tools/run_full_experiment.sh --runs 5 --require-semantic
```

## 5. Interpreting Signal Detection
After the run, check `results/analysis.txt`. The parser will automatically flag if:
- **`reuse_protected`** or **`ephemeral_reclaimed`** counters moved.
- There is a measurable change in **Reclaim Efficiency** (`pgsteal/pgscan`).

If no signal is detected, verify your memory pressure settings in the `run_full_experiment.sh` script; the bias is only visible when the system is actively reclaiming pages.
