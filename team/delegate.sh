#!/usr/bin/env bash
# Dispatch a task brief to an AI teammate CLI, non-interactively.
#
# Usage:
#   team/delegate.sh <agent> <brief-file> [workdir]
#   team/delegate.sh --check          # report which teammates are usable
#
# Agents are defined as wrapper scripts in team/agents.d/<agent>.sh.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
agents_dir="$here/agents.d"

list_agents() {
  for f in "$agents_dir"/*.sh; do
    basename "$f" .sh
  done
}

if [[ "${1:-}" == "--check" ]]; then
  for a in $(list_agents); do
    if "$agents_dir/$a.sh" --check >/dev/null 2>&1; then
      echo "$a: available"
    else
      echo "$a: NOT available (CLI missing or unauthenticated)"
    fi
  done
  exit 0
fi

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <agent> <brief-file> [workdir]  (agents: $(list_agents | tr '\n' ' '))" >&2
  exit 2
fi

agent="$1"
brief="$2"
workdir="${3:-$PWD}"

script="$agents_dir/$agent.sh"
if [[ ! -x "$script" ]]; then
  echo "unknown agent '$agent' (available: $(list_agents | tr '\n' ' '))" >&2
  exit 2
fi
if [[ ! -f "$brief" ]]; then
  echo "brief file not found: $brief" >&2
  exit 2
fi

exec "$script" "$(cd "$(dirname "$brief")" && pwd)/$(basename "$brief")" "$workdir"
