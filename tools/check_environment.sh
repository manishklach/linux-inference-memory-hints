#!/bin/bash
# check_environment.sh - Sanity check for the research environment

echo "Checking environment for linux-inference-memory-hints..."

# Critical checks
if ! command -v gcc &> /dev/null; then
    echo "ERROR: gcc not found. Compilation will fail."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not found. Result parsing and plotting will fail."
    exit 1
fi

# Kernel / OS Info
echo "Kernel version: $(uname -r)"
if grep -qi microsoft /proc/version; then
    echo "[WARN] WSL detected. WSL is suitable for validating scripts, but not for meaningful reclaim/MGLRU results."
fi

# Feature checks
if [ -f /proc/vmstat ]; then
    echo "[OK] /proc/vmstat exists."
else
    echo "[FAIL] /proc/vmstat missing."
fi

if [ -f /proc/pressure/memory ]; then
    echo "[OK] Pressure Stall Information (PSI) available."
else
    echo "[WARN] PSI (/proc/pressure/memory) missing. Pressure stats will be empty."
fi

if [ -f /sys/kernel/mm/lru_gen/enabled ]; then
    echo "[OK] MGLRU enabled."
else
    echo "[WARN] MGLRU not detected. This patchset is optimized for MGLRU."
fi

if command -v numastat &> /dev/null; then
    echo "[OK] numastat available."
else
    echo "[WARN] numastat missing. NUMA locality stats will be skipped."
fi

# Permissions
if [ "$EUID" -ne 0 ]; then
    echo "[WARN] Not running as root. Some stats (like MGLRU debug) may be inaccessible."
fi

# Python libraries
if python3 -c "import matplotlib" &> /dev/null; then
    echo "[OK] matplotlib available."
else
    echo "[WARN] matplotlib not found. Plotting target will fail."
fi

echo "Environment check complete."
