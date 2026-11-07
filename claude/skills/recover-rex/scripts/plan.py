#!/usr/bin/env python3
"""Plan the recovery of agent panes after a Rex server crash/restart.

Rex restores sessions, tabs, panes and cwds, but every pane comes back as a
bare shell. This script gathers the evidence of what each pane was running and
proposes a resume command per pane. It changes nothing.

Evidence, strongest first:
  claude   last `REX_BLOCK=block:<id>` in a Claude transcript (startup hook
           output) names the pane the session last ran in.
  chain    an earlier recovery agent typed a resume command into the pane
           (`rex send ... <block> '<cmd>'` found in a Claude transcript).
  snapshot the pane's original launch command stored in Rex's snapshot.db
           (Rex drops it on restore).
  zcode    a zcode-rs session that was closed at the crash, matched by cwd.
  codex    the newest Codex rollout for the pane's cwd (weak).

Usage: plan.py [--json] [--days N] [--crash-time EPOCH]
"""

import glob
import json
import os
import re
import shlex
import sqlite3
import subprocess
import sys
import time
from collections import defaultdict
from datetime import datetime

HOME = os.path.expanduser("~")
GREP = "/usr/bin/grep"
SHELLS = {"fish", "zsh", "bash", "sh", "-fish", "-zsh", "-bash"}
UUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
RESUME_RE = re.compile(
    r"(claude (?:--resume|-r) " + UUID + r"|codex resume " + UUID +
    r"|zcode-rs --resume sess_" + UUID + r"|pcl --resume " + UUID + r")")


def agent_command(cmd):
    """Normalise an agent resume command (pcl/cl/claude flags...) to the canonical form."""
    m = re.search(r"\b(?:claude|pcl|cl)\b.*?(?:--resume|-r) (" + UUID + ")", cmd)
    if m:
        return f"claude --resume {m.group(1)}"
    m = re.search(r"\bcodex\b.*?\bresume (" + UUID + ")", cmd)
    if m:
        return f"codex resume {m.group(1)}"
    m = re.search(r"\bzcode-rs\b.*?--resume (sess_" + UUID + ")", cmd)
    if m:
        return f"zcode-rs --resume {m.group(1)}"
    return None


def rex(*args):
    out = subprocess.run(["rex", *args], capture_output=True, text=True, timeout=30)
    if out.returncode != 0:
        raise RuntimeError(f"rex {' '.join(args)}: {out.stderr.strip()}")
    return json.loads(out.stdout) if out.stdout.strip() else None


def fmt_ts(ts):
    return datetime.fromtimestamp(ts).strftime("%m-%d %H:%M:%S") if ts else "-"


def grep_o(pattern, path, extra=()):
    r = subprocess.run([GREP, "-oE", *extra, pattern, path], capture_output=True, text=True)
    if r.returncode > 1:
        print(f"warning: grep failed on {path}: {r.stderr.strip()}", file=sys.stderr)
    return r.stdout.splitlines()


# ---------------------------------------------------------------- live state

def live_state():
    who = rex("whoami", "--json")
    self_block = os.environ.get("REX_BLOCK") or who.get("block_id")
    panes = []
    sessions = {}
    for s in rex("ls", "--json")["sessions"]:
        sid = s["session_id"]
        info = rex("session", "inspect", sid, "--json")
        sessions[sid] = info.get("label")
        wnames = {w["window_id"]: (w.get("name") or w.get("label") or w.get("title"))
                  for w in info.get("windows", [])}
        for b in rex("block", "ls", "-s", sid, "--json")["blocks"]:
            bid = b["block_id"]
            fg = {}
            try:
                fg = (rex("block", "call", "-s", sid, "-b", bid, "process") or {}).get("foreground") or {}
            except Exception:
                pass
            panes.append({
                "session_id": sid, "session": info.get("label"),
                "window_id": b.get("window_id"), "tab": wnames.get(b.get("window_id")),
                "block_id": bid, "fg": fg.get("name"), "cwd": fg.get("cwd"),
                "is_shell": (fg.get("name") in SHELLS) or (fg.get("argv0") in SHELLS),
                "self": bid == self_block,
            })
    return who, panes, sessions


def snapshot_commands(who):
    db = who["log_path"][:-len(".log")] + "/snapshot/snapshot.db"
    out = {}
    if not os.path.exists(db):
        return out
    con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
    for bid, opts in con.execute("select id, options from blocks"):
        try:
            o = json.loads(opts)
        except Exception:
            continue
        out[bid] = {"command": o.get("command"), "cwd": o.get("cwd")}
    return out


