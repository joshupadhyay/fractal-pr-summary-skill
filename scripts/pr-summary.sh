#!/usr/bin/env bash
set -euo pipefail

SEEN_FILE="$HOME/.pr-summary-seen"

# Clear mode (no dependencies needed)
if [[ "${1:-}" == "--clear" ]]; then
  rm -f "$SEEN_FILE"
  echo "PR summary history cleared."
  exit 0
fi

# Check dependencies
if ! command -v gh &>/dev/null; then
  echo "Error: gh (GitHub CLI) is not installed. Install it from https://cli.github.com/" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Install it with: brew install jq" >&2
  exit 1
fi

TODAY=$(date +%Y-%m-%d)

# Auto-clear if file is from a previous day
if [[ -f "$SEEN_FILE" ]]; then
  file_date=$(head -1 "$SEEN_FILE")
  if [[ "$file_date" != "$TODAY" ]]; then
    rm -f "$SEEN_FILE"
  fi
fi

# Initialize seen file with today's date as first line
if [[ ! -f "$SEEN_FILE" ]]; then
  echo "$TODAY" > "$SEEN_FILE"
fi

# Fetch today's PRs across all repos
prs=$(gh search prs --author=@me --created=">=${TODAY}" --json url,title,state --limit 100 2>/dev/null)

if [[ -z "$prs" || "$prs" == "[]" ]]; then
  echo "No PRs found for today ($TODAY)."
  exit 0
fi

total=$(echo "$prs" | jq length)

echo "=== PR Summary for $TODAY ==="
echo ""

new_count=0
while IFS= read -r pr; do
  url=$(echo "$pr" | jq -r '.url')
  title=$(echo "$pr" | jq -r '.title')
  state=$(echo "$pr" | jq -r '.state')

  # Skip if already seen
  if grep -qxF "$url" "$SEEN_FILE"; then
    continue
  fi

  echo "  $url"
  echo "  Status: $state | $title"
  echo ""

  echo "$url" >> "$SEEN_FILE"
  new_count=$((new_count + 1))
done < <(echo "$prs" | jq -c '.[]')

if [[ "$new_count" -eq 0 ]]; then
  echo "No new PRs since last check."
fi

echo "---"
echo "New: $new_count | Total today: $total"
