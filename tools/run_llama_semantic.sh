#!/bin/bash
# run_llama_semantic.sh - Benchmarking script (Refined)
set -e

MODEL_PATH=${1:-"./models/llama-7b.gguf"}
THREADS=${2:-$(nproc)}

run_test() {
    local MODE=$1
    local EXTRA_ARGS=$2
    echo "--- Running $MODE Test ---"
    sync && echo 3 > /proc/sys/vm/drop_caches
    ./benchmarks/llama.cpp/main -m "$MODEL_PATH" -t "$THREADS" -n 128 $EXTRA_ARGS > "results/${MODE}_output.log" 2>&1
    ./tools/collect_mm_stats.sh "$MODE"
}

# 1. Baseline
run_test "baseline" ""

# 2. Existing Madvise (COLD)
# Simulate what happens if we just use standard hints
run_test "madvise_cold" "--madvise-cold"

# 3. Semantic Hints
# Requires our patched runtime
run_test "semantic" "--semantic-hints"

echo "All tests complete. Comparison data available in results/"
