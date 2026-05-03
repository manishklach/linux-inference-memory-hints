#!/bin/bash
# run_llama_baseline.sh - Run llama.cpp without semantic hints
set -e

MODEL_PATH=${1:-"./models/llama-7b.gguf"}
THREADS=${2:-$(nproc)}

echo "Starting Baseline Llama.cpp Run..."
echo "Model: $MODEL_PATH"
echo "Threads: $THREADS"

# Clear caches for reproducible results
sync
echo 3 > /proc/sys/vm/drop_caches

# Run llama.cpp (baseline)
./benchmarks/llama.cpp/main -m "$MODEL_PATH" -t "$THREADS" -n 128 --prompt "The future of kernel-level memory management is" > baseline_output.log 2>&1

echo "Baseline Run Complete. Results in baseline_output.log"
./tools/collect_mm_stats.sh baseline
