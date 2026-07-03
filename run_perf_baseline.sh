#!/bin/sh
# FITPACK Performance Baseline
# Times each test program and records wall time
# Usage: ./run_perf_baseline.sh
#
# Output: baselines/perf_baseline.json
# Records: wall time in seconds per test, system info, compiler version

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR"
EX_DIR="$SRC_DIR/ex"
BUILD_DIR="$SRC_DIR/build"
BASELINE_DIR="$SRC_DIR/baselines"
OUT="$BASELINE_DIR/perf_baseline.json"

mkdir -p "$BUILD_DIR" "$BASELINE_DIR"

LIB_SOURCES=""
for f in "$SRC_DIR"/*.f; do
    LIB_SOURCES="$LIB_SOURCES $f"
done

# System info
GFORTRAN_VER=$(gfortran --version 2>&1 | head -1)
OS=$(uname -s)
ARCH=$(uname -m)
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "FITPACK Performance Baseline"
echo "============================"
echo "Compiler: $GFORTRAN_VER"
echo "System:   $OS $ARCH"
echo "Date:     $DATE"
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

# Build JSON manually (no jq dependency)
printf '{\n' > "$OUT"
printf '  "date": "%s",\n' "$DATE" >> "$OUT"
printf '  "compiler": "%s",\n' "$GFORTRAN_VER" >> "$OUT"
printf '  "os": "%s",\n' "$OS" >> "$OUT"
printf '  "arch": "%s",\n' "$ARCH" >> "$OUT"
printf '  "optimisation": "-O2",\n' >> "$OUT"
printf '  "note": "Wall time in seconds. Each test run 3 times, median recorded.",\n' >> "$OUT"
printf '  "tests": {\n' >> "$OUT"

FIRST=1

for TEST_SRC in "$EX_DIR"/mn*.f; do
    STEM=$(basename "$TEST_SRC" .f)
    EXE="$BUILD_DIR/perf_$STEM"
    DATA=$(data_file_for "$STEM")

    # Compile with optimisation
    if ! gfortran -O2 -w -o "$EXE" "$TEST_SRC" $LIB_SOURCES 2>/dev/null; then
        continue
    fi

    # Run 3 times and take median
    T1=""; T2=""; T3=""

    run_timed() {
        if [ -n "$DATA" ] && [ -f "$EX_DIR/$DATA" ]; then
            { time "$EXE" < "$EX_DIR/$DATA" > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}'
        else
            { time "$EXE" > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}'
        fi
    }

    # Convert "0m0.012s" to seconds as float
    to_secs() {
        printf "%s\n" "$1" | sed 's/m/:/g' | sed 's/s//g' | awk -F: '{printf "%.4f", $1*60+$2}'
    }

    T1=$(to_secs "$(run_timed)")
    T2=$(to_secs "$(run_timed)")
    T3=$(to_secs "$(run_timed)")

    # Median of 3
    MED=$(printf "%s\n%s\n%s\n" "$T1" "$T2" "$T3" | sort -n | sed -n '2p')

    printf "  %-15s %.4fs\n" "$STEM" "$MED"

    if [ "$FIRST" = "1" ]; then
        FIRST=0
    else
        printf ',\n' >> "$OUT"
    fi
    printf '    "%s": {"wall_sec": %s, "runs": [%s, %s, %s]}' \
        "$STEM" "$MED" "$T1" "$T2" "$T3" >> "$OUT"
done

printf '\n  }\n}\n' >> "$OUT"

echo ""
echo "Performance baseline written to: $OUT"
