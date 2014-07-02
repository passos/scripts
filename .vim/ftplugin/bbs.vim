" Vim filetype plugin file
" Language:	BBS
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2007 Apr 30

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let b:undo_ftplugin = "setl modeline< tw< fo< comments<"

" Don't use modelines in e-mail messages, avoid trojan horses and nasty
" "jokes" (e.g., setting 'textwidth' to 5).
setlocal nomodeline

" many people recommend keeping e-mail messages 72 chars wide
if &tw == 0
  setlocal tw=72
endif

" Set 'formatoptions' to break text lines and keep the comment leader ">" or ":".
setlocal fo+=tcql
set comments+=::

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_bbs_maps")
  " Quote text by inserting ": "
  if !hasmapto('<Plug>BBSQuote')
    vmap <buffer> <LocalLeader>q <Plug>BBSQuote
    nmap <buffer> <LocalLeader>q <Plug>BBSQuote
  endif
  vnoremap <buffer> <Plug>BBSQuote :s/^/: /<CR>:noh<CR>``
  nnoremap <buffer> <Plug>BBSQuote :.,$s/^/: /<CR>:noh<CR>``
endif

setlocal foldmethod=expr foldlevel=1 foldminlines=2
setlocal foldexpr=strlen(substitute(substitute(getline(v:lnum),'\\s','','g'),'[^>:].*','',''))
