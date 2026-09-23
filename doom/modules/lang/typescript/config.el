;;; lang/typescript/config.el -*- lexical-binding: t; -*-
;; Lightweight TS/JS: built-in tree-sitter modes only (no LSP, no tide).

(use-package! typescript-ts-mode
  :defer t
  :mode (("\\.[cm]?ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'"     . tsx-ts-mode)))

(use-package! js
  :defer t
  :mode ("\\.[cm]?jsx?\\'" . js-ts-mode))   ; js-ts-mode handles JSX too
