
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

  autocmd TermOpen * 
        \ call tabbuffers#prop_tabbufs#add() |
        \ if (exists('w:has_tabbuffers')) | set ft=tabbuffers-terminal | endif

  autocmd FileType tabbuffers-terminal call s:setup_term()
augroup END

let g:loaded_tabbuffer = 1

"=============================
" tabbuffers#quit
"=============================
" handy quit and write
nnoremap Q ZQ
nnoremap <silent> q :call tabbuffers#quit()<CR>
vnoremap Q ZQ
vnoremap <silent> q :call tabbuffers#quit()<CR>

inoremap <C-w><C-e> <C-\><C-n>:w<CR>
inoremap <C-w>d <C-\><C-n>:w<bar>call tabbuffers#quit()<CR>
inoremap <C-w><C-d> <C-\><C-n>:w<bar>call tabbuffers#quit()<CR>

nnoremap <C-w><C-e> :w<CR>
nnoremap <C-w>d :w<bar>call tabbuffers#quit()<CR>
nnoremap <C-w><C-d> :w<bar>call tabbuffers#quit()<CR>

nnoremap <silent> W :w<bar>call tabbuffers#quit()<CR>

"=============================
" Buffer related mapping
"=============================
" enhance buffer navigation
" require 'Shougo/tabpagebuffer.vim'
noremap <silent> <C-l> :call tabbuffers#switch(1)<CR>
noremap <silent> <C-h> :call tabbuffers#switch(-1)<CR>
inoremap <silent> <C-l> <C-\><C-n>:call tabbuffers#switch(1)<CR>
inoremap <silent> <C-h> <C-\><C-n>:call tabbuffers#switch(-1)<CR>

noremap <silent> + :call tabbuffers#move(1)<CR>
noremap <silent> - :call tabbuffers#move(-1)<CR>
" unlist quickfix buffer so that we will not navigate to it
autocmd FileType qf setlocal nobuflisted

" enhance tabline to show tabpage buffers instead of all buffers
set showtabline=2
set tabline=%!tabbuffers#airline#tabline_filtered()
autocmd VimEnter * :call airline#extensions#tabline#load_theme(g:airline#themes#{g:airline_theme}#palette)

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