def server_history(who):
    """Restart events and crash signals from the server log: [(ts, kind, detail, prev_ts)]."""
    events, last_ts = [], None
    ts_re = re.compile(r"^(\d{4}/\d\d/\d\d \d\d:\d\d:\d\d) ")
    with open(who["log_path"], errors="replace") as f:
        for line in f:
            m = ts_re.match(line)
            if m:
                ts = time.mktime(time.strptime(m.group(1), "%Y/%m/%d %H:%M:%S"))
                if "restored saved sessions" in line:
                    clean = "clean_shutdown=true" in line
                    events.append((ts, "start", "after clean stop" if clean else "AFTER CRASH", last_ts))
                elif "Rex server stopped" in line:
                    events.append((ts, "stop", "clean", last_ts))
                last_ts = ts
            elif re.match(r"^(SIG[A-Z]+: |fatal error: |panic: )", line):
                events.append((last_ts, "crash", line.strip() + " (time = last log line before it)", last_ts))
    return events


def death_windows(events):
    """When running programs were killed, one (lo, hi, kind) per restart.

    Clean stop: around the stop. Crash: between the last log line before the
    crash and the restart (the log can be quiet for a while before a crash).
    Returns (recent, older): `recent` are the windows that ended the last
    long-lived server instance plus any crash loop after it."""
    wins, stop, crash, prev_start = [], None, None, None
    for ts, kind, _, prev_ts in events:
        if kind == "stop":
            stop = ts
        elif kind == "crash":
            crash = ts
        elif kind == "start":
            if prev_start is not None:
                if stop is not None:
                    wins.append((stop - 5, ts + 5, "clean restart", prev_start))
                else:
                    lo = crash if crash is not None else (prev_ts or ts)
                    wins.append((lo - 5, ts + 5, "crash", prev_start))
            stop = crash = None
            prev_start = ts
    recent = []
    for w in reversed(wins):
        recent.append(w)
        if w[0] - w[3] > 120:      # the instance before this window lived > 2 min
            break
    older = [w for w in wins if w not in recent]
    return recent, older


# ---------------------------------------------------------------- evidence

def recent_transcripts(since):
    files = glob.glob(f"{HOME}/.claude/projects/*/*.jsonl")
    return [(f, os.path.getmtime(f)) for f in files if os.path.getmtime(f) >= since]


HOOK_RE = r"REX_SESSION=session:" + UUID + r"\\nREX_BLOCK=block:" + UUID
# BSD grep: repetition counts must be <= 255.
SEND_RE = r"rex send.{0,250}|go \$?[A-Za-z0-9_:-]+ [0-9a-f-]{36} '[^']{0,200}'"
LABEL_RE = r'session_id\\?": ?\\?"session:' + UUID + r'\\?",(\\n| )*\\?"label\\?": ?\\?"[^"\\]+'


def scan(item):
    """One pass per transcript: the pane it last started in, plus rex send / label hits."""
    f, mt = item
    p1 =subprocess.Popen([GREP, "-F", '"hook_success"', f], stdout=subprocess.PIPE)
    p2 = subprocess.run([GREP, "-oE", HOOK_RE], stdin=p1.stdout, capture_output=True, text=True)
    p1.wait()
    hooks = p2.stdout.splitlines()
    other = grep_o(SEND_RE + "|" + LABEL_RE, f)
    return f, mt, (hooks[-1].rsplit("=", 1)[1] if hooks else None), other


def scan_all(transcripts):
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 8) as ex:
        return list(ex.map(scan, transcripts))


def claude_evidence(scans, block_ids):
    """block -> list of (mtime, session_id, path), newest first."""
    by_block = defaultdict(list)
    for f, mt, bid, _ in scans:
        if bid in block_ids:
            by_block[bid].append((mt, os.path.basename(f)[:-6], f))
    for v in by_block.values():
        v.sort(reverse=True)
    return by_block


