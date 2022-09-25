
if exists('g:loaded_tabbuffer')
  finish
endif

augroup tabbuffer
  autocmd!
  " assume the top-left window is the main window
  autocmd TabNew,VimEnter * call setwinvar(1, "has_tabbuffers", 1)

  autocmd BufReadPost * call tabbuffers#prop_tabbufs#add()
  autocmd BufDelete * call tabbuffers#prop_tabbufs#unset()
  autocmd BufEnter * call s:jump_to_buftab()

  autocmd BufDelete * call tabbuffers#prop_mrubufs#unset()
  autocmd BufEnter * call tabbuffers#prop_mrubufs#add()

  if has('nvim')
    autocmd TermOpen *
          \ call tabbuffers#prop_tabbufs#add() |
          \ if (exists('w:has_tabbuffers')) | set ft=tabbuffers-terminal | endif

    autocmd FileType tabbuffers-terminal call s:setup_term()
  endif
augroup END

let g:loaded_tabbuffer = 1
let g:tabbuffers_mru_size = 20

"=============================
" tabbuffers#quit
"=============================
" handy quit and write
nnoremap <Plug>(TabbuffersQuit) :call tabbuffers#quit()<CR>

"=============================
" Buffer related mapping
"=============================
" enhance buffer navigation
" require 'Shougo/tabpagebuffer.vim'
noremap <silent> <Plug>(TabbuffersSwitchRight) :call tabbuffers#switch(1)<CR>
noremap <silent> <Plug>(TabbuffersSwitchLeft) :call tabbuffers#switch(-1)<CR>
noremap <silent> <Plug>(TabbuffersMoveRight) :call tabbuffers#move(1)<CR>
noremap <silent> <Plug>(TabbuffersMoveLeft) :call tabbuffers#move(-1)<CR>
nnoremap <Plug>(TabbuffersMruBack) :call tabbuffers#prop_mrubufs#back()<CR>
nnoremap <Plug>(TabbuffersMruForward) :call tabbuffers#prop_mrubufs#forward()<CR>

" unlist quickfix buffer so that we will not navigate to it
autocmd FileType qf setlocal nobuflisted

" terminal specific settings
function! s:setup_term() abort
  tnoremap <buffer> <Esc> <C-\><C-n>
  autocmd TermClose <buffer> call tabbuffers#prop_tabbufs#unset()
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
