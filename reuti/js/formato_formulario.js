/*****************************************************************************/
// formato_formulario.js: 
/*****************************************************************************/
// Redondea:
// FormateaNumero:
// FormateaEntrada:
// QuitarCaracteres:
/*****************************************************************************/

function TRegistro() {
}//TRegistro

var configuracion_formulario = new TRegistro();
configuracion_formulario.redondeo = 2;



/*****************************************************************************/
function Redondea (num, decimales) {
 if (!decimales)
  decimales = configuracion_formulario.redondeo;

 return (Math.round(num*Math.pow(10,decimales)))/Math.pow(10,decimales);
}//Redondea


/*****************************************************************************/
function FormateaNumero (valor, separador, coma) {
 var tmp = new String (Redondea(valor));
 
 if (separador)
  numero = tmp.split (separador);
 else
  numero = tmp.split ('.');

 if (!numero[0]) return 0;
 if (!numero[1]) numero[1]=0;
 numero[1] = QuitarCaracteres (numero[1], ',');

 if (isNaN(numero[0]) || isNaN(numero[1])) {
  alert ('Debe especificar un número válido.');
  return 0;
 }

 if (!coma) coma = ',';

 var numero_final = '';
 while (numero[0].length > 3) {
  numero_final = '.'+numero[0].substring(numero[0].length-3, numero[0].length) + numero_final;
  numero[0] = numero[0].substring (0,numero[0].length-3);
 }
 
 
 return numero[0]+numero_final+((numero[1]) ? coma+numero[1]:'');
}//FormateaNumero


/*****************************************************************************/
function FormateaEntrada (valor) {
 var aux = valor.replace (/\./gi, '');
 aux = aux.replace (/,/,'.');

 return aux;
}//FormateaEntrada


/*****************************************************************************/
function QuitarCaracteres (valor, caracter) {
 var posi;
 valor = String(valor);
 while ((posi = valor.indexOf (caracter)) != -1) {
  valor = valor.substring (0,posi) + valor.substring(posi+1,valor.length);
 }//Se quitan los '.'

 return valor;
}//QuitarCaracteres


