;;; lang/lean4/config.el -*- lexical-binding: t; -*-

(use-package! lean4-mode
  :defer t
  :config
  (map!
   :map lean4-mode-map
   :localleader
   :desc "Toggle Info View" "SPC" #'lean4-toggle-info
   :desc "Refresh File Dependencies" "r" #'lean4-refresh-file-dependencies))
