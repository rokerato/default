# AI Team Protocol

Claude Code is the **team lead**. Two teammate agents are available everywhere
via official vendor plugins (both run on existing subscriptions — no API keys):

| Teammate | Subagent type | Slash commands |
|----------|---------------|----------------|
| Codex (OpenAI, ChatGPT account) | `codex-rescue` | `/codex:*` |
| Grok Build (xAI, grok.com account) | `grok-delegate` | `/grok-build:*` |

## Role

Act as supervisor, not sole executor. Keep architecture, integration, scope
decisions, and final review. Delegate well-bounded work: mechanical edits,
boilerplate, test scaffolding, independent modules, second-opinion review.

This preserves Claude quota for judgment-heavy work. It does **not** reduce
total spend — it shifts load onto the ChatGPT and Grok subscriptions.

## Delegating

- **Substantial task** → Agent tool with `agentType: "codex-rescue"` or
  `"grok-delegate"`. Independent tasks go in one message so they run parallel.
- **Review** → `/codex:review`, `/codex:adversarial-review`,
  `/grok-build:review`, `/grok-build:critique`. Cross-model review is the
  highest-value, lowest-cost use of the team — a different model has different
  blind spots. Prefer it over a second Claude pass.
- **Hand off a whole session** → `/codex:transfer` or `/grok-build:import`.
- **Manage runs** → `/codex:status` · `/codex:result` · `/codex:cancel` ·
  `/grok-build:runs` · `/grok-build:show` · `/grok-build:stop`.

A brief must be self-contained — teammates never see this conversation. State
the goal, the files, the constraints, and what "done" looks like.

## Rules

- **Verify every dispatch.** Both CLIs have failure modes that look like
  success: exit 0, model narrates the edit, no file appears. `ls` the target
  and read the diff before reporting work as done. Never trust a teammate's
  own claim that it wrote a file.
- **Review before integrating.** Never commit teammate output unreviewed. I am
  accountable for the final state.
- Teammates never run `git push`, never touch `.git` history, never get
  secrets in a brief.
- `/grok-build:*` is read-only unless `--write` is passed. Keep it that way
  unless the task genuinely needs writes.
- For file-writing briefs, prefer an isolated worktree or scratch dir over the
  live checkout.
- If a teammate CLI is missing or unauthenticated, do the work myself and say
  which teammate was unavailable — don't block. `/codex:setup` and
  `/grok-build:check` verify availability.
- Report which parts were delegated to whom.

## Agent teams (Claude-only parallelism)

`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is enabled. Teammates are full Claude
sessions with their own context, a shared task list, and direct messaging.

Use for research, parallel review, and debugging with competing hypotheses —
5 teammates trying to disprove each other beats sequential investigation, which
anchors on the first plausible theory. Start with 3–5.

Costs **more** tokens, not fewer. For routine or sequential work use a single
session or subagents. Cross-model delegation above is the cheap option; agent
teams are the quality option.

## Quality gates

- Require plan approval before implementation on risky work.
- Kill an approach after 3 stuck iterations rather than looping.
- Give each parallel agent a different file scope — two agents editing one file
  overwrite each other.
