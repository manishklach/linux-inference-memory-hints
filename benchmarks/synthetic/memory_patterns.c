#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <time.h>

/* RFC SEMANTIC HINTS - Locally defined for research prototype */
#define MADV_SEMANTIC_STREAMING 30
#define MADV_SEMANTIC_REUSE     31
#define MADV_SEMANTIC_EPHEMERAL 32

#define PAGE_SIZE 4096
#define STREAMING_SIZE (256 * 1024 * 1024) // 256MB
#define REUSE_SIZE     (128 * 1024 * 1024) // 128MB
#define EPHEMERAL_SIZE (32 * 1024 * 1024)  // 32MB

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

void access_ephemeral(size_t size) {
    for (int i = 0; i < 50; i++) {
        char *temp = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (temp == MAP_FAILED) return;
        madvise(temp, size, MADV_SEMANTIC_EPHEMERAL);
        memset(temp, 0xCC, size);
        munmap(temp, size);
    }
}

int main(int argc, char **argv) {
    int use_hints = (argc > 1 && strcmp(argv[1], "--hints") == 0);

    printf("Starting Synthetic Memory Pattern Benchmark (Hints: %s)\n", use_hints ? "ON" : "OFF");

    // 1. Streaming Region
    char *streaming = mmap(NULL, STREAMING_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (use_hints) madvise(streaming, STREAMING_SIZE, MADV_SEMANTIC_STREAMING);

    // 2. Reuse Region
    char *reuse = mmap(NULL, REUSE_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (use_hints) madvise(reuse, REUSE_SIZE, MADV_SEMANTIC_REUSE);

    printf("Accessing regions to trigger memory pressure...\n");

    while (1) {
        access_streaming(streaming, STREAMING_SIZE);
        access_reuse(reuse, REUSE_SIZE);
        access_ephemeral(EPHEMERAL_SIZE);
        printf("Iteration complete.\n");
        sleep(1);
    }

    return 0;
}
