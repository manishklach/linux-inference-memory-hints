# Running on a Real Kernel

To obtain meaningful research data regarding reclaim efficiency and MGLRU generational behavior, the benchmarks must be run on a patched kernel in a non-virtualized or fully-virtualized environment.

## 1. Recommended Environment
- **Platform**: Bare-metal Linux (preferred) or a Full VM (KVM/QEMU).
- **OS**: Ubuntu 22.04+, Debian 12+, or Fedora 39+.
- **Kernel**: Mainline 6.6+ or the latest LTS.
- **Hardware**: Minimum 8GB RAM to ensure reclaim activity is observable.

## 2. Kernel Configuration
Ensure the following are enabled in your kernel `.config`:
- `CONFIG_LRU_GEN=y` (Multi-Gen LRU)
- `CONFIG_PSI=y` (Pressure Stall Information)

## 3. Preparation
Before running the benchmarks, install necessary tools:
```bash
sudo apt update
sudo apt install build-essential python3-matplotlib numactl
```

## 4. Execution Steps
1. **Apply the Patch (v2 - Milestone 1)**:
   This version focus on API acceptance.
   ```bash
   git am patches/v2/*.patch
   ```

2. **Verify Support**:
   Use the built-in check tool to confirm the kernel recognizes semantic hints:
   ```bash
   make check-semantic-support
   ```
   A successful result will show `[SUPPORTED]`.

3. **Verify via Selftest**:
   If you have a full kernel tree, you can run the new selftest:
   ```bash
   gcc tools/testing/selftests/mm/semantic_hint_test.c -o semantic_hint_test
   ./semantic_hint_test
   ```

## 5. Result Collection
Once the demo completes:
- Raw metrics: `results/summary.csv`
- Aggregated JSON: `results/summary.json`
- Visualizations: `results/plots/*.png`

## 6. Interpretation
- Compare the **Efficiency Ratio** plot between Baseline and Semantic modes.
- Look for a reduction in `pgscan` activity in the Semantic mode while maintaining similar `pgsteal` counts.
