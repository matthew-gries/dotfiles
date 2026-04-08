-- Autocompletion setup with nvim-cmp
-- Auto-triggers as you type; also manually triggerable with <C-j>

return {
  -- Main completion plugin
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet engine (required by nvim-cmp)
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build step not supported on Windows
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- Collection of pre-made snippets
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip', -- Snippet completions

      -- Completion sources
      'hrsh7th/cmp-nvim-lsp', -- LSP completions
      'hrsh7th/cmp-path', -- File path completions
      'hrsh7th/cmp-buffer', -- Buffer word completions
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        -- Snippet engine configuration
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Auto-show completion menu as you type; also triggerable with <C-j>
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },

        -- Completion menu appearance
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        -- Keymappings for completion
        mapping = cmp.mapping.preset.insert {
          -- Trigger completion manually with Ctrl+j
          ['<C-j>'] = cmp.mapping.complete(),

          -- Navigate completion items
          ['<C-n>'] = cmp.mapping.select_next_item(), -- Next item
          ['<C-p>'] = cmp.mapping.select_prev_item(), -- Previous item

          -- Scroll documentation window
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Confirm selection
          ['<CR>'] = cmp.mapping.confirm { select = false }, -- Only confirm explicitly selected items
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Abort/close completion menu
          ['<C-e>'] = cmp.mapping.abort(),
        },

        -- Completion sources (in priority order)
        sources = {
          { name = 'nvim_lsp' }, -- LSP completions
          { name = 'luasnip' }, -- Snippet completions
          { name = 'buffer', keyword_length = 3 }, -- Buffer words (only after 3 chars)
          { name = 'path' }, -- File paths
        },

        -- Formatting for completion menu
        formatting = {
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, item)
            -- Show source name in menu
            local source_names = {
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              buffer = '[Buf]',
              path = '[Path]',
            }
            item.menu = source_names[entry.source.name] or entry.source.name
            return item
          end,
        },

        -- Experimental features
        experimental = {
          ghost_text = true,
        },
      }
    end,
  },
}
