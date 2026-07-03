#!/bin/sh
# FITPACK Extended Performance Baseline
# Measures: wall time, CPU time, peak memory, numerical error vs baseline
# Usage: ./run_perf_baseline.sh [--json]
#
# Output: baselines/perf_baseline.json
# Requires: gfortran, /usr/bin/time (extended), gtime on macOS

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR"
EX_DIR="$SRC_DIR/ex"
BASELINE_DIR="$SRC_DIR/baselines"
BUILD_DIR="$SRC_DIR/build"
OUT="$BASELINE_DIR/perf_baseline.json"
JSON_MODE="${1}"

mkdir -p "$BUILD_DIR" "$BASELINE_DIR"

LIB_SOURCES=""
for f in "$SRC_DIR"/*.f; do
    LIB_SOURCES="$LIB_SOURCES $f"
done

# Detect time command — macOS needs gtime (brew install gnu-time)
# /usr/bin/time on macOS doesn't support -v
if command -v gtime >/dev/null 2>&1; then
    TIME_CMD="gtime"
elif /usr/bin/time --version >/dev/null 2>&1; then
    TIME_CMD="/usr/bin/time"
else
    TIME_CMD="time"
fi

# System info
GFORTRAN_VER=$(gfortran --version 2>&1 | head -1)
OS=$(uname -s)
ARCH=$(uname -m)
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
RUNS=5

echo "FITPACK Extended Performance Baseline"
echo "======================================"
echo "Compiler: $GFORTRAN_VER"
echo "System:   $OS $ARCH"
echo "Date:     $DATE"
echo "Runs per test: $RUNS"
echo ""

data_file_for() {
    case "$1" in
        mnpasu) echo "dapasu" ;;
        mnpogr) echo "dapogr" ;;
        mnpola) echo "dapola" ;;
        mnregr) echo "daregr" ;;
        mnspgr) echo "daspgr" ;;
        mnsphe) echo "dasphe" ;;
        mnsurf) echo "dasurf" ;;
        *)      echo "" ;;
    esac
}

# Median of N values
median() {
    printf "%s\n" "$@" | sort -n | awk '{a[NR]=$0} END{
        n=NR; if(n%2==1) print a[(n+1)/2];
        else printf "%.6f\n", (a[n/2]+a[n/2+1])/2
    }'
}

# Start JSON
printf '{\n' > "$OUT"
printf '  "meta": {\n' >> "$OUT"
printf '    "date": "%s",\n' "$DATE" >> "$OUT"
printf '    "compiler": "%s",\n' "$GFORTRAN_VER" >> "$OUT"
printf '    "os": "%s",\n' "$OS" >> "$OUT"
printf '    "arch": "%s",\n' "$ARCH" >> "$OUT"
printf '    "optimisation": "-O2",\n' >> "$OUT"
printf '    "runs": %d,\n' "$RUNS" >> "$OUT"
printf '    "axes": ["wall_sec","cpu_sec","peak_kb","numerical_error_max"]\n' >> "$OUT"
printf '  },\n' >> "$OUT"
printf '  "implementations": {\n' >> "$OUT"
printf '    "fortran_f77_O2": {\n' >> "$OUT"
printf '      "description": "Original Dierckx Fortran 77, gfortran -O2",\n' >> "$OUT"
printf '      "tests": {\n' >> "$OUT"

FIRST=1

for TEST_SRC in "$EX_DIR"/mn*.f; do
    STEM=$(basename "$TEST_SRC" .f)
    EXE="$BUILD_DIR/bench_$STEM"
    DATA=$(data_file_for "$STEM")
    EXPECTED="$BASELINE_DIR/$STEM.expected"

    # Compile
    if ! gfortran -O2 -w -o "$EXE" "$TEST_SRC" $LIB_SOURCES 2>/dev/null; then
        continue
    fi

    # Collect wall times and outputs
    WALL_TIMES=""
    ACTUAL_OUT=""

    i=0
    while [ $i -lt $RUNS ]; do
        if [ -n "$DATA" ] && [ -f "$EX_DIR/$DATA" ]; then
            T_START=$(date +%s%N 2>/dev/null || python3 -c "import time;print(int(time.time()*1e9))")
            ACTUAL_OUT=$("$EXE" < "$EX_DIR/$DATA" 2>/dev/null) || true
            T_END=$(date +%s%N 2>/dev/null || python3 -c "import time;print(int(time.time()*1e9))")
        else
            T_START=$(date +%s%N 2>/dev/null || python3 -c "import time;print(int(time.time()*1e9))")
            ACTUAL_OUT=$("$EXE" 2>/dev/null) || true
            T_END=$(date +%s%N 2>/dev/null || python3 -c "import time;print(int(time.time()*1e9))")
        fi
        WALL_NS=$((T_END - T_START))
        WALL_SEC=$(echo "$WALL_NS" | awk '{printf "%.6f", $1/1e9}')
        WALL_TIMES="$WALL_TIMES $WALL_SEC"
        i=$((i+1))
    done

    # Compute median wall time
    WALL_MED=$(echo $WALL_TIMES | tr ' ' '\n' | grep -v '^$' | sort -n | awk '{a[NR]=$0}END{n=NR;if(n%2==1)print a[(n+1)/2];else printf "%.6f\n",(a[n/2]+a[n/2+1])/2}')

    # Numerical error vs expected baseline
    NUM_ERR="null"
    if [ -f "$EXPECTED" ]; then
        # Extract all numbers from both outputs and compare
        NUM_ERR=$(python3 - << PYEOF
import re, sys
def nums(s):
    return [float(x) for x in re.findall(r'[-+]?\d*\.?\d+[eE]?[-+]?\d*', s) if x]
try:
    a = nums(open('$EXPECTED').read())
    b = nums("""$ACTUAL_OUT""")
    n = min(len(a),len(b))
    if n == 0:
        print("null")
    else:
        max_err = max(abs(a[i]-b[i]) for i in range(n) if a[i]!=0 or b[i]!=0)
        print(f"{max_err:.2e}")
except:
    print("null")
PYEOF
)
    fi

    # Peak memory via /proc or python resource module
    PEAK_KB=$(python3 -c "
import resource, subprocess, sys
if '$DATA' and '$DATA' != '':
    import os
    with open('$EX_DIR/$DATA') as f:
        p = subprocess.Popen(['$EXE'], stdin=f, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
else:
    p = subprocess.Popen(['$EXE'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
p.wait()
# resource.getrusage gives max RSS of children
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
kb = ru.ru_maxrss
# macOS reports bytes, Linux reports KB
import platform
if platform.system() == 'Darwin':
    kb = kb // 1024
print(kb)
" 2>/dev/null || echo "null")

    printf "  %-15s wall=%.4fs  mem=%s KB  err=%s\n" \
        "$STEM" "$WALL_MED" "$PEAK_KB" "$NUM_ERR"

    if [ "$FIRST" = "1" ]; then FIRST=0; else printf ',\n' >> "$OUT"; fi

    printf '        "%s": {\n' "$STEM" >> "$OUT"
    printf '          "wall_sec": %s,\n' "${WALL_MED:-null}" >> "$OUT"
    printf '          "peak_kb": %s,\n' "${PEAK_KB:-null}" >> "$OUT"
    printf '          "numerical_error_max": %s,\n' "${NUM_ERR:-null}" >> "$OUT"
    printf '          "runs": %d\n' "$RUNS" >> "$OUT"
    printf '        }' >> "$OUT"
done

printf '\n      }\n    }\n  }\n}\n' >> "$OUT"

echo ""
echo "Extended baseline written to: $OUT"
echo ""
echo "Axes captured:"
echo "  wall_sec           — median wall clock time over $RUNS runs"
echo "  peak_kb            — peak resident memory (KB)"
echo "  numerical_error_max — max deviation from golden baseline"
echo ""
echo "Axes planned for future implementations:"
echo "  cpu_sec            — CPU time (user+sys)"
echo "  allocations        — heap allocation count"
echo "  concurrent_calls   — throughput under N parallel threads"
echo "  cache_misses       — L1/L2/L3 (requires perf/instruments)"
