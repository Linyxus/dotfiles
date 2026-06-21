return {
  {
    "miikanissi/modus-themes.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("modus-themes").setup({
        style = "auto", -- "auto" (follow background), "modus_operandi" (light), "modus_vivendi" (dark)
        variants = { -- "default", "tinted", "deuteranopia", "tritanopia"
          modus_operandi = "default",
          modus_vivendi = "default",
        },
        transparent = false,
        dim_inactive = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = false },
          functions = {},
          variables = {},
        },
      })
      vim.cmd([[colorscheme modus]])
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
    lazy = false,
    build = ":TSUpdate"
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
          p = "PushPopup",
          f = "FetchPopup",
          F = "PullPopup",
          _ = "RevertPopup",
          O = "ResetPopup",
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
    url = "https://git.disroot.org/andyg/leap.nvim",
    config = function()
      vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap)')
    end,
  },

  {
    'chomosuke/typst-preview.nvim',
    lazy = false, -- or ft = 'typst'
    version = '1.*',
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },

  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

    dependencies = {
      'nvim-telescope/telescope.nvim', -- for Lean-specific pickers
      'andymass/vim-matchup',          -- for enhanced % motion behavior
      'andrewradev/switch.vim',        -- for switch support
      'tomtom/tcomment_vim',           -- for commenting
    },

    init = function()
      ---@type lean.Config
      vim.g.lean_config = {
        mappings = true,
      }
    end,
  }
}
