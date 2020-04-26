set nocompatible

set background=dark
let g:base16colorspace=256

call plug#begin('~/.local/share/nvim/plugged')

Plug 'preservim/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'sainnhe/sonokai'
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
"Plug 'tmsvg/pear-tree'
Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/wombat256.vim'

autocmd BufEnter * call ncm2#enable_for_buffer()

set completeopt=noinsert,menuone,noselect

Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-pyclang'
Plug 'ncm2/ncm2-jedi'

call plug#end()

let g:ncm2_pyclang#library_path = '/usr/lib64/libclang.so.9'

" Open NERDTree if opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" Close NERDTree when all files are closed
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Use Ctrl+d to open NERDTree
map <C-q> :NERDTreeToggle<CR>

set shortmess+=c

inoremap <c-c> <ESC>

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
au User Ncm2Plugin call ncm2#register_source({
        \ 'name' : 'css',
        \ 'priority': 9,
        \ 'subscope_enable': 1,
        \ 'scope': ['css','scss'],
        \ 'mark': 'css',
        \ 'word_pattern': '[\w\-]+',
        \ 'complete_pattern': ':\s*',
        \ 'on_complete': ['ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
        \ })

let g:airline_theme='base16'
let g:NERDTreeDirArrows=1
" ---- General settings ----
set backspace=indent,eol,start
set ruler
set number
set showcmd
set incsearch
set hlsearch
set nowrap
set wildmenu
set mouse=a
set fileencoding=utf-8
set termencoding=utf-8
scriptencoding utf-8
set encoding=utf-8
set autoindent
syntax on

" ---- Indentation ----
set expandtab
set tabstop=4
set shiftwidth=4

colors sonokai
