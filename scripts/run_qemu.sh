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
    echo "Please run 'sudo ./scripts/create_rootfs.sh' first to create one."
    exit 1
fi

if [ ! -d "${REPO_PATH}/tools" ]; then
    echo "ERROR: Repository path ${REPO_PATH} does not appear to be the repo root."
    exit 1
fi

echo "All checks passed. Booting patched kernel in QEMU..."

qemu-system-x86_64 \
  -m 4G \
  -smp 4 \
  -kernel kernel-build/arch/x86/boot/bzImage \
  -append "root=/dev/vda console=ttyS0 rw" \
  -drive file=rootfs.ext4,format=raw,if=virtio \
  -fsdev local,id=fsdev0,path=.,security_model=none \
  -device virtio-9p-pci,fsdev=fsdev0,mount_tag=repo \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -nographic 
