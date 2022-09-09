let data_dir = stdpath('data') . '/site'
if empty(glob(data_dir . '/autoload/plug.vim'))
	silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'sheerun/vim-polyglot'
Plug 'machakann/vim-highlightedyank'
Plug 'lambdalisue/suda.vim'
call plug#end()

let mapleader=" "
map <nowait> Q nop
nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>W <cmd>wq<cr>
nnoremap <leader>q <cmd>q<cr>
nnoremap <leader>Q <cmd>q!<cr>
nnoremap <leader>c <cmd>split $MYVIMRC<cr>
nnoremap <leader>z <cmd>set spell!<cr>
nnoremap <leader>r *:%s///gcI<left><left><left><left>
nnoremap <leader>b <cmd>ls<cr>:b<space>
nnoremap <leader>f :find<space>
nnoremap <leader>o <cmd>browse oldfiles<cr>
nnoremap <c-j> m`i<cr><esc>``
nnoremap <a-o> :set paste<cr>m`o<esc>``:set nopaste<cr>
nnoremap <a-O> :set paste<cr>m`O<esc>``:set nopaste<cr>

autocmd BufWritePre * let b:v = winsaveview() | keeppatterns %s/\s\+$//e | call winrestview(b:v)
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

let g:highlightedyank_highlight_duration = 150

set shell=sh
set updatetime=100
set timeoutlen=10000
set clipboard=unnamedplus
set mouse=a
set ignorecase
set smartcase
set undofile
set swapfile
set lazyredraw
set path=**
set completeopt=menuone,noselect
set wildmode=longest:full,full
set spellsuggest=best,9
set shada=!,'20,<50,s10,h
set tabstop=4
set shiftwidth=0
set virtualedit=onemore
set termguicolors
set number
set pumheight=6
set list
set listchars=tab:›\ ,trail:•,precedes:«,extends:»,nbsp:␣
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400
set shortmess+=sIc
set nofoldenable
set nowrap
