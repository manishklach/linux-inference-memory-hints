# Design Specification: Semantic Memory Hints for Inference Workloads

## Overview
Traditional Linux memory management (specifically MGLRU and standard LRU) relies on observing page access patterns to infer "hot" and "cold" behavior. While effective for general-purpose workloads, this reactive approach is suboptimal for AI inference, where memory access intent is often known deterministically by the userspace application or runtime (e.g., llama.cpp, vLLM).

This project proposes a set of semantic memory hints that allow userspace to signal the lifecycle and access characteristics of memory regions, enabling the kernel to make proactive reclaim, Transparent Huge Page (THP), and NUMA placement decisions.

## Problem Statement
Inference workloads typically manage three distinct categories of memory:
1. **Model Weights**: Read-heavy, persistent throughout the process lifecycle, and generally should stay resident (or pinned) in the fastest memory tier.
2. **KV Cache**: High churn, reuse-heavy, but with predictable growth and eviction patterns.
3. **Temporary/Intermediate Buffers**: Extremely short-lived, high-bandwidth requirements, can be reclaimed immediately after a forward pass.

Current `madvise` hints like `MADV_WILLNEED` or `MADV_DONTNEED` are too coarse. They signal *when* to load/unload, but not the *intent* or *class* of the data.

## Proposed Semantic Hints
We introduce three generic semantic classes via `madvise`:

- `MADV_SEMANTIC_STREAMING`: For data that is read once and not reused soon (e.g., initial weight loading or one-time batch processing). Signals the kernel to prioritize these pages for reclaim if memory pressure exists.
- `MADV_SEMANTIC_REUSE`: For data that will be frequently accessed (e.g., KV cache, active model weights). Signals the kernel to protect these pages from reclaim and favor THP collapse.
- `MADV_SEMANTIC_EPHEMERAL`: For scratch/temporary buffers. Signals that the memory can be lazily zeroed or reclaimed immediately without swapping.

## Architectural Approach
1. **VMA Tracking**: Store the semantic class in the Virtual Memory Area (VMA) metadata (`vm_flags`).
2. **MGLRU Integration**: Inject logic into `mm/vmscan.c` to adjust the generation-based reclaim priority based on the VMA semantic class.
3. **THP/khugepaged**: Modify `mm/khugepaged.c` to prioritize `SEMANTIC_REUSE` regions for background collapse.
4. **NUMA Policy**: Future integration with `mm/mempolicy.c` to favor local node allocation for `REUSE` and tiered memory (CXL) for `STREAMING`.

## Why madvise?
Starting with `madvise` allows for seamless integration into existing runtimes without requiring complex cgroup hierarchies or new system calls. It follows the established pattern of providing policy hints to the kernel.
