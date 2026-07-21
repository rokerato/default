#!/usr/bin/env bash
# Codex teammate (OpenAI): run one task brief headlessly via `codex exec`.
#
# Authenticate once with `codex login` — this uses your ChatGPT account, so
# your existing ChatGPT plan powers this teammate. `--full-auto` lets it edit
# files inside its sandboxed workdir without prompting.
set -euo pipefail

: "${CODEX_BIN:=codex}"

if [[ "${1:-}" == "--check" ]]; then
  command -v "$CODEX_BIN" >/dev/null
  exit $?
fi

brief="$1"
workdir="${2:-$PWD}"

cd "$workdir"
exec "$CODEX_BIN" exec --full-auto "$(cat "$brief")"
