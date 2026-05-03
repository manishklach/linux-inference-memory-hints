# v4 Final Research Results

This document summarizes the findings from the Milestone 3 (v4) experiment suite, evaluated on the current research host.

## Environment
- **Kernel Version**: `6.6.87.2-microsoft-standard-WSL2+`
- **Hardware / VM**: WSL2 Virtualized Environment
- **Memory Size**: Variable (WSL Dynamic)
- **NUMA Availability**: Unsupported/Missing
- **MGLRU Availability**: Not Detected

## Experiment Setup
- **Synthetic Workload**: `memory_patterns` (Streaming vs. Reuse vs. Ephemeral regions)
- **Pressure Generator**: `memory_pressure` (Allocating 4GB background load)
- **Number of Runs**: 1 per mode (Validation Run)

## Observations

| Metric | Baseline | Semantic | Delta |
| :--- | :--- | :--- | :--- |
| **Reclaim Efficiency** | 0.1693 | 0.0000 | -0.1693 |
| **pgscan** | 124 | 0 | -124 |
| **pgsteal** | 21 | 0 | -21 |
| **Reuse Protected** | N/A | 0 | - |
| **Ephemeral Reclaimed** | N/A | 0 | - |

## Interpretation: Case C
**“No meaningful signal detected.”**

The current results show no movement in the semantic reclaim counters and inconsistent behavior in the global reclaim metrics. 

### Rationale:
1. **Unpatched Host**: The experiments were conducted on a standard WSL2 kernel. As expected, the `madvise` hints were rejected with `EINVAL`, and the internal reclaim bias logic was not active.
2. **WSL Limitations**: WSL2 memory ballooning and lack of direct `debugfs` access for standard users prevented the capture of fine-grained MGLRU or semantic counters.
3. **Validation Only**: These results successfully validate that the **Experimental Harness** (scripts, collection, and analysis engine) is functional and ready for deployment on a patched research kernel.

---
**Next Steps**: Deploy this harness to a bare-metal machine running the Milestone 3 patched kernel to measure actual reclaim bias impact.
