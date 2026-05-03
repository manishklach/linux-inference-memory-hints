#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# create_rootfs.sh - Create a minimal Debian rootfs for QEMU experiments

ROOTFS_IMG="rootfs.ext4"
SIZE="4G"
MNT_DIR="mnt_rootfs"
DISTRO="bookworm" # Debian 12
PACKAGES="bash,gcc,make,python3,procps,numactl,mount,coreutils,iproute2,ssh"

set -e

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root (to use debootstrap and mount)."
    exit 1
fi

if ! command -v debootstrap &> /dev/null; then
    echo "ERROR: debootstrap not found. Install it with:"
    echo "sudo apt install debootstrap"
    exit 1
fi

if [ -f "${ROOTFS_IMG}" ]; then
    read -p "Warning: ${ROOTFS_IMG} already exists. Overwrite? [y/N] " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        exit 1
    fi
    rm "${ROOTFS_IMG}"
fi

echo "Creating ${SIZE} raw image..."
truncate -s ${SIZE} "${ROOTFS_IMG}"
mkfs.ext4 "${ROOTFS_IMG}"

echo "Mounting image..."
mkdir -p "${MNT_DIR}"
mount "${ROOTFS_IMG}" "${MNT_DIR}"

trap 'umount "${MNT_DIR}" && rmdir "${MNT_DIR}"' EXIT

echo "Running debootstrap (this may take several minutes)..."
debootstrap --include="${PACKAGES}" "${DISTRO}" "${MNT_DIR}" http://deb.debian.org/debian/

echo "Configuring guest..."
# 1. Set hostname
echo "semantic-research-vm" > "${MNT_DIR}/etc/hostname"

# 2. Configure serial console login
echo "ttyS0" >> "${MNT_DIR}/etc/securetty" 2>/dev/null || true

# 3. Enable empty password for root (RESEARCH ONLY)
sed -i 's/root:x:0:0:root:\/root:\/bin\/bash/root::0:0:root:\/root:\/bin\/bash/' "${MNT_DIR}/etc/passwd"

# 4. Create mount point for shared repo
mkdir -p "${MNT_DIR}/mnt/repo"

# 5. Fstab for proc and sys
cat <<EOF > "${MNT_DIR}/etc/fstab"
proc            /proc           proc    defaults        0       0
sysfs           /sys            sysfs   defaults        0       0
debugfs         /sys/kernel/debug debugfs defaults      0       0
EOF

echo "Rootfs created successfully: ${ROOTFS_IMG}"
