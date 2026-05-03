#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
import csv
import os
import sys

# Optional dependency: matplotlib
try:
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False

def read_csv_data(csv_path):
    data = []
    if not os.path.exists(csv_path):
        return data
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            data.append(row)
    return data

def plot_results(csv_path):
    if not HAS_MATPLOTLIB:
        print("INFO: matplotlib not found. Skipping visualization, but summary data is preserved in CSV/JSON.")
        return

    data = read_csv_data(csv_path)
    if not data:
        print("INFO: No data found for plotting.")
        return

    os.makedirs("results/plots", exist_ok=True)

    modes = [r['mode'] for r in data]
    
    # 1. Reclaim: pgscan vs pgsteal
    try:
        fig, ax = plt.subplots(figsize=(10, 6))
        
        # Aggregate pgscan_* and pgsteal_*
        scans = []
        steals = []
        for r in data:
            total_scan = sum(float(v) for k, v in r.items() if 'pgscan' in k)
            total_steal = sum(float(v) for k, v in r.items() if 'pgsteal' in k)
            scans.append(total_scan)
            steals.append(total_steal)
        
        x = range(len(modes))
        width = 0.35
        ax.bar([i - width/2 for i in x], scans, width, label='pgscan')
        ax.bar([i + width/2 for i in x], steals, width, label='pgsteal')
        
        ax.set_xticks(x)
        ax.set_xticklabels(modes)
        ax.set_title('Average Page Scan vs Page Steal')
        ax.set_ylabel('Page Count')
        ax.legend()
        plt.tight_layout()
        plt.savefig('results/plots/reclaim_comparison.png')
        plt.close()
    except Exception as e:
        print(f"WARN: Failed to generate reclaim plot: {e}")

    # 2. Reclaim Efficiency
    try:
        if 'reclaim_efficiency' in data[0]:
            fig, ax = plt.subplots(figsize=(10, 6))
            efficiencies = [float(r['reclaim_efficiency']) for r in data]
            ax.bar(modes, efficiencies, color='teal')
            ax.set_title('Reclaim Efficiency Ratio (Higher is Better)')
            ax.set_ylabel('Ratio (pgsteal / pgscan)')
            plt.tight_layout()
            plt.savefig('results/plots/efficiency_ratio.png')
            plt.close()
    except Exception as e:
        print(f"WARN: Failed to generate efficiency plot: {e}")

    # 3. Page Faults
    try:
        fig, ax = plt.subplots(figsize=(10, 6))
        faults_minor = [float(r.get('pgfault', 0)) for r in data]
        faults_major = [float(r.get('pgmajfault', 0)) for r in data]
        
        x = range(len(modes))
        ax.bar(x, faults_minor, label='Minor Faults')
        ax.bar(x, faults_major, label='Major Faults', bottom=faults_minor)
        
        ax.set_xticks(x)
        ax.set_xticklabels(modes)
        ax.set_title('Average Page Faults Comparison')
        ax.set_ylabel('Count')
        ax.legend()
        plt.tight_layout()
        plt.savefig('results/plots/faults_comparison.png')
        plt.close()
    except Exception as e:
        print(f"WARN: Failed to generate faults plot: {e}")

    print("Plots updated in results/plots/")

if __name__ == "__main__":
    csv_file = "results/summary.csv"
    plot_results(csv_file)
