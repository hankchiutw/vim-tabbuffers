
" Get buffers associated with current tab.
" Not using tabpagebuflist() because it doesn't include background buffers.
" XXX: consider caching the result
function! tabbuffers#get() abort
  if !exists('t:tabbufs')
    return []
  endif
  return t:tabbufs
endfunction

function! tabbuffers#move(offset) abort
  let bufnr = bufnr('%')
  let buf_index = index(t:tabbufs, bufnr)
  let next_index = (buf_index + a:offset) % len(t:tabbufs)
  let next_bufnr = t:tabbufs[next_index]

  " swap values in t:tabbufs
  let t:tabbufs[buf_index] = next_bufnr
  let t:tabbufs[next_index] = bufnr

  bn
  bp
endfunction

function! tabbuffers#switch(bn_or_bp)
  if empty(&buflisted)
    return
  endif

  " switch tab buffers instead of loop all buffers
  let tab_listed_bufs = tabbuffers#get()
  if len(tab_listed_bufs) > 1
    call s:switch(a:bn_or_bp == 'bn' ? 1 : -1)
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

  let tab_listed_bufs = tabbuffers#get()
  if len(tab_listed_bufs) > 1
    let is_first = bufnr('%') == tab_listed_bufs[0]
    " switch buffer, then delete prev buffer
    call s:switch(is_first ? 1 : -1)
    bd! #
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
  let next_bufnr = s:next_bufnr(bufnr('%'), a:offset)
  exec 'b'.next_bufnr
endfunction

function! s:next_bufnr(bufnr, offset) abort
  let bufs = tabbuffers#get()
  let current_index = index(bufs, a:bufnr)
  let next_index = current_index + a:offset
  if next_index >= len(bufs)
    let next_index = 0
  endif
  if next_index < 0
    let next_index = len(bufs) - 1
  endif
  return bufs[next_index]
endfunction
