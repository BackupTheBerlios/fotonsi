package Cb34;

use strict;

# $Id: Cb34.pm,v 1.2 2003/10/31 20:52:43 zoso Exp $

use vars qw(@EXPORT_OK);
require Exporter;
*import = \&Exporter::import;
@EXPORT_OK = qw(cb34 importe_cb34);

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

=back

=head1 FALLOS Y LIMITACIONES

Por ahora, la función C<cb34> sólo imprime registro de transferencias, no de
cheques. En principio, debería ser bastante fácil modificarlo para imprimir
también cheques.

Los importes siempre se truncan, no se redondean. Para redondearlos, hay que
modificar la función C<importe_cb34>.

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

   my $o = 56;    # Sólo entendemos transferencias

   my ($n, $informacion, $importe, $ref_bene);

   my ($g, $c, $dni, $nib);
   my ($suma, $n010, $ntotal) = (0, 0, 0);      # Para los totales

   # Datos generales
   my $ordenante = uc($datos->{ordenante});

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
             $reg->{oficina}, $reg->{cuenta}, $reg->{gastos}, $reg->{c}, $reg->{dc});
      $n010++;
      $suma += $importe;
      $importe = importe_cb34($importe);
      # Comprobaciones
      grep { $_ eq $g } (1, 2) or die "El tipo de gasto es inválido: $g";
      grep { $_ eq $c } (1, 8, 9) or die "El concepto es inválido: $c";

      $fh->format_name("REGISTRO1");
      write $fh;
      $ntotal++;
      # ----------------------------------------------------------------------
      ($n, $informacion) = ('011', $reg->{nombre_beneficiario});
      $fh->format_name("REGISTRO28");
      write $fh;
      $ntotal++;
      # ----------------------------------------------------------------------
   }

   # Línea de totales --------------------------------------------------------
   $fh->format_name("TOTALES");
   $suma = importe_cb34($suma);
   write $fh;

   # Definiciones de formatos ================================================
format CABECERA1 =
0356@>>>>>>>>>            001@|||||@|||||@>>>@>>>@0########@   @>@||||||
    $ordenante,            $envio,$emis,$ent,$ofi,$cuenta,$det,$dc,""
.
format CABECERA234 =
0356@>>>>>>>>>            @>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@||||||
    $ordenante,           $n,$informacion,                       ""
.
format CABECERA56 =
0356@>>>>>>>>>            @>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@||||||
    $ordenante,           $n,$informacion,                       ""
.
format REGISTRO1 =
06@>@>>>>>>>>>@>>>>>>>>>>>010@<<<<<<<<<<<@<<<@<<<@0########@@  @<@||||||
  $o,$ordenante,$ref_bene,   $importe,  $ent,$ofi,$cuenta,$g,$c,$dc,""
.
format REGISTRO28 =
06@>@>>>>>>>>>@>>>>>>>>>>>@>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@||||||
  $o,$ordenante,$ref_bene,$n,$informacion,                       ""
.
format REGISTRO9 =
06@>@>>>>>>>>>@>>>>>>>>>>>018@<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<@||||||
  $o,$ordenante,$ref_bene,   $dni,             $nib,             ""
.
format TOTALES =
0856@>>>>>>>>>               @<<<<<<<<<<<@<<<<<<<@<<<<<<<<<      @||||||
    $ordenante,              $suma,      $n010,  $ntotal,        ""
.
}

sub importe_cb34 {
   my $importe = shift ;

   $importe = int($importe) * 100;
}

1;
