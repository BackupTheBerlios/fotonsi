function valida_ccc(obj_entidad, obj_oficina, obj_dc, obj_ncuenta) {

  var D_C_1 = 0;
  var D_C_2 = 0;
  var tmp;
  var entidad, oficina, dc, ncuenta, enofi;
  var control;
  peso= new Array(6,3,7,9,10,5,8,4,2,1)
  
  //    peso(1) = 6      'Unidad
  //    peso(2) = 3      'Decena
  //    peso(3) = 7      'Centena
  //    peso(4) = 9      'Unidad de Millar
  //    peso(5) = 10     'Decena de Millar
  //    peso(6) = 5      'Centana de Millar
  //    peso(7) = 8      'Unidad de Millon
  //    peso(8) = 4      'Decena de Millon
  //    peso(9) = 2      'Centan de Millon
  //    peso(10) = 1     'Unidad de Millar de millón

  entidad=obj_entidad.value;
  oficina=obj_oficina.value;
  dc=obj_dc.value;
  ncuenta=obj_ncuenta.value;
   
  if (obj_entidad.value.length<4) {
//    alert("El campo entidad no es valido");
    return false;
  }
  if (obj_oficina.value.length<4) {
//    alert("El campo oficina no es valido");
    return false;
  }
  if (obj_dc.value.length<2) {
//    alert("El campo dc no es valido");
    return false;
  }
  if (obj_ncuenta.value.length<10) {
//    alert("El campo numero de cuenta no es valido");
    return false;
  } 
  
  enofi = entidad + oficina
   
   //    For x = 1 To 8 '8 por que son 8 la Oficina + Entidada
   //       D_C_1 = D_C_1 + Val(Mid$(tmp, 9 - x, 1)) * peso(x)
   //   Next x
   
  for (var i=7; i >= 0; i--) {
    tmp = enofi.charAt(i);		
    D_C_1 = D_C_1 + parseInt(tmp) * peso[7-i];
  }
  
  D_C_1 = 11 - (D_C_1 - (11 * parseInt(D_C_1 / 11)));
  
  if (D_C_1 == 10) {
    D_C_1 = 1
  }
  
  if (D_C_1 == 11) {
    D_C_1 = 0
  }
  
  tmp = dc.charAt(0);
   
  if (D_C_1 != parseInt(tmp)) {
//    alert("Atención: El Código de Oficina no es correcto o no has seleccionado correctamente el campo de Bancos, o bien los digitos de control son erroneos. Sirvase de Corregirlo");
    return false;
  }
  
  for (var i=9; i >= 0; i--) {
    tmp = ncuenta.charAt(i);		
    D_C_2 = D_C_2 + parseInt(tmp) * peso[9-i];
  }
  
  D_C_2 = 11 - (D_C_2 - (11 * parseInt(D_C_2 / 11)));
  
  if (D_C_2 == 10) {
    D_C_2 = 1
  }
  
  if (D_C_2 == 11) {
    D_C_2 = 0
  }
  
  tmp = dc.charAt(1);
   
  if (D_C_2 != parseInt(tmp)) {
//    alert("Atención: El Código de Oficina no es correcto o no has seleccionado correctamente el campo de Bancos, o bien los digitos de control son erroneos. Sirvase de Corregirlo");
    return false;
  }
    
  return true;
}

