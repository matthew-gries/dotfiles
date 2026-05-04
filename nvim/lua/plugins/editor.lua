-- Editor enhancement plugins

return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Leap - Fast navigation with 2-character search
  -- Press 'gs' followed by 2 characters to jump anywhere on screen
  -- https://codeberg.org/andyg/leap.nvim
  {
    url = 'https://codeberg.org/andyg/leap.nvim',
    name = 'leap',
    lazy = false, -- Load immediately
    config = function()
      -- Use 'gs' instead of 's' to avoid conflict with mini.surround
      vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-forward)', { desc = 'Leap forward' })
      vim.keymap.set({ 'n', 'x', 'o' }, 'gS', '<Plug>(leap-backward)', { desc = 'Leap backward' })
      vim.keymap.set({ 'n', 'x', 'o' }, 'gz', '<Plug>(leap-from-window)', { desc = 'Leap from windows' })
    end,
  },

  -- Auto-closing brackets and quotes
  -- https://github.com/windwp/nvim-autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local autopairs = require 'nvim-autopairs'
      local Rule = require 'nvim-autopairs.rule'

      autopairs.setup {}

      -- Add rules for block comments
      autopairs.add_rules {
        Rule('/*', ' */'),
        Rule('/**', ' */'),
      }
    end,
  },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      exclude = {
        filetypes = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
      },
    },
  },

  -- Code outline / symbol tree sidebar (like VS Code's Outline panel)
  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>co', '<cmd>AerialToggle!<cr>', desc = '[C]ode [O]utline (Aerial)' },
    },
    opts = {
      backends = { 'lsp', 'treesitter', 'markdown', 'man' },
      show_guides = true,
      layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = 'right',
      },
    },
    config = function(_, opts)
      require('aerial').setup(opts)
      -- Integrate with telescope: <leader>cs for symbol search via aerial
      pcall(require('telescope').load_extension, 'aerial')
      vim.keymap.set('n', '<leader>cs', '<cmd>Telescope aerial<cr>', { desc = '[C]ode [S]ymbols (Aerial)' })
    end,
  },

  -- Code outline: symbol tree sidebar (functions, classes, variables)
  -- Toggle with <leader>co, search symbols with <leader>cs via Telescope
  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>co', '<cmd>AerialToggle!<cr>', desc = '[C]ode [O]utline (Aerial)' },
      { '<leader>cs', '<cmd>Telescope aerial<cr>', desc = '[C]ode [S]ymbols (Aerial+Telescope)' },
    },
    opts = {
      backends = { 'lsp', 'treesitter', 'markdown', 'man' },
      show_guides = true,
      layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = 'right',
      },
      -- Attach aerial to these filetypes automatically
      filter_kind = false,
    },
    config = function(_, opts)
      require('aerial').setup(opts)
      pcall(require('telescope').load_extension, 'aerial')
    end,
  },

  -- Highlight and navigate TODO comments
  -- Highlights TODO, FIXME, HACK, NOTE, etc. in your code
  -- https://github.com/folke/todo-comments.nvim
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = true, -- Show icons in the gutter
      keywords = {
        FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
    },
    config = function(_, opts)
      require('todo-comments').setup(opts)

      -- Keymaps for navigating todos
      vim.keymap.set('n', ']t', function()
        require('todo-comments').jump_next()
      end, { desc = 'Next [T]odo comment' })

      vim.keymap.set('n', '[t', function()
        require('todo-comments').jump_prev()
      end, { desc = 'Previous [T]odo comment' })

      -- Search todos with Telescope
      vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = '[S]earch [T]odos' })
    end,
  },
}
