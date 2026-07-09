#!/usr/bin/env bash
# run_tests.sh - run the four classify_design tests in parallel.
#
# Usage:
#   ./run_tests.sh           # auto-detect stata-mp / stata-se / stata
#   STATA=stata-se ./run_tests.sh
#
# Each test writes to test_<design>.log; this script tails the result and
# prints a final pass/fail summary.

set -u
cd "$(dirname "$0")"

# --- Detect the Stata executable (override with STATA env var) ------------
if [[ -n "${STATA:-}" ]]; then
    :  # respect user override
elif command -v stata-mp >/dev/null 2>&1; then
    STATA=stata-mp
elif command -v stata-se >/dev/null 2>&1; then
    STATA=stata-se
elif command -v StataMP >/dev/null 2>&1; then
    STATA=StataMP
elif command -v StataSE >/dev/null 2>&1; then
    STATA=StataSE
elif command -v stata >/dev/null 2>&1; then
    STATA=stata
else
    echo "Error: no Stata executable found." >&2
    echo "Set STATA=/path/to/your/stata and re-run." >&2
    exit 1
fi
echo "Using Stata: $STATA"

TESTS=(cla sad sfsd had)

# --- Launch tests in parallel --------------------------------------------
declare -a PIDS=()
for t in "${TESTS[@]}"; do
    rm -f "test_${t}.log"
    echo "  -> launching test_${t}.do"
    "$STATA" -b do "test_${t}.do" >/dev/null 2>&1 &
    PIDS+=($!)
done

# --- Wait for all ---------------------------------------------------------
FAIL=0
for i in "${!PIDS[@]}"; do
    if ! wait "${PIDS[$i]}"; then
        FAIL=1
    fi
done

# --- Summarise ------------------------------------------------------------
echo
echo "=================== classify_design test summary ==================="
for t in "${TESTS[@]}"; do
    log="test_${t}.log"
    if [[ ! -f "$log" ]]; then
        printf "  %-6s  NO LOG\n" "$t"
        FAIL=1
        continue
    fi
    if grep -qE "assertion is false|r\([0-9]+\)" "$log"; then
        printf "  %-6s  FAIL  (see %s)\n" "$t" "$log"
        FAIL=1
    elif grep -q "PASS" "$log"; then
        printf "  %-6s  PASS\n" "$t"
    else
        printf "  %-6s  UNKNOWN  (see %s)\n" "$t" "$log"
        FAIL=1
    fi
done
echo "===================================================================="

exit "$FAIL"
