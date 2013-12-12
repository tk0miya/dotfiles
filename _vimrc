if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" add plugins
NeoBundle 'alfredodeza/khuno.vim'  " Lint with flake8
NeoBundle 'Townk/vim-autoclose'    " Close quotations automatically

" search highlights
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>  " turn off highlights


filetype plugin on

NeoBundleCheck
