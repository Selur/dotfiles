" ============================================================================
" File:        utils.vim
" Description: Utility Functions
" Author:      Near Huscarl <near.huscarl@gmail.com>
" Last Change: Wed Oct 04 10:35:17 +07 2017
" Licence:     BSD 3-Clause license
" Note:        Miscellaneous functions in autoload/ is put here
" ============================================================================

function! near#utils#UltiSnips_Complete() " {{{
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-n>\<C-x>"
        else
            call UltiSnips#JumpForwards()
            if g:ulti_jump_forwards_res == 0
               return "\<Tab>"
            endif
        endif
    endif
    return ""
endfunction " }}}
function! near#utils#UltiSnips_JumpForward() " {{{
   if pumvisible()
      return "\<Down>"
   endif
   return "\<C-z>"
endfunction " }}}
function! near#utils#UltiSnips_JumpBackward() " {{{
   if pumvisible()
      return "\<Up>"
   endif
   return "\<C-x>"
endfunction " }}}
" function! near#utils#UltiSnipsLazyLoad() " {{{

"   " Fix cursor move to random position (:(
"   execute "normal! ma"
"   call plug#load('ultisnips')
"   execute "normal! g`a"
"   call feedkeys("\<Right>", 'i')

"   inoremap <silent><Tab> <C-R>=near#utils#UltiSnips_Complete()<CR>
"   return "\<Tab>"
" endfunction " }}}
function! near#utils#ToggleHeader() " {{{
   let fileName = expand('%')
   let name = split(fileName, '\.')[0]
   let extension = split(fileName, '\.')[1]

   if extension == 'cpp'
      let fileNext = join([name, 'h'], ".")

      if filereadable(fileNext)
         execute "e %<.h"
      else
         echom join([fileNext, 'doenst exist :('])
      endif

   elseif extension == 'h'
      let fileNext = join([name, 'cpp'], ".")

      if filereadable(fileNext)
         execute "e %<.cpp"
      else
         echom join([fileNext, 'doenst exist :('])
      endif
   endif

   if line("'\"") > 1 && line("'\"") <= line("$")
      execute "normal! g`\""
   endif
endfunction " }}}
function! near#utils#ToggleWrap() " {{{
   if &wrap
      set nowrap
      nnoremap 0 0
      nnoremap $ $
      echo "wrap off"
   else
      set wrap
      nnoremap 0 g0|    "0 version that treat wrapped line as another line
      nnoremap $ g$|    "$ version that treat wrapped line as another line
      echo "wrap on"
   endif
endfunction " }}}
function! near#utils#NmapJ() " {{{
   if &diff
      return "]czz"
   endif
   return "J"
endfunction " }}}
function! near#utils#NmapK() " {{{
   if &diff
      set timeout
      set timeoutlen=0
      return "[czz"
   endif
   set timeout&
   set timeoutlen&
   return "K"
endfunction " }}}
function! near#utils#Nmap_du() " {{{
   if &diff
      return ":diffupdate\<CR>"
   endif
   return ""
endfunction " }}}
function! near#utils#Nmap_q() " {{{
   if &diff
      return ":q\<CR>"
   endif
   return "q"
endfunction " }}}
function! near#utils#ToggleMenuBar() " {{{
   if(&guioptions =~# 'm')
      set guioptions-=m
   else
      set guioptions+=m
   endif
endfunction " }}}
function! near#utils#OpenHelpInTab(word) " {{{
   " silent to disable error tag not found
   " execute "silent! tab h <C-r><C-w>"
   if mode() == 'n'
      execute "silent! tab h " . expand("<cword>")
      if (&filetype == 'nerdtree')
         execute "wincmd p"
      endif
   elseif mode() == 'v'
      execute "silent! tab h " . a:aword
      if (&filetype == 'nerdtree')
         execute "wincmd p"
      endif
   endif
endfunction " }}}
function! near#utils#RedirInTab(command) " {{{
   " Display output log in another tab eg. :RedirInTab mes
   redir => s:output
   silent! execute a:command
   redir END
   if empty(s:output)
      echoerr "No output"
   else
      tabnew
      setlocal ft=help buftype=nofile noswapfile nobuflisted bufhidden=wipe nomodified
      silent! put=s:output
   endif
endfunction " }}}
function! near#utils#ExistsInTab(...) " {{{
   let a:NumOfWin = winnr('$')
   let a:flag = 0
   while (a:NumOfWin > 0)
      execute "wincmd p"
      for fileType in a:000
         if (string(&filetype) == fileType)
            let a:flag = 1
         endif
      endfor
      let a:NumOfWin-=1
   endwhile
   if (a:flag)
      return 1
   endif
   return 0
endfunction " }}}
function! near#utils#OpenTagInVSplit() " {{{
   if (winnr('$') > 1 && !ExistsInTab('nerdtree', 'tagbar'))
      let g:tagKey = expand('<cword>')
      execute "wincmd p"
      execute "e#"
      execute "tjump " g:tagKey
   else
      execute "vertical split | wincmd p | tjump " . expand('<cword>')
   endif
endfunction " }}}
function! near#utils#TrimWhitespace() " {{{
   let save = winsaveview()
   %s/\s\+$//e
   call winrestview(save)
endfunction " }}}
function! near#utils#MakeSymlink() " {{{
   if has('win64')
      if !empty(glob('$HOME\vimfiles\autoload\NearFunc.vim'))
         silent !del -F \%UserProfile\%\vimfiles\autoload\NearFunc.vim
      endif
      silent !mklink /H \%UserProfile\%\vimfiles\autoload\NearFunc.vim C:\Users\Near\Desktop\.vimrc\autoload\NearFunc.vim

      if !empty(glob('$HOME\_vimrc'))
         silent !del -F \%UserProfile\%\_vimrc
      endif
      silent !mklink /H \%UserProfile\%\_vimrc \%UserProfile\%\Desktop\.vimrc\_vimrc

      if !empty(glob('$HOME\_vsvimrc'))
         silent !del -F \%UserProfile\%\_vsvimrc
      endif
      silent !mklink /H \%UserProfile\%\_vsvimrc \%UserProfile\%\Desktop\.vimrc\_vsvimrc
   endif
endfunction " }}}
function! near#utils#GundoAutoPreviewToggle() " {{{
   if g:gundo_auto_preview == 1
      let g:gundo_auto_preview = 0
      echo "Gundo auto preview off"
   else
      let g:gundo_auto_preview = 1
      echo "Gundo auto preview on"
   endif
endfunction " }}}
function! near#utils#CscopeLoad() " {{{
   if has('cscope')
      if filereadable("cscope.out")
         cscope add cscope.out
      else
         if filereadable("cscope.files")
            silent execute "!cscope -b -i cscope.files -f cscope.out"
            cscope add cscope.out
         else
            silent execute "!dir /b /s *.cpp *.h > cscope.files"
            silent execute "!cscope -b -i cscope.files -f cscope.out"
            cscope add cscope.out
         endif
      endif
   endif
endfunction " }}}
function! near#utils#ToggleGoyo(on) " {{{
   let ftList = ['cpp', 'py', 'vim']
   if index(ftList, &filetype) != -1
      let g:goyo_linenr=1
   else
      let g:goyo_linenr=0
   endif
   noautocmd Goyo

   if a:on
      Limelight!
      set showcmd
      let g:goyo_enable = 0
   else
      Limelight
      set noshowcmd
      let g:goyo_enable = 1
   endif
endfunction " }}}
function! near#utils#ToggleVerbose() " {{{
    if !&verbose
        set verbosefile=~/Desktop/verbose.log
        set verbose=15
        echom "Set verbose=15"
    else
        set verbose=0
        set verbosefile=
        echom "Set verbose=0"
    endif
endfunction " }}}
