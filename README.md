# Linux Inference Memory Hints

## Upstream Status

This work is a research prototype investigating semantic memory hints in Linux memory management.

The current implementation is intentionally minimal and experimental, designed to evaluate feasibility and collect benchmark data. It has not been upstreamed.

## Research Roadmap
- **Milestone 1**: Semantic hints accepted by patched kernel (Patch v2).
- **Milestone 2**: Persistent metadata tracking (VMA tagging) (Patch v3).
- **Milestone 3**: Best-effort semantic reclaim bias (Patch v4).
- **Milestone 4**: Advanced NUMA, THP, and MGLRU experiments.

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
