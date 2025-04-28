vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true

vim.g.mapleader = ','

-- Save
vim.keymap.set('n', ' fs', ':w<CR>')
vim.keymap.set('n', ' fS', ':wa<CR>')

-- Windows
vim.keymap.set('n', ' ww', '<C-w><C-w>')
vim.keymap.set('n', ' 1', '<C-w>1<C-w>')
vim.keymap.set('n', ' 2', '<C-w>2<C-w>')
vim.keymap.set('n', ' 3', '<C-w>3<C-w>')
vim.keymap.set('n', ' 4', '<C-w>4<C-w>')
vim.keymap.set('n', ' w-', ':sp<CR>')
vim.keymap.set('n', ' w2', ':vs<CR>')
vim.keymap.set('n', ' w1', ':only<CR>')
vim.keymap.set('n', ' w1', ':only<CR>')
vim.keymap.set('n', ' wd', ':close<CR>')

-- Telescope keymappings
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files, {})
vim.keymap.set('n', 'fg', builtin.live_grep, {})
vim.keymap.set('n', 'fb', builtin.buffers, {})
vim.keymap.set('n', 'fh', builtin.help_tags, {})

-- Terminal keybindings
vim.keymap.set('n', ' \'', ':ToggleTerm<CR>')
vim.keymap.set('t', '<esc>', '<C-\\><C-n>')

-- Bufferline
vim.opt.termguicolors = true
require("bufferline").setup{}

-- Color scheme
-- vim.cmd[[colorscheme tokyonight-night]]

-- Lualine
require('lualine').setup {
	options = {
		theme = "catppuccin"
	}
}

require('nvim_comment').setup()

-- Hop
vim.keymap.set('n', ' jj', ':HopChar2<CR>')
vim.keymap.set('n', ' jl', ':HopLine<CR>')

-- org-mode
-- require('orgmode').setup_ts_grammar()
-- require'nvim-treesitter.configs'.setup {
--   -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
--   highlight = {
--     enable = true,
--     additional_vim_regex_highlighting = {'org'}, -- Required for spellcheck, some LaTex highlights and code block highlights that do not have ts grammar
--   },
--   ensure_installed = {'org'}, -- Or run :TSUpdate org
-- }

-- require('orgmode').setup({
--   org_agenda_files = {'~/Dropbox/org/*', '~/my-orgs/**/*'},
--   org_default_notes_file = '~/Dropbox/org/refile.org',
-- })

-- Metals
local metals_config = require("metals").bare_config()

-- Example of settings
metals_config.settings = {
  showImplicitArguments = true,
  -- excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
}

-- Autocmd that will actually be in charging of starting the whole thing
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  -- NOTE: You may or may not want java included here. You will need it if you
  -- want basic Java support but it may also conflict if you are using
  -- something like nvim-jdtls which also works on a java filetype autocmd.
  pattern = { "scala", "sbt", "java" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})


require('lean').setup{
  abbreviations = { builtin = true },
  lsp = { on_attach = on_attach },
  lsp3 = { on_attach = on_attach },
  mappings = true,
}
