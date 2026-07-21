#!/usr/bin/env bash
# Grok Build teammate: run one task brief headlessly.
#
# Headless mode is `-p/--single <PROMPT>`, or `--prompt-file <PATH>` to read the
# prompt from a file — we use the latter since briefs are files. Requires prior
# interactive login (`grok login`) or XAI_API_KEY.
#
# `--always-approve` is required for the teammate to actually run tools: the
# config default is `permission_mode = "ask"`, and headless there is nobody to
# ask, so writes are silently skipped (the model narrates the edit but no file
# appears). `--permission-mode acceptEdits` does NOT fix this; only
# `--always-approve` does. Mirror of codex.sh's `--full-auto`.
#
# Set GROK_WORKTREE to run the task in an isolated git worktree instead of the
# live checkout (protocol step 3): GROK_WORKTREE=1 for an auto-named one, or
# GROK_WORKTREE=<name> to name it. The worktree is created here with
# `git worktree add`, NOT with grok's own `-w/--worktree` flag — that flag is
# silently ignored in headless mode and the teammate writes straight into the
# live checkout, which is exactly what the protocol forbids.
#
# The worktree is left in place afterwards for the lead to review; remove it
# with `git worktree remove <path>` once integrated.
set -euo pipefail

: "${GROK_BIN:=grok}"

if [[ "${1:-}" == "--check" ]]; then
  command -v "$GROK_BIN" >/dev/null
  exit $?
fi

brief="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
workdir="${2:-$PWD}"

if [[ -n "${GROK_WORKTREE:-}" ]]; then
  if ! repo="$(git -C "$workdir" rev-parse --show-toplevel 2>/dev/null)"; then
    echo "GROK_WORKTREE set but '$workdir' is not a git repository" >&2
    exit 2
  fi
  name="$GROK_WORKTREE"
  [[ "$name" == "1" ]] && name="task-$$"
  worktree="$(dirname "$repo")/$(basename "$repo")-wt-$name"
  if [[ ! -d "$worktree" ]]; then
    git -C "$repo" worktree add -b "grok/$name" "$worktree" HEAD >&2
  fi
  echo "grok: running in worktree $worktree (branch grok/$name)" >&2
  workdir="$worktree"
fi

cd "$workdir"
exec "$GROK_BIN" --always-approve --prompt-file "$brief"
