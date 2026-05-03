# v4 Experiment Results Template

Researchers should use this template to record and share results from the Milestone 3 (v4) experiment.

## Environment Metadata
- **Kernel Version**: `uname -r`
- **CPU**: (e.g., AMD EPYC 7763)
- **Memory**: (e.g., 128GB DDR4)
- **Storage**: (e.g., NVMe Gen4)
- **Workload Detail**: (e.g., memory_patterns with default sizes)

## Summary Metrics

| Mode | pgscan (Avg) | pgsteal (Avg) | Efficiency | Reuse Protected | Ephemeral Reclaimed |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Baseline** | | | | N/A | N/A |
| **Semantic** | | | | | |

## Observation Table

| Metric | Delta (%) | Interpretation |
| :--- | :--- | :--- |
| Efficiency | | |
| Scan Count | | |
| Steal Count | | |

## Interpretation
- **Counter Signal**: (Did `reuse_protected` move?)
- **Efficiency Signal**: (Did efficiency increase significantly?)
- **Conclusion**: (e.g., "Semantic hints improved reclaim efficiency by 12% on bare metal.")

## Reproducibility
- [ ] Root access used
- [ ] MGLRU enabled
- [ ] PSI enabled
- [ ] `--require-semantic` passed
