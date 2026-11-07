# claude-design-skill

A standalone copy of the `design` skill bundled with Claude Code 2.1.270
(the Claude Design canvas editor preview). Extracted 2026-09-14.

Contents:

- `SKILL.md` — the skill instructions (frontmatter + guidelines), decompressed
  from the zstd asset `SKILL-59d7da6d.md.zst` inside the Claude Code binary.
- `seed-canvas.mjs` — the helper that seeds `.dc.html` artboards, `canvas.json`
  and images into a fresh copy of the editor payload (`--check`, `--extract`).
- `payload.template.html` — the precompiled canvas editor (~2.4 MB, minified).
  Never read it into a model context; only copy and seed it with the helper.

Install as a user skill (Claude Code resolves `<base directory>` in SKILL.md to
the folder that holds it):

```bash
ln -s ~/workspace/claude-design-skill ~/.claude/skills/claude-design
```

Rename the frontmatter `name:` if you want it to coexist with the bundled
`/design` rather than shadow it. Note the editor payload pins Artifact runtime
contract `0.1.31`; a later Claude Code build may ship a newer payload.
