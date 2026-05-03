# Reproducible Research via QEMU

This guide explains how to set up a reproducible environment to evaluate the **Milestone 3 (v4)** reclaim bias using QEMU and a custom-built Linux kernel.

## 1. Prerequisites
- Host running Linux (or WSL2 with nested virtualization enabled)
- `gcc`, `make`, `wget`, `xz-utils`, `git`
- `qemu-system-x86_64`
- A minimal root filesystem image (`rootfs.ext4`)

## 2. Kernel Build
The `./scripts/build_kernel.sh` script automates the process of downloading the 6.6 LTS kernel, applying the research patches, and building the `bzImage`.

```bash
chmod +x scripts/*.sh
./scripts/build_kernel.sh
```

## 3. Root Filesystem Setup
You can create a minimal rootfs using `debootstrap` or use a pre-built BusyBox image. Ensure the following are installed inside the image:
- `bash`
- `python3`
- `build-essential` (gcc, make)

## 4. Launching the VM
The `./scripts/run_qemu.sh` script boots the patched kernel and mounts the current repository as a shared folder via `9p` (virtfs).

```bash
./scripts/run_qemu.sh
```

## 5. Running the Experiment
Once inside the VM, execute the orchestrator script to verify the kernel support and run the benchmarks:

```bash
# Inside the VM guest
/mnt/repo/scripts/run_in_vm.sh
```

## 6. Data Export
Since the repository is mounted as a shared folder, all results generated in the `results/` directory inside the VM will be immediately available on your host machine for analysis.

## 7. Troubleshooting
- **No Signal**: Ensure `debugfs` is mounted inside the VM (`mount -t debugfs none /sys/kernel/debug`).
- **Mount Failure**: Check if your host kernel and QEMU support `virtfs`/`9p` shared folders.
