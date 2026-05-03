#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# build_kernel.sh - Automated kernel download, patch, and build

KERNEL_VERSION="6.6.20"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
BUILD_DIR="kernel-build"
REPO_ROOT=$(pwd)

set -e

echo "--- Kernel Build Preflight Checks ---"
DEPENDENCIES=("wget" "tar" "make" "gcc" "flex" "bison" "bc")
MISSING=()

for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo "ERROR: Missing required build dependencies: ${MISSING[*]}"
    echo "On Ubuntu/Debian, run:"
    echo "sudo apt update && sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc wget"
    exit 1
fi

echo "All dependencies found."

echo "Starting kernel build for version ${KERNEL_VERSION}..."

# 1. Download
if [ ! -f "linux-${KERNEL_VERSION}.tar.xz" ]; then
    echo "Downloading kernel source..."
    wget ${KERNEL_URL}
fi

# 2. Extract
if [ ! -d "${BUILD_DIR}" ]; then
    echo "Extracting source..."
    mkdir -p "${BUILD_DIR}"
    tar -xf "linux-${KERNEL_VERSION}.tar.xz" -C "${BUILD_DIR}" --strip-components=1
fi

cd "${BUILD_DIR}"

# 3. Preflight Check
echo "Verifying kernel source integrity..."
if [ ! -f "include/uapi/asm-generic/mman-common.h" ]; then
    echo "ERROR: Critical header mman-common.h not found in ${BUILD_DIR}!"
    echo "Found files:"
    find . -path "*mman-common.h"
    exit 1
fi

# 4. Apply Patches
echo "Applying research patches..."
for patch_set in v2 v3 v4; do
    echo "--- Applying ${patch_set} patchset ---"
    for p in ${REPO_ROOT}/patches/${patch_set}/*.patch; do
        if [ -f "$p" ]; then
            echo "Applying $(basename "$p")..."
            patch -p1 < "$p"
        fi
    done
done

# 5. Configure
echo "Configuring kernel..."
make defconfig

# Enable required research features
scripts/config --enable CONFIG_DEBUG_FS
scripts/config --enable CONFIG_LRU_GEN
scripts/config --enable CONFIG_PROC_FS
scripts/config --enable CONFIG_PSI
scripts/config --enable CONFIG_CGROUPS
scripts/config --enable CONFIG_MEMCG

echo "--- Research Config Verification ---"
for cfg in CONFIG_DEBUG_FS CONFIG_LRU_GEN CONFIG_PROC_FS CONFIG_PSI CONFIG_CGROUPS CONFIG_MEMCG; do
    if grep -q "${cfg}=y" .config; then
        echo "[OK] ${cfg} is enabled."
    else
        echo "[WARN] ${cfg} might not be enabled. Check .config."
    fi
done

# 6. Build
echo "Building bzImage (this will take time)..."
make -j$(nproc) bzImage

echo "Build complete. Kernel image: ${BUILD_DIR}/arch/x86/boot/bzImage"
