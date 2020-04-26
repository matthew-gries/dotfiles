
set background=dark
let g:base16colorspace=256
" ---- Disabe Vi Compatibility ----
set nocompatible

" ---- Set up the Vundle stuff ----
"filetype off

"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()

"Plugin 'gmarik/Vundle.vim'
"Plugin 'preservim/nerdtree'
"Plugin 'terryma/vim-multiple-cursors'
"Plugin 'vim-airline/vim-airline'
"Plugin 'airblade/vim-gitgutter'
"Plugin 'valloric/youcompleteme'
"Plugin 'dense-analysis/ale'

"call vundle#end()

"filetype plugin indent on

" ---- NERDTree settings ----

" Open NERDTree if opening a directory
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" Close NERDTree when all files are closed
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Use Ctrl+d to open NERDTree
"map <C-d> :NERDTreeToggle<CR>

" ---- General settings ----
set backspace=indent,eol,start
set ruler
set number
"set cursorline
set showcmd
set incsearch
set hlsearch
set nowrap
set wildmenu
set mouse=a
set encoding=utf-8
set autoindent
syntax on

" ---- Indentation ----
set expandtab
set tabstop=4
set shiftwidth=4

" ---- Colorscheme ----
"colors molokai
