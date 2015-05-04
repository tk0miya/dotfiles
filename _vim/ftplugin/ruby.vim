set tabstop=2      " Length of <TAB> char
set shiftwidth=2   " Length of auto-indentation

" Enable rsense
let g:rsenseUseOmniFunc = 1
let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

" Invoke watchdogs on changing buffer
augroup ruby_syntaxchecker
  autocmd!
  autocmd InsertLeave,BufWritePost,TextChanged <buffer> WatchdogsRun
  autocmd BufRead,BufNewFile <buffer> WatchdogsRun
augroup END
