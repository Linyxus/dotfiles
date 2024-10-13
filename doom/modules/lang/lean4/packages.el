;; -*- no-byte-compile: t; -*-
;;; lang/lean4/packages.el

(package! lean4-mode
  :recipe
  (:host github
   :repo "leanprover-community/lean4-mode"
   :files ("*.el" "data")))
