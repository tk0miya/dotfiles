set noexpandtab                     " Disable expanding <TAB>
set tabstop=4                       " Length of <TAB> char
set shiftwidth=4                    " Length of auto-indentation
set nolist                          " Reset listchars (defined at .vimrc)
set listchars=trail:_               " Display trail spaces as '_' (ignore <TAB> char)

" Enable auto completion
let g:neocomplete#force_omni_input_patterns.go = '\h\w\.\w*'
