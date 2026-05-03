#!/usr/bin/env python3
import os
import sys
import json
import csv

def parse_counters(filepath):
    counters = {}
    if not os.path.exists(filepath):
        return counters
    with open(filepath, 'r') as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2:
                counters[parts[0]] = int(parts[1])
    return counters

def main():
    results_dir = "results"
    if not os.path.exists(results_dir):
        print("No results directory found.")
        return

    all_data = {}
    for label in os.listdir(results_dir):
        label_path = os.path.join(results_dir, label)
        if os.path.isdir(label_path):
            counters = parse_counters(os.path.join(label_path, "mm_counters"))
            if counters:
                all_data[label] = counters

    # Save to JSON
    with open("summary_results.json", "w") as f:
        json.dump(all_data, f, indent=2)

    # Save to CSV
    if all_data:
        labels = sorted(all_data.keys())
        # Find all unique metrics
        metrics = set()
        for l in labels:
            metrics.update(all_data[l].keys())
        metrics = sorted(list(metrics))

        with open("summary_results.csv", "w", newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["label"] + metrics)
            for label in labels:
                row = [label] + [all_data[label].get(m, 0) for m in metrics]
                writer.writerow(row)

    print("Parsed results saved to summary_results.json and summary_results.csv")

if __name__ == "__main__":
    main()
