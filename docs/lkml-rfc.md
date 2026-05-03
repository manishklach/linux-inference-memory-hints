# THIS IS A DRAFT. DO NOT SEND TO LKML.

**Subject: [RFC PATCH 0/4] mm: Semantic Memory Hints for Inference Workloads**

/* RFC ONLY – NOT FOR SUBMISSION */

This RFC proposes the addition of three new madvise-style hints intended to improve
memory management efficiency for high-throughput, memory-intensive inference
workloads.

Current Linux memory management heuristics are primarily reactive, inferring page
hotness through access bits and MGLRU generations. For AI inference runtimes
(e.g., llama.cpp, vLLM), the memory lifecycle is often deterministic and
well-understood by the userspace application. This patchset introduces a mechanism
for userspace to communicate "semantic intent" for memory regions.

The proposed hints are:
- MADV_SEMANTIC_STREAMING: For high-bandwidth, low-reuse data.
- MADV_SEMANTIC_REUSE: For high-priority, high-reuse data (weights, active caches).
- MADV_SEMANTIC_EPHEMERAL: For short-lived temporary buffers.

By tagging VMAs with these semantic classes, the kernel can make better decisions
regarding reclaim priority, THP collapse, and NUMA placement, especially under
memory pressure or in tiered memory environments (CXL).

This is a research-oriented proposal. We chose generic naming to avoid coupling
the kernel API to specific machine learning architectures, focusing instead on
the underlying memory access patterns.

**Patch Summary:**
- 0001: Add UAPI definitions for semantic madvise hints.
- 0002: Track semantic class in VMA vm_flags.
- 0003: Integrate semantic hints into MGLRU/vmscan reclaim logic.
- 0004: Add semantic-aware THP policy hooks.

**Known Limitations:**
- VMA-level granularity might be too coarse for some fine-grained buffer management.
- Interaction with existing hints (MADV_COLD, MADV_HUGEPAGE) needs formalization.

We are seeking internal feedback on the API design and the feasibility of integrating
these policy hooks into the core VM subsystem.

Signed-off-by: Research Team <research@example.local>
