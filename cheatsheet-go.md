# Go cheatsheet — Quick benchmarking

Use the provided `scripts/bench.sh` to benchmark your Go solutions with minimal setup.

Examples

- Run with `go run` (no build step):

```bash
./scripts/bench.sh 20 2 "go run day1/main.go -part 1"
# Quiet mode
./scripts/bench.sh -q 20 2 "go run day1/main.go -part 1"
```

- Build and run the binary (faster repeated runs):

```bash
go build -o bin/day1 day1/main.go
./scripts/bench.sh 200 2 "./bin/day1 -part 1"
# Quiet mode
./scripts/bench.sh -q 200 2 "./bin/day1 -part 1"
```

Notes

- Use a higher iteration count for lower-variance results (e.g., 100+ for compiled code).
- For repeatability, pin your Go version (e.g., via `go env` or container image).
