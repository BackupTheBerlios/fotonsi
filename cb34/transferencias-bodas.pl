#!/usr/bin/perl -w

use strict;

use DBI;

use Cb34;
use Foton::Fecha qw(hoy fecha_a_procesar);

sub separa_cc {
   my $cc = shift ;

   $cc =~ /(....)(....)(..)(..........)/;
   return ($1, $2, $3, $4);
}

my $dbh = DBI->connect("DBI:Pg:dbname=tpvboda", "entrada");
my $sth = $dbh->prepare("SELECT cif_caja, cc_origen FROM v_creacion_cb34");
$sth->execute;
my $fila = $sth->fetchrow_hashref;
$sth->finish;

my ($cif_caja, $cc_caja) = ($fila->{cif_caja}, $fila->{cc_origen});
my ($entidad, $oficina, $dc, $cuenta) = separa_cc($cc_caja);
my $datos = { ordenante => $cif_caja,
              fecha_envio => Cb34::fecha_cb34(fecha_a_procesar(hoy)),
              fecha_emision => Cb34::fecha_cb34(fecha_a_procesar(hoy)),
              entidad => $entidad, oficina => $oficina,
              cuenta => $cuenta, dcontrol => $dc,
              detalle => 0,       # DUDA
              nombre_ordenante => 'La Caja de Canarias',
              domicilio_ordenante => 'Triana',
              plaza_ordenante => '3500x',
              # nombre_por_cuenta => undef,
              # domicilio_por_cuenta => undef,
              registros => [],
              };

$sth = $dbh->prepare("SELECT * from v_creacion_cb34");
$sth->execute;
while ($fila = $sth->fetchrow_hashref) {
   ($entidad, $oficina, $dc, $cuenta) = separa_cc($fila->{cc_destino});
   my $nauto = $fila->{des_pago};
   $nauto =~ s/.*nauto=([^;]*);.*/$1/;
   push @{$datos->{registros}}, { beneficiario => $fila->{cod_boda},
                                  fecha => Cb34::fecha_cb34($fila->{fecha_pago}),
                                  importe => $fila->{importe},
                                  entidad => $entidad, oficina => $oficina,
                                  dcontrol => $dc, cuenta => $cuenta,
                                  concepto => 9, gastos => 1,
                                  nombre_beneficiario => $fila->{nombre_alias},
                                  domicilio_beneficiario1 => $fila->{direccion},
                                  # domicilio_beneficiario2 => undef,
                                  plaza_beneficiario => $fila->{codigo_postal}.$fila->{localidad},
                                  provincia_beneficiario => $fila->{provincia},
                                  concepto1 => $fila->{nombre_invitado}.$nauto };
}
$sth->finish;
$dbh->disconnect;

Cb34::cb34(\*STDOUT, $datos);
