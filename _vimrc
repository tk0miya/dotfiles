if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" add plugins
NeoBundle 'alfredodeza/khuno.vim'  " Lint with flake8
NeoBundle 'Townk/vim-autoclose'    " Close quotations automatically
NeoBundle 'kana/vim-smartword'     " Cursor moving helper

" search highlights
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>  " turn off highlight

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

filetype plugin on

NeoBundleCheck
