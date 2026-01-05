;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; (setq doom-font (font-spec :family "CommitMono" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq font-name "CommitMono")
(setq doom-font
      (font-spec
       :family font-name
       :size 13
       :weight 'light)
      doom-symbol-font
      (font-spec
       :family font-name
       :size 13
       :weight 'light))
(setq-default line-spacing 10)

(setq-default tab-width 2)

;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'standard-light-tinted)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq deft-directory "~/.deft/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;

;; General key map preferences
(setq doom-localleader-key ",")

(map! :map 'override
      :leader
      :desc "Switch to buffer" "bb" #'switch-to-buffer
      :desc "Kill Emacs" "qq" #'kill-emacs
      :desc "Quit this connection" "qf" #'save-buffers-kill-terminal
      :desc "Execute command" "SPC" #'execute-extended-command
      :desc "Kill other windows" "w1" #'delete-other-windows
      :desc "Split the current window on the right" "w2" #'split-window-right
      :desc "Split the current window on the below" "w-" #'split-window-below
      :desc "Switch to last buffer" "TAB" #'evil-switch-to-windows-last-buffer
      :desc "Switch to scratch buffer" "bs" #'doom/switch-to-scratch-buffer
      :desc "Adjust text scale" "zx" #'text-scale-adjust
      :desc "Magit status" "gs" #'magit-status
      :desc "Magit blame" "gb" #'magit-blame-addition
      :desc "Toggle Auto-Fill" "tx" #'toggle-text-mode-auto-fill)

(map! :map 'override
      :desc "Avy goto line" :n "gsl" #'evil-avy-goto-line)

;; Wakatime mode
(global-wakatime-mode)
;; The API key and the executable path should be set in custom.el

;; winum
(use-package! winum
  :config
  ;; winum modifies `mode-line-format' in a destructive manner. I'd rather leave
  ;; it to modeline plugins (or the user) to add this if they want it.
  (setq winum-auto-setup-mode-line nil)
  (winum-mode +1)
  (map! :leader
        ;; "0" #'winum-select-window-0-or-10
        "1" #'winum-select-window-1
        "2" #'winum-select-window-2
        "3" #'winum-select-window-3
        "4" #'winum-select-window-4
        "5" #'winum-select-window-5
        "6" #'winum-select-window-6
        "7" #'winum-select-window-7
        "8" #'winum-select-window-8
        "9" #'winum-select-window-9))

;; org-mode kbds
(map! :after org
      :map org-mode-map
      :localleader
      :desc "Todo keywords" "k" #'org-todo
      :desc "Org action" "," #'org-ctrl-c-ctrl-c
      :desc "Org babel tangle" "bt" #'org-babel-tangle)

(map! :after org
      :map 'override
      :leader
      :desc "Org Agenda" "bh" #'org-agenda)

(map! :after org
      :map org-agenda-mode-map
      :localleader
      :desc "Toggle log mode" "l" #'org-agenda-log-mode)

(after! org
  (setq org-agenda-start-with-log-mode '(closed clock state)
        org-log-done t))

;; neotree kbds
(map! :map 'override
      :leader
      "0" #'+neotree/find-this-file
      "ft" #'+neotree/open)

;; vterm kbds
(map! :map 'override
      :leader
      "'" #'+vterm/toggle)

;; input method
(use-package! agda-input)

;; gptel
(use-package! gptel
  :defer t
  :config
  (setq-default gptel-model "gpt-4o")
  (map!
   :map 'gptel-mode-map
   :n "?" #'gptel-menu
   :n "q" #'evil-quit)
  (map!
   :map 'gptel-mode-map
   :localleader
   "SPC" #'gptel-send
   "a" #'gptel-add))
;; Set the api key in custom.el

(map!
 :map 'override
 :leader
 :desc "Open gptel" "og" #'gptel)

;; claude-code
(use-package! claude-code
  :defer t)
(map!
 :map 'override
 :desc "Claude Code" "C-c c" #'claude-code-transient)

;; dotty
(use-package! dotty
  :after-call scala-mode-hook
  :config
  (map!
   :map 'override
   :leader
   :desc "Open SBT console" "os" #'sbt/console))

(map!
 :after scala-mode
 :map scala-mode-map
 :localleader
 :desc "Goto definition" "gg" #'lsp-ui-peek-find-definitions
 :desc "Goto references" "gr" #'lsp-ui-peek-find-references)

(after! lsp-mode
  (setq-default lsp-enable-file-watchers nil))

;; zetteldeft
(use-package! zetteldeft
  :after deft
  :config
  (zetteldeft-set-classic-keybindings)
  (map!
   :after org
   :map org-mode-map
   :localleader
   :desc "Zetteldeft" "z" #'zetteldeft-prefix)
  (map!
   :map 'override
   :leader
   :desc "New Zetteldeft Note" "nzn" #'zetteldeft-new-file))

(setq +latex-viewers '(pdf-tools))

(set-popup-rule! "^\\*claude" :side 'right :size 0.5)
