# AoC Performance Benchmarking script (`aoc-bench-script`)

Quick portable benchmarking helper for [Advent of Code](https://adventofcode.com/).

- `bench.sh` — runs any command multiple times, prints CPU model, core count, RAM, per-iteration times and a small summary.

The output results are not checked - run this once you're sure your solution program produces valid outputs.

Also note that users receive different inputs - so for comparison accuracy, use the same inputs in all benchmarked programs.

### Usage:

```
./bench.sh [options] <num_of_iterations> <num_of_warmups> "<command to run>"
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

# Quick one-liner

You can run the script directly from GitHub using `curl` and piping to `bash` (for quick benchmarking/testing):

```bash
curl -sSL https://raw.githubusercontent.com/Stogas/aoc-bench-script/refs/heads/main/bench.sh | bash -s -- [-q] <num_of_iterations> <num_of_warmups> "<command>"
# example
curl -sSL https://raw.githubusercontent.com/Stogas/aoc-bench-script/refs/heads/main/bench.sh | bash -s -- -q 20 2 "echo hello"
```

**Warning:** Piping remote scripts directly to `bash` is dangerous and not recommended for production or sensitive environments. Always review scripts before running them!

### Language-specific cheatsheets:

- `cheatsheet-go.md`
- `cheatsheet-python.md`
- `cheatsheet-node.md`