def chain_evidence(scans, block_ids):
    """Resume commands an earlier agent typed into a pane: block -> (mtime, cmd, path)."""
    short = {b.split(":", 1)[1]: b for b in block_ids}
    found = {}
    for f, mt, _, lines in scans:
        for ln in lines:
            # one hit can span several commands; judge each command on its own
            for seg in re.split(r"(?=rex send )|;|&&|\\n", ln):
                cmd = RESUME_RE.search(seg)
                if not cmd:
                    continue
                for s, b in short.items():
                    if s in seg and (b not in found or found[b][0] < mt):
                        found[b] = (mt, agent_command(cmd.group(1)) or cmd.group(1), f)
    return found


def zcode_closed_at(windows):
    """zcode sessions whose last log event is a close inside a kill window -> {sess: (ts, cwd)}."""
    out = {}
    for log in sorted(glob.glob(f"{HOME}/.zcode/rust-cli/log/zcode-*.jsonl"))[-2:]:
        last = {}
        with open(log, errors="replace") as fh:
            for line in fh:
                if '"sessionId"' not in line:
                    continue
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                last[e.get("sessionId")] = e
        for sess, e in last.items():
            ts = datetime.fromisoformat(e["timestamp"].replace("Z", "+00:00")).timestamp()
            if e.get("event") == "session.closing" and any(lo <= ts <= hi for lo, hi, *_ in windows):
                cwd = None
                ro = f"{HOME}/.zcode/cli/rollout/model-io-{sess}.jsonl"
                if os.path.exists(ro):
                    m = grep_o(r"working directory: /[^\\\"]+", ro, ("-m", "1"))
                    if m:
                        cwd = m[0].split(": ", 1)[1].strip()
                out[sess] = (ts, cwd)
    return out


def codex_by_cwd():
    """cwd -> newest (mtime, id) Codex rollout."""
    out = {}
    for f in glob.glob(f"{HOME}/.codex/sessions/*/*/*/rollout-*.jsonl"):
        try:
            with open(f) as fh:
                meta = json.loads(fh.readline()).get("payload", {})
        except Exception:
            continue
        cwd, sid, mt = meta.get("cwd"), meta.get("id"), os.path.getmtime(f)
        if cwd and sid and (cwd not in out or out[cwd][0] < mt):
            out[cwd] = (mt, sid)
    return out


def label_history(scans, session_ids):
    """Labels seen for each session in earlier rex listings: sid -> {label: mtime}."""
    seen = defaultdict(dict)
    for f, mt, _, lines in scans:
        for hit in lines:
            m = re.search(r"(session:" + UUID + r")\\?\",.*label\\?\": ?\\?\"(.+)$", hit)
            if m and m.group(1) in session_ids:
                lab = m.group(2)
                seen[m.group(1)][lab] = max(mt, seen[m.group(1)].get(lab, 0))
    return seen


# ---------------------------------------------------------------- plan

