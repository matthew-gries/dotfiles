-- LSP Configuration
-- Language Server Protocol setup with Mason for easy installation

return {
  -- Neovim Lua API completion + type stubs (must load before lua_ls starts)
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      { 'Bilal2453/luvit-meta', lazy = true }, -- vim.uv type stubs
    },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

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
          'lua_ls', -- Lua
          'bashls', -- Bash/Shell
          'jsonls', -- JSON
          'yamlls', -- YAML
          'taplo', -- TOML
          'marksman', -- Markdown
          'dockerls', -- Dockerfile
          'eslint', -- ESLint as LSP (JS/TS)
        },
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
      'b0o/SchemaStore.nvim', -- JSON/YAML schemas for jsonls and yamlls
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
          -- <C-k> in insert mode only; normal mode is reserved for split navigation
          vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = event.buf, desc = 'LSP: Signature Help' })

          -- Code Actions & Refactoring
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Diagnostics (Errors/Warnings)
          -- Use vim.diagnostic.jump (0.11+ API; goto_next/prev are deprecated)
          map(']d', function() vim.diagnostic.jump { count = 1, float = true } end, 'Next [D]iagnostic')
          map('[d', function() vim.diagnostic.jump { count = -1, float = true } end, 'Previous [D]iagnostic')
          map('<leader>e', vim.diagnostic.open_float, 'Show Lin[e] Diagnostics')
          map('<leader>q', vim.diagnostic.setloclist, 'Diagnostic [Q]uickfix List')

          -- Symbol Search (using Telescope)
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>Ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Formatting is handled by conform.nvim (<leader>cf); LSP format is the fallback

          -- Enable inlay hints if supported (for Rust, TypeScript, etc.)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end

          -- Register rust-analyzer client-side commands that it expects the editor to handle.
          -- Without these, code lens "N references" clicks produce a "command not supported" error.
          if client and client.name == 'rust_analyzer' then
            client.commands['rust-analyzer.showReferences'] = function(command, _ctx)
              local locations = command.arguments and command.arguments[3]
              if not locations or #locations == 0 then return end
              if #locations == 1 then
                vim.lsp.util.jump_to_location(locations[1], client.offset_encoding)
              else
                -- Multiple references: send to quickfix then open with telescope if available
                local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
                vim.fn.setqflist({}, ' ', { title = 'References', items = items })
                local ok, tb = pcall(require, 'telescope.builtin')
                if ok then
                  tb.quickfix()
                else
                  vim.cmd 'copen'
                end
              end
            end
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

          -- Code lens: inline action buttons (e.g. "Run", "Debug", reference counts)
          -- Supported by rust-analyzer, gopls, and others
          if client and client.server_capabilities.codeLensProvider then
            local codelens_augroup = vim.api.nvim_create_augroup('lsp-codelens', { clear = false })
            vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
              buffer = event.buf,
              group = codelens_augroup,
              callback = vim.lsp.codelens.refresh,
            })
            vim.lsp.codelens.refresh()
            map('<leader>cc', vim.lsp.codelens.run, '[C]ode Lens a[C]tion')
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

      -- Toggle between virtual_text (end-of-line) and virtual_lines (multi-line, great for Rust)
      vim.keymap.set('n', '<leader>td', function()
        local current = vim.diagnostic.config()
        if current and current.virtual_lines then
          vim.diagnostic.config { virtual_lines = false, virtual_text = true }
        else
          vim.diagnostic.config { virtual_lines = { only_current_line = true }, virtual_text = false }
        end
      end, { desc = '[T]oggle [D]iagnostic virtual lines' })

      -- Toggle inlay hints globally (can be noisy; handy to flip off temporarily)
      vim.keymap.set('n', '<leader>ti', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
      end, { desc = '[T]oggle [I]nlay Hints' })

      -- Toggle between virtual_text (inline) and virtual_lines (multi-line below the code)
      -- virtual_lines is great for long Rust/TS errors; virtual_text is less noisy day-to-day
      vim.keymap.set('n', '<leader>td', function()
        local current = vim.diagnostic.config()
        if current and current.virtual_lines then
          vim.diagnostic.config { virtual_lines = false, virtual_text = true }
        else
          -- only_current_line keeps the display focused
          vim.diagnostic.config { virtual_lines = { only_current_line = true }, virtual_text = false }
        end
      end, { desc = '[T]oggle [D]iagnostic virtual lines' })

      -- Toggle inlay hints globally (they can be noisy in some codebases)
      vim.keymap.set('n', '<leader>ti', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
      end, { desc = '[T]oggle [I]nlay hints' })

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
            checkOnSave = true,
            check = {
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

      -- Lua: lua-language-server (lazydev.nvim provides nvim API completion on top)
      vim.lsp.config('lua_ls', {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
            -- Suppress noisy 'missing-fields' warnings common in config files
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      })

      -- Bash/Shell: bash-language-server
      vim.lsp.config('bashls', {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'sh', 'bash' },
        root_markers = { '.git' },
        capabilities = capabilities,
      })

      -- JSON: vscode-json-language-server with SchemaStore schemas
      vim.lsp.config('jsonls', {
        cmd = { 'vscode-json-language-server', '--stdio' },
        filetypes = { 'json', 'jsonc' },
        root_markers = { '.git' },
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- YAML: yaml-language-server with SchemaStore schemas
      vim.lsp.config('yamlls', {
        cmd = { 'yaml-language-server', '--stdio' },
        filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
        root_markers = { '.git' },
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = { enable = false, url = '' }, -- use SchemaStore.nvim instead
            schemas = require('schemastore').yaml.schemas(),
          },
        },
      })

      -- TOML: taplo
      vim.lsp.config('taplo', {
        cmd = { 'taplo', 'lsp', 'stdio' },
        filetypes = { 'toml' },
        root_markers = { '.git', 'Cargo.toml', 'pyproject.toml' },
        capabilities = capabilities,
      })

      -- Markdown: marksman
      vim.lsp.config('marksman', {
        cmd = { 'marksman', 'server' },
        filetypes = { 'markdown', 'markdown.mdx' },
        root_markers = { '.git', '.marksman.toml' },
        capabilities = capabilities,
      })

      -- Dockerfile: docker-langserver
      vim.lsp.config('dockerls', {
        cmd = { 'docker-langserver', '--stdio' },
        filetypes = { 'dockerfile' },
        root_markers = { 'Dockerfile', '.git' },
        capabilities = capabilities,
      })

      -- ESLint: vscode-eslint-language-server (linting diagnostics as LSP for JS/TS)
      vim.lsp.config('eslint', {
        cmd = { 'vscode-eslint-language-server', '--stdio' },
        filetypes = {
          'javascript', 'javascriptreact', 'javascript.jsx',
          'typescript', 'typescriptreact', 'typescript.tsx',
          'vue', 'svelte',
        },
        root_markers = {
          '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.mjs',
          '.eslintrc.yaml', '.eslintrc.yml', '.eslintrc.json',
          'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs',
          'package.json', '.git',
        },
        capabilities = capabilities,
        settings = {
          validate = 'on',
          run = 'onType',
          workingDirectory = { mode = 'location' },
        },
      })

      -- Enable all configured language servers
      vim.lsp.enable({
        'pyright', 'rust_analyzer', 'ts_ls', 'clangd', 'gopls',
        'lua_ls', 'bashls', 'jsonls', 'yamlls', 'taplo',
        'marksman', 'dockerls', 'eslint',
      })

      -- Format-on-save is handled by conform.nvim (see lua/plugins/formatting.lua)
    end,
  },
}
