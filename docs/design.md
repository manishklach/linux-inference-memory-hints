# Design: Semantic Memory Hints for Inference

## Overview
Traditional Linux memory management (specifically MGLRU and standard LRU) relies on observing page access patterns to infer "hot" and "cold" behavior. While effective for general-purpose workloads, this reactive approach is suboptimal for AI inference, where memory access intent is often known deterministically by the userspace application or runtime (e.g., llama.cpp, vLLM).

This project proposes a set of semantic memory hints that allow userspace to signal the lifecycle and access characteristics of memory regions, enabling the kernel to make proactive reclaim, Transparent Huge Page (THP), and NUMA placement decisions.

## Metadata Storage (Milestone 2)
To preserve semantic intent across VMA splits and merges, we add a `u8 vm_semantic_hint` field to `struct vm_area_struct`.
- **STREAMING**: Hint 1
- **REUSE**: Hint 2
- **EPHEMERAL**: Hint 3

This ensures that if a VMA is split (e.g., via `mprotect` on a sub-range), the semantic intent is automatically cloned to the new VMA.

## v4 Reclaim Bias (Milestone 3)
In Milestone 3, we introduce a minimal, best-effort reclaim bias.
- **REUSE Protection**: We increment the folio reference count in `folio_referenced_one()` even if the hardware bit is not set, effectively slowing down aging for KV Cache regions.
- **EPHEMERAL Pressure**: we suppress reference increments for ephemeral VMAs, allowing them to be reclaimed first when the system is under pressure.

**Limitations**: Reclaim context does not always provide a VMA. This implementation is focused on the rmap-based aging path where the VMA context is available.

## Problem Statement
Inference workloads typically manage three distinct categories of memory:
1. **Model Weights**: Extremely large, read-only (mostly), and frequently accessed in a predictable sequence.
2. **KV Cache**: Large, repeatedly accessed, and critical for latency.
3. **Temporary Buffers**: Short-lived, high-churn, and ephemeral.

Current `madvise` hints like `MADV_WILLNEED` or `MADV_DONTNEED` are too low-level and do not carry enough semantic weight to influence multi-gen LRU (MGLRU) positioning or cross-NUMA migration policy effectively.

## Proposed Hints
We introduce three new `madvise` flags:

1.  **MADV_SEMANTIC_STREAMING**: Signals that a region is being read sequentially once and should not pollute the active LRU generation.
2.  **MADV_SEMANTIC_REUSE**: Signals that a region will be accessed repeatedly and should be protected from reclaim (e.g., KV Cache).
3.  **MADV_SEMANTIC_EPHEMERAL**: Signals that a region is temporary and can be reclaimed immediately once the current operation completes.

## Implementation Strategy
- **UAPI**: Defined in `asm-generic/mman-common.h`.
- **VMA Metadata**: Stored in `vma->vm_semantic_hint`.
- **Reclaim Hook**: Integrated into `folio_referenced_one()` and `lru_gen` paths to bias the aging process.

## Safety & Isolation
To maintain kernel stability:
- All semantic logic is isolated behind RFC-only patches.
- We avoid modifying `vm_flags` to prevent conflicts with standard kernel flags.
- Reclaim bias is implemented as a "soft" recommendation, not a hard guarantee.
