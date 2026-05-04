-- Highlight, edit, and navigate code (nvim-treesitter `main` branch).
--
-- The `main` branch is a rewrite that does not ship `query_predicates.lua`
-- and uses Neovim's built-in runtime queries. It avoids a class of crashes
-- in the legacy `master` branch caused by stale custom directives such as
-- `set-lang-from-info-string!` (used for markdown fenced-block injections,
-- which Rust doc comments rely on).
--
-- Differences from master:
--   * No `opts`, no `nvim-treesitter.configs`.
--   * Parsers are installed explicitly via `require('nvim-treesitter').install`.
--   * Highlighting is started per buffer via `vim.treesitter.start()`.
--   * Indent is opt-in per buffer via `nvim-treesitter.indentexpr()`.
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- Idempotent; safe to call on every startup.
      require('nvim-treesitter').install {
        'bash', 'c', 'css', 'scss', 'diff', 'html',
        'lua', 'luadoc',
        'markdown', 'markdown_inline',
        'query', 'vim', 'vimdoc',
        'javascript', 'typescript', 'tsx', 'jsdoc',
        'json',
        'rust', 'toml',
      }

      -- Enable treesitter highlight + indent for any buffer whose filetype
      -- maps to an installed parser. Done as a FileType autocmd because the
      -- main branch deliberately does not auto-attach.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local ft = vim.bo[bufnr].filetype

          -- Ruby: keep on regex highlighting; treesitter indent is also unreliable.
          if ft == 'ruby' then return end

          -- vim.treesitter.start() resolves the parser from filetype and
          -- returns gracefully if none is installed; pcall guards anyway.
          if not pcall(vim.treesitter.start, bufnr) then return end

          -- Treesitter-based indentation (per-buffer; opt-in).
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Auto-closing and auto-renaming of HTML/JSX tags. Works with either
  -- nvim-treesitter branch since it only needs a live treesitter parser.
  {
    'windwp/nvim-ts-autotag',
    opts = {},
  },
}
