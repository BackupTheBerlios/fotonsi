#!/usr/bin/perl -w

use strict;

my $pruebas = 6;
use Test::More tests => 6;
use Test::Deep;
use DBIx::DataSource qw(create_database drop_database);
use Config::Tiny;
use Foton::BBDD qw(conectar_bdd);
use Class::DBI::FastPager;

my $fich_config = 't/paging.ini';
my $conf = Config::Tiny->read($fich_config);
use lib qw(t);
my $conf_bdd_eval = "nombre => '$conf->{base_datos}->{nombre}',
                     usuario => '$conf->{base_datos}->{usuario}',
                     clave => '$conf->{base_datos}->{clave}'";
eval "use Cosa $conf_bdd_eval";
eval "use Vacia $conf_bdd_eval";

SKIP: {
    skip "NO EXISTE EL FICHERO DE CONFIGURACIÓN $fich_config", $pruebas unless -r $fich_config;

    create_database($conf->{base_datos}->{nombre},
                    $conf->{base_datos}->{usuario},
                    $conf->{base_datos}->{clave});

    my $dbh = conectar_bdd($conf->{base_datos}->{nombre},
                               $conf->{base_datos}->{usuario},
                               $conf->{base_datos}->{clave},
                               't/paging.sql');
    ok (defined $dbh,                         'Creación de la base de datos');
    $dbh->disconnect;


    # Las pruebas del módulo en sí
    my @lista = Cosa->paged_search({}, { page => 2, nelems => 3 });
    is (scalar @lista, 3,                     'paged_search');
    is ($lista[0]->cod_cosa, 4,               ' cod_cosa');
    @lista = Cosa->paged_search({ des_cosa => { 'LIKE' => '%cosa' } },
                                { page => 3, nelems => 3,
                                  order_by => 'cod_cosa' });
    is (scalar @lista, 3,                     ' restricciones');
    cmp_deeply([ map { $_->cod_cosa } @lista ],
               [ 7, 8, 9 ],                   ' cod_cosa');


    # Comprobamos que no pete con tablas vacías
    eval { Vacia->paged_search({ cod_vacio => 0 }, { nelems => 5 }); };
    is ($@, "", 'tabla vacía');


    # Tenemos que cerrar las conexiones de Class::DBI. Si no, no funcionará
    Cosa->db_Main->disconnect;
    sleep(1);
    drop_database($conf->{base_datos}->{nombre},
                  $conf->{base_datos}->{usuario},
                  $conf->{base_datos}->{clave});
}
