" got a lot of stuff from https://github.com/ryanb/dotfiles/raw/master/vimrc
"
" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible


" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands

set nobackup
set nowritebackup

set incsearch           " do incremental searching
set hlsearch            " highlight search results

set nowrap              " switch wrap off for everything set nowrap

set wildmenu            " : menu has tab completion, etc

set mousehide           " hide the cursor while writing

set showmatch           " show matching brackets when typing

set ignorecase          " you nearly always want this
set smartcase           " overrides ignorecase if uppercase used in search string (cool)

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

" Always display the status line
set laststatus=2

" Numbers
set number
set numberwidth=5

"Display extra whitespace with a character
"This is awesome in contrast to red highlighting
"when browsing some ugly code
"wihout clear whitespace convention
set list listchars=trail:·
:map <F6> :set list!<CR>

syntax on               "Syntax highlighting on

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Set File type to 'text' for files ending in .txt
  autocmd BufNewFile,BufRead *.txt setfiletype text

  " Enable soft-wrapping for text files
  autocmd FileType text,markdown,html,xhtml,eruby setlocal wrap linebreak nolist

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Automatically load .vimrc source when saved
  autocmd BufWritePost .vimrc source $MYVIMRC

  augroup END

else

  set autoindent                " always set autoindenting on

endif " has("autocmd")

"Load pathogen for managing plugins
filetype off 
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

"Enable loading of filetype plugins
filetype plugin indent on

"Use zenburn
set background=dark
set t_Co=256
let g:zenburn_high_Contrast=1
:colorscheme zenburn

"Handy stuff
let mapleader = ","
"inserts ' => ' helpful for Ruby hashes
imap <C-L> <Space>=><Space>
"Aligns keys and valies in hashes or python dicts
"the following means - left align everything before '=>' and leave
"one space, right align everything after that prefixed with one space
map <Leader>== :Tabularize /=>/l1r1<CR>

" For Haml
au! BufRead,BufNewFile *.haml         setfiletype haml
"
" No Help, please
nmap <F1> <Esc>

" set spelling both Bulgarian and English
:map <F5> :setlocal spell! spelllang=en_us,bg<CR>
:imap <F5> <ESC>:setlocal spell! spelllang=en_us,bg<CR>

" Maps autocomplete to tab¶
imap <Tab> <C-N>
set showcmd  " display incomplete commands
set completeopt=longest,menu
set wildmode=list:longest,list:full
set complete=.,t
