-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.numberwidth = 5

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- `'completeopt'`  `'cot'` 	string	(default: "menu,preview")
-- 			global
-- 	A comma-separated list of options for Insert mode completion
-- 	|ins-completion|
--
-- 	   menu	    Use a popup menu to show the possible completions.  The
-- 		    menu is only shown when there is more than one match and
-- 		    sufficient colors are available.  |ins-completion-menu|
--
-- 	   longest  Only insert the longest common text of the matches.  If
-- 		    the menu is displayed you can use CTRL-L to add more
-- 		    characters.  Whether case is ignored depends on the kind
-- 		    of completion.  For buffer text the `'ignorecase'`  option is
-- 		    used.
--
-- 	   preview  Show extra information about the currently selected
-- 		    completion in the preview window.  Only works in
-- 		    combination with "menu" or "menuone".
vim.opt.completeopt = "longest,menu,preview"

-- `'wildmode'`  `'wim'` 	string	(default: "full")
-- 			global
-- 	Completion mode that is used for the character specified with
-- 	`'wildchar'` .
--
-- 	Each part consists of a colon separated list consisting of the
-- 	following possible values:
-- 	""		Complete only the first match.
-- 	"full"		Complete the next full match.  After the last match,
-- 			the original string is used and then the first match
-- 			again.  Will also start `'wildmenu'`  if it is enabled.
-- 	"longest"	Complete till longest common string.  If this doesn't
-- 			result in a longer string, use the next part.
-- 	"list"		When more than one match, list all matches.
-- 	"lastused"	When completing buffer names and more than one buffer
-- 			matches, sort buffers by time last used (other than
-- 			the current buffer).
-- 	When there is only a single match, it is fully completed in all cases.
vim.opt.wildmode = "longest,list"

-- `'colorcolumn'`  `'cc'` 	string	(default "")
-- 			local to window
-- 	`'colorcolumn'`  is a comma-separated list of screen columns that are
-- 	highlighted with ColorColumn |hl-ColorColumn|.  Useful to align
-- 	text.  Will make screen redrawing slower.
vim.opt.colorcolumn = "100"

-- `'textwidth'`  `'tw'` 	number	(default 0)
-- 			local to buffer
-- 	Maximum width of text that is being inserted.  A longer line will be
-- 	broken after white space to get this width.  A zero value disables
-- 	this.
vim.opt.textwidth = 100



-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- https://github.com/catppuccin/nvim
vim.cmd.colorscheme "catppuccin"

local opt = vim.opt
opt.clipboard = "unnamedplus"  -- Sync with system clipboard
opt.conceallevel = 3           -- Hide * markup for bold and italic
opt.confirm = true             -- Confirm to save changes before exiting modified buffer
opt.cursorline = true          -- Enable highlighting of the current line
opt.expandtab = true           -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m" -- Format for grep results
opt.grepprg = "rg --vimgrep"   -- Use ripgrep for grep commands
opt.inccommand = "nosplit"     -- Preview incremental substitute
opt.list = true                -- Show some invisible characters (tabs...)
opt.pumblend = 10              -- Popup blend
opt.pumheight = 10             -- Maximum number of entries in a pop-up
opt.scrolloff = 4              -- Number of lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" } -- Save session options
opt.shiftround = true          -- Round indent
opt.shiftwidth = 4             -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true }) -- Configure short messages
opt.showmode = false           -- Don't show mode since we have a statusline
opt.sidescrolloff = 8          -- Number of columns of context
opt.signcolumn = "yes"         -- Always show the signcolumn
opt.smartcase = true           -- Don't ignore case with capitals
opt.smartindent = true         -- Insert indents automatically
opt.splitbelow = true          -- Put new windows below current
opt.splitright = true          -- Put new windows right of current
opt.tabstop = 4                -- Number of spaces tabs count for
opt.termguicolors = true       -- True color support
opt.timeoutlen = 300           -- Time in milliseconds for key codes
opt.undofile = true            -- Enable persistent undo
opt.undolevels = 10000         -- Number of changes that can be undone
opt.updatetime = 200           -- Save swap file and trigger CursorHold
opt.winminwidth = 5            -- Minimum window width
opt.wrap = false               -- Disable line wrap

-- Enable
opt.spelllang = { "en_gb" }
opt.spell = false
