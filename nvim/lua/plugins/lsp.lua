-- LSP Configuration
-- Language Server Protocol setup with Mason for easy installation

return {
  -- Mason: Portable package manager for LSP servers, formatters, linters, etc.
  {
    'williamboman/mason.nvim',
    enabled = true, -- TEMP: testing exit code issue
    config = function()
      require('mason').setup {
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      }
    end,
  },

  -- Mason-lspconfig: Bridge between mason.nvim and nvim-lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = true, -- TEMP: testing exit code issue
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup {
        -- Automatically install these language servers
        ensure_installed = {
          'pyright', -- Python
          'rust_analyzer', -- Rust
          'ts_ls', -- TypeScript/JavaScript
          'clangd', -- C/C++
          'gopls', -- Go
        },
        -- Automatically install language servers when entering a buffer
        automatic_installation = true,
      }
    end,
  },

  -- Nvim-lspconfig: Quickstart configs for Neovim's built-in LSP client
  {
    'neovim/nvim-lspconfig',
    enabled = true, -- TEMP: testing exit code issue
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      -- This function runs when an LSP attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          -- Helper function to make keymap creation easier
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- VS Code-style Navigation Keymaps
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Type information & Documentation
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
          vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = event.buf, desc = 'LSP: Signature Help' })

          -- Code Actions & Refactoring
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Diagnostics (Errors/Warnings)
          map(']d', vim.diagnostic.goto_next, 'Next [D]iagnostic')
          map('[d', vim.diagnostic.goto_prev, 'Previous [D]iagnostic')
          map('<leader>e', vim.diagnostic.open_float, 'Show Lin[e] Diagnostics')
          map('<leader>q', vim.diagnostic.setloclist, 'Diagnostic [Q]uickfix List')

          -- Symbol Search (using Telescope)
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Format command
          map('<leader>f', function()
            vim.lsp.buf.format { async = true }
          end, '[F]ormat buffer')

          -- Enable inlay hints if supported (for Rust, TypeScript, etc.)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end

          -- Highlight references of word under cursor (like VS Code)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            -- Clean up on detach
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                -- Use pcall to avoid errors when buffer is already gone (e.g., on quit)
                pcall(vim.lsp.buf.clear_references)
                pcall(vim.api.nvim_clear_autocmds, { group = 'lsp-highlight', buffer = event2.buf })
              end,
            })
          end
        end,
      })

      -- Configure diagnostic display (VS Code-style: virtual text + signs)
      vim.diagnostic.config {
        virtual_text = true, -- Show errors inline at end of line
        signs = {
          -- Define diagnostic signs using modern API (Neovim 0.11+)
          text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
          },
        },
        update_in_insert = false, -- Don't update diagnostics while typing
        underline = true, -- Underline errors
        severity_sort = true, -- Sort by severity
        float = {
          border = 'rounded',
          source = 'always', -- Show source of diagnostic
          header = '',
          prefix = '',
        },
      }

      -- LSP server capabilities (for autocompletion support)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- Enable snippet and completion support from nvim-cmp
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Configure each language server using the new vim.lsp.config API (Neovim 0.11+)
      -- See :help lspconfig-nvim-0.11

      -- Python: pyright
      vim.lsp.config('pyright', {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = 'basic', -- off, basic, or strict
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly', -- openFilesOnly or workspace
            },
          },
        },
      })

      -- Rust: rust-analyzer
      vim.lsp.config('rust_analyzer', {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'rust-project.json' },
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = 'clippy', -- Use clippy for extra lints
            },
            inlayHints = {
              bindingModeHints = { enable = true },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true },
              closureReturnTypeHints = { enable = 'always' },
              lifetimeElisionHints = { enable = 'always' },
              parameterHints = { enable = true },
              reborrowHints = { enable = 'always' },
              typeHints = { enable = true },
            },
          },
        },
      })

      -- TypeScript/JavaScript: ts_ls (formerly tsserver)
      vim.lsp.config('ts_ls', {
        cmd = { 'typescript-language-server', '--stdio' },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- C/C++: clangd
      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
        capabilities = capabilities,
      })

      -- Go: gopls
      vim.lsp.config('gopls', {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.work', 'go.mod', '.git' },
        capabilities = capabilities,
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
          },
        },
      })

      -- Enable language servers for the configured filetypes
      vim.lsp.enable({ 'pyright', 'rust_analyzer', 'ts_ls', 'clangd', 'gopls' })

      -- Format on save (disabled - was causing non-zero exit codes)
      -- vim.api.nvim_create_autocmd('BufWritePre', {
      --   group = vim.api.nvim_create_augroup('lsp-format-on-save', { clear = true }),
      --   callback = function()
      --     vim.lsp.buf.format { async = false }
      --   end,
      -- })
    end,
  },
}
