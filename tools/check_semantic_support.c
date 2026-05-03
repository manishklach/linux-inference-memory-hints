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

int main() {
    size_t size = 4096;
    void *ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    
    if (ptr == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    printf("Checking for kernel semantic hint support...\n");
    if (madvise(ptr, size, MADV_SEMANTIC_STREAMING) == 0) {
        printf("[SUPPORTED] Kernel successfully accepted MADV_SEMANTIC_STREAMING.\n");
        printf("            Note: API is accepted, behavior implementation depends on kernel Milestone level.\n");
    } else {
        if (errno == EINVAL) {
            printf("[UNSUPPORTED] Kernel rejected semantic hint (EINVAL). Patch not detected.\n");
        } else {
            fprintf(stderr, "[ERROR] Unexpected failure during madvise check: %s (errno: %d)\n", 
                    strerror(errno), errno);
        }
    }

    munmap(ptr, size);
    return 0;
}
