if exists('g:loaded_sniper') || &cp
  finish
endif

let g:loaded_sniper = 1

let s:focus = {}

function Snipe(buffer_function)
  call Setup()
  call OpenSniperBuffer(a:buffer_function)
endfunction

function Setup()
  let s:focus['originBuffer'] = bufnr('%')
  let s:focus['tempFilename'] = tempname() . '.sniper'
  let s:focus['regionStartLine'] = line("'<")
  let s:focus['regionEndLine'] = line("'>")
endfunction

function OpenSniperBuffer(buffer_function)
  let origin_filetype = &filetype
  execute "'<,'> write " . s:focus['tempFilename']
  execute a:buffer_function . ' ' . s:focus['tempFilename']
  execute 'set filetype=' . origin_filetype
  set bufhidden=wipe
  autocmd BufWritePost <buffer> silent call UpdateOriginBuffer()
  setlocal noswapfile
endfunction

function UpdateOriginBuffer()
  let new_lines = getbufline('%', 0, '$')
  let sniper_buffer = bufnr('%')

  let from = s:focus['regionStartLine']
  let to = s:focus['regionEndLine']

  " Switch to the original buffer, delete the relevant lines, add the new
  " ones, switch back to the sniper buffer.
  set bufhidden=hide
  call FocusBuffer(s:focus['originBuffer'])
  call cursor(from, 1)
  execute 'silent! ' . (to - from + 1) .'foldopen!'
  execute 'normal! ' . (to - from + 1) .'dd'
  call append(from - 1, new_lines)
  execute 'update'
  call FocusBuffer(sniper_buffer)
  set bufhidden=wipe

  let s:focus['regionEndLine'] = from + len(new_lines) - 1
endfunction

function FocusBuffer(bufno)
  exe "buffer " . a:bufno
endfunction
