/******************************************************************************/
// fechas.js: Tratamiento y manejo de fechas.
/******************************************************************************/
// FechaES2EN:
// EsFecha:
// EsHora:
/******************************************************************************/



/******************************************************************************/
function FechaES2EN (fecha_txt) {
 var fecha = fecha_txt.split ('/');

 return fecha[2]+"/"+fecha[1]+"/"+fecha[0];
}//FechaES2EN


/******************************************************************************/
function EsFecha (fecha_txt) {
 if (!fecha_txt) return true;

 var fecha = new Date (FechaES2EN(fecha_txt));

 var dia = fecha.getDate();
 if (dia < 10) dia = "0"+dia;
 var mes = fecha.getMonth()+1;
 if (mes < 10) mes = "0"+mes;

 var fecha_aux = dia+"/"+mes+"/"+fecha.getFullYear();

 return (fecha_aux == fecha_txt) ? true:false;
}//EsFecha


/******************************************************************************/
function EsHora (tiempo_aux) {
 if (!tiempo_aux) return true;

 var tiempo = tiempo_aux.split (':');
 if (tiempo.length != 2) return false;

 if (tiempo[0].length==1 || tiempo[1].length==1 || isNaN(tiempo[0]) || isNaN(tiempo[1])) return false;
 if (tiempo[0] <0 || tiempo[0]>23) return false;
 if (tiempo[1] <0 || tiempo[1]>59) return false;

 return true;
}//EsHora

