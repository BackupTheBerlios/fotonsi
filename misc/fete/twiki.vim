" Sintaxis (más o menos) para el TWiki
" Language: 	Twiki
" Maintainer:	Ayose Cazorla <ayose.cazorla@hispalinux.es>
" Last Change:	2004 nov 20

syn region notify start='##' end='##([^)]*)'

syn region comentario  start=/\[\w:/ end=+\]+ contains=inicio_cmt
syn match inicio_cmt '\[\w:' contained

syn region verbatim  start=/<verbatim>/ end=+</verbatim>+
syn region verbatim  start=/<pre>/ end=+</pre>+
syn match verbatim '=[^ ]*='

syn region list  start='^\s*\*' end='$' contains=ALLBUT,inicio_cmt

syn match cmt '^####.*$'
syn match bold '\*[^* ]*\*' display
syn match macro '%[^%]*%' display 

syn region urls start='\[\[http'hs=s+2 end='\]\]' display contains=url1
syn match url1 'htt.*\]\['he=e-2

syn region notwikilink start='<nop>' end='\s'
syn match url '[A-Z]\w*[a-z]\w*[A-Z]\w*'
syn match url 'http://\S*'
syn match url 'https://\S*'

hi def comentario ctermbg=green
hi def inicio_cmt ctermbg=cyan 
hi def bold cterm=bold
hi def macro Macro
hi def link verbatim Identifier
hi def link cmt Comment
hi def urls cterm=underline ctermbg=yellow
hi def url ctermfg=blue cterm=underline
hi def url1 ctermfg=blue
hi def notify ctermbg=blue ctermfg=white

