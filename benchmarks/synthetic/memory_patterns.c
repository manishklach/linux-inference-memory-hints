#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <time.h>

/* RFC SEMANTIC HINTS - Locally defined for research prototype */
#ifndef MADV_SEMANTIC_STREAMING
#define MADV_SEMANTIC_STREAMING 30
#endif
#ifndef MADV_SEMANTIC_REUSE
#define MADV_SEMANTIC_REUSE     31
#endif
#ifndef MADV_SEMANTIC_EPHEMERAL
#define MADV_SEMANTIC_EPHEMERAL 32
#endif

#define PAGE_SIZE 4096
#define STREAMING_SIZE (256 * 1024 * 1024) // 256MB
#define REUSE_SIZE     (128 * 1024 * 1024) // 128MB
#define EPHEMERAL_SIZE (32 * 1024 * 1024)  // 32MB

typedef enum {
    MODE_BASELINE,
    MODE_EXISTING,
    MODE_SEMANTIC
} bench_mode_t;

void access_streaming(char *ptr, size_t size) {
    for (size_t i = 0; i < size; i += PAGE_SIZE) {
        ptr[i] = (char)(i & 0xFF);
    }
}

void access_reuse(char *ptr, size_t size) {
    for (int loop = 0; loop < 100; loop++) {
        for (size_t i = 0; i < size; i += PAGE_SIZE) {
            ptr[i] += 1;
        }
    }
}

void access_ephemeral(size_t size, bench_mode_t mode) {
    for (int i = 0; i < 50; i++) {
        char *temp = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (temp == MAP_FAILED) return;
        
        if (mode == MODE_SEMANTIC) {
            madvise(temp, size, MADV_SEMANTIC_EPHEMERAL);
        } else if (mode == MODE_EXISTING) {
            madvise(temp, size, MADV_DONTNEED);
        }

        memset(temp, 0xCC, size);
        munmap(temp, size);
    }
}

int main(int argc, char **argv) {
    bench_mode_t mode = MODE_BASELINE;
    
    if (argc > 2 && strcmp(argv[1], "--mode") == 0) {
        if (strcmp(argv[2], "baseline") == 0) mode = MODE_BASELINE;
        else if (strcmp(argv[2], "existing-madvise") == 0) mode = MODE_EXISTING;
        else if (strcmp(argv[2], "semantic") == 0) mode = MODE_SEMANTIC;
    }

    printf("Starting Synthetic Memory Pattern Benchmark\n");
    printf("Mode: %s\n", (mode == MODE_BASELINE) ? "Baseline" : 
                          (mode == MODE_EXISTING) ? "Existing Madvise" : "Semantic Hints");

#if !defined(MADV_SEMANTIC_STREAMING) || !defined(MADV_SEMANTIC_REUSE)
    if (mode == MODE_SEMANTIC) {
        printf("WARNING: MADV_SEMANTIC_* constants not found in system headers. Using fallback definitions.\n");
    }
#endif

    // 1. Streaming Region
    char *streaming = mmap(NULL, STREAMING_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (mode == MODE_SEMANTIC) {
        madvise(streaming, STREAMING_SIZE, MADV_SEMANTIC_STREAMING);
    } else if (mode == MODE_EXISTING) {
        madvise(streaming, STREAMING_SIZE, MADV_SEQUENTIAL);
    }

    // 2. Reuse Region
    char *reuse = mmap(NULL, REUSE_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (mode == MODE_SEMANTIC) {
        madvise(reuse, REUSE_SIZE, MADV_SEMANTIC_REUSE);
    } else if (mode == MODE_EXISTING) {
        madvise(reuse, REUSE_SIZE, MADV_WILLNEED);
        madvise(reuse, REUSE_SIZE, MADV_HUGEPAGE);
    }

    printf("Accessing regions to trigger memory pressure...\n");

    while (1) {
        access_streaming(streaming, STREAMING_SIZE);
        access_reuse(reuse, REUSE_SIZE);
        access_ephemeral(EPHEMERAL_SIZE, mode);
        printf("Iteration complete.\n");
        sleep(1);
    }

    return 0;
}
