vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99

vim.o.clipboard = 'unnamedplus'

vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter', 'WinEnter' }, {
  pattern = 'term://*',
  callback = function()
    vim.cmd.startinsert()
  end,
})

-- parsers are prebuilt by nix and already on runtimepath; no setup() call.
vim.treesitter.language.register('hcl', 'terraform')
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if pcall(vim.treesitter.start) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { source = 'if_many' },
  severity_sort = true,
  float = { border = 'rounded' },
})

vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
-- no dedicated zsh server; bashls is close enough.
vim.lsp.config('bashls', { filetypes = { 'bash', 'sh', 'zsh' } })
vim.lsp.enable({
  'basedpyright',
  'ruff',
  'ts_ls',
  'jdtls',
  'nil_ls',
  'bashls',
  'terraformls',
  'marksman',
  'jsonls',
  'cssls',
  'html',
  'tailwindcss',
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local function opts(desc)
      return { buffer = bufnr, desc = desc }
    end
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts('Go to definition'))
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('Go to declaration'))
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts('References'))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts('Go to implementation'))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('Hover'))
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts('Rename'))
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts('Code action'))
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts('Line diagnostics'))
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts('Previous diagnostic'))
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts('Next diagnostic'))
  end,
})

require('blink.cmp').setup({
  keymap = { preset = 'default' },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  signature = { enabled = true },
})

require('conform').setup({
  formatters_by_ft = {
    python = { 'ruff_format' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    css = { 'prettier' },
    html = { 'prettier' },
    markdown = { 'prettier' },
    yaml = { 'prettier' },
    nix = { 'nixfmt' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    zsh = { 'shfmt' },
    terraform = { 'terraform_fmt' },
  },
  format_on_save = { timeout_ms = 2000, lsp_format = 'fallback' },
})
vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format({ async = true })
end, { desc = 'Format buffer' })

require('telescope').setup({ extensions = { fzf = {} } })
require('telescope').load_extension('fzf')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fr', telescope_builtin.oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fs', telescope_builtin.lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>fd', telescope_builtin.diagnostics, { desc = 'Diagnostics' })

require('gitsigns').setup({})
require('which-key').setup({})
require('which-key').add({
  { '<leader>f', group = 'Find' },
  { '<leader>c', group = 'Code' },
  { '<leader>a', group = 'Claude' },
})

require('snacks').setup({})
require('claudecode').setup({})
vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
vim.keymap.set('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add buffer' })
vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send selection' })
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })

local function target_dir()
  if vim.fn.argc() > 0 then
    local arg = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.argv(0), ':p'))
    return vim.fn.isdirectory(arg) == 1 and arg or vim.fs.dirname(arg)
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= '' and vim.bo.buftype == '' then return vim.fs.dirname(name) end
  return vim.fn.getcwd()
end

vim.o.title = true
vim.o.titlestring = 'vi ' .. vim.fs.basename(target_dir())
