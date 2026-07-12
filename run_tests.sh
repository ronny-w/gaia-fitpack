#!/bin/sh
# FITPACK Test Runner
# Usage: ./run_tests.sh [--baseline | --check]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR"
EX_DIR="$SRC_DIR/ex"
BASELINE_DIR="$SRC_DIR/baselines"
BUILD_DIR="$SRC_DIR/build"
TMP_OUT="$BUILD_DIR/tmp_output.txt"
MODE="${1:---baseline}"
PASS=0; FAIL=0; SKIP=0

mkdir -p "$BASELINE_DIR" "$BUILD_DIR"

LIB_SOURCES=""
for f in "$SRC_DIR"/*.f; do
    LIB_SOURCES="$LIB_SOURCES $f"
done

echo "FITPACK Test Runner (mode: $MODE)"
echo "==================================="

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

for TEST_SRC in "$EX_DIR"/mn*.f; do
    STEM=$(basename "$TEST_SRC" .f)
    EXE="$BUILD_DIR/$STEM"
    BASELINE="$BASELINE_DIR/$STEM.expected"
    DATA=$(data_file_for "$STEM")

    if ! gfortran -O2 -w -fdefault-real-8 -fdefault-double-8 -o "$EXE" "$TEST_SRC" $LIB_SOURCES 2>/dev/null; then
        printf "  COMPILE_FAIL  %s\n" "$STEM"
        FAIL=$((FAIL+1))
        continue
    fi

    if [ -n "$DATA" ]; then
        DATA_PATH="$EX_DIR/$DATA"
        if [ ! -f "$DATA_PATH" ]; then
            printf "  SKIP          %s (missing %s)\n" "$STEM" "$DATA"
            SKIP=$((SKIP+1))
            continue
        fi
        "$EXE" < "$DATA_PATH" > "$TMP_OUT" 2>&1
        EXIT_CODE=$?
    else
        "$EXE" > "$TMP_OUT" 2>&1
        EXIT_CODE=$?
    fi

    # Detect segfault (exit code 139 on Linux, signal 11 on macOS)
    if [ $EXIT_CODE -gt 128 ]; then
        printf "  SEGFAULT      %s (exit code %d)\n" "$STEM" "$EXIT_CODE"
        FAIL=$((FAIL+1))
        continue
    fi

    if [ "$MODE" = "--baseline" ]; then
        cp "$TMP_OUT" "$BASELINE"
        printf "  BASELINE      %s\n" "$STEM"
        PASS=$((PASS+1))
    else
        if [ ! -f "$BASELINE" ]; then
            printf "  NO_BASELINE   %s\n" "$STEM"
            SKIP=$((SKIP+1))
            continue
        fi
        if diff -q "$TMP_OUT" "$BASELINE" > /dev/null 2>&1; then
            printf "  PASS          %s\n" "$STEM"
            PASS=$((PASS+1))
        else
            printf "  FAIL          %s\n" "$STEM"
            FAIL=$((FAIL+1))
        fi
    fi
done

rm -f "$TMP_OUT"
echo ""
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped"
