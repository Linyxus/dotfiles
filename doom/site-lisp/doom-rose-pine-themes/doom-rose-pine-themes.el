;;; doom-rose-pine-themes.el --- Rosé Pine for doom-themes -*- lexical-binding: t; -*-
;;
;; Author: linyxus <linyxus00@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (doom-themes "2.2"))
;; Keywords: faces, themes
;; SPDX-License-Identifier: MIT
;;
;;; Commentary:
;;
;; All natural pine, faux fur and a bit of soho vibes for the classy minimalist.
;; A port of Rosé Pine (https://rosepinetheme.com) built on `def-doom-theme'.
;;
;; Provides three themes sharing a single face mapping:
;;
;;   doom-rose-pine       Rosé Pine (main)
;;   doom-rose-pine-moon  Rosé Pine Moon
;;   doom-rose-pine-dawn  Rosé Pine Dawn (light)
;;
;; Syntax roles follow the upstream Neovim port: keywords are pine, functions
;; rose, strings and constants gold, types and properties foam, builtins love.
;;
;;; Code:

(require 'cl-lib)
(require 'doom-themes)

(defgroup doom-rose-pine-themes nil
  "Options for the Rosé Pine doom themes."
  :group 'doom-themes)

(eval-and-compile
  (defconst doom-rose-pine-palettes
    '((main
       (base . "#191724") (surface . "#1f1d2e") (overlay . "#26233a")
       (muted . "#6e6a86") (subtle . "#908caa") (text . "#e0def4")
       (love . "#eb6f92") (gold . "#f6c177") (rose . "#ebbcba")
       (pine . "#31748f") (foam . "#9ccfd8") (iris . "#c4a7e7")
       (hl-low . "#21202e") (hl-med . "#403d52") (hl-high . "#524f67")
       (nc . "#16141f"))
      (moon
       (base . "#232136") (surface . "#2a273f") (overlay . "#393552")
       (muted . "#6e6a86") (subtle . "#908caa") (text . "#e0def4")
       (love . "#eb6f92") (gold . "#f6c177") (rose . "#ea9a97")
       (pine . "#3e8fb0") (foam . "#9ccfd8") (iris . "#c4a7e7")
       (hl-low . "#2a283e") (hl-med . "#44415a") (hl-high . "#56526e")
       (nc . "#1f1d30"))
      (dawn
       (base . "#faf4ed") (surface . "#fffaf3") (overlay . "#f2e9e1")
       (muted . "#9893a5") (subtle . "#797593") (text . "#575279")
       (love . "#b4637a") (gold . "#ea9d34") (rose . "#d7827e")
       (pine . "#286983") (foam . "#56949f") (iris . "#907aa9")
       (hl-low . "#f4ede8") (hl-med . "#dfdad9") (hl-high . "#cecacd")
       (nc . "#f8f0e7")))
    "Rosé Pine palettes, keyed by variant.
Colors are taken verbatim from https://rosepinetheme.com/palette; `nc' is the
inactive-window background used by the upstream Neovim port.")

  (defconst doom-rose-pine--ansi
    '((love . "red") (pine . "green") (gold . "yellow") (foam . "blue")
      (iris . "magenta") (rose . "cyan") (muted . "brightblack")
      (subtle . "brightblack"))
    "Fallback colors for 16-color terminals, matching Rosé Pine's ANSI mapping.
Neutral roles without an entry fall back to the terminal's defaults.")

  (defun doom-rose-pine--color (palette role)
    "Return ROLE from PALETTE as a quoted doom-themes (GUI 256 16) triple."
    (let ((hex (or (alist-get role palette)
                   (error "Rosé Pine palette has no role `%s'" role))))
      `'(,hex ,hex ,(alist-get role doom-rose-pine--ansi)))))

(defmacro doom-rose-pine-define-theme (name variant docstring)
  "Define the doom theme NAME from the Rosé Pine VARIANT palette.
VARIANT is a key of `doom-rose-pine-palettes'.  DOCSTRING describes the theme."
  (declare (doc-string 3) (indent 2))
  (let* ((palette (or (alist-get variant doom-rose-pine-palettes)
                      (error "Unknown Rosé Pine variant `%s'" variant)))
         (light (eq variant 'dawn))
         ;; ANSI slot -> Rosé Pine role, per the upstream terminal themes.
         (ansi '((black . overlay) (red . love) (green . pine) (yellow . gold)
                 (blue . foam) (magenta . iris) (cyan . rose) (white . text))))
    `(def-doom-theme ,name
       ,docstring
       :family 'doom-rose-pine
       :background-mode ',(if light 'light 'dark)

       ;; Rosé Pine roles, bound so faces below can name them directly.
       (,@(cl-loop for (role . _) in palette
                   collect `(,role ,(doom-rose-pine--color palette role)))

        ;; doom-themes palette slots
        (bg      base)
        (bg-alt  surface)
        ;; base0..base8 run from the background towards the foreground.
        ,@(cl-loop for slot in '(base0 base1 base2 base3 base4
                                 base5 base6 base7 base8)
                   for role in (if light
                                   '(surface nc hl-low overlay hl-med
                                     hl-high muted subtle text)
                                 '(nc surface hl-low overlay hl-med
                                   hl-high muted subtle text))
                   collect `(,slot ,role))
        (fg        text)
        (fg-alt    subtle)
        (grey      muted)
        (red       love)
        (orange    rose)
        (yellow    gold)
        (green     foam)
        (teal      foam)
        (blue      pine)
        (dark-blue pine)
        (magenta   iris)
        (violet    iris)
        (cyan      foam)
        (dark-cyan pine)

        ;; face categories -- required for all themes
        (highlight    iris)
        (vertical-bar hl-med)
        (selection    overlay)
        (builtin      love)
        (comments     muted)
        (doc-comments subtle)
        (constants    gold)
        (functions    rose)
        (keywords     pine)
        (methods      rose)
        (operators    subtle)
        (type         foam)
        (strings      gold)
        (variables    text)
        (numbers      gold)
        (region       (doom-blend iris base 0.15))
        (error        love)
        (warning      gold)
        (success      foam)
        (vc-modified  rose)
        (vc-added     foam)
        (vc-deleted   love))

       ;; --- Extra faces ------------------------
       (;;;; Editor
        (cursor :background rose)
        (hl-line :background hl-low :extend t)
        (solaire-hl-line-face :background hl-low :extend t)
        (fringe :background bg :foreground muted)
        ((line-number &override) :foreground muted)
        ((line-number-current-line &override) :foreground text :weight 'bold)
        (lazy-highlight :background (doom-blend foam base 0.2) :foreground text)
        (isearch :background gold :foreground base :weight 'bold)
        (evil-ex-search :inherit 'isearch)
        (evil-ex-lazy-highlight :inherit 'lazy-highlight)
        (show-paren-match :background (doom-blend pine base 0.25) :foreground foam
                          :weight 'bold)
        (minibuffer-prompt :foreground iris :weight 'bold)
        (link :foreground iris :underline t)
        (tooltip :background surface :foreground subtle)

        ;;;; font-lock
        (font-lock-comment-face :foreground comments :slant 'italic)
        (font-lock-doc-face :inherit 'font-lock-comment-face :foreground doc-comments)
        (font-lock-function-call-face :foreground functions)
        (font-lock-property-name-face :foreground foam)
        (font-lock-property-use-face :foreground foam)
        (font-lock-variable-use-face :foreground variables)
        (font-lock-punctuation-face :foreground subtle)
        (font-lock-escape-face :foreground pine)
        (font-lock-preprocessor-face :foreground iris)
        (font-lock-regexp-grouping-backslash :foreground pine)
        (font-lock-regexp-grouping-construct :foreground iris)

        ;;;; Mode line
        (mode-line :background surface :foreground text)
        (mode-line-inactive :background nc :foreground muted)
        (mode-line-emphasis :foreground rose)
        (mode-line-buffer-id :foreground rose :weight 'bold)
        (solaire-mode-line-face :inherit 'mode-line :background overlay)
        (solaire-mode-line-inactive-face :inherit 'mode-line-inactive)
        (doom-modeline-bar :background rose)
        (doom-modeline-buffer-file :foreground text :weight 'bold)
        (doom-modeline-buffer-path :foreground subtle)
        (doom-modeline-buffer-modified :foreground gold :weight 'bold)
        (doom-modeline-project-dir :foreground foam :weight 'bold)
        (doom-modeline-info :foreground foam)
        (doom-modeline-evil-normal-state :foreground rose)
        (doom-modeline-evil-insert-state :foreground foam)
        (doom-modeline-evil-visual-state :foreground iris)
        (doom-modeline-evil-replace-state :foreground pine)
        (doom-modeline-evil-operator-state :foreground love)
        (doom-modeline-evil-motion-state :foreground gold)
        (doom-modeline-evil-emacs-state :foreground love)

        ;;;; Completion
        (vertico-current :background overlay :foreground text :extend t)
        (corfu-default :background surface :foreground subtle)
        (corfu-current :background overlay :foreground text)
        (corfu-border :background hl-med)
        (completions-common-part :foreground rose :weight 'bold)
        (orderless-match-face-0 :foreground rose :weight 'bold)
        (orderless-match-face-1 :foreground iris :weight 'bold)
        (orderless-match-face-2 :foreground foam :weight 'bold)
        (orderless-match-face-3 :foreground gold :weight 'bold)

        ;;;; LSP
        (lsp-face-highlight-textual :background hl-med :foreground 'unspecified
                                    :weight 'normal)
        (lsp-face-highlight-read :inherit 'lsp-face-highlight-textual)
        (lsp-face-highlight-write :inherit 'lsp-face-highlight-textual :weight 'bold)

        ;;;; Diffs
        (diff-added :background (doom-blend foam base 0.2) :foreground text :extend t)
        (diff-removed :background (doom-blend love base 0.2) :foreground text :extend t)
        (diff-changed :background (doom-blend rose base 0.2) :foreground text :extend t)
        (diff-refine-added :background (doom-blend foam base 0.4) :foreground text)
        (diff-refine-removed :background (doom-blend love base 0.4) :foreground text)
        (diff-refine-changed :background (doom-blend rose base 0.4) :foreground text)

        ;;;; Headings (h1..h6: iris, foam, rose, gold, pine, foam)
        ,@(cl-loop for i from 1 to 8
                   for role in '(iris foam rose gold pine foam iris foam)
                   collect `(,(intern (format "outline-%d" i))
                             :foreground ,role :weight 'bold))
        ,@(cl-loop for i from 1 to 6
                   collect `(,(intern (format "markdown-header-face-%d" i))
                             :inherit ',(intern (format "outline-%d" i))))

        ;;;; Org
        (org-block :background surface :extend t)
        (org-block-begin-line :background surface :foreground muted :extend t)
        (org-block-end-line :inherit 'org-block-begin-line)
        (org-code :foreground gold)
        (org-verbatim :foreground foam)
        (org-todo :foreground rose :weight 'bold)
        (org-done :foreground muted :weight 'bold)
        (org-headline-done :foreground muted)
        (org-date :foreground foam)
        (org-tag :foreground subtle :weight 'normal)
        (org-link :foreground iris :underline t)
        (org-quote :background surface :slant 'italic :extend t)
        (org-hide :foreground bg)
        (solaire-org-hide-face :foreground bg-alt)

        ;;;; Markdown
        (markdown-code-face :background surface :extend t)
        (markdown-inline-code-face :foreground gold)
        (markdown-link-face :foreground iris)
        (markdown-url-face :foreground subtle :underline t)
        (markdown-blockquote-face :foreground subtle :slant 'italic)

        ;;;; Rainbow delimiters
        ,@(cl-loop for i from 1 to 9
                   for role in '(iris foam rose gold pine love iris foam rose)
                   collect `(,(intern (format "rainbow-delimiters-depth-%d-face" i))
                             :foreground ,role))

        ;;;; Terminals: ansi-color, term and vterm
        ,@(cl-loop for (slot . role) in ansi
                   for bright = (if (eq slot 'black) 'muted role)
                   append
                   `((,(intern (format "ansi-color-%s" slot))
                      :foreground ,role :background ,role)
                     (,(intern (format "ansi-color-bright-%s" slot))
                      :foreground ,bright :background ,bright)
                     (,(intern (format "term-color-%s" slot))
                      :inherit ',(intern (format "ansi-color-%s" slot)))
                     (,(intern (format "term-color-bright-%s" slot))
                      :inherit ',(intern (format "ansi-color-bright-%s" slot)))))

        ;;;; Doom dashboard
        (doom-dashboard-banner :foreground rose)
        (doom-dashboard-menu-title :foreground iris)
        (doom-dashboard-menu-desc :foreground subtle)
        (doom-dashboard-loaded :foreground muted)))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-directory load-file-name)))

(provide 'doom-rose-pine-themes)
;;; doom-rose-pine-themes.el ends here
