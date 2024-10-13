(use-package! ledger-mode
  :mode ("\\.\\(ledger\\|journal\\|ldg\\)\\'" . ledger-mode)
  :defer t

  :init
  (setq ledger-binary-path "hledger"
        ledger-mode-should-check-version nil
        ledger-report-links-in-register nil)

  :config
  (setq ledger-post-amount-alignment-column 62)
  (setq-default ledger-reports
                '(("monthly expenses" "%(binary) balance expenses --tree --no-total --row-total --average --monthly --begin '6 months ago'")
                ("weekly expenses" "%(binary) balance expenses --tree --no-total --row-total --average --weekly --begin '4 weeks ago'")
                ("weekly expenses (more)" "%(binary) balance expenses --tree --no-total --row-total --average --weekly --begin '10 weeks ago'")
                ("daily expenses" "%(binary) balance expenses --tree --no-total --row-total --average --daily --begin '5 days ago'")
                ("expenses this week" "%(binary) balance expenses --tree --no-total --row-total --average --daily --begin 'this week'")
                ("expenses this month" "%(binary) balance expenses --tree --no-total --row-total --average --weekly --begin 'this month'")
                ("sources this week" "%(binary) balance sources --tree --no-total --row-total --average --daily --begin 'this week'")
                ("sources this month" "%(binary) balance sources --tree --no-total --row-total --average --weekly --begin 'this month'")
                ("all assets" "%(binary) balance assets liabilities --tree")))
  (setq-default ledger-report-auto-width nil)
  (setq-default ledger-report-use-native-highlighting nil)

  (map!
   :map 'ledger-mode-map
   :localleader
   "q" #'ledger-post-align-xact
   "r" #'ledger-report))

(use-package! evil-ledger
  :defer t
  :init (add-hook 'ledger-mode-hook 'evil-ledger-mode))
