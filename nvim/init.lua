-- [[ Load-order-critical settings ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.termguicolors = true

-- [[ Options ]]
vim.o.hlsearch = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.numberwidth = 5
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 200
vim.o.timeout = true
vim.o.timeoutlen = 300

local opt = vim.opt
opt.completeopt = 'longest,menu,preview'
opt.wildmode = 'longest,list'
opt.colorcolumn = '100'
opt.textwidth = 100
opt.conceallevel = 3
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.formatoptions = 'jcroqlnt'
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --vimgrep'
opt.inccommand = 'nosplit'
opt.list = true
opt.pumblend = 10
opt.pumheight = 10
opt.scrolloff = 4
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize' }
opt.shiftround = true
opt.shiftwidth = 4
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 4
opt.undolevels = 10000
opt.winminwidth = 5
opt.wrap = false

opt.spelllang = { 'en_gb' }
opt.spell = false

opt.laststatus = 3

-- disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- [[ Filetypes ]]
vim.filetype.add({
  pattern = {
    ['.*/.*[T|t]iltfile.*'] = 'tiltfile',
  },
})

-- [[ Keymaps and autocmds ]]
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

local yank_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Plugins ]]
vim.pack.add({
  'https://github.com/catppuccin/nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
})
require('catppuccin').setup({
  transparent_background = true,
  integrations = { gitsigns = true },
})
vim.cmd.colorscheme('catppuccin-mocha')

require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})
vim.api.nvim_create_user_command('GitBlame', function()
  require('gitsigns').blame()
end, { desc = 'Show git blame for current buffer (scroll-synced split)' })

-- Extend the built-in default statusline with the current branch (0.12 exposes
-- the default as a real expression string, so we can read and prepend to it).
vim.o.statusline = "%{exists('b:gitsigns_head') && b:gitsigns_head != '' ? b:gitsigns_head .. ' ' : ''}" .. vim.o.statusline
