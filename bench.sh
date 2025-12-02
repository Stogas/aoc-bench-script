#!/usr/bin/env bash
set -euo pipefail

# Simple portable benchmarking helper
# Usage: ./scripts/bench.sh "<command>" [iterations] [warmup]
# Example: ./scripts/bench.sh "go run day1/main.go -part 1" 20 2

CMD=${1:-}
if [ -z "$CMD" ]; then
  echo "Usage: $0 \"<command>\" [iterations] [warmup]" >&2
  exit 2
fi

ITERATIONS=${2:-10}
WARMUP=${3:-1}

echo "Benchmark: $CMD"
echo "Iterations: $ITERATIONS, Warmup: $WARMUP"

printf "\n--- System information ---\n"
# CPU model
if command -v lscpu >/dev/null 2>&1; then
  CPU_MODEL=$(lscpu 2>/dev/null | awk -F: '/Model name|Model/ {print $2; exit}' | sed 's/^ *//')
else
  CPU_MODEL=$(awk -F: '/model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null | sed 's/^ *//') || CPU_MODEL="unknown"
fi
CPU_CORES=$(nproc 2>/dev/null || echo "unknown")
RAM_KB=$(awk '/MemTotal/ {print $2; exit}' /proc/meminfo 2>/dev/null || echo "0")
RAM_MB=$((RAM_KB/1024))

echo "CPU model: ${CPU_MODEL:-unknown}"
echo "CPU cores: ${CPU_CORES:-unknown}"
echo "RAM (MB): ${RAM_MB:-unknown}"

printf "\n--- Warmup (%d runs) ---\n" "$WARMUP"
for i in $(seq 1 "$WARMUP"); do
  echo "Warmup #$i..."
  if ! bash -c "$CMD" >/dev/null 2>&1; then
    echo "Warmup run failed (exit != 0). Aborting." >&2
    exit 1
  fi
done

printf "\n--- Measurements (%d runs) ---\n" "$ITERATIONS"
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

for i in $(seq 1 "$ITERATIONS"); do
  echo "Run #$i..."
  START=$(date +%s%N)
  if ! bash -c "$CMD" >/dev/null 2>&1; then
    echo "Run #$i failed (exit != 0). Aborting." >&2
    exit 1
  fi
  END=$(date +%s%N)
  ELAPSED_MS=$(((END-START)/1000000))
  echo "$ELAPSED_MS" >> "$TMPFILE"
  echo "  ${ELAPSED_MS} ms"
done

COUNT=$(wc -l < "$TMPFILE" | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
  echo "No measurements recorded." >&2
  exit 1
fi

MIN=$(sort -n "$TMPFILE" | head -n1)
MAX=$(sort -n "$TMPFILE" | tail -n1)

# median
MEDIAN=$(sort -n "$TMPFILE" | awk -v n="$COUNT" ' {a[++i]=$1} END { if (n%2==1) print a[(n+1)/2]; else print (a[n/2]+a[n/2+1])/2 }')

# p95 index (ceiling)
P95_IDX=$(awk -v n=$COUNT 'BEGIN{printf "%d", (n*0.95==int(n*0.95)?n*0.95:int(n*0.95)+1)}')
P95=$(sort -n "$TMPFILE" | awk -v idx="$P95_IDX" 'NR==idx{print; exit}')

printf "\n--- Summary ---\n"
echo "Command: $CMD"
echo "Iterations: $ITERATIONS"
echo "Min (ms): $MIN"
echo "Median (ms): $MEDIAN"
echo "P95 (ms): ${P95:-$MAX}"
echo "Max (ms): $MAX"

exit 0
