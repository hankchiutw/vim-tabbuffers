
function! tabbuffers#move(offset) abort
  let bufnr = bufnr('%')
  let buf_index = index(t:tabbufs, bufnr)
  let next_index = buf_index + a:offset
  let len = len(t:tabbufs)

  call remove(t:tabbufs, buf_index)
  if a:offset == -1 && next_index == -1
    " append the first item to the end
    call add(t:tabbufs, bufnr)
  elseif a:offset == 1 && next_index == len
    " prepend the last item to the begin
    call insert(t:tabbufs, bufnr)
  else
    call insert(t:tabbufs, bufnr, next_index)
  endif

  " redraw tabline
  edit
endfunction

function! tabbuffers#switch(offset)
  if empty(&buflisted)
    return
  endif

  " switch tab buffers instead of loop all buffers
  if len(t:tabbufs) > 1
    call s:switch(a:offset)
    return
  endif

  let current_winnr = winnr()
  if a:offset == 1
    " switch to next window
    " or to topleft window if currently at the last window
    execute "normal! \<C-w>".(current_winnr == len(getwininfo()) ? "t" : "l")
    return
  endif

  if a:offset == -1
    " switch to previous window
    " or to bottomright window if currently at the first window
    execute "normal! \<C-w>".(current_winnr == 1 ? "b" : "h")
    return
  endif
endfunction

" Close the current buffer and back to the last buffer
function! tabbuffers#quit()
  " delete terminal buffer normally
  " TermClose autocmd in tabbuffers.vim will handle buffer switching
  if &buftype == "terminal"
    bd!
    return
  endif

  " quit current window if non-file buffer
  if !empty(&buftype)
    q!
    return
  endif

  lclose

  if len(tabbuffers#prop_tabbufs#get()) > 1
    " to keep the window open
    enew
    bd! #
    exec 'b' . (empty(t:mrubufs) ? t:tabbufs[0] : t:mrubufs[-1])
  elseif winnr('$') == 1
    " only one window and one buffer
    q!
  elseif empty(getbufinfo('%')[0].name)
    " only one empty buffer
    if tabpagenr('$') > 1
      " more than one tabpage
      tabc
    else
      qa!
    endif
  else
    " only one non-empty buffer, switch to empty buffer
    enew | bd! #
  endif
endfunction

function! s:switch(offset) abort
  let bufnr = bufnr('%')
  let buf_index = index(t:tabbufs, bufnr)
  let next_index = (buf_index + a:offset) % len(t:tabbufs)
  let next_bufnr = t:tabbufs[next_index]
  exec 'b'.next_bufnr
endfunction
