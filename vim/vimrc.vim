syntax on

set nocompatible

set autoindent
set smartindent
" set cindent

set smarttab

set shiftwidth=4 " width of an indent
set softtabstop=4 " number of spaces of an indent (expandtab)
set tabstop=4 " number of visual spaces for an indent
" set noexpandtab " input spaces instead of a <TAB>
set expandtab

set number
set ruler
set cursorline
set cursorcolumn

set hlsearch
set incsearch

set mouse=a
set whichwrap+=[,]
" set nowrap

set t_Co=256
colorscheme codedark
" colorscheme seti
" colorscheme jellybeans
" colorscheme torte
" hi Search cterm=reverse ctermbg=none ctermfg=none

noremap <C-t> :NERDTreeToggle<CR>
let NERDTreeMapOpenInTab='<space>'

inoremap <C-p> <C-x><C-f>
inoremap <C-a> <C-n>

command -nargs=1 NE :set noexpandtab shiftwidth=<args> tabstop=<args>
command -nargs=1 ET :set expandtab shiftwidth=<args> tabstop=<args> softtabstop=<args>
command AI :set ai si
command NI :set noai nosi
command MN :set mouse=
command MA :set mouse=a

if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
