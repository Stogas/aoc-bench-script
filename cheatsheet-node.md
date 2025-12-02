# JavaScript / Node.js cheatsheet — Quick benchmarking

Run Node.js solutions using `node` with the benchmark helper:

```bash
./scripts/bench.sh "node day1/solution.js 1" 20 2

# When you have a built/bundled binary (optional)
./scripts/bench.sh "node ./dist/day1.js 1" 50 2
```

Tips

- Use `--enable-source-maps` or `--prof` separately if you need deeper profiling; this helper is intentionally minimal.
- For short scripts, include larger iteration counts to reduce noise from Node startup.
