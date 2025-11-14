-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Set 2-space indentation for JavaScript/TypeScript files
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Use 2-space indentation for JS/TS files',
  group = vim.api.nvim_create_augroup('js-ts-indent', { clear = true }),
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Customize colorcolumn per filetype
-- Commented out to disable colorcolumn
-- vim.api.nvim_create_autocmd('FileType', {
--   desc = 'Set colorcolumn based on filetype',
--   group = vim.api.nvim_create_augroup('custom-colorcolumn', { clear = true }),
--   pattern = { 'rust', 'python', 'go', 'java' },
--   callback = function()
--     vim.opt_local.colorcolumn = '100' -- Longer line for code
--   end,
-- })
--
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { 'markdown', 'text', 'gitcommit' },
--   callback = function()
--     vim.opt_local.colorcolumn = '72' -- Shorter for prose
--   end,
-- })

-- Format on save (placeholder for when LSP is added back)
-- Uncomment and modify when you add LSP/formatters
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   desc = 'Format on save',
--   group = vim.api.nvim_create_augroup('format-on-save', { clear = true }),
--   pattern = { '*.rs', '*.py', '*.lua' }, -- Add your filetypes
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })
