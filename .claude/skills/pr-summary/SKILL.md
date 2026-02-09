---
name: pr-summary
description: Displays a summary of your PRs for the day across all repos using gh CLI. Use when the user wants to review daily PRs, do an afternoon or evening check-in, or asks about their PR activity.
---

# PR Summary

Shows PRs you've authored today across all GitHub repos. Tracks which PRs have already been shown so repeat runs only display new ones.

## Usage

```bash
bash scripts/pr-summary.sh
```

**Auto-clears daily** — the seen file (`~/.pr-summary-seen`) resets automatically when the date changes. No need to clear manually in the morning.

To force-reset mid-day:

```bash
bash scripts/pr-summary.sh --clear
```

## Workflow

1. **Afternoon check-in**: Run the script. All of today's PRs are displayed and saved.
2. **Evening check-in**: Run again. Only PRs created since the afternoon are shown.
3. **Next morning**: Auto-clears. Running shows a fresh view of the new day's PRs.

## Output

Each PR shows:
- URL (e.g. `https://github.com/org/repo/pull/4`)
- Status (`open` / `closed`)
- PR title

Footer shows new count vs total for the day.

## Requirements

- `gh` CLI authenticated
- `jq` installed
