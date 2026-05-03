# QEMU Troubleshooting Guide

Common issues encountered when running the `linux-inference-memory-hints` project in QEMU.

## 1. Patch Application Failure
- **Symptoms**: `scripts/build_kernel.sh` fails during the `git am` phase.
- **Cause**: The base kernel version (6.6.x) may have drifted significantly, or the patches were applied out of order.
- **Fix**: Ensure you are using the exact version specified in `build_kernel.sh` (6.6.20). Try `rm -rf kernel-build` and restart.

## 2. Kernel Panic on Boot
- **Symptoms**: QEMU hangs or loops after "End of boot".
- **Cause**: Usually a missing `init` in the rootfs or incorrect `root=` parameter.
- **Fix**: Verify your `rootfs.ext4` contains a valid `/sbin/init` or `/bin/sh`.

## 3. 9p Mount Failure
- **Symptoms**: `scripts/run_in_vm.sh` fails to find `/mnt/repo`.
- **Cause**: The guest kernel lacks `CONFIG_NET_9P` or `CONFIG_9P_FS`.
- **Fix**: `build_kernel.sh` enables these via `defconfig`. If using a custom config, ensure 9P support is built-in (not a module).

## 4. Semantic Hints Still Unsupported
- **Symptoms**: `verify_semantic_pipeline.sh` reports `[UNSUPPORTED]`.
- **Cause**: You may be booting an old `bzImage` instead of the newly patched one.
- **Fix**: Check `uname -r` inside the VM and verify it matches your build timestamp.

## 5. No pgscan/pgsteal Movement
- **Symptoms**: Reclaim counters stay at zero.
- **Cause**: Insufficient memory pressure.
- **Fix**: Increase the background load in `memory_pressure` or reduce the VM RAM (e.g., `-m 1G`).

## 6. DebugFS Unavailable
- **Symptoms**: `/sys/kernel/debug` is empty.
- **Fix**: Run `mount -t debugfs none /sys/kernel/debug` inside the guest.
