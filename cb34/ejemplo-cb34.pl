#!/usr/bin/perl -w

use strict;
use Config::Tiny;
use Cb34 qw(cb34);

my $datos = Config::Tiny->read('ejemplo-cb34.ini');

$datos->{general}->{registros} = [ { beneficiario => '1',
                                     importe      => 123.45,
                                     entidad      => 2052,
                                     oficina      => 8000,
                                     cuenta       => 1326542564,
                                     gastos       => 1,
                                     concepto     => 9,
                                     dcontrol     => '**',
                                     nombre_beneficiario => 'CASADO Y CASADA',
                                     domicilio_beneficiario1 => 'DOMICILIO DE LOS CASADOS',
                                     domicilio_beneficiario2 => 'DOMIICILIO 2 DE LOS CASADOS',
                                     plaza_beneficiario => '35009PLAZA DE LOS CASADOS',
                                     provincia_beneficiario => 'PROVINCIA DE LOS CASADOS',
                                     concepto1    => 'LINEA 1 DE CONCEPTO',
                                     concepto2    => 'LINEA 2 DE CONCEPTO',
                                   }
                                 ];

cb34(\*STDOUT, $datos->{general});
