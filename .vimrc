" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

if exists('*minpac#init')
  " minpac is loaded.
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})

  " rails
  call minpac#add('tpope/vim-rails')
  " jobs
  call minpac#add('tpope/vim-dispatch')
  call minpac#add('radenling/vim-dispatch-neovim')
  " git
  call minpac#add('tpope/vim-fugitive')
  " ruby
  call minpac#add('vim-ruby/vim-ruby')
  " coffee script
  call minpac#add('kchmck/vim-coffee-script')
  " test things
  call minpac#add('janko-m/vim-test')
  " theme
  call minpac#add('jnurmine/Zenburn')
  " elixir
  call minpac#add('elixir-editors/vim-elixir')
  call minpac#add('slashmili/alchemist.vim')
  " multi-lang lint
  call minpac#add('w0rp/ale')
  " ctrl-p fuzzy search
  call minpac#add('junegunn/fzf')
  " grep
  call minpac#add('mhinz/vim-grepper')
  " go
  call minpac#add('fatih/vim-go')
  " split/join structs
  call minpac#add('AndrewRadev/splitjoin.vim')
  " completion
  call minpac#add('Shougo/deoplete.nvim')
  " go completeion
  call minpac#add('deoplete-plugins/deoplete-go', {'do': 'silent! !make'})
  " go rspec
  call minpac#add('ivy/vim-ginkgo')
  " go debug
  call minpac#add('sebdah/vim-delve')
endif

command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | source $MYVIMRC | call minpac#status()

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

" highlight 80-th column
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

" auto read/write the file on make
set autoread
set autowrite

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

"save a file as root
command! -bar -nargs=0 SudoW   :setl nomod|silent exe 'write !sudo tee %>/dev/null'|let &mod = v:shell_error

" pretty list chars
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

" set quickfix window size
"au FileType qf call AdjustWindowHeight(3, 20)
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

" Testing
nmap <silent> tt :TestNearest<CR>" t Ctrl+n
nmap <silent> tf :TestFile<CR>    " t Ctrl+f
nmap <silent> ts :TestSuite<CR>   " t Ctrl+s
"nmap <silent> t<C-l> :TestLast<CR>    " t Ctrl+l
"nmap <silent> t<C-g> :TestVisit<CR>   " t Ctrl+g

let test#strategy = "dispatch_background"
"let test#strategy = "dispatch"
if has('nvim')
  let test#strategy = "neovim"
end
if has('nvim')
  tmap <C-o> <C-\><C-n>
endif

"let g:test#preserve_screen = 1


" ALE
"
let g:ale_linters = {
\ 'javascript': ['eslint'],
\ 'ruby': ['rubocop'],
\ }

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 1
let g:ale_lint_on_filetype_changed = 0

" Mappings in the style of unimpaired-next
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

" FZF
nnoremap <C-p> :<C-u>FZF<CR>

" grepper
let g:grepper = {}
let g:grepper.tools = ['rg']

nnoremap <Leader>* :Grepper -cword -noprompt<CR>
xmap gs <plug>(GrepperOperator)
nmap gs <plug>(GrepperOperator)

" quickfix
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

" go
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <Leader>c  <Plug>(go-coverage-toggle)
autocmd FileType go nmap <Leader>i  <Plug>(go-info)

let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_metalinter_autosave = 1
let g:go_metalinter_deadline = "2s"
let g:go_template_autocreate = 0
"let g:go_auto_type_info = 1
let g:go_auto_sameids = 1
set updatetime=100

autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')


autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

let g:go_def_mode = 'godef'

" autocomplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#go#source_importer = 1
let g:deoplete#sources#go#builtin_objects = 1
let g:deoplete#sources#go#unimported_packages = 1
let g:deoplete#sources#go#package_dot = 1
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
