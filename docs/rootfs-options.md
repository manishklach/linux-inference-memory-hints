# Root Filesystem Options

To run the benchmarking suite inside QEMU, you need a root filesystem that supports standard Linux utilities.

## Option 1: Debian/Ubuntu Minimal (Recommended)
This is the easiest path for full benchmarking as it includes `gcc`, `python3`, and `bash`.

### Steps to create:
1. Use `virt-builder` (from `libguestfs-tools`):
   ```bash
   virt-builder ubuntu-22.04 --size 10G --format raw -o rootfs.ext4 --root-password password:root
   ```
2. Or use `debootstrap`:
   ```bash
   dd if=/dev/zero of=rootfs.ext4 bs=1G count=10
   mkfs.ext4 rootfs.ext4
   mkdir mnt
   sudo mount rootfs.ext4 mnt
   sudo debootstrap --arch amd64 jammy mnt
   sudo umount mnt
   ```

## Option 2: BusyBox (Minimalist)
Suitable for verifying UAPI acceptance, but may lack dependencies for full plotting and analysis.

### Steps to create:
1. Build BusyBox statically.
2. Create a minimal directory structure (`/bin`, `/sbin`, `/etc`, `/proc`, `/sys`).
3. Create an `init` script that mounts filesystems.
4. Use `cpio` to create an `initrd.img` or `mkfs.ext4` for a disk image.

## Required Guest Packages
Ensure these are installed in your rootfs:
- `build-essential` (gcc, make)
- `python3`
- `bash`
- `coreutils`
- `kmod`
