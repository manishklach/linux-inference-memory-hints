#!/usr/bin/env python3
import sys
import json

def parse_vmstat(filepath):
    stats = {}
    with open(filepath, 'r') as f:
        for line in f:
            parts = line.split()
            if len(parts) == 2:
                stats[parts[0]] = int(parts[1])
    return stats

def main():
    if len(sys.argv) < 3:
        print("Usage: parse_proc_vmstat.py <before_file> <after_file>")
        sys.exit(1)

    before = parse_vmstat(sys.argv[1])
    after = parse_vmstat(sys.argv[2])

    diff = {}
    for key in after:
        if key in before:
            diff[key] = after[key] - before[key]

    print(json.dumps(diff, indent=2))

if __name__ == "__main__":
    main()
