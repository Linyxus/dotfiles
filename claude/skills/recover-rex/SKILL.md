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

It changes nothing. It reads the server log to find when running programs
were killed (the crash or restart windows), then prints one entry per pane:
an `ACTION` line and ranked candidates.

| source | evidence | trust |
|---|---|---|
| `claude` | the last `REX_BLOCK` the Claude startup hook recorded in a transcript is this pane. `high` if the transcript was last written inside the kill window, which Claude does when it's killed. `low` otherwise (it exited earlier, or was killed by an older restart and never resumed) | high/low |
| `chain` | an earlier recovery agent typed this resume command into this pane | medium |
| `snapshot` | the pane's original launch command from Rex's `snapshot.db`. Agent commands are normalised to their resume form. Anything else (dev servers, editors, one-shot commands) is `low` | medium/low |
| `zcode` | zcode-rs session closed in the kill window, same cwd. `low` if several panes share the cwd | medium/low |
| `codex` | newest Codex rollout for this cwd | low |

`ACTION` is the top candidate when it's high or medium. When only low
candidates exist it says `review`, so leave that pane as a shell unless you
confirm the candidate. Panes that aren't at a shell prompt (already recovered or
in use) are skipped, and so is your own pane (`self`).

If the log doesn't show the restart (for example, it was rotated), pass
`--crash-time <epoch seconds>`.

## 2. Decide each pane

- **Resume the `ACTION` command** for high/medium panes. If two medium
  candidates disagree, prefer the newest evidence.
- **`review` panes:** read the candidate transcript's last messages. Resume
  only if it was clearly still in use. A non-agent snapshot command should only
  be re-run if it's long-running (a dev server, `tail -f`, an editor), never a
  one-shot command like `git push`, a deploy, or a test run. Otherwise list the
  pane in the report.
- **Stub transcripts:** a tiny transcript (~10K) may only be a stub that
  `/resume`d into another session. Resume the session it continued into.
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
