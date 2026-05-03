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
    df.set_index('label', inplace=True)

    # 1. pgscan vs pgsteal
    fig, ax = plt.subplots(figsize=(10, 6))
    scan_cols = [c for c in df.columns if 'pgscan' in c]
    steal_cols = [c for c in df.columns if 'pgsteal' in c]
    
    total_scan = df[scan_cols].sum(axis=1)
    total_steal = df[steal_cols].sum(axis=1)
    
    plot_df = pd.DataFrame({'pgscan': total_scan, 'pgsteal': total_steal})
    plot_df.plot(kind='bar', ax=ax)
    ax.set_title('Page Scan vs Page Steal (Efficiency)')
    ax.set_ylabel('Page Count')
    plt.tight_layout()
    plt.savefig('reclaim_comparison.png')

    # 2. Page Faults
    fig, ax = plt.subplots(figsize=(10, 6))
    fault_cols = [c for c in df.columns if 'pgfault' in c or 'pgmajfault' in c]
    df[fault_cols].plot(kind='bar', ax=ax)
    ax.set_title('Page Faults Comparison')
    ax.set_ylabel('Count')
    plt.tight_layout()
    plt.savefig('faults_comparison.png')

    # 3. Efficiency Ratio
    fig, ax = plt.subplots(figsize=(10, 6))
    efficiency = total_steal / total_scan
    efficiency.plot(kind='bar', ax=ax, color='teal')
    ax.set_title('Reclaim Efficiency (pgsteal / pgscan)')
    ax.set_ylabel('Ratio')
    plt.tight_layout()
    plt.savefig('efficiency_ratio.png')

    print("Plots saved as reclaim_comparison.png, faults_comparison.png, and efficiency_ratio.png")

if __name__ == "__main__":
    csv_file = "summary_results.csv"
    if len(sys.argv) > 1:
        csv_file = sys.argv[1]
    plot_results(csv_file)
