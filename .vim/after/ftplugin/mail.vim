setlocal foldmethod=expr foldlevel=1 foldminlines=2
setlocal foldexpr=strlen(substitute(substitute(getline(v:lnum),'\\s','','g'),'[^>].*','',''))
