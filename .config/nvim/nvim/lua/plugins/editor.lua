-- Editor enhancement plugins

return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Leap - Fast navigation with 2-character search
  -- Press 'gs' followed by 2 characters to jump anywhere on screen
  -- https://github.com/ggandor/leap.nvim
  {
    'ggandor/leap.nvim',
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
    opts = {},
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
}
