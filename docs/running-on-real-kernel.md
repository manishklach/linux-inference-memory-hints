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
1. **Apply the Patch (v3 - Milestone 2)**:
   This version includes VMA metadata tracking.
   ```bash
   git am patches/v3/*.patch
   ```

2. **Verify Support**:
   Use the built-in check tool:
   ```bash
   make check-semantic-support
   ```

3. **Verify Metadata Recording**:
   Run the metadata validation tool and check kernel logs:
   ```bash
   gcc tools/check_semantic_metadata.c -o check_semantic_metadata
   ./check_semantic_metadata
   dmesg | grep madvise
   ```

## 5. Result Collection
Once the demo completes:
- Raw metrics: `results/summary.csv`
- Aggregated JSON: `results/summary.json`
- Visualizations: `results/plots/*.png`

## 6. Interpretation
- Compare the **Efficiency Ratio** plot between Baseline and Semantic modes.
- Look for a reduction in `pgscan` activity in the Semantic mode while maintaining similar `pgsteal` counts.
