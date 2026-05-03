// SPDX-License-Identifier: GPL-2.0-only
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#ifndef MADV_SEMANTIC_STREAMING
#define MADV_SEMANTIC_STREAMING 30
#endif
#ifndef MADV_SEMANTIC_REUSE
#define MADV_SEMANTIC_REUSE 31
#endif
#ifndef MADV_SEMANTIC_EPHEMERAL
#define MADV_SEMANTIC_EPHEMERAL 32
#endif

void test_region(const char *name, int hint) {
    size_t size = 4096;
    void *ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap");
        return;
    }

    printf("Testing %s (hint %d) on region %p...\n", name, hint, ptr);
    if (madvise(ptr, size, hint) == 0) {
        printf("[PASS] %s hint accepted.\n", name);
    } else {
        printf("[FAIL] %s hint rejected: %s\n", name, strerror(errno));
    }

    // Keep memory mapped for a moment if we want to check /proc/pid/maps 
    // (though metadata isn't exported there yet in v3)
    munmap(ptr, size);
}

int main() {
    printf("--- Semantic Metadata Validation Tool (Milestone 2) ---\n");
    printf("Note: This tool verifies API acceptance. To verify internal kernel state,\n");
    printf("      check dmesg for 'madvise: vma ... semantic hint set to X'\n\n");

    test_region("STREAMING", MADV_SEMANTIC_STREAMING);
    test_region("REUSE", MADV_SEMANTIC_REUSE);
    test_region("EPHEMERAL", MADV_SEMANTIC_EPHEMERAL);

    printf("\nValidation complete. Check dmesg for kernel-side confirmation.\n");
    return 0;
}
