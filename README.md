# Linux Inference Memory Hints

## Upstream Status

This work is a research prototype investigating semantic memory hints in Linux memory management.

The current implementation is intentionally minimal and experimental, designed to evaluate feasibility and collect benchmark data. It has not been upstreamed.

## Running on a Patched Kernel

While the **WSL2 environment** is excellent for validating scripts and build correctness, measuring actual reclaim behavior requires the research patches to be active in the kernel.

We provide a reproducible **QEMU-based environment** to evaluate these patches:
1. **Build**: `./scripts/build_kernel.sh` (Downloads and patches 6.6 LTS).
2. **Setup**: Follow the [QEMU Setup Guide](docs/qemu-setup.md) to prepare a rootfs.
3. **Run**: `./scripts/run_qemu.sh` launches the VM with the patched kernel and shared repo access.

### QEMU Workflow Status
The QEMU environment is intended for **patched-kernel validation** and behavioral verification. While it lacks the physical NUMA characteristics of a production server, it provides a stable environment to verify:
- **API Acceptance**: `MADV_SEMANTIC_*` is recognized.
- **Metadata Tracking**: Hints are correctly recorded in VMA structures.
- **Reclaim Movement**: Verify that `semantic_reclaim` counters increment during pressure.

## Quick Start
To build and run a full comparative demo (Baseline vs. Semantic Hints):

```bash
make validate  # Check dependencies and syntax
make demo      # Run full experiment pipeline
```

The `make demo` target will generate visualizations in `results/plots/`.

## Runtime Modes

### Run without root
- You can compile and run the synthetic benchmarks.
- Reclaim stats will be captured, but `drop_caches` will fail, potentially biasing sequential runs.
- MGLRU debug data from `debugfs` will be skipped.

### Run with root (Recommended)
- Ensures clean state between runs via `drop_caches`.
- Captures full MGLRU generational data.
- Provides accurate PSI (Pressure Stall Information) in restricted environments.

## Interpreting Results

### Analysis Report
Check `results/analysis.txt` after a run for an automated interpretation of the data.

### Signal Categories

#### 1. Metadata Signal (`reuse_protected`, `ephemeral_reclaimed`)
- **Action**: Look for non-zero values in `summary.csv` or `analysis.txt`.
- **Meaning**: This confirms the kernel is successfully identifying semantic regions during reclaim and applying the experimental bias.

#### 2. Reclaim Signal (`pgscan`, `pgsteal`, `reclaim_efficiency`)
- **Action**: Compare the `reclaim_efficiency` (`pgsteal / pgscan`) between **Baseline** and **Semantic**.
- **Meaning**: An increase in efficiency suggests the kernel is successfully avoiding "hot" reuse pages and focusing on "cold" or ephemeral ones.

#### 3. No Change
- **Meaning**: This is expected if the system is not under significant memory pressure. Ensure the `memory_pressure` tool is running and `pgscan` values are non-zero.

## Design Constraints
- **Primary Language**: C
- **Minimal Surface Area**: Implementation avoids invasive changes to core VM structures.
- **No VM Flag Conflicts**: Semantic state is stored in `vma->vm_semantic_hint`.

## Experimental Findings (v4)
Current testing on unpatched host environments (WSL2) confirms that the **experimental harness is fully functional**. While no behavioral signal is expected or observed on standard kernels (Case C), the metadata recording and signal detection engine successfully flag the absence of kernel-side support. Real-world reclaim bias evaluation requires a patched bare-metal kernel.

## Next Steps
- **Improve VMA → Folio Mapping**: Investigate more robust folio-to-VMA lookups if rmap-based bias proves too narrow.
- **Milestone 4 (Planned)**: Proceed to NUMA-aware placement and Transparent Huge Page (THP) optimization experiments once reclaim bias is verified on bare metal.
- **Broaden Workloads**: Integrate with `llama.cpp` to measure latency impact on real-world inference tokens-per-second.

## License
GPL-2.0-only
