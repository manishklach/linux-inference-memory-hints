#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# verify_semantic_pipeline.sh - End-to-end verification of the research harness

echo "--- Semantic Hint Pipeline Verification ---"

# 1. API Check
./tools/check_semantic_support
if [ $? -ne 0 ]; then
    echo "[FAIL] Kernel does not support semantic madvise hints."
    exit 1
fi

# 2. Metadata Recording Check (via dmesg)
echo "Checking metadata recording..."
./tools/check_semantic_metadata > /dev/null
if dmesg | grep -q "madvise: vma .* semantic hint set"; then
    echo "[OK] Metadata recording verified in dmesg."
else
    echo "[WARN] No metadata recording seen in dmesg. (Check if dynamic debug is enabled?)"
fi

# 3. Observability Check (DebugFS)
echo "Checking reclaim counters..."
if [ -d /sys/kernel/debug/semantic_reclaim ]; then
    echo "[OK] Semantic reclaim counters found in debugfs."
    echo "Current values:"
    cat /sys/kernel/debug/semantic_reclaim/* | sed 's/^/  /'
else
    echo "[FAIL] Semantic reclaim counters missing from debugfs. Milestone 3 patch not active?"
fi

echo "--- Verification Complete ---"
