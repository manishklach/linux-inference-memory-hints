#!/bin/bash
# run_pressure_test.sh - Simulate memory pressure while running inference
set -e

# Run inference in background
./tools/run_llama_semantic.sh &
LLAMA_PID=$!

echo "Simulating Memory Pressure (allocating 80% of RAM)..."
# Simple memory eater
./benchmarks/pressure/mem_eater --percent 80 --duration 60 &

wait $LLAMA_PID
echo "Pressure test complete."
