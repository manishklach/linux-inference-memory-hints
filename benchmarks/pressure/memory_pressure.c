#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define GB (1024UL * 1024UL * 1024UL)
#define PAGE_SIZE 4096

int main(int argc, char **argv) {
    size_t size_gb = (argc > 1) ? atoi(argv[1]) : 4;
    size_t total_size = size_gb * GB;

    printf("Memory Pressure Generator: Allocating %zu GB...\n", size_gb);

    char *ptr = mmap(NULL, total_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    printf("Touching pages to force reclaim...\n");
    while (1) {
        for (size_t i = 0; i < total_size; i += PAGE_SIZE) {
            ptr[i] = (char)(i & 0xFF);
        }
        printf("Completed sweep of %zu GB.\n", size_gb);
        sleep(1);
    }

    return 0;
}
