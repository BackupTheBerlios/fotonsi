package Cb34;

use strict;

# $Id: Cb34.pm,v 1.7 2003/11/06 04:16:19 eduardo Exp $

use vars qw(@EXPORT_OK);
require Exporter;
*import = \&Exporter::import;
@EXPORT_OK = qw(cb34 importe_cb34 fecha_cb34);

=head1 NOMBRE

Cb34 - Impresión de ficheros CB34

=head1 SINOPSIS

 use Cb34;

 cb34(\*STDOUT, {ordenante => '12345678X', ...});

=head1 DESCRIPCIÓN

El módulo C<Cb34> contiene funciones para imprimir ficheros que cumplan la
norma CB34.

=head1 FUNCIONES

=over 4

=item cb34(FH, $datos)

Imprime un fichero de la norma CB34 con los datos dados en el manejador de
fichero C<FH>.

=item importe_cb34($importe)

Formatea una cantidad entera para incluirla en un fichero CB34.

=item fecha_cb34($fecha)

Formatea una fecha en formato C<aaaa-mm-dd> en el formato esperado de CB34.

=back

=head1 FALLOS Y LIMITACIONES

Por ahora, la función C<cb34> sólo imprime registro de transferencias, no de
cheques. En principio, debería ser bastante fácil modificarlo para imprimir
también cheques.

Los importes se redondean con la función C<sprintf> de Perl. En los casos en
los que las milésimas valen C<5>, se redondea por I<debajo>.

=head1 DERECHOS

Este módulo es libre. Puedes redistribuirlo o modificarlo bajo los mismos
términos que Perl.

 Derechos de autor 2002 Fotón Sistemas Inteligentes

=head1 AUTORES

Este módulo lo escribió Esteban Manchado Velázquez <zoso@foton.es>.

=cut

use FileHandle;
use POSIX qw(strftime);

