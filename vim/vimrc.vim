syntax on

set nocompatible
set backspace=indent,eol,start

set autoindent
set smartindent
" set cindent

set whichwrap=b,s,<,>,[,]

set smarttab

set shiftwidth=4 " width of an indent when using < >
set softtabstop=4 " number of spaces inserted (when expandtab)
set tabstop=8 " width of a <TAB> character
" set noexpandtab 
set expandtab " input spaces instead of a <TAB>

set number
set ruler
set cursorline
" set cursorcolumn

set hlsearch
set incsearch

set ignorecase
set smartcase

" set nowrap

set t_Co=256
colorscheme seti
" colorscheme jellybeans
" colorscheme torte
" hi Search cterm=reverse ctermbg=none ctermfg=none

if has('termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

noremap <C-t> :NERDTreeToggle<CR>
let NERDTreeMapOpenInTab='<space>'
let NERDSpaceDelims=1

inoremap <C-p> <C-x><C-f>
inoremap <C-a> <C-n>

command -nargs=1 NE :set noexpandtab shiftwidth=<args> tabstop=<args>
command -nargs=1 ET :set expandtab shiftwidth=<args> tabstop=<args> softtabstop=<args>
command AI :set ai si
command NI :set noai nosi
command MN :set mouse=
command MA :set mouse=a

filetype plugin indent on

if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    autocmd FileType ruby,html,javascript,yaml,json,vue,css,scss,sass set expandtab shiftwidth=2 softtabstop=2 tabstop=8
    autocmd FileType go set noexpandtab shiftwidth=4 softtabstop=8 tabstop=4
    "autocmd FileType makefile set noexpandtab shiftwidth=8 softtabstop=8 tabstop=8
endif
