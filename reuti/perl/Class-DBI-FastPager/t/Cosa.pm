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
Cosa->columns(Primary => qw(cod_cosa));
Cosa->columns(Essential => qw(des_cosa obs_cosa));

1;
