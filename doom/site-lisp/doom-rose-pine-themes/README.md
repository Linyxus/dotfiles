# doom-rose-pine-themes

[Rosé Pine](https://rosepinetheme.com) for Emacs, built on
[doom-themes](https://github.com/doomemacs/themes).

| Theme                 | Variant         |
|-----------------------|-----------------|
| `doom-rose-pine`      | Rosé Pine       |
| `doom-rose-pine-moon` | Rosé Pine Moon  |
| `doom-rose-pine-dawn` | Rosé Pine Dawn  |

All three share one face mapping in `doom-rose-pine-themes.el`; each theme file
just picks a palette. Syntax roles follow the upstream Neovim port (keywords
pine, functions rose, strings/constants gold, types/properties foam, builtins
love, comments muted italic). On top of the doom-themes base faces it styles
the cursor, search, the mode line and doom-modeline evil states, vertico,
corfu, orderless, lsp highlights, diffs, org/markdown headings, rainbow
delimiters and the terminal ANSI colors (term, vterm, ansi-color) to match
Rosé Pine's own terminal themes.

## Install

This package lives in my dotfiles at `doom/site-lisp/doom-rose-pine-themes`.
In `$DOOMDIR/packages.el`:

```elisp
(package! doom-rose-pine-themes
  :recipe (:local-repo "site-lisp/doom-rose-pine-themes"))
```

In `$DOOMDIR/config.el`:

```elisp
(setq doom-theme 'doom-rose-pine)   ; or doom-rose-pine-moon / doom-rose-pine-dawn
```

Then run `doom sync` and restart. It is a self-contained package, so it can be
moved to its own repository later and installed with
`:recipe (:host github :repo "...")` instead.

## Hacking

Palettes live in `doom-rose-pine-palettes`; faces are defined once in
`doom-rose-pine-define-theme`. After editing, re-run `M-x load-theme` (Doom:
`SPC h r t`) to see the change.
