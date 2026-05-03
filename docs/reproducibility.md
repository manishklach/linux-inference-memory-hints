# Reproducibility Guide

To reproduce the measurements in this project, follow the guidelines below.

## System Requirements
- **Linux Kernel**: 6.8+ recommended (the patches are developed against mainline 6.x).
- **Architecture**: x86_64 or AArch64.
- **Config**: 
  - `CONFIG_LRU_GEN=y` (Multi-Gen LRU)
  - `CONFIG_PSI=y` (Pressure Stall Information)
  - `CONFIG_TRANSPARENT_HUGEPAGE=y`

## Verifying MGLRU
Ensure MGLRU is active by checking:
```bash
cat /sys/kernel/mm/lru_gen/enabled
# Should return a non-zero value (e.g., 0x0007)
```

## NUMA Configuration
If testing on a multi-socket system, the project will automatically capture `numastat`. If running on a single-node system (e.g., a laptop or small VM), warnings about NUMA can be ignored.

## Cgroup v2
This project assumes a Cgroup v2 environment for memory pressure tracking. Verify with:
```bash
mount | grep cgroup2
```

## Permissions
While the synthetic benchmark and pressure generator can run as a standard user, **root permissions** are required for:
- Clearing kernel caches (`echo 3 > /proc/sys/vm/drop_caches`)
- Accessing `debugfs` for MGLRU generational data.
- Viewing some PSI details in restricted environments.

## Running the Demo
The easiest way to verify the environment is to run the top-level sanity check:
```bash
make check-env
```

## Hardware Consistency
For credible results:
- Disable CPU frequency scaling (use `performance` governor).
- Ensure no other heavy background processes are running.
- Use a dedicated disk if testing file-backed workloads (though v1 focuses on anonymous memory).
