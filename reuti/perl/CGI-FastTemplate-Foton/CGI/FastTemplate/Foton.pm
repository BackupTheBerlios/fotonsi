#!/usr/local/bin/perl

package CGI::FastTemplate::Foton;


use strict;

our $VERSION = '0.01';


use UNIVERSAL qw(isa);

use CGI::FastTemplate;




my $_variable_base = 'CONTENT';
my $_variable_no_strict = 0;
#my $_debug = 1;


sub out 
{
  my ($datos_ref) = @_;

  if (defined $datos_ref) {
    my ($templates_ref, $valores_ref) = @{$datos_ref};

    if (defined $templates_ref) {
      my %templates = %{$templates_ref};

      my $tpl = new CGI::FastTemplate;

      $tpl->no_strict if $_variable_no_strict;

      foreach (values %templates) {
        my $template_temp = _template_define($_);
        $tpl->define($template_temp => $_);
      }

      _valores($tpl, $templates_ref, $_variable_base, $valores_ref);

      my $contenido_ref = $tpl->fetch($_variable_base);

      if (defined $contenido_ref) {
        return ${$contenido_ref};
      }
    }
  }
}

sub _valores
{
  my ($tpl, $templates_ref, $variable_final, $valores_array_ref) = @_;

#print STDERR "_valores de: $variable_final\n" if ($_debug);

  if (defined $valores_array_ref) {
    if (isa($valores_array_ref, 'HASH')) {
#print STDERR "Necesito transformar a array\n" if ($_debug);
      $valores_array_ref = [$valores_array_ref];
    }
    
    my @valores_array = @{$valores_array_ref};

    foreach my $valores_ref (@valores_array) {

      my %valores = %{$valores_ref};
  
      foreach my $variable_tpl (keys %valores) {

        if (!ref($valores{$variable_tpl})) {
#print STDERR " Cojo: $variable_tpl\n" if ($_debug);
          $tpl->assign($variable_tpl => $valores{$variable_tpl});
        }
        else {
          _valores($tpl, $templates_ref, $variable_tpl, $valores{$variable_tpl});
        }
      }
      my $template_temp = _template_define(${$templates_ref}{$variable_final}); 
#print STDERR qq(_valores de: $variable_final => ".$template_temp"\n) if ($_debug);
      $tpl->parse($variable_final => ".$template_temp");  
    }
  }
}

sub _template_define {
  my ($cadena) = @_;

#print STDERR " Convierto: $cadena\n" if ($_debug);
  $cadena =~ s/\./_/go;

  return $cadena;
}


sub strict
{
  $_variable_no_strict = 0;
}


sub no_strict
{
  $_variable_no_strict = 1;
}

1;

__END__


=head1 NOMBRE

CGI::FastTemplate::Foton - Módulo de facilitación de uso de CGI::FastTemplate

=head1 SINOPSIS

 use CGI::FastTemplate::Foton;

 my $datos_ref = [{CONTENT    => 'simple.tpl'},

                  {TITLE      => 'Ejemplo simple',
		   NUMBER     => '1',
		   BIG_NUMBER => '10'}
		 ];

 print CGI::FastTemplate::Foton::out($datos_ref);

=head1 DESCRIPCIÓN

Este paquete es una clase derivada de CGI::FastTemplate que facilita su uso.


=head1 FUNCIONES

=over 4

=item out

Devuelve el resultado de tratar un conjunto de variables de template, ficheros y
valores con CGI::FastTemplate.

=back


=head1 AUTHORS

=over

=item Esteban Manchado Velazquez <zoso@foton.es>, Javier Arbelo <jarbelo@foton.es>, Eduardo Navarro <eduardo@foton.es>

=back


=cut
