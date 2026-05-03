#!/bin/bash
# run_llama_semantic.sh - Run llama.cpp with semantic hints enabled
# Note: Requires a patched llama.cpp that calls madvise(MADV_SEMANTIC_*)
set -e

MODEL_PATH=${1:-"./models/llama-7b.gguf"}
THREADS=${2:-$(nproc)}

echo "Starting Semantic-Aware Llama.cpp Run..."
echo "Model: $MODEL_PATH"
echo "Threads: $THREADS"

# Clear caches for reproducible results
sync
echo 3 > /proc/sys/vm/drop_caches

# Run llama.cpp (semantic)
# Assuming a flag '--semantic-hints' is implemented in our research fork
./benchmarks/llama.cpp/main -m "$MODEL_PATH" -t "$THREADS" -n 128 --semantic-hints --prompt "The future of kernel-level memory management is" > semantic_output.log 2>&1

echo "Semantic Run Complete. Results in semantic_output.log"
./tools/collect_mm_stats.sh semantic
