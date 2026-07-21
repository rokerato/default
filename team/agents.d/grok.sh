#!/usr/bin/env bash
# Grok Build teammate: run one task brief headlessly.
#
# Headless mode is `-p/--single <PROMPT>`, or `--prompt-file <PATH>` to read the
# prompt from a file — we use the latter since briefs are files. Requires prior
# interactive login (`grok login`) or XAI_API_KEY.
set -euo pipefail

: "${GROK_BIN:=grok}"

if [[ "${1:-}" == "--check" ]]; then
  command -v "$GROK_BIN" >/dev/null
  exit $?
fi

brief="$1"
workdir="${2:-$PWD}"

cd "$workdir"
exec "$GROK_BIN" --prompt-file "$brief"
