#!/usr/bin/env bash
set -euo pipefail

# Simple portable benchmarking helper
# Usage: ./scripts/bench.sh [iterations] [warmup] "<command>"
# Example: ./scripts/bench.sh 20 2 "go run day1/main.go -part 1"

QUIET=0
if [[ "$1" == "-q" || "$1" == "--quiet" ]]; then
  QUIET=1
  shift
fi
ITERATIONS=${1:-10}
WARMUP=${2:-1}
CMD=${3:-}
if [ -z "$CMD" ]; then
  echo "Usage: $0 [-q|--quiet] [iterations] [warmup] \"<command>\"" >&2
  exit 2
fi


echo -e "# Benchmark Results\n"
# print the command wrapped in markdown code ticks without emitting literal backslashes
printf '**Command:** `%s`\n' "$CMD"
echo "**Iterations:** $ITERATIONS, **Warmup:** $WARMUP"

# System info as Markdown
echo -e "\n## System Information\n"
echo '```'
# System information (Linux and macOS-aware)
if [ "$(uname -s)" = "Darwin" ]; then
  # macOS
  if command -v system_profiler >/dev/null 2>&1; then
    # Prefer the human-friendly Chip or Processor Name field which may contain
    # "Apple M2 Pro" on Apple Silicon or the Intel processor name on Intel Macs.
    CPU_MODEL=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F: '/Chip|Processor Name/ {print $2; exit}' | sed 's/^ *//')
  else
    # Fallbacks: try common sysctl keys
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.model 2>/dev/null || echo "unknown")
  fi
  CPU_CORES=$(sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
  RAM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
  RAM_MB=$((RAM_BYTES/1024/1024))
else
  # Assume Linux-like environment
  if command -v lscpu >/dev/null 2>&1; then
    CPU_MODEL=$(lscpu 2>/dev/null | awk -F: '/Model name|Model/ {print $2; exit}' | sed 's/^ *//')
  else
    CPU_MODEL=$(awk -F: '/model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null | sed 's/^ *//') || CPU_MODEL="unknown"
  fi
  CPU_CORES=$(nproc 2>/dev/null || echo "unknown")
  RAM_KB=$(awk '/MemTotal/ {print $2; exit}' /proc/meminfo 2>/dev/null || echo "0")
  RAM_MB=$((RAM_KB/1024))
fi

echo "CPU model: ${CPU_MODEL:-unknown}"
echo "CPU cores: ${CPU_CORES:-unknown}"
echo "RAM (MB): ${RAM_MB:-unknown}"
echo '```'

echo -e "\n## Warmup (${WARMUP} runs)\n"
if [ "$QUIET" -eq 0 ]; then
  echo '```'
fi
for i in $(seq 1 "$WARMUP"); do
  if [ "$QUIET" -eq 0 ]; then
    echo -n "Warmup #$i: "
  fi
  elapsed=$( { TIMEFORMAT=%R; time bash -c "$CMD" >/dev/null 2>&1; } 2>&1 ) || {
    echo "Warmup run failed (exit != 0). Aborting." >&2
    exit 1
  }
  ELAPSED_MS=$(awk -v t="$elapsed" 'BEGIN{printf "%d", t*1000}')
  if [ "$QUIET" -eq 0 ]; then
    echo "${ELAPSED_MS} ms"
  fi
done
if [ "$QUIET" -eq 0 ]; then
  echo '```'
fi

echo -e "\n## Measurements (${ITERATIONS} runs)\n"
TMPFILE=$(mktemp)
MEMFILE=$(mktemp)
trap 'rm -f "$TMPFILE" "$MEMFILE"' EXIT

# Determine platform for memory measurement
UNAME_OS=$(uname -s)

if [ "$QUIET" -eq 0 ]; then
  echo '```'
fi
for i in $(seq 1 "$ITERATIONS"); do
  if [ "$QUIET" -eq 0 ]; then
    echo -n "Run #$i: "
  fi
  
  # Capture both elapsed time and memory usage
  TMPSTDERR=$(mktemp)
  if [ "$UNAME_OS" = "Darwin" ]; then
    # macOS: use /usr/bin/time -l which outputs max resident set size in kilobytes
    elapsed=$( { TIMEFORMAT=%R; time /usr/bin/time -l bash -c "$CMD" >/dev/null 2>"$TMPSTDERR"; } 2>&1 ) || {
      echo "Run #$i failed (exit != 0). Aborting." >&2
      rm -f "$TMPSTDERR"
      exit 1
    }
    # Extract max resident set size (in KB) from macOS time output
    MEM_KB=$(awk '/maximum resident set size/{print int($1)}' "$TMPSTDERR" 2>/dev/null || echo "0")
  elif [ "$UNAME_OS" = "Linux" ]; then
    # Linux: use GNU time with -v flag
    elapsed=$( { TIMEFORMAT=%R; time /usr/bin/time -v bash -c "$CMD" >/dev/null 2>"$TMPSTDERR"; } 2>&1 ) || {
      echo "Run #$i failed (exit != 0). Aborting." >&2
      rm -f "$TMPSTDERR"
      exit 1
    }
    # Extract max resident set size (in KB) from Linux time output
    MEM_KB=$(awk '/Maximum resident set size/{print int($6)}' "$TMPSTDERR" 2>/dev/null || echo "0")
  else
    elapsed=$( { TIMEFORMAT=%R; time bash -c "$CMD" >/dev/null 2>&1; } 2>&1 ) || {
      echo "Run #$i failed (exit != 0). Aborting." >&2
      rm -f "$TMPSTDERR"
      exit 1
    }
    MEM_KB="0"
  fi
  
  ELAPSED_MS=$(awk -v t="$elapsed" 'BEGIN{printf "%d", t*1000}')
  echo "$ELAPSED_MS" >> "$TMPFILE"
  
  # Store memory usage if available
  if [ "$MEM_KB" != "0" ]; then
    MEM_MB=$((MEM_KB / 1024))
    echo "$MEM_MB" >> "$MEMFILE"
  fi
  
  rm -f "$TMPSTDERR"
  if [ "$QUIET" -eq 0 ]; then
    echo "${ELAPSED_MS} ms"
  fi
done
if [ "$QUIET" -eq 0 ]; then
  echo '```'
fi

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

# average
AVG=$(awk '{sum+=$1} END {if (NR>0) printf "%d", sum/NR; else print "-"}' "$TMPFILE")


echo -e "\n## Summary\n"
echo '| Metric      | Value (ms) |'
echo '|-------------|------------|'
echo "| Min         | $MIN       |"
echo "| Median      | $MEDIAN    |"
echo "| Average     | $AVG       |"
echo "| P95         | ${P95:-$MAX}    |"
echo "| Max         | $MAX       |"

# Add memory stats if available
if [ -f "$MEMFILE" ] && [ -s "$MEMFILE" ]; then
  MEM_COUNT=$(wc -l < "$MEMFILE" | tr -d ' ')
  if [ "$MEM_COUNT" -gt 0 ]; then
    MEM_MIN=$(sort -n "$MEMFILE" | head -n1)
    MEM_MAX=$(sort -n "$MEMFILE" | tail -n1)
    MEM_AVG=$(awk '{sum+=$1} END {printf "%.0f", sum/NR}' "$MEMFILE")
    echo ""
    echo '| Memory      | Value (MB) |'
    echo '|-------------|------------|'
    echo "| Min         | $MEM_MIN   |"
    echo "| Average     | $MEM_AVG   |"
    echo "| Max         | $MEM_MAX   |"
  fi
fi

exit 0
