" Sintaxis (más o menos) para el TWiki
" Language: 	Twiki
" Maintainer:	Ayose Cazorla <ayose.cazorla@hispalinux.es>
"               Ignacio Aliende <ialiende@foton.es>
" Last Change:	2005 jun 3

syn region notify start='##' end='##'

hi def url ctermfg=blue cterm=underline

" Poner las notas con el color (aproximado en el caso de una terminal) de cada
" uno
syn region nota_k start="\[k:" end="\]"
    hi def nota_k guibg=#000 guifg=#fff ctermfg=white ctermbg=black
syn region nota_o start="\[o:" end="\]"
    hi def nota_o guibg=#ecdefc  ctermbg=cyan
syn region nota_e start="\[e:" end="\]"
    hi def nota_e guibg=#eeffe0  ctermbg=green
syn region nota_i start="\[i:" end="\]"
    hi def nota_i guibg=#bfd8f2  ctermbg=cyan ctermfg=white
syn region nota_z start="\[z:" end="\]"
    hi def nota_z guibg=#eae1bb  ctermbg=brown
syn region nota_n start="\[n:" end="\]"
    hi def nota_n guibg=#ffecc9  ctermbg=brown
syn region nota_c start="\[c:" end="\]"
    hi def nota_c guibg=#000 guifg=#f00  ctermbg=black ctermfg=red
syn region nota_a start="\[a:" end="\]"
    hi def nota_a guibg=#ffdde1  ctermbg=cyan ctermfg=yellow
syn region nota_h start="\[h:" end="\]"
    hi def nota_h guibg=#1e720d guifg=#fff  ctermbg=green ctermfg=white
syn region nota_g start="\[g:" end="\]"
    hi def nota_g guibg=#ff2aff  ctermbg=magenta
syn region nota_s start="\[s:" end="\]"
    hi def nota_s guibg=#beffbe  ctermfg=darkgreen
syn region nota_mj start="\[mj:" end="\]"
    hi def nota_mj guibg=#000 guifg=#f00  ctermbg=black ctermfg=red
syn region nota_rf start="\[rf:" end="\]"
    hi def nota_rf guibg=#eee guifg=#000  ctermbg=white
syn region nota_ab start="\[ab:" end="\]"
    hi def nota_ab guibg=#eee guifg=#00c  ctermfg=blue
syn region nota__ start="\[_:" end="\]"
    hi def nota__ guibg=#ffc  ctermbg=brown



syn region verbatim  start=/<verbatim>/ end=+</verbatim>+
syn region verbatim  start=/<pre>/ end=+</pre>+
syn match verbatim '=[^ ]*='

syn region list  start='^\s*\*' end='$' contains=ALLBUT,inicio_cmt
syn region head start='^---\++' end='$'

syn match cmt '^####.*$'
syn match bold '\*[^* ]*\*' display
syn match macro '%[^%]*%' display 

syn region urls start='\[\[http'hs=s+2 end='\]\]' display contains=url1
syn match url1 'htt.*\]\['he=e-2

syn region notwikilink start='<nop>' end='\s'
syn match url2 '[A-Z]\w*[a-z]\w*[A-Z]\w*'
syn match url2 'http://\S*'
syn match url2 'https://\S*'

hi def bold cterm=bold gui=bold
hi def macro Macro
hi def link verbatim Identifier
hi def link cmt Comment
hi def urls cterm=underline guifg=blue gui=underline
hi def url1 ctermfg=blue guifg=blue 
hi def url2 ctermfg=blue cterm=underline guifg=blue gui=underline
hi def notify ctermbg=blue ctermfg=white gui=italic guibg=#aff
hi def link head Identifier

"Ayuda para generación de tareas:
"- Se pueden poner los valores en el .vimrc de cada uno como 'let b:proj =
"  "valor"'. Si no los encuentra pone los por defecto.
"- Una vez dentro se pueden cargar ejecutando 'call TaskDefaults()'
"- Para usarlo se puede seleccionar el texto con visual y pulsar ';k'
"  o empezar el texto con '##' y al acabar pulsar '<esc>;k' con lo que añadirá
"  los '##' que faltan y el resto.
"  (si se quiere cambiar la tecla se puede sustituir lo que pone abajo en los
"  *map ;k)
if !exists("b:proj")
    let b:proj = "PROJ"
endif
if !exists("b:prio")
    let b:prio = "PRIO"
endif
if !exists("b:login")
    let b:login = "LOGIN"
endif

function! TaskDefaults()
    let b:proj = input("Project: ", b:proj)
    let b:prio = input("Priority: ", b:prio)
    let b:login = input("Login: ", b:login)
endfunction


syn sync minlines=50

vnoremap ;k "tda##<c-r>t##(task: <c-r>=b:proj <c-r>=b:prio <c-r>=b:login)<esc>15<left>
nnoremap ;k a##(task: <c-r>=b:proj <c-r>=b:prio <c-r>=b:login)<esc>15<left>

set sts=3 sw=3 expandtab
