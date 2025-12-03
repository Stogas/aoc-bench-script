# AoC Performance Benchmarking script (`aoc-bench-script`)

Quick portable benchmarking helper for [Advent of Code](https://adventofcode.com/).

- `bench.sh` — runs any command multiple times, prints CPU model, core count, RAM, per-iteration times and a small summary.

### Usage:

```
./bench.sh "<command to run>" <num_of_iterations> <num_of_warmup_iterations>
```

Note that warmup iterations are very useful for performance comparisons on JIT interpreted languages like Javascript and Python.

### Example:

```
./bench.sh "node ./day1/index.js 1" 50 2
```

### Language-specific cheatsheets:

- `cheatsheet-go.md`
- `cheatsheet-python.md`
- `cheatsheet-node.md`
