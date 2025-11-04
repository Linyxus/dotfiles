return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  {
    "https://github.com/neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.enable('texlab')
      vim.lsp.enable('tinymist')
    end,
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    init = function()
      vim.g.startuptime_tries = 10
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = "<cmd>TSUpdate<cr>",
    config = function ()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "lua", "scala" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
        },
      }
    end
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>bb', builtin.buffers, {})
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    opts = {},
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    opts = {
      mappings = {
        popup = {
          P = "PullPopup",
          p = "PushPopup",
        },
      },
    },
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
  },

  { 'wakatime/vim-wakatime', lazy = false },

  {
    "ggandor/leap.nvim",
    config = function()
      local leap = require('leap')
      leap.set_default_mappings()
    end,
  },

  {
    'chomosuke/typst-preview.nvim',
    lazy = false, -- or ft = 'typst'
    version = '1.*',
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  }
}
