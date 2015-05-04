if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" add plugins
NeoBundle 'szw/vim-tags'                        " Control ctags
NeoBundle 'alfredodeza/khuno.vim'               " Lint with flake8
NeoBundle 'hynek/vim-python-pep8-indent'        " PEP8 based auto indentation
NeoBundle 'Shougo/neocomplete.vim'              " Auto completion
NeoBundle 'marcus/rsense'                       " Ruby development helper
NeoBundle 'supermomonga/neocomplete-rsense.vim' " rsense plugin for neocomplete
NeoBundle 'tpope/vim-endwise'                   " Auto complete 'end' keyword (in Ruby)
NeoBundle 'nishigori/increment-activator'       " Enhance increment/decrement feature
NeoBundle 'thinca/vim-ref'                      " Reference viewer
NeoBundle 'yuku-t/vim-ref-ri'                   " Ruby plugin for vim-ref
NeoBundle 'itchyny/lightline.vim'               " Customize status line
NeoBundle 'nanotech/jellybeans.vim'             " Colorscheme
NeoBundle 'w0ng/vim-hybrid'                     " Colorscheme
NeoBundle 'Shougo/vimproc.vim', {
\           'build' : {
\             'windows' : 'tools\\update-dll-mingw',
\             'cygwin' : 'make -f make_cygwin.mak',
\             'mac' : 'make -f make_mac.mak',
\             'linux' : 'make',
\             'unix' : 'gmake',
\           },
\         }                                     " Asynchronous execution
NeoBundle "thinca/vim-quickrun"                 " Command runner
NeoBundle "osyo-manga/shabadou.vim"             " plugins for quickrun
NeoBundle "osyo-manga/vim-watchdogs"            " syntax checker plugin for quickrun
NeoBundle "cohama/vim-hier"                     " Highlights quickfix errors
NeoBundle "dannyob/quickfixstatus"              " Show quickfix error message for current line
NeoBundle "KazuakiM/vim-qfstatusline"           " Show quickfix status to status-line

call neobundle#end()

" lightline (status-line)
let g:lightline = {
\  'mode_map': {'c': 'NORMAL'},
\  'active': {
\    'right': [
\      [ 'syntaxcheck' ],
\    ]
\  },
\  'component_expand': {
\    'syntaxcheck': 'qfstatusline#Update',
\  },
\  'component_type': {
\    'syntaxcheck': 'error',
\  },
\}

" Setup quickrun
if !exists("g:quickrun_config")
  let g:quickrun_config = {}
endif
let g:quickrun_config["_"] = {
\  "runner" : "vimproc",
\  "runner/vimproc/sleep": 5,
\  "runner/vimproc/updatetime" : 20,
\  "runner/vimproc/read_timeout" : 1,
\}

" Setup watchdogs
let g:quickrun_config["watchdogs_checker/_"] = {
\  "outputter/quickfix/open_cmd" : "",
\  "hook/qfstatusline_update/enable_exit" : 1,
\  "hook/qfstatusline_update/priority_exit" : 4,
\}

let g:quickrun_config["ruby/watchdogs_checker"] = {
\  "type" : "watchdogs_checker/rubocop"
\}

let g:watchdogs_check_CursorHold_enables = {
\  "ruby" : 1
\}
call watchdogs#setup(g:quickrun_config)

" Callback lightline#update after :WatchdogsRun
let g:Qfstatusline#Text = 0
let g:Qfstatusline#UpdateCmd = function('lightline#update')

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

" Enable 256 colors FORCELY on screen
if $TERM == 'screen'
    set t_Co=256
endif

" Enable colorscheme
colorscheme jellybeans
syntax on

" Enable neocomplete
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif

filetype plugin on
filetype plugin indent on

augroup vimrc
  autocmd!

  " Do not treat new line as comment
  " (this setting should be enable after filetype plugin)
  autocmd Filetype * set formatoptions-=ro

  " Jump to last position on the file
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" For neocomplete
function! s:choice_from_neocomplete()
  return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction

NeoBundleCheck
