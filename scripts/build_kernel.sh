#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# build_kernel.sh - Automated kernel download, patch, and build

KERNEL_VERSION="6.6.20"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
BUILD_DIR="kernel-build"
REPO_ROOT=$(pwd)

set -e

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

# 3. Apply Patches
echo "Applying research patches..."
git init 2>/dev/null || true
git add .
git commit -m "Base kernel" 2>/dev/null || true

git am ${REPO_ROOT}/patches/v2/*.patch
git am ${REPO_ROOT}/patches/v3/*.patch
git am ${REPO_ROOT}/patches/v4/*.patch

# 4. Configure
echo "Configuring kernel..."
make defconfig

# Enable required research features
scripts/config --enable CONFIG_DEBUG_FS
scripts/config --enable CONFIG_LRU_GEN
scripts/config --enable CONFIG_PROC_FS
scripts/config --enable CONFIG_PSI

# 5. Build
echo "Building bzImage (this will take time)..."
make -j$(nproc) bzImage

echo "Build complete. Kernel image: ${BUILD_DIR}/arch/x86/boot/bzImage"
