" Enable dein
let s:dein_dir = expand('~/.vim/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" Plugin settings
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  let g:rc_dir    = expand('~/.vim/rc')
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif

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
set backspace=indent,eol            " Allow removing indents and EOLs by backspace
set completeopt=menuone             " Use popup menu for completion if there is only one match
set splitbelow                      " Put a new window below the current one when opening it

" key mappings (moves)
" - Move cursor by display line
vnoremap j gj
vnoremap k gk
noremap j gj
noremap k gk
" - Enable C-a, C-e (like Emacs)
nnoremap <C-a> ^
nnoremap <C-e> $
" - quickfix
nnoremap <silent> <C-n> :cnext<CR>
nnoremap <silent> <C-p> :cprevious<CR>
" - turn off highlights
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>
" - choice from neocomplete or send <CR>
inoremap <silent> <CR> <C-r>=<SID>choice_from_neocomplete()<CR>
" - switch a choice of neocomplete
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" - Do centering after search
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
" - call Denite.nvim
nnoremap [unite] <Nop>
nmap <C-g> [unite]
nnoremap <silent> [unite]<C-b>  :<C-u>Denite buffer<CR>
nnoremap <silent> [unite]<C-f>  :<C-u>Denite `finddir('.git', ';') != '' ? 'file/rec/git' : 'file/rec'`<CR>
nnoremap <silent> [unite]<C-g>  :<C-u>Denite buffer<CR>
nnoremap <silent> [unite]<C-m>  :<C-u>Denite file_mru<CR>
nnoremap <silent> [unite]<C-u>  :<C-u>Denite buffer file_mru<CR>

" Enable 256 colors FORCELY on screen
if $TERM == 'screen'
  set t_Co=256
endif

" Disable auto indent on pasting from clipboard
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

" Enable colorscheme
if dein#tap('jellybeans.vim')
  colorscheme jellybeans
endif
syntax on

filetype plugin on
filetype plugin indent on

augroup vimrc
  autocmd!

  " Do not treat new line as comment
  " (this setting should be enable after filetype plugin)
  autocmd Filetype * set formatoptions-=ro

  " CHANGES of Sphinx should be folded with 80 columns
  autocmd BufRead,BufNewFile CHANGES let &colorcolumn=join(range(81,255),",")

  " Jump to last position on the file
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" For neocomplete
function! s:choice_from_neocomplete()
  return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
