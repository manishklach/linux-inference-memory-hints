#!/bin/bash
# run_full_experiment.sh - Orchestrate multi-run MM experiments
set -e

RUNS=3
RESULTS_DIR="results"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --runs) RUNS="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "Starting Full Experiment Pipeline ($RUNS runs per mode)..."

# 1. Environment Check
./tools/check_environment.sh

# 2. Build
make build

# 3. Mode Orchestration
MODES=("baseline" "existing-madvise" "semantic")

for mode in "${MODES[@]}"; do
    echo "=================================================="
    echo "MODE: $mode"
    echo "=================================================="
    
    for ((i=1; i<=RUNS; i++)); do
        echo "Run $i/$RUNS..."
        
        # Isolation: drop caches (requires root)
        if [ "$EUID" -eq 0 ]; then
            sync && echo 3 > /proc/sys/vm/drop_caches
        else
            echo "WARN: Not root, cannot drop caches between runs. Results may be biased."
        fi
        
        MODE_DIR="$RESULTS_DIR/$mode/run_$i"
        mkdir -p "$MODE_DIR"
        
        # Start collection (baseline stats)
        ./tools/collect_mm_stats.sh "${mode}/run_${i}/before"
        
        # Launch workload
        ./benchmarks/synthetic/patterns --mode "$mode" &
        BENCH_PID=$!
        
        # Wait for initialization
        sleep 2
        
        # Launch pressure
        ./benchmarks/pressure/pressure 4 &
        PRESS_PID=$!
        
        # Run duration
        sleep 30
        
        # Cleanup
        kill $BENCH_PID $PRESS_PID 2>/dev/null || true
        wait $BENCH_PID 2>/dev/null || true
        wait $PRESS_PID 2>/dev/null || true
        
        # End collection
        ./tools/collect_mm_stats.sh "${mode}/run_${i}/after"
        
        echo "Run $i complete."
    done
done

echo "Experiment suite complete. Parsing results..."
python3 ./tools/parse_results.py --multi
echo "Generating visualizations..."
make plot
