#!/usr/bin/env python3
import matplotlib.pyplot as plt
import sys
import json

def plot_metrics(baseline_json, semantic_json):
    with open(baseline_json) as f:
        baseline = json.load(f)
    with open(semantic_json) as f:
        semantic = json.load(f)

    metrics = ['pgfault', 'pgmajfault', 'pgsteal_kswapd', 'thp_collapse_alloc']
    
    b_vals = [baseline.get(m, 0) for m in metrics]
    s_vals = [semantic.get(m, 0) for m in metrics]

    x = range(len(metrics))
    width = 0.35

    fig, ax = plt.subplots()
    ax.bar([i - width/2 for i in x], b_vals, width, label='Baseline')
    ax.bar([i + width/2 for i in x], s_vals, width, label='Semantic Hints')

    ax.set_ylabel('Count')
    ax.set_title('Kernel Metrics: Baseline vs Semantic Hints')
    ax.set_xticks(x)
    ax.set_xticklabels(metrics)
    ax.legend()

    plt.savefig('comparison_plot.png')
    print("Plot saved as comparison_plot.png")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: plot_results.py <baseline.json> <semantic.json>")
        sys.exit(1)
    plot_metrics(sys.argv[1], sys.argv[2])
