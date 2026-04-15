#!/usr/bin/env bash
# Ralph Wiggum loop — run Claude Code repeatedly against PROMPT.md until the
# backlog in specs/ is fully checked off.
#
# Usage:
#   ./ralph.sh                 # run forever
#   ./ralph.sh 10              # run at most 10 iterations
#   MODEL=claude-sonnet-4-6 ./ralph.sh
#
# Reference: https://ghuntley.com/ralph/

set -euo pipefail

MODEL="${MODEL:-claude-opus-4-6}"
MAX_ITERS="${1:-0}"            # 0 = unlimited
PROMPT_FILE="${PROMPT_FILE:-PROMPT.md}"
LOG_DIR="${LOG_DIR:-.ralph/logs}"
STOP_FILE="${STOP_FILE:-.ralph/STOP}"

mkdir -p "$LOG_DIR"
rm -f "$STOP_FILE"

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found in PATH" >&2
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "error: $PROMPT_FILE not found" >&2
  exit 1
fi

iter=0
while :; do
  iter=$((iter + 1))
  ts="$(date +%Y%m%d-%H%M%S)"
  log="$LOG_DIR/iter-$(printf '%04d' "$iter")-$ts.log"

  echo "=== Ralph iteration $iter ($ts) — logging to $log ==="

  # Feed PROMPT.md to Claude Code in non-interactive mode.
  # --dangerously-skip-permissions lets the loop run unattended; run only
  # inside an isolated dev env or a throwaway worktree.
  if ! claude -p \
      --model "$MODEL" \
      --dangerously-skip-permissions \
      < "$PROMPT_FILE" \
      2>&1 | tee "$log"; then
    echo "warn: iteration $iter exited non-zero — continuing"
  fi

  # Auto-commit any changes produced this iteration.
  if [[ -d .git ]] && ! git diff --quiet || ! git diff --cached --quiet; then
    git add -A
    git -c user.email="${GIT_EMAIL:-ralph@localhost}" \
        -c user.name="${GIT_NAME:-Ralph Loop}" \
        commit -m "ralph: iteration $iter" || true
  fi

  # Exit conditions.
  if [[ -f "$STOP_FILE" ]]; then
    echo "=== STOP file detected — exiting after iteration $iter ==="
    break
  fi

  if [[ "$MAX_ITERS" -gt 0 && "$iter" -ge "$MAX_ITERS" ]]; then
    echo "=== reached MAX_ITERS=$MAX_ITERS — exiting ==="
    break
  fi

  # Small breather so the user can ^C between runs.
  sleep 2
done
