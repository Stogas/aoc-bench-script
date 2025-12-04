# JavaScript / Node.js cheatsheet — Quick benchmarking

Run Node.js solutions using `node` with the benchmark helper:

```bash
./scripts/bench.sh 20 2 "node day1/solution.js 1"
# Quiet mode
./scripts/bench.sh -q 20 2 "node day1/solution.js 1"

# When you have a built/bundled binary (optional)
./scripts/bench.sh 50 2 "node ./dist/day1.js 1"
# Quiet mode
./scripts/bench.sh -q 50 2 "node ./dist/day1.js 1"
```

## Using Bun (recommended for accurate benchmarks)

To eliminate Node's ~100ms startup cost, use [Bun](https://bun.sh/) instead:

```bash
./scripts/bench.sh 20 2 "bun day1/solution.js 1"
# Quiet mode
./scripts/bench.sh -q 20 2 "bun day1/solution.js 1"

# With a bundled binary
./scripts/bench.sh 50 2 "bun ./dist/day1.js 1"
# Quiet mode
./scripts/bench.sh -q 50 2 "bun ./dist/day1.js 1"
```

Bun has significantly faster startup time, making it ideal for short-running benchmarks where Node's overhead would dominate the results.

### Installation

Install Bun from [bun.sh](https://bun.sh/) or via:
```bash
curl -fsSL https://bun.sh/install | bash
```

Tips

- Use `--enable-source-maps` or `--prof` separately if you need deeper profiling; this helper is intentionally minimal.
- Prefer Bun for accurate benchmarking of JavaScript/TypeScript solutions (especially for very fast solutions where startup time is significant).
