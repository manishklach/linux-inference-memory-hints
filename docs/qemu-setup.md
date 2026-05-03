# QEMU Setup Guide

Follow these steps to run the `linux-inference-memory-hints` benchmarks in a reproducible, patched environment.

## Step 1: Install Host Dependencies
On your host Linux machine:
```bash
sudo apt update
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc wget qemu-system-x86_64
```

## Step 2: Build the Patched Kernel
Run the automated build script. This will download 6.6.20, apply the research patches, and build the image.
```bash
chmod +x scripts/*.sh
./scripts/build_kernel.sh
```

## Step 3: Prepare the Root Filesystem
You need a `rootfs.ext4` in the repository root. See [docs/rootfs-options.md](rootfs-options.md) for detailed instructions.
A 10GB Ubuntu or Debian minimal image is recommended.

## Step 4: Boot QEMU
Launch the VM. This script mounts the repo as `/mnt/repo` inside the guest.
```bash
./scripts/run_qemu.sh
```

## Step 5: Run Experiments (Inside VM)
Once you have a shell inside the VM:
```bash
# Inside Guest
/mnt/repo/scripts/run_in_vm.sh
```

## Step 6: Analyze Results
Exit the VM (`Ctrl-A` then `X`). The results will be in the `results/` directory of your host repository.

Check [docs/qemu-troubleshooting.md](qemu-troubleshooting.md) if you encounter issues.
