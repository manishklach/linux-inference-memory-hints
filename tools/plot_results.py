#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
import os
import sys

def plot_results(csv_path):
    if not os.path.exists(csv_path):
        print(f"File not found: {csv_path}")
        return

    df = pd.read_csv(csv_path)
    df.set_index('mode', inplace=True)

    # 1. Reclaim: pgscan vs pgsteal
    fig, ax = plt.subplots(figsize=(10, 6))
    scan_cols = [c for c in df.columns if 'pgscan' in c]
    steal_cols = [c for c in df.columns if 'pgsteal' in c]
    
    total_scan = df[scan_cols].sum(axis=1)
    total_steal = df[steal_cols].sum(axis=1)
    
    plot_df = pd.DataFrame({'pgscan': total_scan, 'pgsteal': total_steal})
    plot_df.plot(kind='bar', ax=ax)
    ax.set_title('Average Page Scan vs Page Steal')
    ax.set_ylabel('Page Count')
    plt.tight_layout()
    plt.savefig('results/plots/reclaim_comparison.png')

    # 2. Reclaim Efficiency
    fig, ax = plt.subplots(figsize=(10, 6))
    if 'reclaim_efficiency' in df.columns:
        df['reclaim_efficiency'].plot(kind='bar', ax=ax, color='teal')
        ax.set_title('Reclaim Efficiency Ratio (Higher is Better)')
        ax.set_ylabel('Ratio (pgsteal / pgscan)')
        plt.tight_layout()
        plt.savefig('results/plots/efficiency_ratio.png')

    # 3. Page Faults
    fig, ax = plt.subplots(figsize=(10, 6))
    fault_cols = [c for c in df.columns if c in ['pgfault', 'pgmajfault']]
    if fault_cols:
        df[fault_cols].plot(kind='bar', ax=ax)
        ax.set_title('Average Page Faults Comparison')
        ax.set_ylabel('Count')
        plt.tight_layout()
        plt.savefig('results/plots/faults_comparison.png')

    print("Plots saved to results/plots/")

if __name__ == "__main__":
    csv_file = "results/summary.csv"
    if not os.path.exists("results/plots"):
        os.makedirs("results/plots")
    plot_results(csv_file)
