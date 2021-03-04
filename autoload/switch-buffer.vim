
"=============================
" Buffer related mapping
"=============================
" enhance buffer navigation
" require 'Shougo/tabpagebuffer.vim'
noremap <silent> <C-l> :call SwitchBuffer('bn')<CR>
noremap <silent> <C-h> :call SwitchBuffer('bp')<CR>
inoremap <silent> <C-l> <C-\><C-n>:call SwitchBuffer('bn')<CR>
inoremap <silent> <C-h> <C-\><C-n>:call SwitchBuffer('bp')<CR>

noremap <silent> + :call tabbuffers#move(1)<CR>
noremap <silent> - :call tabbuffers#move(-1)<CR>
" unlist quickfix buffer so that we will not navigate to it
autocmd FileType qf setlocal nobuflisted

" Do <C-w>l or <C-w>h if only one buffer
function! SwitchBuffer(bn_or_bp)
  if empty(&buflisted)
    return
  endif

  " switch tab buffers instead of loop all buffers
  let tab_listed_bufs = tabbuffers#get()
  if len(tab_listed_bufs) > 1
    call tabbuffers#switch(a:bn_or_bp == 'bn' ? 1 : -1)
    return
  endif

  let current_winnr = winnr()
  if a:bn_or_bp == 'bn'
    " switch to next window
    " or to topleft window if currently at the last window
    execute "normal! \<C-w>".(current_winnr == len(getwininfo()) ? "t" : "l")
    return
  endif

  if a:bn_or_bp == 'bp'
    " switch to previous window
    " or to bottomright window if currently at the first window
    execute "normal! \<C-w>".(current_winnr == 1 ? "b" : "h")
    return
  endif

  execute a:bn_or_bp
endfunction
