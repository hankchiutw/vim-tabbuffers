" t:mrubufs stores the navigation history

" Remvoe all the target bufnr from t:mrubufs, not only the last one.
" Keep no repeated adjacent bufnr in the list.
function! tabbuffers#prop_mrubufs#unset() abort
  if !exists('t:mrubufs')
    return
  endif

  let bufnr = str2nr(expand('<abuf>'))
  call filter(t:mrubufs, 'v:val != bufnr')
  if !empty(t:mrubufs) && t:mrubufs[-1] == bufnr('%')
    call remove(t:mrubufs, -1)
  endif
  call uniq(t:mrubufs)
endfunction

function! tabbuffers#prop_mrubufs#add() abort
  if !exists('t:mrubufs')
    let t:mrubufs = []
  endif

  if !&buflisted
    return
  endif

  let bufnr = bufnr('#')
  let current_bufnr = str2nr(expand('<abuf>'))
  if bufnr == current_bufnr || bufnr == -1
    " only one buffer
    return
  endif

  if !empty(t:mrubufs) && bufnr == t:mrubufs[-1]
    " enter the same buffer
    return
  endif

  if empty(bufname(bufnr))
    " not a tab buffer
    return
  endif

  " actually add append buffer below
  call s:append_buf(bufnr)
endfunction

function! s:append_buf(bufnr) abort
  call add(t:mrubufs, a:bufnr)
  if len(t:mrubufs) > g:tabbuffers_mru_size
    call remove(t:mrubufs, 0)
  endif
endfunction
