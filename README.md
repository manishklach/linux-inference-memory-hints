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

## Usage (Local Research)
1. **Compile Benchmarks**:
   ```bash
   gcc benchmarks/synthetic/memory_patterns.c -o benchmarks/synthetic/patterns
   gcc benchmarks/pressure/memory_pressure.c -o benchmarks/pressure/pressure
   ```
2. **Run with Pressure**:
   ```bash
   ./benchmarks/pressure/pressure 8 &
   ./benchmarks/synthetic/patterns --hints &
   ```
3. **Collect & Plot**:
   ```bash
   ./tools/run_llama_semantic.sh
   python3 tools/parse_results.py
   python3 tools/plot_results.py
   ```

## License
MIT
