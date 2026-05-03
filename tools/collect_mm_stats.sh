#!/bin/bash
# collect_mm_stats.sh - Capture vmstat and psi metrics
LABEL=$1
OUT_DIR="results/$LABEL"
mkdir -p "$OUT_DIR"

echo "Collecting Kernel Stats for $LABEL..."

cp /proc/vmstat "$OUT_DIR/vmstat_after"
cp /proc/pressure/memory "$OUT_DIR/psi_memory"
cp /proc/meminfo "$OUT_DIR/meminfo"

# If we have a custom proc entry for our patchset:
if [ -f /proc/mm/semantic_stats ]; then
    cp /proc/mm/semantic_stats "$OUT_DIR/semantic_stats"
fi

echo "Stats saved to $OUT_DIR"
