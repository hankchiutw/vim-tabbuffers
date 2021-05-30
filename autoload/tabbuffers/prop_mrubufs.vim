" t:mrubufs stores the navigation history
" t:mrubufs_cur stores the current index of mrubufs navigation

" Remvoe all the target bufnr from t:mrubufs, not only the last one.
" Keep no repeated adjacent bufnr in the list.
function! tabbuffers#prop_mrubufs#unset() abort
  if !exists('t:mrubufs')
    return
  endif

  let bufnr = str2nr(expand('<abuf>'))
  call filter(t:mrubufs, 'v:val != bufnr')
  call uniq(t:mrubufs)
  let t:mrubufs_cur = len(t:mrubufs) - 1
endfunction

function! tabbuffers#prop_mrubufs#add() abort
  if !exists('t:mrubufs')
    let t:mrubufs = []
  endif

  if !exists('t:mrubufs_cur')
    let t:mrubufs_cur = len(t:mrubufs) - 1
  endif

  let bufnr = str2nr(expand('<abuf>'))

  if empty(&buflisted)
    return
  endif

  if empty(bufname(bufnr))
    " empty new buffer
    return
  endif

  if !empty(t:mrubufs) && bufnr == t:mrubufs[t:mrubufs_cur]
    " enter the same buffer
    " or enter by tabbuffers#prop_mrubufs#{back,forward} 
    return
  endif

  " cut mrubufs if jumping to any buffer
  if t:mrubufs_cur > -1 && t:mrubufs_cur < len(t:mrubufs) - 1
    call remove(t:mrubufs, t:mrubufs_cur + 1, -1)
  endif

  " actually append the buffer
  call s:append_buf(bufnr)
  let t:mrubufs_cur = len(t:mrubufs) - 1
endfunction

function! tabbuffers#prop_mrubufs#back() abort
  if t:mrubufs_cur == 0
    return
  endif

  let t:mrubufs_cur = t:mrubufs_cur - 1
  exec 'b' . t:mrubufs[t:mrubufs_cur]
endfunction

function! tabbuffers#prop_mrubufs#forward() abort
  if t:mrubufs_cur == len(t:mrubufs) - 1
    return
  endif

  let t:mrubufs_cur = t:mrubufs_cur + 1
  exec 'b' . t:mrubufs[t:mrubufs_cur]
endfunction

function! s:append_buf(bufnr) abort
  call add(t:mrubufs, a:bufnr)
  if len(t:mrubufs) > g:tabbuffers_mru_size
    call remove(t:mrubufs, 0)
  endif
endfunction
