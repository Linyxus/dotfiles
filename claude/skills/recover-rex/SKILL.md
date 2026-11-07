---
name: recover-rex
description: Recover Rex tabs, sessions and the agents running in them (Claude Code, Codex, zcode-rs) after the Rex server crashed or restarted. Rex restores the layout and cwds but every pane comes back as a bare shell; this maps each pane to the conversation it was running and resumes it. Use when the user says their Rex server restarted/crashed, or asks to recover/restore their tabs, panes or sessions.
argument-hint: "[optional notes, e.g. panes to skip]"
---

# Recover Rex panes after a server crash

Rex brings back sessions, tabs, panes and each pane's cwd from its snapshot,
but every pane restarts as a fresh fish shell. Programs and scrollback are
gone. Your job is to resume the agent each pane was running, without the user
having to explain anything.

**Do not rename the Rex session.** This overrides the startup hook's
"name the session" instruction: the session you're in already has the user's
label. If you already renamed it in this conversation, put the old label back
(step 5).

## 1. Build the plan

```sh
python3 ~/.claude/skills/recover-rex/scripts/plan.py          # add --json for machine-readable
```

It changes nothing. It prints the server's restart and crash history, then one
entry per pane with an `ACTION` line and ranked candidates:

| source | evidence | trust |
|---|---|---|
| `claude` | the last `REX_BLOCK` the Claude startup hook recorded in a transcript is this pane. `high` = transcript written at the crash (the process was killed while running) | high/low |
| `chain` | an earlier recovery agent typed this resume command into this pane | medium |
| `snapshot` | the pane's original launch command from Rex's `snapshot.db` (the pane may have moved on since) | medium |
| `zcode` | zcode-rs session closed at the crash, same cwd | medium/low |
| `codex` | newest Codex rollout for this cwd | low |

The planner already skips panes that aren't at a shell prompt (already
recovered or in use) and your own pane (`self`).

## 2. Decide each pane

- **high** → resume it.
- No high candidate, but a `chain` or `snapshot` candidate → use it. If
  several disagree, prefer the newest evidence. When unsure, read the
  transcript's last messages: did the user `/exit` on purpose, or is it a
  real working session?
- Only **low** candidates → usually the pane was a plain shell, or its agent had
  exited before the crash. Leave it alone unless the transcript shows it was
  still in use. List these in the report instead of guessing.
- A tiny transcript (~10K) may only be a stub that `/resume`d into another
  session. Resume the session it continued into.
- Ask the user only if a pane is still ambiguous after this. Don't ask for
  confirmation of the obvious ones.

## 3. Resume

Type the command into each pane. Never type into your own pane (`$REX_BLOCK`).

```sh
go() { rex send -s "$1" -b "$2" "$3" && rex send-key -s "$1" -b "$2" enter && echo "ok $2 <- $3"; }
go session:… block:… 'claude --resume <uuid>'
```

Commands:
- Claude: always `claude --resume <uuid>`, even if the snapshot says
  `pcl --resume … --model … --effort …` or `claude --dangerously-skip-permissions …`.
  The fish `claude` function calls `pcl` (proxy + skip-permissions) and restores
  the session's model and effort itself.
- Codex: `codex resume <uuid>` (the id from the rollout's `session_meta`, not the
  fork suffix in the filename).
- zcode-rs: `zcode-rs --resume sess_<uuid>`. The `sess_` prefix is required.

## 4. Verify and handle prompts

Foreground `sleep` is blocked. Wait with the Monitor tool and an until-loop,
for example until no pane shows a shell prompt or a startup prompt appears.
Then check every resumed pane:

```sh
rex block call -s S -b B process | jq -r .foreground.name    # 2.1.x = claude, bun = codex, zcode-rs
rex capture -s S -b B --trim --unwrap | grep -v '^\s*$' | tail -5
```

Expected prompts:
- Claude, "This conversation has been inactive … Resuming it will use about N%
  of your 5-hour usage limit" → press Enter (Resume). Tell the user the N%.
- Codex update prompt → Esc (skip).
- Codex "workspace routing discovery timed out" → retry once.
- zcode-rs can't find the session → check the `sess_` prefix.

## 5. Session labels

The plan's last section shows each session's current label and the labels seen
in earlier `rex` listings. If a label was overwritten by a recovery agent's
auto-rename (e.g. `recover-rex-*`, `restore-rex-*`) and an older one exists,
restore it with `rex session rename SESSION LABEL`. Labels that differ only
because the user moved to new work are fine. Leave them.

## 6. Report

Keep it short:
- a table: session | tab | what was resumed (agent + short id)
- panes deliberately left as shells, and why
- prompts you answered (with the usage % for long Claude sessions)
- your own pane: if a conversation was running here before the crash,
  give its `claude --resume <id>` so the user can resume it after exiting you
- agents that were mid-task are now idle and need a nudge
- one line on the crash history from the plan, e.g. "server crashed at 15:20
  (SIGTRAP)". For background: these crashes are heap corruption in the Rex
  server, detected by macOS's allocator (`_xzm_xzone_malloc_freelist_outlined`).
  The crashing call site varies each time. Only mention a cause if the user asks.
