#!/bin/bash
# collect_mm_stats.sh - Capture comprehensive kernel MM metrics
LABEL=$1
OUT_DIR="results/$LABEL"
mkdir -p "$OUT_DIR"

echo "Collecting Kernel Stats for $LABEL..."

# 1. Standard vmstat
cp /proc/vmstat "$OUT_DIR/vmstat"

# 2. Extract specific counters for easy parsing
grep -E "pgscan|pgsteal|pgfault|pgmajfault" /proc/vmstat > "$OUT_DIR/mm_counters"

# 3. NUMA stats
if command -v numastat &> /dev/null; then
    numastat > "$OUT_DIR/numastat"
fi

# 4. Memory pressure (PSI)
cp /proc/pressure/memory "$OUT_DIR/psi_memory"

# 5. kswapd CPU usage
ps -eo comm,pcpu,pid | grep kswapd > "$OUT_DIR/kswapd_activity"

# 6. MGLRU stats (if enabled)
if [ -f /sys/kernel/mm/lru_gen/enabled ]; then
    echo "Capturing MGLRU stats..."
    cat /sys/kernel/mm/lru_gen/enabled > "$OUT_DIR/mglru_status"
    # Capture a snapshot of generations if debugfs is mounted
    if [ -d /sys/kernel/debug/lru_gen ]; then
        cp -r /sys/kernel/debug/lru_gen "$OUT_DIR/mglru_debug"
    fi
fi

echo "Stats collection complete for $LABEL. Data in $OUT_DIR"
