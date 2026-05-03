# Sample Results (Placeholder)

This document provides a template for recording benchmark results. Actual results will vary based on hardware and the specific kernel implementation.

## 1. Reclaim Counters (vmstat)

| Metric | Baseline | Existing Madvise | Semantic Hints |
| :--- | :---: | :---: | :---: |
| pgscan_kswapd | [placeholder] | [placeholder] | [placeholder] |
| pgsteal_kswapd | [placeholder] | [placeholder] | [placeholder] |
| pgscan_direct | [placeholder] | [placeholder] | [placeholder] |
| pgsteal_direct | [placeholder] | [placeholder] | [placeholder] |
| **Efficiency (%)** | | | |

## 2. Page Fault Attribution

| Metric | Baseline | Existing Madvise | Semantic Hints |
| :--- | :---: | :---: | :---: |
| pgfault (Minor) | [placeholder] | [placeholder] | [placeholder] |
| pgmajfault (Major)| [placeholder] | [placeholder] | [placeholder] |

## 3. Pressure Stall Information (PSI)

| Resource | Baseline (Avg10) | Semantic (Avg10) |
| :--- | :---: | :---: |
| Memory (Some) | [placeholder] | [placeholder] |
| Memory (Full) | [placeholder] | [placeholder] |

## 4. Runtime Metrics
- **Test Duration**: 30 seconds
- **Pressure Load**: 4GB allocation sweep
- **MGLRU Status**: Enabled (0x0007)

---
*Note: No data is presented here yet as measurements require a patched kernel environment.*
