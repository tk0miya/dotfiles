if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" add plugins
NeoBundle 'alfredodeza/khuno.vim'         " Lint with flake8
NeoBundle 'hynek/vim-python-pep8-indent'  " PEP8 based auto indentation
NeoBundle 'scrooloose/syntastic'          " Syntax checker
NeoBundle 'tpope/vim-endwise'             " Auto complete 'end' keyword (in Ruby)
NeoBundle 'nishigori/increment-activator' " Enhance increment/decrement feature
NeoBundle 'itchyny/lightline.vim'         " Customize status line
NeoBundle 'nanotech/jellybeans.vim'       " Colorscheme
NeoBundle 'w0ng/vim-hybrid'               " Colorscheme

call neobundle#end()

" highlight Zenkaku spaces
augroup highlightDoubleByteSpace
  autocmd!
  autocmd VimEnter,Colorscheme * highlight DoubleByteSpace term=underline ctermbg=Red guibg=Red
  autocmd VimEnter,WinEnter,BufRead * match DoubleByteSpace /　/
augroup END

" basic settings
set smarttab                        " Expand <TAB>
set expandtab                       " Expand <TAB> to multiple spaces (see tabstop)
set tabstop=4                       " Length of <TAB> char
set shiftwidth=4                    " Length of auto-indentation
set incsearch                       " Do incremental search
set ignorecase                      " Case insensitive search as default
set smartcase                       " Case sensitive search if pattern contains CAPITAL chars
set infercase                       " Case insensitive completion
set hlsearch                        " Highlight search results
set list                            " Display invisible characters
set listchars=tab:>.,trail:_        " Display <TAB> as '>', trail spaces as '_'
set wildmenu                        " Show wildmenu on completion
set wildmode=longest,list,full      " Completion behavior
set ambiwidth=double                " Use twice width to some special characters (cf. ○,△) 
set formatoptions+=mM               " Do not insert spaces when join japanese lines
set display+=lastline               " Display last line in a window possibly
set lazyredraw                      " Do not redraw while executing macros, registers and so on
set laststatus=2                    " Show status line always
set ruler                           " Show position of cursor in status line
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
" - Enable C-a, C-e (like Emacs)
nnoremap <C-a> ^
nnoremap <C-e> $
" - turn off highlights
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>
" - Do centering after search
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" Enable 256 colors FORCELY on screen
if $TERM == 'screen'
    set t_Co=256
endif

" Enable colorscheme
colorscheme jellybeans
syntax on

filetype plugin on
filetype plugin indent on

" Do not treat new line as comment
" (this setting should be enable after filetype plugin)
autocmd Filetype * set formatoptions-=ro

" Jump to last position on the file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

NeoBundleCheck
