# pr-summary

A Claude Code skill that shows your GitHub PRs for the day across all repos. Run it multiple times — it tracks what you've already seen so you only get new PRs on repeat runs.

## How it works

1. **Afternoon** — run `/pr-summary`. See all your PRs for the day so far.
2. **Evening** — run again. Only new PRs since your last check are shown.
3. **Next morning** — auto-resets. Fresh view of the new day.

Seen PRs are tracked in `~/.pr-summary-seen`, which auto-clears when the date changes.

## Output

```
=== PR Summary for 2026-02-09 ===

  https://github.com/org/repo/pull/12
  Status: open | Add authentication flow

  https://github.com/org/repo/pull/11
  Status: closed | Fix layout bug on mobile

---
New: 2 | Total today: 5
```

Each PR shows its URL, status (`open`/`closed`), and title.

## Setup

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) — authenticated with `gh auth login`
- `jq` — install with `brew install jq` on macOS
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

### Install as a Claude Code skill

Clone this repo somewhere on your machine:

```bash
git clone https://github.com/fractal-bootcamp/fractal-pr-summary-skill.git
```

Then add it to your Claude Code project settings (`.claude/settings.json`):

```json
{
  "skills": [
    "/path/to/fractal-pr-summary-skill/.claude/skills/pr-summary"
  ]
}
```

Or copy the files directly into your project:

```bash
# Copy the skill definition
cp -r .claude/skills/pr-summary /your-project/.claude/skills/

# Copy the script
cp scripts/pr-summary.sh /your-project/scripts/
chmod +x /your-project/scripts/pr-summary.sh
```

## Usage

Inside Claude Code, run:

```
/pr-summary
```

Or run the script directly:

```bash
bash scripts/pr-summary.sh
```

To force-reset the seen list mid-day:

```bash
bash scripts/pr-summary.sh --clear
```
