#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# collect_mm_stats.sh - Capture comprehensive kernel MM metrics
LABEL=$1
OUT_DIR="results/$LABEL"

mkdir -p "$OUT_DIR"

# Standard vmstat
if [ -f /proc/vmstat ]; then
    cp /proc/vmstat "$OUT_DIR/vmstat"
    grep -E "pgscan|pgsteal|pgfault|pgmajfault" /proc/vmstat > "$OUT_DIR/mm_counters"
else
    echo "WARN: /proc/vmstat not found."
fi

# NUMA stats
if command -v numastat &> /dev/null; then
    numastat > "$OUT_DIR/numastat"
fi

# Pressure Stall Information (PSI)
if [ -f /proc/pressure/memory ]; then
    cp /proc/pressure/memory "$OUT_DIR/psi_memory"
fi

# kswapd activity
ps -eo comm,pcpu,pid | grep kswapd > "$OUT_DIR/kswapd_activity" 2>/dev/null || true

# MGLRU stats
if [ -f /sys/kernel/mm/lru_gen/enabled ]; then
    cat /sys/kernel/mm/lru_gen/enabled > "$OUT_DIR/mglru_status"
    if [ -d /sys/kernel/debug/lru_gen ]; then
        cp -r /sys/kernel/debug/lru_gen "$OUT_DIR/mglru_debug" 2>/dev/null || echo "WARN: Failed to copy debugfs lru_gen (insufficient permissions?)"
    fi
fi

# Semantic Reclaim Counters (Milestone 3)
if [ -d /sys/kernel/debug/semantic_reclaim ]; then
    cp -r /sys/kernel/debug/semantic_reclaim "$OUT_DIR/semantic_reclaim" 2>/dev/null
fi
