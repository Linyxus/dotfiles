-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- General settings
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
-- Save
vim.keymap.set('n', '<leader>fs', ':w<CR>')
vim.keymap.set('n', '<leader>fS', ':wa<CR>')

-- Windows
vim.keymap.set('n', '<leader>ww', '<C-w><C-w>')
vim.keymap.set('n', '<leader>1', '<C-w>1<C-w>')
vim.keymap.set('n', '<leader>2', '<C-w>2<C-w>')
vim.keymap.set('n', '<leader>3', '<C-w>3<C-w>')
vim.keymap.set('n', '<leader>4', '<C-w>4<C-w>')
vim.keymap.set('n', '<leader>w-', ':sp<CR>')
vim.keymap.set('n', '<leader>w2', ':vs<CR>')
vim.keymap.set('n', '<leader>w1', ':only<CR>')
vim.keymap.set('n', '<leader>w1', ':only<CR>')
vim.keymap.set('n', '<leader>wd', ':close<CR>')

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
