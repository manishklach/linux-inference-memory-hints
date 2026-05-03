#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# run_qemu.sh - Boot the patched kernel in QEMU

KERNEL_IMG="kernel-build/arch/x86/boot/bzImage"
ROOTFS_IMG="rootfs.ext4"
REPO_PATH=$(pwd)

if [ ! -f "${KERNEL_IMG}" ]; then
    echo "ERROR: Kernel image not found. Run ./scripts/build_kernel.sh first."
    exit 1
fi

echo "Booting patched kernel in QEMU..."

qemu-system-x86_64 \
    -kernel "${KERNEL_IMG}" \
    -m 4G \
    -smp 4 \
    -nographic \
    -append "root=/dev/sda console=ttyS0 earlyprintk=ttyS0 nokaslr" \
    -drive file="${ROOTFS_IMG}",format=raw \
    -virtfs local,path="${REPO_PATH}",mount_tag=repo,security_model=none,id=repo \
    -net nic -net user,hostfwd=tcp::2222-:22
