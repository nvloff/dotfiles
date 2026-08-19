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
vim.o.timeoutlen = 600 -- room to finish a <leader>xy sequence without rushing

vim.o.autocomplete = true

local opt = vim.opt
opt.completeopt = 'menu,menuone,noselect,popup,fuzzy'
opt.wildmode = 'longest,list'
opt.colorcolumn = '100'
opt.textwidth = 100
opt.conceallevel = 3
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.formatoptions = 'jcroqlnt'
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = "rg --vimgrep -g '!vendor'" -- skip Go's committed vendor/ dir
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

opt.spelllang = { 'en_gb', 'bg' } -- checked simultaneously once 'spell' is on

opt.laststatus = 3

-- disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- netrw file explorer (must be set before netrw first loads)
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25

-- [[ Filetypes ]]
-- A templates/*.{yaml,yml,tpl,txt} file counts as Helm only if its chart root
-- (the templates/ dir's parent) has a sibling Chart.yaml.
local function helm_if_chart_sibling(path)
  local chart_root = path:match('^(.*)/templates/')
  if chart_root and vim.uv.fs_stat(chart_root .. '/Chart.yaml') then
    return 'helm'
  end
end

vim.filetype.add({
  pattern = {
    ['.*/.*[T|t]iltfile.*'] = 'tiltfile',
    ['.*/templates/.*%.ya?ml'] = helm_if_chart_sibling,
    ['.*/templates/.*%.tpl'] = helm_if_chart_sibling,
    ['.*/templates/.*%.txt'] = helm_if_chart_sibling,
    ['.*/values.*%.ya?ml'] = 'yaml.helm-values',
    ['.*/helmfile.*%.ya?ml'] = 'helm',
  },
  extension = {
    gotmpl = 'helm', -- helmfile templated values files
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'helm',
  callback = function()
    vim.bo.commentstring = '{{/* %s */}}'
    vim.opt_local.conceallevel = 2 -- helm-ls.nvim's inline value hints need this
  end,
})

-- [[ Keymaps and autocmds ]]
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>', { desc = 'Toggle file explorer' })

-- 'spell' is window-local; spelllang above already covers en_gb + bg together.
vim.keymap.set('n', '<F5>', '<cmd>setlocal spell!<CR>', { desc = 'Toggle spell checker' })

local yank_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Super-tab style completion: Tab/S-Tab cycle the popup, Enter accepts.
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true })

-- Fires once per buffer, each time a language server attaches to it (a buffer
-- can have more than one client, e.g. gopls + a linter, so this may run
-- several times for the same buffer with different `client`s).
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Not every server implements completion (e.g. a formatter-only client),
    -- so guard on capability before turning the popup on for this client.
    -- autotrigger = true is what makes the menu open as you type; without it
    -- you'd have to invoke vim.lsp.completion.get() (or <C-x><C-o>) by hand.
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    -- Off by default even when the server supports it (e.g. gopls' 'hints'
    -- table in servers.lua only controls what it *offers*; Neovim still
    -- needs telling to render them).
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    -- Same story for code lenses (the "run go generate", "tidy go.mod"
    -- buttons gopls' codelenses settings enable server-side): off until
    -- told to render. Refreshes itself on buffer changes; "grx" (built-in
    -- default keymap) runs the lens under the cursor.
    if client and client:supports_method('textDocument/codeLens') then
      vim.lsp.codelens.enable(true, { bufnr = args.buf })
    end

    -- buffer = args.buf keeps these mappings scoped to this buffer only, so
    -- e.g. a plain-text buffer with no LSP client never gets a "gd" that does
    -- nothing.
    local function nmap(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = args.buf, desc = 'LSP: ' .. desc })
    end

    -- gra/gri/grn/grr/grt/grx/gO/K/<C-s> are already default keymaps as of
    -- Neovim 0.11+ (see :help lsp-defaults) -- only add what's missing.
    -- Notably there's no default for goto-definition/declaration: 'tagfunc'
    -- wires up <C-]>/:tag to the LSP, but "gd"/"gD" themselves are plain Vim
    -- motions unless mapped here.
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- gq/formatexpr already does LSP-backed formatting per-motion by default
    -- (:help lsp-defaults); these give a whole-buffer shortcut and a memorable
    -- :Format command on top of that.
    nmap('<C-l>', vim.lsp.buf.format, 'Format')
    vim.api.nvim_buf_create_user_command(args.buf, 'Format', function()
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    -- Toggles compiler-optimization diagnostics (escape analysis, inlining,
    -- bounds-check elimination, nil checks) for this package, shown as
    -- regular diagnostics. Gated to gopls: servers.lua's 'hints'/'analyses'
    -- tables control what other servers offer, but this command is gopls-
    -- specific (gopls.gc_details), not part of the generic LSP spec.
    if client and client.name == 'gopls' then
      vim.api.nvim_buf_create_user_command(args.buf, 'GcDetails', function()
        client:exec_cmd({
          command = 'gopls.gc_details',
          arguments = { vim.uri_from_bufnr(args.buf) },
        }, { bufnr = args.buf })
      end, { desc = 'Toggle compiler optimization diagnostics (gopls)' })
    end
  end,
})

