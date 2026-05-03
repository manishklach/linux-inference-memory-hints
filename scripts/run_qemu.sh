#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# run_qemu.sh - Boot the patched kernel in QEMU

KERNEL_IMG="kernel-build/arch/x86/boot/bzImage"
ROOTFS_IMG="rootfs.ext4"
REPO_PATH=$(pwd)

echo "--- QEMU Preflight Checks ---"

if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "ERROR: qemu-system-x86_64 not found. Please install QEMU."
    exit 1
fi

if [ ! -f "${KERNEL_IMG}" ]; then
    echo "ERROR: Kernel image not found at ${KERNEL_IMG}."
    echo "Please run ./scripts/build_kernel.sh first."
    exit 1
fi

if [ ! -f "${ROOTFS_IMG}" ]; then
    echo "ERROR: Root filesystem image not found at ${ROOTFS_IMG}."
    echo "See docs/rootfs-options.md for instructions on creating one."
    exit 1
fi

if [ ! -d "${REPO_PATH}/tools" ]; then
    echo "ERROR: Repository path ${REPO_PATH} does not appear to be the repo root."
    exit 1
fi

echo "All checks passed. Booting patched kernel in QEMU..."

qemu-system-x86_64 \
    -kernel "${KERNEL_IMG}" \
    -m 4G \
    -smp 4 \
    -nographic \
    -append "root=/dev/sda console=ttyS0 earlyprintk=ttyS0 nokaslr" \
    -drive file="${ROOTFS_IMG}",format=raw \
    -virtfs local,path="${REPO_PATH}",mount_tag=repo,security_model=none,id=repo \
    -net nic -net user,hostfwd=tcp::2222-:22
