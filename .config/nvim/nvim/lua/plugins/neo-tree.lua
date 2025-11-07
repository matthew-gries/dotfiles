-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
      -- Auto-expand single child directories
      scan_mode = 'deep',
      follow_current_file = {
        enabled = true,
      },
      group_empty_dirs = true, -- Group empty parent directories into a single entry
      filtered_items = {
        visible = false, -- Show filtered items with different highlighting
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          'node_modules',
          '.git',
          '.DS_Store',
        },
        hide_by_pattern = {
          'target', -- Rust/Maven build directory
          'build', -- General build directory
          'dist', -- Distribution directory
          '*.class', -- Java compiled files
          '__pycache__', -- Python cache
          '.next', -- Next.js build
          '.gradle', -- Gradle cache
        },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = '',
        expander_expanded = '',
      },
    },
  },
}
