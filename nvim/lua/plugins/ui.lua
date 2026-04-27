-- UI and visual plugins

return {
  -- Gruvbox colorscheme
  -- {
  --   'ellisonleao/gruvbox.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   config = function()
  --     require('gruvbox').setup {
  --       -- You can configure gruvbox options here
  --       -- contrast = "hard", -- can be "hard", "soft" or empty string
  --       -- transparent_mode = true, -- Enable transparency
  --     }
  --
  --     -- Load the colorscheme here.
  --     -- You can also use 'gruvbox-light' for light mode
  --     vim.cmd.colorscheme 'gruvbox'
  --   end,
  -- },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
          require('catppuccin').setup {
            -- You can configure gruvbox options here
            -- contrast = "hard", -- can be "hard", "soft" or empty string
            -- transparent_mode = true, -- Enable transparency
          }

          -- Load the colorscheme here.
          -- You can also use 'gruvbox-light' for light mode
          vim.cmd.colorscheme 'catppuccin-mocha'
        end,
    },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>x', group = 'Trouble/Diagnostics' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>w', group = '[W]indow' },
        { '<leader>W', group = '[W]orkspace' },
      },
    },
  },

  -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- Buffer deletion without closing the window/split
      require('mini.bufremove').setup()
      vim.keymap.set('n', '<leader>bd', function()
        require('mini.bufremove').delete()
      end, { desc = '[B]uffer [D]elete' })
      vim.keymap.set('n', '<leader>bD', function()
        require('mini.bufremove').delete(0, true)
      end, { desc = '[B]uffer [D]elete (force)' })

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  -- Buffer tab line with LSP diagnostics and catppuccin theming
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        -- Delegate buffer closing to mini.bufremove (keeps splits intact)
        close_command = function(n) require('mini.bufremove').delete(n, false) end,
        right_mouse_command = function(n) require('mini.bufremove').delete(n, false) end,
        -- Show LSP error/warning counts on each tab
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and ' ' or ' '
          return ' ' .. icon .. count
        end,
        -- Reserve space for neo-tree sidebar so tabs don't overlap it
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
        separator_style = 'slant',
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)

      -- Cycle buffers with Shift-h/l (common convention) and bracket pairs
      vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
      vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
      vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
      vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })

      -- Pin/unpin a buffer (keeps it anchored in the tab row)
      vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = '[B]uffer [P]in toggle' })
      -- Close all unpinned buffers at once
      vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', { desc = '[B]uffer close un[P]inned' })
    end,
  },

}
