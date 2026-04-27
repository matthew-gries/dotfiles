-- Formatting with conform.nvim and linting with nvim-lint
-- conform handles format-on-save and <leader>cf
-- nvim-lint runs linters that aren't LSPs (ruff, eslint_d, shellcheck, etc.)
-- mason-tool-installer auto-installs all formatters and linters via Mason

return {
  -- Formatter runner
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[C]ode [F]ormat buffer',
      },
    },
    opts = {
      -- Format-on-save: skippable per-buffer or globally, skipped for large files
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
          return
        end
        if vim.api.nvim_buf_line_count(bufnr) > 5000 then
          return
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,

      -- Per-filetype formatter list (all installed via mason-tool-installer below)
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        html = { 'prettierd' },
        markdown = { 'prettierd' },
        yaml = { 'prettierd' },
        -- rustfmt is managed by rustup, not Mason
        rust = { 'rustfmt' },
        go = { 'goimports', 'gofumpt' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
      },
    },
    config = function(_, opts)
      -- Auto-format is disabled by default; enable with <leader>tF
      vim.g.disable_autoformat = true
      require('conform').setup(opts)

      -- Toggle format-on-save for the current buffer only
      vim.keymap.set('n', '<leader>tf', function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify(
          'Format on save ' .. (vim.b.disable_autoformat and 'disabled' or 'enabled') .. ' for this buffer',
          vim.log.levels.INFO
        )
      end, { desc = '[T]oggle [F]ormat on save (buffer)' })

      -- Toggle format-on-save globally for all buffers
      vim.keymap.set('n', '<leader>tF', function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify(
          'Format on save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled') .. ' globally',
          vim.log.levels.INFO
        )
      end, { desc = '[T]oggle [F]ormat on save (global)' })
    end,
  },

  -- Linter runner: complements LSP with lint-only tools
  {
    'mfussenegger/nvim-lint',
    event = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        python = { 'ruff' },
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        go = { 'golangcilint' },
        sh = { 'shellcheck' },
        bash = { 'shellcheck' },
        dockerfile = { 'hadolint' },
        markdown = { 'markdownlint' },
      }

      -- Run linting automatically on these events
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      -- Manual lint trigger
      vim.keymap.set('n', '<leader>cl', function()
        lint.try_lint()
      end, { desc = '[C]ode [L]int buffer' })
    end,
  },

  -- Auto-install all formatters and linters via Mason
  -- LSP servers are handled by mason-lspconfig in lsp.lua
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        -- Formatters
        'stylua', -- Lua
        'prettierd', -- JS/TS/JSON/CSS/HTML/MD/YAML
        'ruff', -- Python (formatter + linter)
        'goimports', -- Go
        'gofumpt', -- Go (stricter gofmt)
        'clang-format', -- C/C++
        'shfmt', -- Shell
        -- Linters
        'eslint_d', -- JS/TS
        'golangci-lint', -- Go
        'shellcheck', -- Shell
        'hadolint', -- Dockerfile
        'markdownlint', -- Markdown
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
