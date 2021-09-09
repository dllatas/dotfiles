set backspace=indent,eol,start
set cursorline
set expandtab
set hidden
set ignorecase
set incsearch
set laststatus=2
set mouse+=a
set nocompatible
set noerrorbells visualbell t_vb=
set number
set relativenumber
set smartcase
set softtabstop=4
set splitbelow
set splitright
set shiftwidth=4
set shortmess+=I
set showcmd
set showmatch
set tabstop=4
set updatetime=100

syntax on
filetype plugin on
filetype indent on

nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>

inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
inoremap <Down>  <ESC>:echoe "Use j"<CR>

nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

call plug#begin()

" File finder
Plug 'ctrlpvim/ctrlp.vim'

" Code Search
Plug 'mileszs/ack.vim'

" Syntax
Plug 'w0rp/ale'                        " Linting engine
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Movement
Plug 'easymotion/vim-easymotion'

" GUI
Plug 'itchyny/lightline.vim'          " Better Status Bar
Plug 'mhinz/vim-startify'             " Better start screen
Plug 'scrooloose/nerdtree'            " File explorer

call plug#end()

" NerdTree
let NERDTreShowBookmarks=1
let NERDTreeShowHidden=1

" Ale
let g:ale_fix_on_save  = 1
let g:ale_sign_error   = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_fixers = {
\  'javascript': ['eslint', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
\}
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

" GoVIM
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

" Lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
\ }
