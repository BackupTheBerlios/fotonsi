
/*******************************************************************************/
function AbrirVentana (pagina, ancho, alto) {
 var x = Math.abs((screen.availWidth-ancho)/2);
 var y = Math.abs((screen.availHeight-alto)/2);

 var IdWin = window.open (pagina,'','left='+y+',top='+x+',width='+ancho+',height='+alto+',scrollbars=yes');

 return IdWin;
}//AbrirVentana