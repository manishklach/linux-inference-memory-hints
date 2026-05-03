#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
import os
import sys
import json
import csv
import argparse

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

def compute_diff(before, after):
    diff = {}
    for key in after:
        if key in before:
            diff[key] = after[key] - before[key]
    return diff

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--multi", action="store_true", help="Parse multi-run directory structure")
    args = parser.parse_args()

    results_dir = "results"
    if not os.path.exists(results_dir):
        print("No results directory found.")
        return

    summary = {}

    modes = ["baseline", "existing-madvise", "semantic"]
    for mode in modes:
        mode_path = os.path.join(results_dir, mode)
        if not os.path.isdir(mode_path):
            continue
        
        runs_data = []
        subdirs = [d for d in os.listdir(mode_path) if os.path.isdir(os.path.join(mode_path, d))]
        
        for run_dir in subdirs:
            before_path = os.path.join(mode_path, run_dir, "before", "mm_counters")
            after_path = os.path.join(mode_path, run_dir, "after", "mm_counters")
            
            if os.path.exists(before_path) and os.path.exists(after_path):
                before = parse_counters(before_path)
                after = parse_counters(after_path)
                diff = compute_diff(before, after)
                
                # Parse semantic counters (Milestone 3)
                sem_dir = os.path.join(mode_path, run_dir, "after", "semantic_reclaim")
                if os.path.exists(sem_dir):
                    for fname in os.listdir(sem_dir):
                        val_path = os.path.join(sem_dir, fname)
                        if os.path.isfile(val_path):
                            try:
                                with open(val_path, 'r') as vf:
                                    diff[f"semantic_{fname}"] = int(vf.read().strip())
                            except ValueError:
                                pass

                if diff:
                    runs_data.append(diff)
        
        if runs_data:
            avg_metrics = {}
            metric_keys = runs_data[0].keys()
            for key in metric_keys:
                vals = [r[key] for r in runs_data if key in r]
                avg_metrics[key] = sum(vals) / len(vals)
            
            pgscan = avg_metrics.get('pgscan_kswapd', 0) + avg_metrics.get('pgscan_direct', 0)
            pgsteal = avg_metrics.get('pgsteal_kswapd', 0) + avg_metrics.get('pgsteal_direct', 0)
            if pgscan > 0:
                avg_metrics['reclaim_efficiency'] = pgsteal / pgscan
            else:
                avg_metrics['reclaim_efficiency'] = 0
                
            summary[mode] = avg_metrics

    with open("results/summary.json", "w") as f:
        json.dump(summary, f, indent=2)

    if summary:
        metrics = sorted(list(next(iter(summary.values())).keys()))
        with open("results/summary.csv", "w", newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["mode"] + metrics)
            for mode in sorted(summary.keys()):
                row = [mode] + [summary[mode].get(m, 0) for m in metrics]
                writer.writerow(row)

    print("Summary results saved to results/summary.json and results/summary.csv")

if __name__ == "__main__":
    main()
