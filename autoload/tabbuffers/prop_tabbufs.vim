" t:tabbufs stores buffers that are associated with current tab.
" Not using tabpagebuflist() because it doesn't include background buffers.

" b:buftab is the tabpagenr associated with a buffer

function! tabbuffers#prop_tabbufs#get() abort
  if !exists('t:tabbufs')
    return []
  endif
  return t:tabbufs
endfunction

function! tabbuffers#prop_tabbufs#unset() abort
  if !exists('t:tabbufs')
    return
  endif

  let bufnr = str2nr(expand('<abuf>'))
  let buf_index = index(t:tabbufs, bufnr)
  if buf_index == -1
    return
  endif

  unlet t:tabbufs[buf_index]
endfunction

function! tabbuffers#prop_tabbufs#add() abort
  if !&buflisted
    return
  endif

  if !exists('t:tabbufs')
    let t:tabbufs = []
  endif

  let bufnr = str2nr(expand('<abuf>'))
  if index(t:tabbufs, bufnr) != -1
    " already exists
    return
  endif

  call add(t:tabbufs, bufnr)
  let b:buftab = tabpagenr()
endfunction
