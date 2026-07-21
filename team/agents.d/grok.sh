#!/usr/bin/env bash
# Grok Build teammate: run one task brief headlessly.
#
# Adjust GROK_BIN and the non-interactive flag below to match your installed
# version — check `grok --help` for the one-shot/prompt flag (commonly
# `-p`/`--prompt`). Requires prior interactive login or XAI_API_KEY.
set -euo pipefail

: "${GROK_BIN:=grok}"

if [[ "${1:-}" == "--check" ]]; then
  command -v "$GROK_BIN" >/dev/null
  exit $?
fi

brief="$1"
workdir="${2:-$PWD}"

cd "$workdir"
exec "$GROK_BIN" --prompt "$(cat "$brief")"
