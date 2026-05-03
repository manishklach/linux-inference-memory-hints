# Benchmark Results Template

## Environment
- **Kernel**: [e.g., 6.x-semantic-v1]
- **CPU**: [e.g., AMD EPYC 7763]
- **Memory**: [e.g., 512GB DDR4 + 1TB CXL]
- **Workload**: [e.g., llama.cpp Llama-3-70B Q4_K_M]

## Performance Metrics

| Metric | Baseline | Semantic Hints | Δ % |
| :--- | :---: | :---: | :---: |
| P50 Latency (ms) | | | |
| P95 Latency (ms) | | | |
| P99 Latency (ms) | | | |
| Tokens/sec | | | |

## Kernel Stats (vmstat/proc)

| Metric | Baseline | Semantic Hints | Δ % |
| :--- | :---: | :---: | :---: |
| Major Faults | | | |
| Minor Faults | | | |
| pgscan_kswapd | | | |
| pgsteal_kswapd | | | |
| numa_miss | | | |
| THP Collapse (succ) | | | |
| kswapd CPU (%) | | | |

## PSI (Pressure Stall Information)

| Resource | Baseline (Avg10) | Semantic (Avg10) |
| :--- | :---: | :---: |
| Memory (Some) | | |
| Memory (Full) | | |
| CPU | | |
| IO | | |

## Notes & Observations
- [Observation 1]
- [Observation 2]
