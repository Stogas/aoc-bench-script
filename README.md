# AoC Performance Benchmarking script (`aoc-bench-script`)

Quick portable benchmarking helper for [Advent of Code](https://adventofcode.com/).

- `bench.sh` — runs any command multiple times, prints CPU model, core count, RAM, per-iteration times and a small summary.

The output results are not checked - run this once you're sure your solution program produces valid outputs.

Also note that users receive different inputs - so for comparison accuracy, use the same inputs in all benchmarked programs.

### Usage:

```
./bench.sh [options] <num_of_iterations> <num_of_warmup_iterations> "<command to run>"
```

Options:
- `-q`, `--quiet` — suppress per-run output (only summary and errors are printed)

Note that warmup iterations are very useful for performance comparisons on JIT interpreted languages like Javascript and Python.

### Example:

```
./bench.sh 50 2 "node ./day1/index.js 1"
# Quiet mode example:
./bench.sh -q 50 2 "node ./day1/index.js 1"
```

### Language-specific cheatsheets:

- `cheatsheet-go.md`
- `cheatsheet-python.md`
- `cheatsheet-node.md`
