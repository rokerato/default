#!/usr/bin/env bash
# Codex teammate (OpenAI): run one task brief headlessly via `codex exec`.
#
# Authenticate once with `codex login` — this uses your ChatGPT account, so
# your existing ChatGPT plan powers this teammate.
#
# `--sandbox workspace-write` lets it edit files inside its workdir without
# prompting (it replaces `--full-auto`, which now warns as deprecated).
# `--skip-git-repo-check` is needed because codex otherwise refuses to start in
# a plain scratch directory: "Not inside a trusted directory". Stdin is closed
# so codex doesn't block reading a second prompt from the pipe when run
# non-interactively.
set -euo pipefail

: "${CODEX_BIN:=codex}"

if [[ "${1:-}" == "--check" ]]; then
  command -v "$CODEX_BIN" >/dev/null
  exit $?
fi

brief="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
workdir="${2:-$PWD}"

cd "$workdir"
exec "$CODEX_BIN" exec \
  --sandbox workspace-write \
  --skip-git-repo-check \
  "$(cat "$brief")" </dev/null
