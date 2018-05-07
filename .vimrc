" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

if exists('*minpac#init')
  " minpac is loaded.
  call minpac#init()
  "call minpac#add('k-takata/minpac', {'type': 'opt'})

  call minpac#add('tpope/vim-rails')
  call minpac#add('tpope/vim-dispatch')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('vim-ruby/vim-ruby')
  call minpac#add('kchmck/vim-coffee-script')
  call minpac#add('janko-m/vim-test')
  call minpac#add('jnurmine/Zenburn')
endif

command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()

filetype off

syntax on               " mac os vim has this off by default

set ttyfast
set lazyredraw
unlet! ruby_no_identifiers
unlet! ruby_no_expensive
"let ruby_no_identifiers = 1
"let ruby_no_expensive = 1

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set history=10000       " keep 10000 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands

set hidden              " allow unsaved background buffers and remember marks/undo for them

"Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

set incsearch           " do incremental searching
set hlsearch            " highlight search results

set nowrap              " switch wrap off for everything set nowrap

set wildmenu            " : menu has tab completion, etc

set mousehide           " hide the cursor while writing

set ignorecase          " you nearly always want this
set smartcase           " overrides ignorecase if uppercase used in search string (cool)

set cursorline          " highlight the current line

set showmatch           " when a bracket is inserted, briefly jump to the matching one.

set showtabline=2       " allways show the tab line

set scrolloff=3         " keep 3 lines of context when scrolling

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

set colorcolumn=80

" Always display the status line
set laststatus=2
if exists('g:loaded_fugitive')
  set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
endif

"Line Numbers
set number
set numberwidth=5

set completeopt=longest,menu
set wildmode=longest,list

set autoread

"Use zenburn
set background=dark
set t_Co=256
let g:zenburn_high_Contrast=1
let g:zenburn_alternate_Visual = 1
let g:zenburn_alternate_Error = 1
silent! colorscheme zenburn

" set spelling both Bulgarian and English
:map <F5> :setlocal spell! spelllang=en_us,bg<cr>
:imap <F5> <ESC>:setlocal spell! spelllang=en_us,bg<cr>

"Handy stuff
let mapleader = ","

map <Leader>\| :Tabularize /\|<cr>

"edit a file as root
command! -bar -nargs=0 SudoW   :setl nomod|silent exe 'write !sudo tee %>/dev/null'|let &mod = v:shell_error

let &listchars = "tab:\u21e5\u00b7,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u26ad"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>


" Run a given vim command on the results of fuzzy selecting from a given shell
" command. See usage below.
function! SelectaCommand(choice_command, selecta_args, vim_command)
  try
    silent let selection = system(a:choice_command . " | selecta " . a:selecta_args)
  catch /Vim:Interrupt/
    " Swallow the ^C so that the redraw below happens; otherwise there will be
    " leftovers from selecta on the screen
    redraw!
    return
  endtry
  redraw!
  exec a:vim_command . " " . selection
endfunction

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
nnoremap <leader>f :call SelectaCommand("find * -type f", "", ":e")<cr>

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
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown


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

au FileType qf call AdjustWindowHeight(3, 20)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

" highlight space errors
:highlight ExtraWhitespace ctermbg=239
" the following pattern will match trailing whitespace, except
" when typing at the end of a line.
" show tabs that are not at the start of a line:
:autocmd BufWinEnter * match ExtraWhitespace /\s\+\%#\@<!$\|[^\t]\zs\t\+/

" different error highlighting
hi Error ctermfg=210 ctermbg=239 gui=bold

" these "Ctrl mappings" work well when Caps Lock is mapped to Ctrl
nmap <silent> tt :TestNearest<CR>" t Ctrl+n
nmap <silent> tf :TestFile<CR>    " t Ctrl+f
nmap <silent> ts :TestSuite<CR>   " t Ctrl+s
"nmap <silent> t<C-l> :TestLast<CR>    " t Ctrl+l
"nmap <silent> t<C-g> :TestVisit<CR>   " t Ctrl+g

"let test#strategy = "dispatch_background"
let test#strategy = "dispatch"
"let g:test#preserve_screen = 1
