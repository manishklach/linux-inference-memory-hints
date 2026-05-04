#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# apply_patches_only.sh - Reset kernel-build and apply research patches for verification

BUILD_DIR="kernel-build"
REPO_ROOT=$(pwd)

set -e

if [ ! -d "${BUILD_DIR}" ]; then
    echo "ERROR: ${BUILD_DIR} does not exist. Please run scripts/build_kernel.sh first to extract source."
    exit 1
fi

echo "--- Preparing ${BUILD_DIR} ---"
cd "${BUILD_DIR}"

# Ensure it's a git repo for easy reset
if [ ! -d ".git" ]; then
    echo "Initializing temporary git repo for reset tracking..."
    git init
    git add -A
    git commit -m "Base kernel"
else
    echo "Resetting to clean state..."
    git reset --hard HEAD
    git clean -fd
fi

echo "Verifying critical headers..."
if [ ! -f "include/uapi/asm-generic/mman-common.h" ]; then
    echo "ERROR: Critical header mman-common.h not found!"
    exit 1
fi

# Apply Patches
echo "--- Applying research patches ---"
for patch_set in v2 v3 v4; do
    echo ">> Applying ${patch_set} patchset..."
    for p in ${REPO_ROOT}/patches/${patch_set}/*.patch; do
        if [ -f "$p" ]; then
            echo "Applying $(basename "$p")..."
            patch -p1 < "$p"
        else
            echo "WARN: No patches found in ${patch_set}"
        fi
    done
done

echo "--- Patch Application Complete ---"
echo "Kernel source is now ready for inspection or build."
echo "Location: ${BUILD_DIR}"
