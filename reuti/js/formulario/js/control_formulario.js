/*****************************************************************************/
// comprobar_formulario:
/*****************************************************************************/


/*****************************************************************************/


var TIPO_NUMERO = 1;
var TIPO_FECHA = 2;
var TIPO_LISTA = 4;


var ERR_OK = 0;
var ERR_NO_NUMERO = 1;
var ERR_NO_VACIO = 2;
var ERR_NO_FECHA = 4;
var ERR_NO_EVENTO = 8;


var eventos_validos = new Array();
eventos_validos['onClick'] = 1;
eventos_validos['onBlur'] = 2;
eventos_validos['onFocus'] = 4;
eventos_validos['onKeyDown'] = 8;
eventos_validos['onKeyUp'] = 16;
eventos_validos['onKeyPress'] = 32;



/*****************************************************************************/
function _AddEvent (evento, accion, ejecuta) {
 if (!eventos_validos[evento]) return ERR_NO_EVENTO;

 evento = evento.toLowerCase();

 var str = 'this.'+evento+'='+accion+';';
 eval (str);
 
 return ERR_OK;
}//_AddEvent



/*****************************************************************************/
function _Error (errno) {
 var mensaje = '';
 switch (errno) {
  case ERR_NO_NUMERO:
   mensaje = 'Se esperaba un número.';
  break;

  case ERR_NO_VACIO:
   mensaje = 'El campo no puede estar vacío.';
  break;

  case ERR_NO_FECHA:
   mensaje = 'El formato de fecha es: dd/mm/aaaa';
  break;
 }//Selecciona el tipo de error

 if (mensaje) {
  alert (mensaje);
  if (this.getFocus()) this.focus();
 }//Hay un error

 return true;
}//_Error



/*****************************************************************************/
function _ComprobarNumero () {
// if (this.vacio && !this.value) return false;

 if (isNaN (this.value))
  return false;
 else
  return true;
}//_ComprobarNumero



/*****************************************************************************/
function _ComprobarFecha () {
// if (this.vacio && !this.value) return true;

 var fecha_es = this.value.split ('/');

 var fecha = new Date (fecha_es[2]+'/'+fecha_es[1]+'/'+fecha_es[0]);
 var dia = fecha.getDate();
 var mes = (fecha.getMonth()+1);
 var anyo = fecha.getFullYear().toString();

 if (dia <= 9) dia = '0'+dia;
 if (mes <= 9) mes = '0'+mes;

 var fecha = dia+'/'+mes+'/'+anyo;

 if (fecha != this.value)
  return false;
 else
  return true;
}//_ComprobarFecha


/*****************************************************************************/
function _MensajeError () {

 if (!this.comprobar()) {
  var error = 0;
  switch (this.tipo) {
   case TIPO_NUMERO: error = ERR_NO_NUMERO; break;
   case TIPO_FECHA: error = ERR_NO_FECHA; break;
  }//Selecciona el tipo de ERROR en función del tipo de objeto

  this.error (error);
  return false;
 }//El valor del campo no es el correcto
 else if (!this.valor() && this.getNull()) {
  this.error (ERR_NO_VACIO);
  return false;
 }//El campo no puede estar vacio

 return true;
}//_MensajeError


/*****************************************************************************/
function _getNull () {
 return this.vacio;
}//_getNull


/*****************************************************************************/
function _setNull () {
 this.vacio = 1;
}//_setNull


/*****************************************************************************/
function _setNoNull () {
 this.vacio = 0;
}//_setNoNull


/*****************************************************************************/
function _getFocus () {
 return this.coger_foco;
}//_getFocus

/*****************************************************************************/
function _setFocus () {
 this.coger_foco = 1;
}//_setNull


/*****************************************************************************/
function _setNoFocus () {
 this.coger_foco = 0;
}//_setNoNull


/*****************************************************************************/
function _ValorTexto () {
 return this.value;
}//_ValorNumero



