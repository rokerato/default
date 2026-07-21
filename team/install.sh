#!/usr/bin/env bash
# Install the AI team scaffold into another project (or ~/.claude for a
# global install).
#
# Usage:
#   team/install.sh [target-dir]     # default: current directory
#
# Copies the team/ scripts into <target>/team/ and appends the "AI Team
# Protocol" section to <target>/CLAUDE.md (creating it if absent, skipping if
# the section is already there). The teammate CLIs (grok, codex) are NOT
# installed by this — install and authenticate those once, globally, yourself.
set -euo pipefail

src_team="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_root="$(dirname "$src_team")"
target="${1:-$PWD}"

if [[ ! -f "$src_root/CLAUDE.md" ]]; then
  echo "can't find source CLAUDE.md next to team/ — run this from a scaffold checkout" >&2
  exit 1
fi

mkdir -p "$target/team"
# Copy scripts and template; preserve the executable bit.
cp -p "$src_team/delegate.sh" "$src_team/install.sh" "$target/team/"
cp -pr "$src_team/agents.d" "$target/team/"
mkdir -p "$target/team/briefs"
cp -p "$src_team/briefs/TEMPLATE.md" "$target/team/briefs/"
echo "installed team/ scripts into $target/team/"

# Append the protocol to the target CLAUDE.md unless it's already present.
if [[ -f "$target/CLAUDE.md" ]] && grep -q "^# AI Team Protocol" "$target/CLAUDE.md"; then
  echo "CLAUDE.md already has the AI Team Protocol — left as-is"
else
  # Extract the section from the source CLAUDE.md (header to EOF).
  section="$(awk '/^# AI Team Protocol/{p=1} p' "$src_root/CLAUDE.md")"
  if [[ -f "$target/CLAUDE.md" ]]; then
    printf '\n\n%s\n' "$section" >>"$target/CLAUDE.md"
    echo "appended AI Team Protocol to existing $target/CLAUDE.md"
  else
    printf '%s\n' "$section" >"$target/CLAUDE.md"
    echo "created $target/CLAUDE.md with the AI Team Protocol"
  fi
fi

cat >&2 <<'NOTE'

heads-up: the installed teammates auto-approve their own tool calls
(grok.sh --always-approve, codex.sh --sandbox workspace-write) so they can
work non-interactively. That means a delegated teammate runs tools
unsupervised in whatever directory it's given. To keep that sandboxed, set
GROK_WORKTREE=1 (see team/agents.d/grok.sh) so writes land in a throwaway
git worktree you review before integrating, rather than the live checkout.
NOTE
echo "done — run 'team/delegate.sh --check' in $target to verify the teammates."
