if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" add plugins
NeoBundle 'alfredodeza/khuno.vim'   " Lint with flake8
NeoBundle 'Townk/vim-autoclose'     " Close quotations automatically
NeoBundle 'kana/vim-smartword'      " Cursor moving helper
NeoBundle 'nanotech/jellybeans.vim' " Colorscheme
NeoBundle 'w0ng/vim-hybrid'         " Colorscheme

" search highlights
set hlsearch
" - turn off highlight
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" basic settings
set smarttab                        " Expand <TAB>
set expandtab                       " Expand <TAB> to multiple spaces (see tabstop)
set tabstop=4                       " Length of <TAB> char
set shiftwidth=4                    " Length of auto-indentation
set incsearch                       " Do incremental search
set ignorecase                      " Case insensitive search as default
set smartcase                       " Case sensitive search if pattern contains CAPITAL chars
set list                            " Display invisible characters
set listchars=tab:>.,trail:_        " Display <TAB> as '>', trail spaces as '_'
set wildmenu                        " Show wildmenu on completion
set wildmode=longest,list,full      " Completion behavior
set ambiwidth=double                " Use twice width to some special characters (cf. ○,△) 
set formatoptions+=mM               " Do not insert spaces when join japanese lines
set display+=lastline               " Display last line in a window possibly
set lazyredraw                      " Do not redraw while executing macros, registers and so on
set showcmd                         " Show command in status line
set cursorline                      " Show cursor line
set autoread                        " Auto reload file if buffer is not changed
set autoindent                      " Do auto indent
set smartindent                     " Do auto indent

" key mappings (moves)
" - Move cursor by display line
vnoremap j gj
vnoremap k gk
noremap j gj
noremap k gk
" Enable C-a, C-e (like Emacs)
nnoremap <C-a> ^
nnoremap <C-e> $
" - Do centering after search
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
" - replace smartword mover
map w <Plug>(smartword-w)
map b <Plug>(smartword-b)
map e <Plug>(smartword-e)
map ge <Plug>(smartword-ge)

" Enable colorscheme
colorscheme jellybeans
syntax on

filetype plugin on
filetype plugin indent on

NeoBundleCheck
