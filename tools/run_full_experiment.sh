#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# run_full_experiment.sh - Orchestrate multi-run MM experiments
set -e

RUNS=3
RESULTS_DIR="results"
DRY_RUN=false

# Root of the repo
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

cleanup() {
    echo "Cleaning up background processes..."
    [ -n "$BENCH_PID" ] && kill "$BENCH_PID" 2>/dev/null || true
    [ -n "$PRESS_PID" ] && kill "$PRESS_PID" 2>/dev/null || true
}
trap cleanup EXIT

REQUIRE_SEMANTIC=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --runs) RUNS="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        --require-semantic) REQUIRE_SEMANTIC=1 ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [ "$REQUIRE_SEMANTIC" -eq 1 ]; then
    echo "Checking for semantic support..."
    if ! ./tools/check_semantic_support | grep -q "SUPPORTED"; then
        echo "ERROR: --require-semantic specified but kernel does not support semantic hints."
        exit 1
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would perform $RUNS runs per mode."
    echo "[DRY RUN] Modes: baseline, existing-madvise, semantic"
    exit 0
fi

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
        
        # Baseline stats
        ./tools/collect_mm_stats.sh "${mode}/run_${i}/before"
        
        # Launch workload
        ./benchmarks/synthetic/patterns --mode "$mode" > "$MODE_DIR/stdout.log" 2>&1 &
        BENCH_PID=$!
        
        sleep 2
        
        # Launch pressure
        ./benchmarks/pressure/pressure 4 > "$MODE_DIR/pressure.log" 2>&1 &
        PRESS_PID=$!
        
        sleep 30
        
        # Cleanup specific to this run
        kill "$BENCH_PID" "$PRESS_PID" 2>/dev/null || true
        wait "$BENCH_PID" 2>/dev/null || true
        wait "$PRESS_PID" 2>/dev/null || true
        unset BENCH_PID PRESS_PID
        
        # End collection
        ./tools/collect_mm_stats.sh "${mode}/run_${i}/after"
        
        echo "Run $i complete."
    done
done

echo "Experiment suite complete. Parsing results..."
python3 ./tools/parse_results.py --multi
echo "Generating visualizations..."
make plot