/*****************************************************************************/
// BaseFormulario:
/*****************************************************************************/
function BaseFormulario (objeto, tipo) {
 objeto.evento = new Array();
 objeto.tipo = tipo;

 objeto.setNull = _setNull;
 objeto.setNoNull = _setNoNull;
 objeto.setFocus = _setFocus;
 objeto.setNoFocus = _setNoFocus;
 objeto.AddEvent = _AddEvent;
 objeto.getNull = _getNull;
 objeto.getFocus = _getFocus;

 return objeto;
}//BaseFormulario


/*****************************************************************************/
// ControlNumero:
/*****************************************************************************/
function ControlNumero (objeto) {
 objeto = BaseFormulario (objeto, TIPO_NUMERO);

 objeto.requerido = 1;
 objeto.vacio = 1;
 objeto.coger_foco = 1;

 objeto.valor = _ValorTexto;


 objeto.comprobar = _ComprobarNumero;
 objeto.onblur = _MensajeError;
 objeto.error = _Error;

 return objeto;
}//ControlNumero


/*****************************************************************************/
// ControlFecha:
/*****************************************************************************/
function ControlFecha (objeto) {
 objeto = BaseFormulario (objeto, TIPO_FECHA);

 objeto.requerido = 1;
 objeto.vacio = 1;
 objeto.coger_foco = 1;

 objeto.valor = _ValorTexto;

 objeto.comprobar = _ComprobarFecha;
 objeto.onblur = _MensajeError;
 objeto.error = _Error;

 return objeto;
}//ControlFecha


/*****************************************************************************/
function _IndiceLista () {
 return this.selectedIndex;
}//_IndiceLista


/*****************************************************************************/
function _ValorLista () {
 return this.value;
}//_ValorLista


/*****************************************************************************/
function _SeleccionarInicioOpcion (event) {
 if (!event) event = window.event;

 var code = event.keyCode;
 if (code == 27 ||
     code == 8 ||
     code == 46) {
  this.palabra = '';
  this.parser_anterior = 0;
  return true;
 }

 var tecla = String.fromCharCode (code).toUpperCase();

 if (!tecla.match (/^[A-Z0-9]/)) return true;


 var palabra_aux = this.palabra;
 this.palabra += tecla; 
 var lon = this.length;
 var reg = /ó/;

 var er = 'str.match(/^'+(this.palabra)+'/);';

 for (var i = 0; i < lon; i++) {
  var str = this.options[i].text;

  str = str.replace (reg, 'o');
  str = str.toUpperCase ();

  if (eval (er)) {
   this.options[i].selected = true;
   this.parser_anterior = 1;

   return false;
  }//Una opción coincide
 }//Se recorren todas las opciones

 if (this.parser_anterior) {
  this.palabra = tecla;
  return;
 }
 else
  this.palabra = '';

 this.parser_anterior = 0;

 return false;
}//_SeleccionarInicioOpcion


/*****************************************************************************/
// ControlLista:
/*****************************************************************************/
function ControlLista (objeto) {
 objeto = BaseFormulario (objeto, TIPO_LISTA);

 objeto.requerido = 1;
 objeto.vacio = 1;
 objeto.coger_foco = 0;

 objeto.valor = _ValorLista;
 objeto.AddEvent = _AddEvent;
 objeto.indice = _IndiceLista;

 objeto.comprobar = _ComprobarFecha;
 objeto.onblur = _MensajeError;
 objeto.error = _Error;

 return objeto;
}//ControlLista


/*****************************************************************************/
// ControlListaTeclado:
/*****************************************************************************/
function ControlListaTeclado (objeto) {
 objeto = ControlLista (objeto);

 objeto.palabra = '';
 objeto.parser_anterior = 0;
 objeto.onkeydown = _SeleccionarInicioOpcion;

 return objeto;
}//ControlListaTeclado




/*
//Ejemplo de la creación de una clase y como se hereda de ella

function ObjetoPadre () {
 this.nombre = 'Padre';

 this.getName = function () {return this.nombre;};
 this.setName = function (nombre) {this.nombre = nombre;};
}


function ObjetoHijo () {
 this.superclass = ObjetoPadre;
 this.superclass();

 this.nombre = 'Hijo';

 this.test = function () {alert ('test');};
}
*/