-- [[ Plugins ]]

-- Update parsers whenever nvim-treesitter itself is installed/updated (must be
-- registered before vim.pack.add so it also fires on the very first install).
-- Uses the Lua API (not the :TSUpdate command) since the plugin's commands
-- aren't guaranteed to be sourced yet at this exact point in the install batch.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(args)
    if args.data.spec.name == 'nvim-treesitter' and (args.data.kind == 'install' or args.data.kind == 'update') then
      require('nvim-treesitter').update()
    end
  end,
})

vim.pack.add({
  'https://github.com/catppuccin/nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/mason-org/mason.nvim',
  -- ensure_installed for the servers below, so a fresh machine doesn't need
  -- a manual :MasonInstall pass. See servers.lua.
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/folke/lazydev.nvim',
  -- Data-only: supplies lsp/*.lua server configs that vim.lsp.config merges
  -- automatically via 'runtimepath'. Never call require('lspconfig').
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/folke/snacks.nvim',
  -- Icon provider for the snacks.picker file list. Mocks nvim-web-devicons
  -- for any third party that only knows that provider.
  'https://github.com/nvim-mini/mini.icons',
  -- Parser installer only -- highlighting itself is vim.treesitter.start()
  -- below, a Neovim 0.12 built-in.
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/junegunn/vim-easy-align',
  -- In-buffer rendering while editing (headers/tables/code blocks styled
  -- inline via extmarks -- file stays plain markdown underneath).
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  -- Browser preview with Mermaid/KaTeX/GFM, for when in-buffer isn't enough.
  -- Unmaintained iamcco/markdown-preview.nvim replaced by this active fork.
  'https://github.com/selimacerbas/live-server.nvim',
  'https://github.com/selimacerbas/markdown-preview.nvim',
  -- :GenTocGFM inserts a GitHub-anchor-style TOC at the cursor; :UpdateToc
  -- refreshes it in place afterwards (also on save, enabled below).
  'https://github.com/mzlogin/vim-markdown-toc',
  -- Detects tabs/spaces/width per file, no setup call needed.
  'https://github.com/tpope/vim-sleuth',
  -- Helm chart navigation: % across if/with/range blocks, current-block
  -- highlighting, inline value hints. Recommended by helm_ls's own docs.
  'https://github.com/qvalentin/helm-ls.nvim',
})
-- Align installed plugins to the committed lockfile revisions (no upstream
-- fetch of newer versions). Run after pulling config on another machine.
-- Opens a review buffer like any update -- :write to apply, :quit to discard.
vim.api.nvim_create_user_command('PackSync', function()
  vim.pack.update(nil, { target = 'lockfile' })
end, { desc = 'Sync plugins to nvim-pack-lock.json revisions' })

require('mason').setup()
require('lazydev').setup()
require('mini.icons').setup()
require('catppuccin').setup({
  transparent_background = true,
  integrations = { gitsigns = true, snacks = true },
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
-- gitsigns' own :Gitsigns blame does the work (scroll-synced split); this is
-- just a shorter way to reach it.
vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame<CR>', { desc = 'Git blame current buffer' })

-- Only picker + indent -- explorer/dashboard/etc. stay off, netrw already
-- covers file browsing. frecency ranks recently/frequently opened files higher.
require('snacks').setup({
  picker = {
    enabled = true,
    matcher = { frecency = true, sort_empty = true },
    -- Go vendors deps into a committed vendor/ dir, so rg/fd (which only honor
    -- .gitignore) don't skip it. Top-level exclude propagates to every source
    -- that shells out: files, grep, grep_word, smart. Passed as `-g !vendor`.
    exclude = { 'vendor' },
    -- rg/fd skip dotfiles by default, which hides this very repo's
    -- nvim/.config/nvim/init.lua from the files picker. .git and .gitignored
    -- paths stay excluded either way; toggle per-search with <A-h>.
    sources = { files = { hidden = true } },
    -- 'autocomplete' (global, Nvim 0.12+) fires in any insert-mode buffer,
    -- including the picker's live-filter prompt, where its popup steals
    -- redraws from search-as-you-type. buftype = 'prompt' already excludes
    -- nvim-cmp; native autocomplete needs this explicit opt-out too.
    win = { input = { bo = { autocomplete = false } } },
  },
  indent = {
    enabled = true,
    char = '┊',
  },
})
-- Route vim.ui.select through the picker so LSP code-action menus, etc. use the
-- same UI as everything else (also silences the snacks.picker health check).
vim.ui.select = Snacks.picker.select
vim.keymap.set('n', '<leader>?', function() Snacks.picker.recent() end, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = 'Smart find files (buffers + recent + files)' })
vim.keymap.set('n', '<leader>,', function() Snacks.picker.buffers() end, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function() Snacks.picker.lines() end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>sf', function() Snacks.picker.files() end, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', function() Snacks.picker.help() end, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', function() Snacks.picker.grep_word() end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<C-f>', function() Snacks.picker.grep() end, { desc = 'Find in files' })
vim.keymap.set('n', '<C-p>', function() Snacks.picker.files() end, { desc = 'Find files' })

-- c/lua/markdown/markdown_inline/query/vim/vimdoc ship inside Neovim itself;
-- everything else here is fetched on demand.
require('nvim-treesitter').install({
  'go', 'bash', 'json', 'yaml', 'terraform', 'dockerfile', 'starlark',
  'regex', -- snacks.picker highlights search patterns with this grammar
  'html', -- render-markdown's inline HTML rendering
  'helm', 'gotmpl', -- Go-template + Helm dialect grammars for {{ }} syntax.
  -- go.mod/go.sum/go.work are their own grammars, distinct from 'go' --
  -- without these, files with filetype gomod/gosum/gowork get no highlighting
  -- at all (Neovim ships no legacy syntax/gomod.vim to fall back to either).
  'gomod', 'gosum', 'gowork',
})
-- Tiltfiles and jsonc reuse another language's grammar wholesale.
vim.treesitter.language.register('starlark', 'tiltfile')
vim.treesitter.language.register('json', 'jsonc')

require('helm-ls').setup({})

-- Every filetype, not just the ones with a parser installed above: falls back
-- to legacy regex 'syntax' highlighting when vim.treesitter.start() errors
-- (no parser for that language) -- start() asserts rather than no-oping.
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      vim.bo[args.buf].syntax = 'on'
    end
  end,
})

-- ga*<Bar> (select rows, ga, *, |) aligns markdown tables -- vim-easy-align's
-- own predefined "Table markdown" rule.
vim.keymap.set({ 'n', 'x' }, 'ga', '<Plug>(EasyAlign)')

-- html rendering is on (needs the 'html' parser, installed above); latex stays
-- off -- it also needs a LaTeX converter (tectonic/pdflatex) we don't install.
require('render-markdown').setup({
  latex = { enabled = false },
})

require('markdown_preview').setup({
  instance_mode = 'takeover',
  open_browser = true,
  default_theme = 'dark',
})
vim.keymap.set('n', '<leader>mps', '<cmd>MarkdownPreview<CR>', { desc = 'Markdown preview start' })
vim.keymap.set('n', '<leader>mpS', '<cmd>MarkdownPreviewStop<CR>', { desc = 'Markdown preview stop' })
vim.keymap.set('n', '<leader>mpr', '<cmd>MarkdownPreviewRefresh<CR>', { desc = 'Markdown preview refresh' })

-- Keep an inserted TOC in sync with headings automatically, not just on
-- explicit :UpdateToc.
vim.g.vmt_auto_update_on_save = 1
vim.keymap.set('n', '<leader>mtg', '<cmd>GenTocGFM<CR>', { desc = 'Markdown: [G]enerate GFM toc at cursor' })
vim.keymap.set('n', '<leader>mtu', '<cmd>UpdateToc<CR>', { desc = 'Markdown: [U]pdate toc' })

-- Extend the built-in default statusline with the current branch (0.12 exposes
-- the default as a real expression string, so we can read and prepend to it).
vim.o.statusline = "%{exists('b:gitsigns_head') && b:gitsigns_head != '' ? b:gitsigns_head .. ' ' : ''}" .. vim.o.statusline

dofile(vim.fn.stdpath('config') .. '/servers.lua')
