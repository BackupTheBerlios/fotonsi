package Vacia;

use base qw(Class::DBI);
use Class::DBI::FastPager;

our $configurado = 0;

sub import {
    my ($pkg, @args) = @_;

    return if $configurado;
    pop @args if scalar @args % 2;
    my %args = @args;

    Vacia->set_db('Main', $args{nombre}, $args{usuario}, $args{clave},
                         {AutoCommit => 1});
    $configurado = 1;
}

Vacia->table('tvacia');
Vacia->columns(Primary => qw(cod_vacio));

1;
