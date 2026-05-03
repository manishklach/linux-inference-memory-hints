#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# run_in_vm.sh - Script to be executed inside the QEMU guest

MOUNT_POINT="/mnt/repo"

set -e

echo "--- VM Experiment Orchestrator ---"

# 1. Mount shared folder if not already mounted
if [ ! -d "${MOUNT_POINT}" ]; then
    mkdir -p "${MOUNT_POINT}"
    mount -t 9p -o trans=virtio repo "${MOUNT_POINT}" -oversion=9p2000.L
fi

cd "${MOUNT_POINT}"

# 2. Run verification
echo "Verifying semantic pipeline..."
sudo ./tools/verify_semantic_pipeline.sh

# 3. Run full experiment
echo "Running full experiment suite..."
sudo ./tools/run_full_experiment.sh --require-semantic --runs 3

echo "Experiment complete. Results are available in ${MOUNT_POINT}/results/"
