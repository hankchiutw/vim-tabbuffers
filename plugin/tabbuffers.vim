
if exists('g:loaded_tabbuffer')
  finish
endif

augroup tabbuffer
  autocmd!
  " assume the top-left window is the main window
  autocmd TabNew,VimEnter * call setwinvar(1, "has_tabbuffers", 1)

  autocmd BufReadPost * call s:append_buf()
  autocmd BufDelete * call s:unset_buf()
  autocmd BufEnter * call s:jump_to_buftab()

  autocmd TermOpen * 
        \ call s:append_buf() |
        \ if (exists('w:has_tabbuffers')) | set ft=tabbuffers-terminal | endif

  autocmd FileType tabbuffers-terminal call s:setup_term()
augroup END

let g:loaded_tabbuffer = 1

" terminal specific settings
function! s:setup_term() abort
  tnoremap <buffer> <Esc> <C-\><C-n>
  autocmd TermClose <buffer> call s:unset_buf()
  autocmd TermClose <buffer> b# | bd! #
  autocmd TermEnter <buffer> call s:jump_to_buftab()
endfunction

" Switch to the tab where the buffer associated with.
function! s:jump_to_buftab() abort
  let buftab = getbufvar(bufnr('%'), 'buftab')
  if !empty(buftab) && buftab !=# tabpagenr()
    bp
    exec buftab . 'tabn'
  endif
endfunction

function! s:unset_buf() abort
  let bufnr = expand('<abuf>')
  if !exists('t:tabbuffer') || !has_key(t:tabbuffer, bufnr)
    return
  endif

  unlet t:tabbuffer[bufnr]
endfunction

" Associate the buffer with the current tab.
function! s:append_buf() abort
  if !&buflisted
    return
  endif

  if !exists('t:tabbuffer')
    let t:tabbuffer = {}
  endif

  let bufnr = expand('<abuf>')
  let t:tabbuffer[bufnr] = max(t:tabbuffer) + 1
  let b:buftab = tabpagenr()
endfunction

" Get buffers associated with current tab.
" Not using tabpagebuflist() because it doesn't include background buffers.
" XXX: consider caching the result
function! tabbuffers#get() abort
  if !exists('t:tabbuffer')
    return []
  endif
  let buf_items = sort(items(t:tabbuffer), {item1, item2 -> item1[1] - item2[1]})
  let bufs = map(buf_items, 'str2nr(v:val[0])')
  return bufs
endfunction

function! tabbuffers#switch(offset) abort
  let next_bufnr = s:next_bufnr(bufnr('%'), a:offset)
  exec 'b'.next_bufnr
endfunction

function! tabbuffers#move(offset) abort
  let bufnr = bufnr('%')
  let next_bufnr = s:next_bufnr(bufnr, a:offset)

  " swap values in t:tabbuffer
  let tmp = t:tabbuffer[bufnr]
  let t:tabbuffer[bufnr] = t:tabbuffer[next_bufnr]
  let t:tabbuffer[next_bufnr] = tmp

  bn
  bp
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
