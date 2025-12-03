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

Tips

- Use `--enable-source-maps` or `--prof` separately if you need deeper profiling; this helper is intentionally minimal.
- For short scripts, include larger iteration counts to reduce noise from Node startup.
