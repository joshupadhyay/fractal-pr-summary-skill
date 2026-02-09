#!/usr/bin/env bash
# Tests for pr-summary.sh dependency checks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/scripts/pr-summary.sh"
PASS=0
FAIL=0

run_test() {
  local name="$1"
  local expected_exit="$2"
  local expected_msg="$3"
  shift 3

  output=$("$@" 2>&1) || true
  actual_exit=${PIPESTATUS[0]:-$?}

  # Re-run to capture exit code properly
  set +e
  output=$("$@" 2>&1)
  actual_exit=$?
  set -e

  if [[ "$actual_exit" -ne "$expected_exit" ]]; then
    echo "FAIL: $name (expected exit $expected_exit, got $actual_exit)"
    FAIL=$((FAIL + 1))
    return
  fi

  if [[ -n "$expected_msg" ]] && ! echo "$output" | grep -qF "$expected_msg"; then
    echo "FAIL: $name (expected message containing '$expected_msg')"
    echo "  Got: $output"
    FAIL=$((FAIL + 1))
    return
  fi

  echo "PASS: $name"
  PASS=$((PASS + 1))
}

# Create a temp dir with a fake PATH that hides gh/jq
TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT

# Test 1: Missing gh
echo "--- Test: missing gh ---"
# Create a PATH with only basic utils (no gh, no jq)
FAKE_BIN="$TMPDIR_TEST/fake-bin"
mkdir -p "$FAKE_BIN"

# Symlink only the essentials (bash, date, head, grep, rm, cat, echo, mktemp)
for cmd in bash date head grep rm cat echo mktemp; do
  real=$(command -v "$cmd" 2>/dev/null || true)
  if [[ -n "$real" ]]; then
    ln -sf "$real" "$FAKE_BIN/$cmd"
  fi
done

# Add jq but NOT gh
jq_path=$(command -v jq 2>/dev/null || true)
if [[ -n "$jq_path" ]]; then
  ln -sf "$jq_path" "$FAKE_BIN/jq"
fi

run_test "missing gh prints error" 1 "gh (GitHub CLI) is not installed" \
  env PATH="$FAKE_BIN" bash "$SCRIPT"

# Test 2: Missing jq
echo "--- Test: missing jq ---"
FAKE_BIN2="$TMPDIR_TEST/fake-bin2"
mkdir -p "$FAKE_BIN2"

for cmd in bash date head grep rm cat echo mktemp; do
  real=$(command -v "$cmd" 2>/dev/null || true)
  if [[ -n "$real" ]]; then
    ln -sf "$real" "$FAKE_BIN2/$cmd"
  fi
done

# Add gh but NOT jq
gh_path=$(command -v gh 2>/dev/null || true)
if [[ -n "$gh_path" ]]; then
  ln -sf "$gh_path" "$FAKE_BIN2/gh"
fi

run_test "missing jq prints error" 1 "jq is not installed" \
  env PATH="$FAKE_BIN2" bash "$SCRIPT"

# Test 3: Missing both
echo "--- Test: missing both ---"
FAKE_BIN3="$TMPDIR_TEST/fake-bin3"
mkdir -p "$FAKE_BIN3"

for cmd in bash date head grep rm cat echo mktemp; do
  real=$(command -v "$cmd" 2>/dev/null || true)
  if [[ -n "$real" ]]; then
    ln -sf "$real" "$FAKE_BIN3/$cmd"
  fi
done

# gh is checked first, so expect gh error
run_test "missing both prints gh error first" 1 "gh (GitHub CLI) is not installed" \
  env PATH="$FAKE_BIN3" bash "$SCRIPT"

# Test 4: --clear works without gh/jq
echo "--- Test: --clear doesn't need deps ---"
FAKE_BIN4="$TMPDIR_TEST/fake-bin4"
mkdir -p "$FAKE_BIN4"

for cmd in bash date head grep rm cat echo mktemp; do
  real=$(command -v "$cmd" 2>/dev/null || true)
  if [[ -n "$real" ]]; then
    ln -sf "$real" "$FAKE_BIN4/$cmd"
  fi
done

run_test "--clear works without gh/jq" 0 "PR summary history cleared" \
  env PATH="$FAKE_BIN4" HOME="$TMPDIR_TEST" bash "$SCRIPT" --clear

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ "$FAIL" -eq 0 ]]
