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
    
    # Signal Detection & Analysis (Milestone 3)
    generate_analysis(summary)

def generate_analysis(summary):
    baseline = summary.get('baseline')
    semantic = summary.get('semantic')
    
    if not baseline or not semantic:
        return

    analysis_path = "results/analysis.txt"
    with open(analysis_path, 'w') as f:
        f.write("--- Semantic Memory Hints Signal Analysis ---\n\n")
        
        # 1. Counter Check
        reuse_protected = semantic.get('semantic_reuse_protected', 0)
        ephemeral_reclaimed = semantic.get('semantic_ephemeral_reclaimed', 0)
        
        f.write(f"Metadata Observation:\n")
        f.write(f"  - Reuse Protected Count: {reuse_protected}\n")
        f.write(f"  - Ephemeral Reclaimed Count: {ephemeral_reclaimed}\n\n")

        # 2. Efficiency Delta
        b_eff = baseline.get('reclaim_efficiency', 0)
        s_eff = semantic.get('reclaim_efficiency', 0)
        delta_eff = s_eff - b_eff
        
        f.write(f"Reclaim Efficiency Analysis:\n")
        f.write(f"  - Baseline: {b_eff:.4f}\n")
        f.write(f"  - Semantic: {s_eff:.4f}\n")
        f.write(f"  - Delta: {delta_eff:+.4f}\n\n")

        # 3. Interpretation
        f.write("Interpretation:\n")
        if reuse_protected > 0 or ephemeral_reclaimed > 0:
            f.write("  [OK] SIGNAL DETECTED: Kernel is observing semantic hints via counters.\n")
        else:
            f.write("  [FAIL] NO COUNTER SIGNAL: Kernel did not report any semantic reclaim activity.\n")
            f.write("         Check if debugfs was mounted and accessible during run.\n")

        if abs(delta_eff) > 0.05:
            direction = "INCREASED" if delta_eff > 0 else "DECREASED"
            f.write(f"  [OK] BEHAVIOR CHANGE: Reclaim efficiency {direction} by {abs(delta_eff)*100:.1f}%.\n")
        else:
            f.write("  [INFO] NO SIGNIFICANT BEHAVIOR CHANGE: Efficiency delta is within noise threshold.\n")
            f.write("         The reclaim bias might be too weak or memory pressure was insufficient.\n")

    print(f"Analysis report generated at {analysis_path}")

if __name__ == "__main__":
    main()
