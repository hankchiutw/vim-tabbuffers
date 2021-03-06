
function! tabbuffers#airline#tabline_filtered() abort
  let b = airline#extensions#tabline#new_builder()

  if get(g:, 'airline#extensions#tabline#buf_label_first', 0)
    call airline#extensions#tabline#add_label(b, 'buffers', 0)
  endif

  let b.overflow_group = 'airline_tabhid'
  let b.buffers = tabbuffers#prop_tabbufs#get()

  function! b.get_group(i) dict
    let bufnum = get(self.buffers, a:i, -1)
    if bufnum == -1
      return ''
    endif
    let group = airline#extensions#tabline#group_of_bufnr(self.buffers, bufnum)
    return group
  endfunction

  function! b.get_title(i) dict
    let spc = g:airline_symbols.space
    let bufnum = get(self.buffers, a:i, -1)
    let group = self.get_group(a:i)
    let pgroup = self.get_group(a:i - 1)
    " always add a space when powerline_fonts are used
    " or for the very first item
    if get(g:, 'airline_powerline_fonts', 0) || a:i == 0
      let space = spc
    else
      let space= (pgroup == group ? spc : '')
    endif

    return space.'%(%{airline#extensions#tabline#get_buffer_name('.bufnum.')}%)'.spc
  endfunction

  let current_buffer = max([index(b.buffers, bufnr('%')), 0])
  let last_buffer = len(b.buffers) - 1
  call b.insert_titles(current_buffer, 0, last_buffer)

  call b.add_section('airline_tabfill', '')
  call b.split()
  call b.add_section('airline_tabfill', '')

  call s:add_tab_label(b)
  let tabline = b.build()

  return tabline
endfunction

function! s:add_tab_label(dict)
  if get(g:, 'airline#extensions#tabline#show_tab_count', 1)
    let current_fname = fnamemodify(getcwd(), ':~:.')
    call a:dict.add_section_spaced('airline_tabmod', printf('%s %d/%d', current_fname, tabpagenr(), tabpagenr('$')))
  endif
endfunction

nnoremap <C-g>n :call <SID>prompt_tabname_input()<CR>
autocmd TabEnter * :call <SID>set_tabname()

function! s:prompt_tabname_input() abort
  call inputsave()
  let t:tabname = input('Enter tab name: ')
  call inputrestore()
  echo ''
  call <SID>set_tabname()
endfunction

function! s:set_tabname() abort
  if !exists('t:tabname') 
    let t:tabname = 'T'.tabpagenr()
  endif
  let g:airline#extensions#tabline#buffers_label = t:tabname.' »'
  " redrawtabline may not work for vim
  call airline#extensions#tabline#redraw()
endfunction
