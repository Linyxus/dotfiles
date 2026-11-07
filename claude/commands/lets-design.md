---
description: Open a design question — design it well with the design skill, delivered as local static HTML pages
argument-hint: <what you want designed>
allowed-tools: Read, Grep, Glob, Bash(node:*)
---
This is an open design question: $ARGUMENTS

Act as a talented designer and make a well-thought design.

Load the `claude-code-design` skill (installed as a personal skill — invoke it with the Skill tool) and follow its workflow: match any existing design system in this project first, author the artboards, seed the canvas with seed-canvas.mjs, and run its --check.

Present your design to me when it is ready.

Hard rule — NO artifact publication. Skip the skill's publish step entirely: never call the Artifact tool, never publish, upload, or share anything. Instead, leave the design as local static HTML page(s) in the working tree and give me the file path(s) so I can review them in my browser.
