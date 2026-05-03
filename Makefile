# Makefile for linux-inference-memory-hints research demo

CC = gcc
CFLAGS = -O2 -Wall
BENCH_DIR = benchmarks
TOOLS_DIR = tools
RESULTS_DIR = results

.PHONY: all build run-baseline run-semantic run-pressure collect parse plot demo clean check-env

all: build

build:
	@echo "Building benchmarks..."
	$(CC) $(CFLAGS) $(BENCH_DIR)/synthetic/memory_patterns.c -o $(BENCH_DIR)/synthetic/patterns
	$(CC) $(CFLAGS) $(BENCH_DIR)/pressure/memory_pressure.c -o $(BENCH_DIR)/pressure/pressure

check-env:
	@bash $(TOOLS_DIR)/check_environment.sh

run-baseline: build
	@echo "Running Baseline Workload..."
	@mkdir -p $(RESULTS_DIR)/baseline
	./$(BENCH_DIR)/synthetic/patterns --mode baseline & \
	BENCH_PID=$$!; \
	sleep 2; \
	./$(BENCH_DIR)/pressure/pressure 4 & \
	PRESS_PID=$$!; \
	sleep 30; \
	kill $$BENCH_PID $$PRESS_PID; \
	$(TOOLS_DIR)/collect_mm_stats.sh baseline

run-semantic: build
	@echo "Running Semantic-Hint Workload..."
	@mkdir -p $(RESULTS_DIR)/semantic
	./$(BENCH_DIR)/synthetic/patterns --mode semantic & \
	BENCH_PID=$$!; \
	sleep 2; \
	./$(BENCH_DIR)/pressure/pressure 4 & \
	PRESS_PID=$$!; \
	sleep 30; \
	kill $$BENCH_PID $$PRESS_PID; \
	$(TOOLS_DIR)/collect_mm_stats.sh semantic

collect:
	@echo "Manual collection not implemented as standalone. Use run-* targets."

parse:
	@echo "Parsing results..."
	python3 $(TOOLS_DIR)/parse_results.py

plot:
	@echo "Generating plots..."
	@mkdir -p $(RESULTS_DIR)/plots
	python3 $(TOOLS_DIR)/plot_results.py
	@mv reclaim_comparison.png faults_comparison.png efficiency_ratio.png $(RESULTS_DIR)/plots/

demo: check-env build
	@echo "Running full experiment demo..."
	@bash $(TOOLS_DIR)/run_full_experiment.sh --runs 2
	@echo "--------------------------------------------------"
	@echo "Demo Complete. Results available in $(RESULTS_DIR)/"
	@echo "Check $(RESULTS_DIR)/plots/ for visualizations."
	@echo "--------------------------------------------------"

clean:
	rm -f $(BENCH_DIR)/synthetic/patterns $(BENCH_DIR)/pressure/pressure
	rm -rf $(RESULTS_DIR)/*
