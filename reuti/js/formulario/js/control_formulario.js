/*****************************************************************************/
// comprobar_formulario:
/*****************************************************************************/


/*****************************************************************************/


var TIPO_NUMERO = 1;
var TIPO_FECHA = 2;
var TIPO_LISTA = 4;

var ERR_BASE_NUMERO = 0x8000;
var ERR_BASE_FECHA = 0x4000;
var ERR_COMUN = 0x1000;

var ERR_OK = 1;
var ERR_NO_NUMERO = 0x8001;
var ERR_NO_VACIO = 0x8002;
var ERR_NO_DECIMAL = 0x8004;
var ERR_NO_FECHA = 0x4001;
var ERR_NO_EVENTO = 0x1001;
var ERR_NO_RANGO = 0x1002;


var eventos_validos = new Array();
eventos_validos['onClick'] = 1;
eventos_validos['onBlur'] = 2;
eventos_validos['onFocus'] = 4;
eventos_validos['onKeyDown'] = 8;
eventos_validos['onKeyUp'] = 16;
eventos_validos['onKeyPress'] = 32;


var CHAR_F1 = 112;
var CHAR_F2 = 113;
var CHAR_F3 = 114;
var CHAR_F4 = 115;
var CHAR_F5 = 116;
var CHAR_F6 = 117;
var CHAR_F7 = 118;
var CHAR_F8 = 119;
var CHAR_F9 = 120;
var CHAR_F10 = 121;
var CHAR_F11 = 122;
var CHAR_F12 = 123;

var CHAR_SHIFT = 0x01;
var CHAR_ALT = 0x02;
var CHAR_CONTROL = 0x04;


var _documento = null;



/*****************************************************************************/
function _KeyEvent (event) {
 if (!event) event = window.event;
 
 var code = event.keyCode;
 var tecla = String.fromCharCode (code).toUpperCase();

 var mode = 0;
 if (event.shiftKey) mode = mode | CHAR_SHIFT;
 if (event.altKey) mode = mode | CHAR_ALT;
 if (event.ctrlKey) mode = mode | CHAR_CONTROL; 


 if (_documento.key_acelerator[code+mode])
   _documento.key_acelerator[code+mode]();

//   alert ('Entra...'+documento.key_acelerator);
//  alert (this.key_acelerator[tecla+mode]());
// alert (code+':'+tecla);

// alert (tecla); 

/* var mensaje = '';
 for (var info in event)
  mensaje += '<b>'+info+':</b> '+event[info]+'<br>\n';

 document.getElementById ('CAPA_TEST').innerHTML = mensaje;
*/

 return false;
}//_KeyEvent


/*****************************************************************************/
function _AddAcelerator (key, shift, alt, control, action) {
 var mode = 0;
 if (shift) mode = mode | CHAR_SHIFT;
 if (alt) mode = mode | CHAR_ALT;
 if (control) mode = mode | CHAR_CONTROL; 

// this.key_acelerator['CHAR_'+key+String(mode)] = action; 
 this.key_acelerator[key+mode] = action;
}//_AddAcelerator


/*****************************************************************************/
// ControlDocumento
/*****************************************************************************/
function TDocumento (event) {
 if (event) alert ('OK');

 this.key_acelerator = new Array();
 this.key_event = _KeyEvent;
 this.AddAcelerator = _AddAcelerator;
 this.setRoot = function () {_documento = this;};

 document.onkeydown = this.key_event;

 window.onhelp = function () {return false;}; //Desabilita F1 en el Explorer
}//TDocumento



/*****************************************************************************/
function _AddEvent (evento, accion, ejecuta) {
 if (!eventos_validos[evento]) return ERR_NO_EVENTO;

 evento = evento.toLowerCase();

 var str = 'this.'+evento+'='+accion+';';
 eval (str);
 
 return ERR_OK;
}//_AddEvent


/*****************************************************************************/
function _MensajeErrorNumero () {
 var mensaje = '';
 switch (this.error) {
  case ERR_NO_VACIO: mensaje = 'El campo no puede estar vacío.';break; 
  case ERR_NO_NUMERO: mensaje = 'Se esperaba un número.';break; 
  case ERR_NO_DECIMAL: mensaje = 'Se esperaba un número entero.';break; 
  case ERR_NO_RANGO: mensaje = 'El valor se pasa del límite establecido.';break; 
  default: mensaje = 'Error no reconocido.';
 }//Tipos de errores

 if (mensaje) alert (mensaje);
 if (this.getFocus()) this.focus();

 return this.error;
}//_MensajeErrorNumero


/*****************************************************************************/
function _MensajeErrorFecha () {
 var mensaje = '';
 switch (this.error) {
  case ERR_NO_VACIO: mensaje = 'El campo no puede estar vacío.';break; 
  case ERR_NO_FECHA: mensaje = 'El formato de fecha es dd/mm/aaaa.'; break;
  default: mensaje = 'Error no reconocido.';
 }//Tipos de errores

 if (mensaje) alert (mensaje);
 if (this.getFocus()) this.focus();

 return this.error;
}//_MensajeErrorFecha


