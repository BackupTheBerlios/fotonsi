package Cosa;

use base qw(Class::DBI);
use Class::DBI::FastPager;

our $configurado = 0;

sub import {
    my ($pkg, @args) = @_;

    return if $configurado;
    pop @args if scalar @args % 2;
    my %args = @args;

    Cosa->set_db('Main', $args{nombre}, $args{usuario}, $args{clave},
                         {AutoCommit => 1});
    $configurado = 1;
}

Cosa->table('tcosa');
Cosa->columns(All => qw(cod_cosa des_cosa));

1;
