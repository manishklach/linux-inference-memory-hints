# Linux Inference Memory Hints

## Upstream Status

This work is a research prototype investigating semantic memory hints in Linux memory management.

The current implementation is intentionally minimal and experimental, designed to evaluate feasibility and collect benchmark data. It has not been upstreamed.

## Research Roadmap
- **Milestone 1**: Semantic hints accepted by patched kernel (Patch v2).
- **Milestone 2**: Persistent metadata tracking (VMA tagging).
- **Milestone 3**: Basic reclaim bias implementation.
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

### Failed Semantic madvise calls
If you see `madvise failed: Invalid Argument` in the benchmark output:
- **Reason**: You are likely running on an unpatched kernel.
- **Impact**: The benchmark will continue to run, but the kernel will ignore the semantic hints, effectively making the "Semantic" run identical to the "Baseline."

### What to look for
> **NOTE ON WSL2**: WSL2 validation confirms the harness works but does not provide meaningful reclaim data. Real reclaim behavior should be measured on a patched kernel running on bare metal or a full VM.

1. **Reclaim Efficiency**: In the `efficiency_ratio.png` plot, look for higher values in the Semantic mode. 
2. **Support Verification**: Run `make check-semantic-support` to verify if your kernel supports the RFC hints.
3. **Scan Counters**: A reduction in `pgscan` relative to `pgsteal` suggests the kernel is making more targeted reclaim decisions.

## Design Constraints
- **Primary Language**: C
- **Minimal Surface Area**: Implementation avoids invasive changes to core VM structures.
- **No VM Flag Conflicts**: Semantic state is stored in `vma->vm_private_data`.

## Known Limitations
See [docs/known-limitations.md](docs/known-limitations.md) for a detailed list of prototype constraints.

## License
GPL-2.0-only
