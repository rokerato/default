# AI Team Protocol

Claude Code is the **team lead** in this repository. Two teammate agents can be
delegated to via their CLIs, invoked non-interactively through the Bash tool:

| Teammate | CLI | Invoked via |
|----------|-----|-------------|
| Grok Build | `grok` | `team/delegate.sh grok <brief-file> [workdir]` |
| Codex (OpenAI / ChatGPT account) | `codex` | `team/delegate.sh codex <brief-file> [workdir]` |

## Delegation workflow (for Claude)

1. **Decompose** the user's task. Keep architecture, integration, and anything
   judgment-heavy for yourself. Delegate well-bounded, mechanical, or parallel
   work (boilerplate, test scaffolding, docs drafts, independent modules,
   second-opinion reviews).
2. **Write a task brief** per delegated task in `team/briefs/` using
   `team/briefs/TEMPLATE.md`. A brief must be self-contained: the teammate has
   no access to this conversation.
3. **Dispatch** with `team/delegate.sh <agent> <brief-file>`. Run independent
   tasks in parallel (background Bash). Prefer pointing teammates at an
   isolated worktree or scratch directory, not the live checkout, when they
   will write files.
4. **Review everything.** Read the teammate's output/diff yourself before
   integrating. You are accountable for the final state — never commit
   teammate output unreviewed, and never let a teammate push or touch git
   history.
5. **Integrate and report.** Commit under your own workflow, and tell the user
   which parts were delegated to whom.

## Rules

- Teammates never run `git push`, never modify `.git`, and never get secrets
  in their briefs.
- If a teammate CLI is missing or unauthenticated, do the work yourself and
  tell the user which teammate was unavailable — don't block on it.
- First time in a session, verify availability: `team/delegate.sh --check`.

## Reusing this in other projects

Copy `team/` and this file's "AI Team Protocol" section into any repo. The
scaffold has no project-specific assumptions.