sub cb34 {
   my ($fh, $datos) = @_;

   if ((scalar @{$datos->{registros}}) == 0) {
     return;
   }

   my $o = 56;    # Sólo entendemos transferencias

   my ($n, $informacion, $importe, $ref_bene);

   my ($g, $c, $dni, $nib);
   my ($suma, $n010, $ntotal) = (0, 0, 0);      # Para los totales

   # Datos generales
   my $ordenante = uc($datos->{ordenante});
   my $libre = ".";         # Siete caracteres libres al final de cada línea

   # Cabecera 1 --------------------------------------------------------------
   my ($envio, $emis,
       $ent, $ofi, $cuenta, $dc, $det)  = ($datos->{fecha_envio},
                                           $datos->{fecha_emision},
                                           $datos->{entidad},
                                           $datos->{oficina},
                                           $datos->{cuenta},
                                           $datos->{dcontrol},
                                           $datos->{detalle}
                                          );
   $ent    = sprintf("%04s",  $ent   );
   $ofi    = sprintf("%04s",  $ofi   );
   $cuenta = sprintf("%010s", $cuenta);
   $dc     = sprintf("%02s",  $dc    );
   # Campos no obligatorios
   $envio ||= strftime("%d%m%y", localtime);
   $emis  ||= strftime("%d%m%y", localtime);
   $fh->format_name("CABECERA1");
   write $fh;
   $ntotal++;

   # Cabecera 2 --------------------------------------------------------------
   ($n, $informacion) = ('002', uc($datos->{nombre_ordenante}));
   $fh->format_name("CABECERA234");
   write $fh;
   $ntotal++;

   # Cabecera 3 --------------------------------------------------------------
   ($n, $informacion) = ('003', uc($datos->{domicilio_ordenante}));
   $fh->format_name("CABECERA234");
   write $fh;
   $ntotal++;

   # Cabecera 4 --------------------------------------------------------------
   ($n, $informacion) = ('004', uc($datos->{plaza_ordenante}));
   $fh->format_name("CABECERA234");
   write $fh;
   $ntotal++;

   # Cabeceras 5 y 6 (optativas) ---------------------------------------------
   if (defined $datos->{nombre_por_cuenta}) {
      ($n, $informacion) = ('007', uc($datos->{nombre_por_cuenta}));
      $fh->format_name("CABECERA56");
      write $fh;
      $ntotal++;

      ($n, $informacion) = ('008', uc($datos->{domicilio_por_cuenta}));
      $fh->format_name("CABECERA56");
      write $fh;
      $ntotal++;
   }

   # Registros ---------------------------------------------------------------
   foreach my $reg (@{$datos->{registros}}) {
      ($ref_bene, $importe, $ent, $ofi, $cuenta, $g, $c, $dc) =
            (uc($reg->{beneficiario}), $reg->{importe}, $reg->{entidad},
             $reg->{oficina}, $reg->{cuenta}, $reg->{gastos}, $reg->{concepto}, $reg->{dcontrol});
      $n010++;
      $suma += $importe;
      $importe = importe_cb34($importe);
      $ent    = sprintf("%04s",  $ent   );
      $ofi    = sprintf("%04s",  $ofi   );
      $cuenta = sprintf("%010s", $cuenta);
      $dc     = sprintf("%02s",  $dc    );
      $importe= sprintf("%012s",  $importe);
      # Comprobaciones
      grep { $_ eq $g } (1, 2) or die "El tipo de gasto es inválido: $g";
      grep { $_ eq $c } (1, 8, 9) or die "El concepto es inválido: $c";

      $fh->format_name("REGISTRO1");
      write $fh;
      $ntotal++;
      # Registro 2 -----------------------------------------------------------
      ($n, $informacion) = ('011', $reg->{nombre_beneficiario});
      $fh->format_name("REGISTRO28");
      write $fh;
      $ntotal++;
      # Registro 3------------------------------------------------------------
      if (defined $reg->{domicilio_beneficiario1}) {
         ($n, $informacion) = ('012', $reg->{domicilio_beneficiario1});
         write $fh;
         $ntotal++;
      }
      if (defined $reg->{domicilio_beneficiario2}) {
         ($n, $informacion) = ('013', $reg->{domicilio_beneficiario2});
         write $fh;
         $ntotal++;
      }
      if (defined $reg->{plaza_beneficiario}) {
         ($n, $informacion) = ('014', $reg->{plaza_beneficiario});
         write $fh;
         $ntotal++;
      }
      if (defined $reg->{provincia_beneficiario}) {
         ($n, $informacion) = ('015', $reg->{provincia_beneficiario});
         write $fh;
         $ntotal++;
      }
      if (defined $reg->{concepto1}) {
         ($n, $informacion) = ('016', $reg->{concepto1});
         write $fh;
         $ntotal++;
      }
      if (defined $reg->{concepto2}) {
         ($n, $informacion) = ('017', $reg->{concepto2});
         write $fh;
         $ntotal++;
      }
      if (defined $reg->{dni}) {
         ($n, $dni, $nib) = ('018', $reg->{dni}, $reg->{nib});
         $dni = sprintf("%018s", $dni);
         $fh->format_name("REGISTRO9");
         write $fh;
         $ntotal++;
      }
   }

   # Línea de totales --------------------------------------------------------
   $fh->format_name("TOTALES");
   $ntotal++;     # Se cuenta también el de totales
   $suma = importe_cb34($suma);
   $suma = sprintf("%012s", $suma);
   $n010 = sprintf("%08s", $n010);
   $ntotal = sprintf("%010s", $ntotal);
   write $fh;

   # Definiciones de formatos ================================================
format CABECERA1 =
0356@>>>>>>>>>            001@|||||@|||||@>>>@>>>@>>>>>>>>>@   @>@>>>>>>
    $ordenante,            $envio,$emis,$ent,$ofi,$cuenta,$det,$dc,$libre
.
format CABECERA234 =
0356@>>>>>>>>>            @>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>>>>>
    $ordenante,           $n,$informacion,                       $libre
.
format CABECERA56 =
0356@>>>>>>>>>            @>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>>>>>
    $ordenante,           $n,$informacion,                       $libre
.
format REGISTRO1 =
06@>@>>>>>>>>>@<<<<<<<<<<<010@>>>>>>>>>>>@>>>@>>>@>>>>>>>>>@@  @<@>>>>>>
  $o,$ordenante,$ref_bene,   $importe,  $ent,$ofi,$cuenta,$g,$c,$dc,$libre
.
format REGISTRO28 =
06@>@>>>>>>>>>@<<<<<<<<<<<@>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>>>>>
  $o,$ordenante,$ref_bene,$n,$informacion,                       $libre
.
format REGISTRO9 =
06@>@>>>>>>>>>@>>>>>>>>>>>018@>>>>>>>>>>>>>>>>>@>>>>>>>>>>>>>>>>>@>>>>>>
  $o,$ordenante,$ref_bene,   $dni,             $nib,             $libre
.
format TOTALES =
0856@>>>>>>>>>               @>>>>>>>>>>>@>>>>>>>@>>>>>>>>>      @>>>>>>
    $ordenante,              $suma,      $n010,  $ntotal,        $libre
.
}

sub importe_cb34 {
   my $importe = shift ;

   $importe = sprintf("%.2f", $importe) * 100;
}

sub fecha_cb34 {
   my $fecha = shift ;

   my @trozos = split('-', $fecha);
   $trozos[0] =~ s/^..//go;
   $trozos[2] =~ s/ .*//go;
   return sprintf("%02s%02s%02s", $trozos[2], $trozos[1], $trozos[0]);
}

1;
