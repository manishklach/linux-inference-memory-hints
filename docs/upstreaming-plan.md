# Upstreaming Plan (Future Phase)

**Current Status**: Research / Prototyping. **NOT READY FOR SUBMISSION.**

This document outlines the requirements and milestones that must be met before this project can transition from a research prototype to a formal Linux Kernel Mailing List (LKML) submission.

## 1. Prerequisites for Submission
Before any code is sent to maintainers, the following must be achieved:

### Benchmark Thresholds
- **Reproducible Gains**: Demonstrate a consistent >10% improvement in P99 latency under memory pressure across at least three different hardware architectures (x86_64, AArch64).
- **Zero Regression**: Ensure no performance penalty for non-semantic workloads when the patches are enabled.
- **Memory Overhead**: Quantify the impact on VMA metadata size and kernel memory consumption.

### API Refinement
- **Naming Consensus**: Verify that `SEMANTIC_REUSE` etc., are the most descriptive and least controversial names.
- **Interaction with Existing Hints**: Formally define how these hints interact with `MADV_HUGEPAGE`, `MADV_COLD`, and `MADV_PAGEOUT`.
- **UAPI Stability**: Ensure the bit flags in `mman-common.h` do not conflict with other out-of-tree or pending patches.

## 2. Technical Concerns to Address
- **VMA Splitting**: Frequent calls to `madvise` can lead to VMA fragmentation. We need to evaluate if a more efficient tracking mechanism (like a per-process semantic map) is required.
- **Locking Contention**: Ensure that checking semantic flags in the MGLRU path does not introduce new lock contention on the VMA or MM locks.
- **Cgroup Interaction**: Determine if these hints should be controllable/overridable via cgroup attributes.

## 3. Submission Strategy
If the research proves successful:
1. **Internal Review**: Share the results with the mm-community in a "heads up" fashion without patches.
2. **RFC v1**: Send the patchset clearly labeled as RFC to `linux-mm` and `linux-kernel`, explicitly requesting feedback on the UAPI design first.
3. **Tracepoints**: Add kernel tracepoints to allow maintainers to verify the policy decisions in real-time.

## 4. Maintenance Plan
- Identify long-term maintainers within the research team.
- Commit to maintaining the benchmark harness as a public verification tool.

---
**Reminder**: Do not initiate any part of this plan until the benchmark phase is complete and the "Upstream Status" in README is officially updated.