function Validar(valor,opcion)
{
  switch (opcion)
  {
    case '1': //nombre: obligatorio, alfabético
    case '2': //apellido1: obligatorio, alfabético
    case '4': //nacionalidad: obligatorio, alfabético
//      var re = /^[A-Z][a-z]+$/;
      var re = /^[A-Za-zÑñÁÉÍÓÚáéíóú ]+$/;
      if (re.exec(valor))
        return true;
      break;
    case '3': //apellido2: opcional, alfabético
//      var re = /^[A-Z][a-z]+$/;
      var re = /^[A-Za-zÑñÁÉÍÓÚáéíóú ]+$/;
      if ((valor=="") || re.exec(valor))
        return true;    
      break;
    case '6': //documento_numero
      var re = /^[\d]{6,8}[A-Za-zÑñ]$/
      if (re.exec(valor))
        if (ValidarLetra(valor))
          return true;    
      break;      
    case '8': //nombre_via: obligatorio, alfanumérico
    case '14': //localidad: obligatorio, alfanumérico
//      var re = /^[A-Za-z0-9ÑñÁÉÍÓÚáéíóú \.,;:-ºª]+$/;
      var re = /^[A-Za-z0-9ÑñÁÉÍÓÚáéíóú .,;:-]+$/;
      if (re.exec(valor))
        return true;    
      break;    
    case '9': //numero: obligatorio, alfanumérico 
    case '0': //documento_numero: obligatorio, alfanumérico
//      var re = /^[A-Za-z0-9]+$/;
      var re = /^[A-Za-z0-9ÑñÁÉÍÓÚáéíóú ]+$/;
      if (re.exec(valor))
        return true;    
      break;
    case '10': //piso: opcional, alfanumérico
    case '11': //puerta: opcional, alfanumérico
    case '12': //escalera: opcional, alfanumérico
//      var re = /^[A-Za-z0-9]+$/;
      var re = /^[A-Za-z0-9ÑñÁÉÍÓÚáéíóú ]+$/;
      if ((valor=="") || re.exec(valor))
        return true;        
      break;
    case '13': //cpostal: obligatorio, numérico, máx_car=5, mín_car=4
      var re = /^[\d]{4,5}$/;
      if (re.exec(valor))
        return true;
      break;
    case '15': //email: opcional, @ 1 vez ni al principio ni al final
//      var re = /^[\w\W^@]+@[\w\W^@]+$/
      var re = /^[^@]+@[^@]+$/;
      if ((valor=="") || re.exec(valor))
        return true;
      break;
    case '16': //teléfono1
      var re = /^[\d]{8,9}$/
      if (re.exec(valor))
        return true;
      break;
    case '19': //teléfono2
      var re = /^[\d]{8,9}$/
      if ((valor=="") || re.exec(valor))
        return true;
      break;
    case '23': //oficina
      var re = /^8[\d]{3}$/
      if (re.exec(valor))
        return true;
      break;
    case '5': //D.C.
      var re = /^[\d]{2}$/
      if (re.exec(valor))
        return true;
      break;      
    case '25': //número de cuenta
//      var re = /^[23|30|33|35|38|39|43|44|45|47|48|49|50][\d]{8}$/
      var re = /^00|23|30|33|35|38|39|43|44|45|47|48|49|50[\d]{8}$/
      if (re.exec(valor))
        return true;
      break;
/*      
    case '22': //entidad
      var re = /^[\d]{4}$/;
      if (re.exec(valor))
        return true;
      break;
*/      
  }
  return false;
}

function ValidarLetra(valor)
{
  var Letra = new Array();

  Letra[0] = "T";
  Letra[1] = "R";
  Letra[2] = "W";
  Letra[3] = "A";
  Letra[4] = "G";
  Letra[5] = "M";
  Letra[6] = "Y";
  Letra[7] = "F";
  Letra[8] = "P";
  Letra[9] = "D";
  Letra[10] = "X";
  Letra[11] = "B";
  Letra[12] = "N";
  Letra[13] = "J";
  Letra[14] = "Z";
  Letra[15] = "S";
  Letra[16] = "Q";
  Letra[17] = "V";
  Letra[18] = "H";
  Letra[19] = "L";
  Letra[20] = "C";
  Letra[21] = "K";
  Letra[22] = "E";
  Letra[23] = "O";

  return valor.substr(valor.length-1, 1).toUpperCase() == Letra[parseFloat(valor) % 23];
}

function ObtenerLetra(valor)
{
  var Letra = new Array();

  Letra[0] = "T";
  Letra[1] = "R";
  Letra[2] = "W";
  Letra[3] = "A";
  Letra[4] = "G";
  Letra[5] = "M";
  Letra[6] = "Y";
  Letra[7] = "F";
  Letra[8] = "P";
  Letra[9] = "D";
  Letra[10] = "X";
  Letra[11] = "B";
  Letra[12] = "N";
  Letra[13] = "J";
  Letra[14] = "Z";
  Letra[15] = "S";
  Letra[16] = "Q";
  Letra[17] = "V";
  Letra[18] = "H";
  Letra[19] = "L";
  Letra[20] = "C";
  Letra[21] = "K";
  Letra[22] = "E";
  Letra[23] = "O";

  return Letra[parseFloat(valor) % 23];
}
