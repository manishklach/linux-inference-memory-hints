# Known Limitations

This project is a research prototype. Users should be aware of the following limitations when interpreting results.

## 1. Patched Kernel Requirement
The semantic hints (`MADV_SEMANTIC_*`) require a Linux kernel patched with the RFC patchset provided in the `patches/` directory. 
- Running the benchmarks on an **unpatched kernel** will result in `madvise` returning `EINVAL` (Invalid Argument).
- The `patterns` benchmark includes fallback definitions so it will compile on any system, but the functional logic in the kernel will only execute if the patch is applied.

## 2. Metric Noise & WSL Limitations
Standard Linux `vmstat` counters (like `pgscan` and `pgsteal`) are system-wide.
- **WSL2**: While WSL2 is excellent for validating script logic and build correctness, its memory management (including ballooning) can mask standard reclaim behavior. **Zero values** for `pgscan` or `pgsteal` in WSL2 typically mean no measurable reclaim was triggered within the Linux container's view.
- **Root Requirement**: Without root, the `drop_caches` command fails, making sequential runs less isolated and potentially skewing averages.

## 3. Support Detection
- If semantic hints are rejected with `EINVAL`, the benchmark will log an `INFO` message and continue. In this state, the "Semantic" mode results will be functionally identical to the "Baseline."

## 4. Workload Representation
- The synthetic benchmark (`memory_patterns.c`) is designed to isolate specific memory behaviors (Streaming vs. Reuse).
- While it mimics inference patterns, it is **not a replacement** for testing with real-world runtimes like vLLM, llama.cpp, or TensorRT-LLM.
- Real workloads have more complex access patterns and thread contention that the synthetic tool may not capture.

## 5. Lifecycle Trade-offs
The current prototype implementation stores semantic state in `vma->vm_semantic_hint`. 
- This ensures hints are cloned during VMA splits.
- Advanced merging logic for differing semantic hints is not yet implemented.

## 6. Reclaim Context (Milestone 3)
The v4 reclaim bias relies on `folio_referenced_one()` having access to the VMA.
- In some reclaim paths (like global direct reclaim without rmap walks), the semantic hint may not be visible.
- Consequently, the `semantic_reclaim` counters may not capture every eviction event, but they provide a consistent delta for synthetic validation.

---
**Upstream Status**: These limitations are expected for a v1 RFC. Future iterations would address VMA lifecycle integration and broader architectural support.