/*****************************************************************************/
function _ComprobarNumero () {
 if (this.vacio && !this.value) {
  if (this.mostrar_error) {
   this.error = ERR_NO_VACIO;
   return this.Error ();
  }
  else
   return ERR_NO_VACIO;
 }//Está vacio y es requerido

 if (!this.vacio && !this.value) {
  return ERR_OK;
 }//No requerido y vacío

 if (isNaN (this.value)) {
  if (this.mostrar_error) {
   this.error = ERR_NO_NUMERO;
   return this.Error ();
  }
  else
   return ERR_NO_NUMERO;
 }//No es un número
 else {
  if (!this.getDecimal()) {
   if (this.value.indexOf ('.') != -1) {
    if (this.mostrar_error) {
     this.error = ERR_NO_DECIMAL;
     return this.Error();  
    }
    else
     return ERR_NO_DECIMAL;
   }//Se trata de un número decimal
  }//No puede ser un número negativo

  if (this.minimo != this.maximo) {
   var valor = parseFloat (this.value);

   if (this.minimo > valor || this.maximo < valor) {
    if (this.mostrar_error) {
     this.error = ERR_NO_RANGO;
     return this.Error ();
    }
    else
     return ERR_NO_RANGO;
   }//Se pasa del rango establecido
  }//Se comprueba el máximo y el mínimo

  return ERR_OK;
 }//Se trata de un número
}//_ComprobarNumero


/*****************************************************************************/
function _ComprobarFecha () {
 if (this.vacio && !this.value) {
  if (this.mostrar_error) {
   this.error = ERR_NO_VACIO;
   return this.Error ();
  }
  else
   return ERR_NO_VACIO;
 }//Está vacio y es requerido

 if (!this.vacio && !this.value) return ERR_OK;

 var fecha_es = this.value.split ('/');

 var fecha = new Date (fecha_es[2]+'/'+fecha_es[1]+'/'+fecha_es[0]);
 var dia = fecha.getDate();
 var mes = (fecha.getMonth()+1);
 var anyo = fecha.getFullYear().toString();

 if (dia <= 9) dia = '0'+dia;
 if (mes <= 9) mes = '0'+mes;

 var fecha = dia+'/'+mes+'/'+anyo;

 if (fecha != this.value) {
  if (this.mostrar_error) {
   this.error = ERR_NO_FECHA;
   return this.Error();
  }
  else
   return ERR_NO_FECHA;
 }
 else
  return ERR_OK;
}//_ComprobarFecha


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
 objeto.mostrar_error = 1;
 objeto.error = ERR_OK;

 objeto.setMessageError = function () {this.mostrar_error = 1;};
 objeto.setNoMessageError = function () {this.mostrar_error = 0;};
 objeto.getMessageError = function () {return this.mostrar_error;};
 objeto.setNull = function () {this.vacio = 1;};//_setNull;
 objeto.setNoNull = function() {this.vacio = 0;};//_setNoNull;
 objeto.setFocus = function () {this.coger_foco = 1;}//_setFocus;
 objeto.setNoFocus = function () {this.coger_foco = 0;}; //_setNoFocus;
 objeto.AddEvent = _AddEvent;
 objeto.getNull = function () {return this.vacio;};//_getNull;
 objeto.getFocus = function () {return this.coger_foco;};//_getFocus;
 objeto.Error = function () {return;};//_MensajeErrorNumero;

 return objeto;
}//BaseFormulario


/*****************************************************************************/
function _setMinimo (minimo) {
 if (!isNaN(minimo))
  this.minimo = minimo;
}//_setMinimo


/*****************************************************************************/
function _setMaximo (maximo) {
 if (!isNaN (maximo))
  this.maximo = maximo;
}//_setMaximo


/*****************************************************************************/
function _setRange (min, max) {
 if (isNaN(minimo) || isNaN(maximo)) return ERR_NO_NUMERO;
 if (parseFloat (min) > parseFloat (max)) return ERR_NO_RANGO;

 this.minimo = min;
 this.maximo = max;

 return ERR_OK;
}//_setRange


/*****************************************************************************/
// ControlNumero:
/*****************************************************************************/
function ControlNumero (objeto) {
 objeto = BaseFormulario (objeto, TIPO_NUMERO);

 objeto.requerido = 1;
 objeto.vacio = 0;
 objeto.coger_foco = 1;

 objeto.valor = _ValorTexto;
 objeto.minimo = objeto.maximo = 0;
 objeto.es_decimal = 0;

 objeto.Error = _MensajeErrorNumero;

 objeto.setMinimo = _setMinimo;
 objeto.setMaximo = _setMaximo;
 objeto.setNoRange = function () {this.minimo = this.maximo = 0;};
 objeto.setRange = _setRange;
 objeto.setDecimal = function () {this.es_decimal = 1;};
 objeto.setNoDecimal = function () {this.es_decimal = 0;};
 objeto.getDecimal = function () {return this.es_decimal;};

 objeto.comprobar = _ComprobarNumero;
 objeto.onblur = objeto.comprobar;

 return objeto;
}//ControlNumero


/*****************************************************************************/
// ControlFecha:
/*****************************************************************************/
function ControlFecha (objeto) {
 objeto = BaseFormulario (objeto, TIPO_FECHA);

 objeto.requerido = 1;
 objeto.vacio = 0;
 objeto.coger_foco = 1;

 objeto.valor = _ValorTexto;

 objeto.comprobar = _ComprobarFecha;
 objeto.onblur = objeto.comprobar;
// objeto.onblur = _MensajeError;
 objeto.Error = _MensajeErrorFecha;

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
 objeto.vacio = 0;
 objeto.coger_foco = 0;

 objeto.valor = _ValorLista;
 objeto.AddEvent = _AddEvent;
 objeto.indice = _IndiceLista;

 objeto.comprobar = _ComprobarFecha;
// objeto.onblur = _MensajeError;
 //objeto.error = _Error;

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