def main():
    as_json = "--json" in sys.argv
    days = float(sys.argv[sys.argv.index("--days") + 1]) if "--days" in sys.argv else 3
    since = time.time() - days * 86400

    who, panes, sessions = live_state()
    block_ids = {p["block_id"] for p in panes}
    snap = snapshot_commands(who)
    events = server_history(who)
    hist = [e[:3] for e in events if e[0] and e[0] >= time.time() - 86400]
    recent, older = death_windows(events)
    if "--crash-time" in sys.argv:     # manual override: epoch seconds
        t = float(sys.argv[sys.argv.index("--crash-time") + 1])
        recent, older = [(t - 5, t + 5, "manual", t)], []
    scans = scan_all(recent_transcripts(since))
    claude = claude_evidence(scans, block_ids)
    chain = chain_evidence(scans, block_ids)
    zcode = zcode_closed_at(recent)
    codex = codex_by_cwd()

    def in_win(t, wins):
        return next((w for w in wins if w[0] <= t <= w[1]), None)

    plan = []
    for p in panes:
        cands = []
        for mt, sid, path in claude.get(p["block_id"], [])[:3]:
            if in_win(mt, recent):
                conf, note = "high", "running when the server went down"
            elif in_win(mt, older):
                conf, note = "low", f"killed by an earlier restart ({fmt_ts(in_win(mt, older)[1])}) and not resumed since"
            else:
                conf, note = "low", "last written outside any restart window: probably exited before"
            cands.append({"source": "claude", "cmd": f"claude --resume {sid}", "mtime": mt,
                          "confidence": conf, "note": note, "path": path})
        if p["block_id"] in chain:
            mt, cmd, path = chain[p["block_id"]]
            cands.append({"source": "chain", "cmd": cmd, "mtime": mt, "confidence": "medium",
                          "note": "typed into this pane by an earlier recovery", "path": path})
        sc = (snap.get(p["block_id"]) or {}).get("command")
        if sc:
            inner = sc[2] if len(sc) == 3 and sc[1] == "-c" and os.path.basename(sc[0]) in SHELLS else None
            raw = inner if inner is not None else shlex.join(sc)
            agent = agent_command(raw)
            if agent:
                cands.append({"source": "snapshot", "cmd": agent, "mtime": None, "confidence": "medium",
                              "note": f"original launch command: {raw}"})
            else:
                cands.append({"source": "snapshot", "cmd": raw, "mtime": None, "confidence": "low",
                              "note": "original launch command, not an agent: re-run only if long-running (server, editor, monitor)"})
        plan.append({**p, "candidates": cands})

    # cwd-based matches for panes without block-exact evidence
    for sess, (ts, cwd) in zcode.items():
        cmd = f"zcode-rs --resume {sess}"
        if any(c["cmd"] == cmd for e in plan for c in e["candidates"]):
            continue
        targets = [e for e in plan if e["cwd"] == cwd and not e["self"]
                   and not any(c["confidence"] in ("high", "medium") for c in e["candidates"])]
        for e in targets:
            e["candidates"].append({"source": "zcode", "cmd": cmd, "mtime": ts,
                                    "confidence": "medium" if len(targets) == 1 else "low",
                                    "note": "zcode-rs session closed when the server went down, same cwd"
                                            + ("" if len(targets) == 1 else f"; {len(targets)} panes share this cwd")})
    for e in plan:
        if not e["candidates"] and e["cwd"] in codex and not e["self"]:
            mt, sid = codex[e["cwd"]]
            e["candidates"].append({"source": "codex", "cmd": f"codex resume {sid}", "mtime": mt,
                                    "confidence": "low", "note": "newest Codex rollout for this cwd"})

    rank = {"high": 0, "medium": 1, "low": 2}
    for e in plan:
        e["candidates"].sort(key=lambda c: (rank[c["confidence"]], -(c["mtime"] or 0)))
        top = e["candidates"][0] if e["candidates"] else None
        if e["self"]:
            e["action"] = "self (cannot resume itself; report the top candidate to the user)"
        elif not e["is_shell"]:
            e["action"] = f"skip: already running {e['fg']}"
        elif not top:
            e["action"] = "none: no evidence (likely a plain shell)"
        elif top["confidence"] == "low":
            e["action"] = "review: only weak evidence, leave as a shell unless the candidate checks out"
        else:
            e["action"] = top["cmd"]

    labels = label_history(scans, set(sessions))
    result = {"server": {"pid": who.get("pid"), "started_at": who.get("started_at"),
                         "version": who.get("rex_version"), "log": who["log_path"]},
              "kill_windows": [{"from": w[0], "to": w[1], "kind": w[2]} for w in recent],
              "history_24h": hist, "panes": plan,
              "labels": {sid: {"current": sessions[sid], "seen": labels.get(sid, {})} for sid in sessions}}

    if as_json:
        print(json.dumps(result, indent=1, default=str))
        return

    print(f"Rex server pid {who.get('pid')} started {who.get('started_at')}  ({who.get('rex_version')})")
    for lo, hi, kind, _ in recent:
        print(f"Programs were killed by a {kind} between {fmt_ts(lo)} and {fmt_ts(hi)}")
    print("\nServer events, last 24h:")
    for ts, kind, detail in hist:
        print(f"  {fmt_ts(ts)}  {kind:5}  {detail}")
    print("\nPanes:")
    for e in plan:
        print(f"\n[{e['session']}] tab={e['tab']!r} {e['block_id']}")
        print(f"   fg={e['fg']} cwd={e['cwd']}")
        print(f"   ACTION: {e['action']}")
        for c in e["candidates"]:
            print(f"     - {c['confidence']:6} {c['source']:8} {c['cmd']}   [{fmt_ts(c['mtime'])}] {c['note']}")
    print("\nSession labels (current vs seen in earlier rex listings):")
    for sid, d in result["labels"].items():
        seen = ", ".join(f"{k} @{fmt_ts(v)}" for k, v in sorted(d["seen"].items(), key=lambda kv: -kv[1]))
        print(f"  {sid}  current={d['current']!r}  seen: {seen or '-'}")


if __name__ == "__main__":
    main()
