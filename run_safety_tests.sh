#!/bin/sh
# FITPACK Safety Test Runner
# Usage: ./run_safety_tests.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR"
EX_DIR="$SRC_DIR/ex"
BUILD_DIR="$SRC_DIR/build"
PASS=0; FAIL=0; INFO=0

mkdir -p "$BUILD_DIR"

LIB_SOURCES=""
for f in "$SRC_DIR"/*.f; do
    LIB_SOURCES="$LIB_SOURCES $f"
done

echo "FITPACK Safety Tests"
echo "===================="

count_word() {
    printf "%s\n" "$1" | grep -c "$2" 2>/dev/null
    return 0
}

# Fortran tests
for TEST_SRC in "$EX_DIR"/safety_*.f; do
    STEM=$(basename "$TEST_SRC" .f)
    EXE="$BUILD_DIR/$STEM"

    if ! gfortran -O2 -w -o "$EXE" "$TEST_SRC" $LIB_SOURCES 2>/dev/null; then
        printf "\n--- %s ---\nCOMPILE FAILED\n" "$STEM"
        FAIL=$((FAIL+1))
        continue
    fi

    OUTPUT=$("$EXE" 2>&1) || true
    printf "\n--- %s ---\n%s\n" "$STEM" "$OUTPUT"

    P=0; F=0; I=0
    while IFS= read -r line; do
        case "$line" in
            *PASS*) P=$((P+1)) ;;
            *FAIL*) F=$((F+1)) ;;
            *INFO*) I=$((I+1)) ;;
        esac
    done << HEREDOC
$(printf "%s\n" "$OUTPUT")
HEREDOC

    PASS=$((PASS+P))
    FAIL=$((FAIL+F))
    INFO=$((INFO+I))
done

# Python tests
for TEST_SRC in "$EX_DIR"/safety_*.py; do
    [ -f "$TEST_SRC" ] || continue
    STEM=$(basename "$TEST_SRC" .py)

    printf "\n--- %s ---\n" "$STEM"
    OUTPUT=$(python3 "$TEST_SRC" 2>&1) || true
    printf "%s\n" "$OUTPUT"

    P=0; F=0; I=0
    while IFS= read -r line; do
        case "$line" in
            *PASS*) P=$((P+1)) ;;
            *FAIL*) F=$((F+1)) ;;
            *INFO*) I=$((I+1)) ;;
        esac
    done << HEREDOC
$(printf "%s\n" "$OUTPUT")
HEREDOC

    PASS=$((PASS+P))
    FAIL=$((FAIL+F))
    INFO=$((INFO+I))
done

echo ""
echo "========================"
printf "PASS: %d  FAIL: %d  INFO: %d\n" "$PASS" "$FAIL" "$INFO"
echo "(INFO = behavior documented, not necessarily wrong)"
