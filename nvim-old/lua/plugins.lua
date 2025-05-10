-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Configurations for Nvim LSP
  use 'neovim/nvim-lspconfig'

  -- Autocompletion plugin
  use 'hrsh7th/nvim-cmp'

  -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-nvim-lsp'

  -- Snippets source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'

  -- Snippets plugin
  use 'L3MON4D3/LuaSnip'

  -- Lean
  use { 
    'Julian/lean.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use 'neovim/nvim-lspconfig'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    -- run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    run = ':TSUpdate',
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Wakatime
  use 'wakatime/vim-wakatime'

  -- terminal
  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

  -- auto pair
  use {
	  "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  -- bufferline
  use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}

  -- lualine
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Themes
  use 'folke/tokyonight.nvim'
  use 'rmehri01/onenord.nvim'

  use "terrortylor/nvim-comment"

  use "tpope/vim-fugitive"

  use {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  }

  -- Neorg
  -- use {
  --     "nvim-neorg/neorg",
  --     run = ":Neorg sync-parsers",
  --     config = function()
  --       require('neorg').setup {
  --         load = {
  --           ["core.defaults"] = {}
  --         }
  --       }
  --     end,
  --     requires = "nvim-lua/plenary.nvim"
  -- }

  -- catppuccin
  use {
    "catppuccin/nvim",
    as = "catppuccin",
    config = function()
      vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
      require("catppuccin").setup()
      vim.api.nvim_command "colorscheme catppuccin"
    end
  }

  -- metals
  use({'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" }})

  -- use {
  --   'nvim-orgmode/orgmode', 
  --   config = function()
  --     require('orgmode').setup{}
  --   end
  -- }
  --
  -- use {
  --   'akinsho/org-bullets.nvim', 
  --   config = function()
  --     require('org-bullets').setup()
  --   end
  -- }
end)

