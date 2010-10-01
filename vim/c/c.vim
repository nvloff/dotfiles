" process only once
if exists("my_vim_c_vim_loaded") || &compatible
   finish
endif

let my_vim_c_vim_loaded = 1

" useful for arranging a block of comments
nmap <C-J> vip=

" Setup tabstops to 8 and indents to 8
set tabstop=8
set shiftwidth=8
set noexpandtab
set textwidth=78        " Set the line wrap length

let c_space_errors=1
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/


" line wrapping in c comments not c code

syn match ErrorLeadSpace /^ \+/      " highlight any leading spaces
syn match ErrorTailSpace / \+$/      " highlight any trailing spaces
syn match Error80            /\%>80v.\+/ " highlight anything past 80 in red

" more types...
syn keyword cType uint ubyte ulong uint64_t uint32_t uint16_t uint8_t boolean_t int64_t int32_t int16_t int8_t u_int64_t u_int32_t u_int16_t u_int8_t

syn keyword cOperator likely unlikely

" C-mode formatting options
"   t auto-wrap comment
"   c allows textwidth to work on comments
"   q allows use of gq* for auto formatting
"   l don't break long lines in insert mode
"   r insert '*' on <cr>
"   o insert '*' on newline with 'o'
"   n recognize numbered bullets in comments
set formatoptions=tcqlron

set nu          "line numbers

" C-mode options (cinoptions==cino)
" N number of spaces
" Ns    number of spaces * shiftwidth
" >N    default indent
" eN    extra indent if the { is at the end of a line
" nN    extra indent if there is no {} block
" fN    indent of the { of a function block
" gN    indent of the C++ class scope declarations (public, private, protected)
" {N    indent of a { on a new line after an if,while,for...
" }N    indent of a } in reference to a {
" ^N    extra indent inside a function {}
" :N    indent of case labels
" =N    indent of case body
" lN    align case {} on the case line
" tN    indent of function return type
" +N    indent continued algibreic expressions
" cN    indent of comment line after /*
" )N    vim searches for closing )'s at most N lines away
" *N    vim searches for closing */ at most N lines away
set cinoptions=:0l1t0g0
