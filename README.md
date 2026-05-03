# Linux Inference Memory Hints

> **CRITICAL SAFETY NOTICE**: This project is for **LOCAL RESEARCH AND DEVELOPMENT ONLY**. 
> - **DO NOT** submit these patches to the Linux Kernel Mailing List (LKML).
> - **DO NOT** contact kernel maintainers regarding this experimental prototype.

## Upstream Status
This project is **NOT** submitted to LKML.

## Overview
- **Primary Language**: C
- **Primary Subsystem**: Linux Memory Management (mm/)

`linux-inference-memory-hints` is a research project exploring the use of **semantic memory hints** to optimize Linux kernel memory management for large-scale AI inference workloads.

## Quick Start
To build the research tools and run a full comparative demo (Baseline vs. Semantic Hints):

```bash
make demo
```
This target will check your environment, compile the C tools, run the synthetic workloads under memory pressure, and generate comparison plots in `results/plots/`.

## What This Demo Proves
- **Measurement Infrastructure**: It validates that the kernel-to-userspace observability loop is functional and capable of capturing subtle MM (Memory Management) changes.
- **Counter Sensitivity**: It shows whether the lightweight reclaim bias in `vmscan.c` successfully alters standard counters like `pgscan` and `pgsteal`.
- **Reproducibility**: It provides a standardized framework for testing memory policy changes without external dependencies like large LLM weights.

## What This Demo Does Not Prove
- **Production Gains**: It does not prove that these hints will improve tokens/sec in a production vLLM or llama.cpp deployment yet.
- **Upstream Acceptance**: It does not imply that this specific API or implementation is ready for the mainline Linux kernel.
- **Optimality**: It does not prove that the current reclaim bias (1x increment) is the optimal value for all workloads.

## Synthetic Benchmark
To evaluate semantic hints in a controlled environment, we provide a synthetic benchmark (`benchmarks/synthetic/memory_patterns.c`) that simulates the core memory behaviors of an LLM inference engine:

1. **Streaming**: Simulates weight loading or one-time batch processing. Large memory region accessed sequentially once per iteration. Marked with `MADV_SEMANTIC_STREAMING`.
2. **Reuse**: Simulates the KV Cache or active model weights. Medium-sized region accessed randomly and frequently. Marked with `MADV_SEMANTIC_REUSE`.
3. **Ephemeral**: Simulates intermediate activation tensors or scratch buffers. Small regions frequently allocated, used, and freed. Marked with `MADV_SEMANTIC_EPHEMERAL`.

This benchmark, combined with the memory pressure generator (`benchmarks/pressure/memory_pressure.c`), allows us to observe how the kernel prioritizes different semantic classes under stress.

## Metrics and Observability
We focus on low-level kernel metrics rather than high-level application throughput (tokens/sec) because semantic hints primarily affect **memory management efficiency**.

- **pgscan**: The number of pages the kernel had to scan to find candidates for reclaim. Higher values indicate the kernel is "working harder" to find memory.
- **pgsteal**: The number of pages successfully reclaimed. 
- **Reclaim Efficiency (pgsteal / pgscan)**: A critical ratio. If semantic hints work, the kernel should spend less time scanning "hot" pages (`SEMANTIC_REUSE`) and more time successfully stealing "cold" or "ephemeral" pages.
- **Page Faults (Minor/Major)**: Major faults (disk I/O) are the primary source of latency spikes in inference. Semantic hints aim to keep critical weights resident, reducing major faults under pressure.
- **PSI (Pressure Stall Information)**: Provides a system-wide view of how much the CPU/IO is stalled waiting for memory.

## Repository Structure
- `patches/`: RFC (DO NOT SUBMIT) patchset.
- `benchmarks/`: 
    - `synthetic/`: Controlled memory pattern simulation.
    - `pressure/`: Tool to force kernel memory reclaim.
    - `llama.cpp/`: Logic for real-world model testing.
- `tools/`: 
    - `collect_mm_stats.sh`: Captures `/proc/vmstat` and PSI.
    - `parse_results.py`: Converts raw logs to structured JSON/CSV.
    - `plot_results.py`: Generates comparative visualizations.
- `docs/`: Design and upstreaming documents.

## Results (Preliminary)
Experiments are conducted to compare **Baseline**, **Existing Linux Hints**, and our proposed **Semantic Hints**. 

- **Primary Metric**: Reclaim Efficiency (`pgsteal / pgscan`).
- **Focus**: Observing how userspace intent signals affect kernel-level page reclamation priority.
- **Data Status**: Results will be populated here after completing local experiment runs. Use `make demo` to generate results on your local patched kernel.

## Usage (Local Research)
1. **Compile Benchmarks**:
   ```bash
   make build
   ```
2. **Run Full Experiment (Multi-run)**:
   ```bash
   ./tools/run_full_experiment.sh --runs 3
   ```
3. **View Plots**:
   Check `results/plots/` for visual comparisons.

## License
GPL v2
