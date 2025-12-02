# Python cheatsheet — Quick benchmarking

Run Python solutions (script accepts `iterations` and `warmup`):

```bash
# If your script expects a part flag
./scripts/bench.sh "python3 day1/solution.py 1" 20 2

# If your program reads from a file
./scripts/bench.sh "python3 day1/solution.py day1/input.txt" 20 2
```

Tips

- Use a virtual environment to pin dependencies.
- Python startup overhead is significant; use higher iteration counts or consider running with PyPy for long benchmarks.
