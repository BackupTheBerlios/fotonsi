package CGI::FastTemplate::Foton;


use strict;

our $VERSION = '0.01';


use UNIVERSAL qw(isa);

use CGI::FastTemplate;


#use base qw(CGI::FastTemplate);  # Queda pendiente derivar la clase


sub new
{
  my $proto = shift;
  my $class = ref $proto || $proto;
  my $self = {};
  $self->{VARIABLE_BASE} = 'CONTENT';
  # $self->{DEBUG} = 1;
  bless ($self, $class);
  return $self;
}



sub out 
{
  my $self = shift;
  my ($datos_ref) = @_;

  if (defined $datos_ref) {
    my ($templates_ref, $valores_ref) = @{$datos_ref};

    if (defined $templates_ref) {
      my %templates = %{$templates_ref};

      my $tpl = new CGI::FastTemplate;

      $tpl->no_strict if $self->{VARIABLE_NO_STRICT};

      foreach (values %templates) {
        my $template_temp = $self->out($datos_ref);
        $tpl->define($template_temp => $_);
      }

      _valores($tpl, $templates_ref, $self->{VARIABLE_BASE}, $valores_ref);

      my $contenido_ref = $tpl->fetch($self->{VARIABLE_BASE});

      if (defined $contenido_ref) {
        return ${$contenido_ref};
      }
    }
  }
}

sub _valores
{
  my $self = shift;
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
      my $template_temp = $self->_template_define(${$templates_ref}{$variable_final}); 
#print STDERR qq(_valores de: $variable_final => ".$template_temp"\n) if ($_debug);
      $tpl->parse($variable_final => ".$template_temp");  
    }
  }
}

sub _template_define {
  my $self = shift;
  my ($cadena) = @_;

#print STDERR " Convierto: $cadena\n" if ($_debug);
  $cadena =~ s/\./_/go;

  return $cadena;
}


sub strict
{
  my $self = shift ;
  $self->{VARIABLE_NO_STRICT} = 0;
}


sub no_strict
{
  my $self = shift ;
  $self->{VARIABLE_NO_STRICT} = 1;
}

1;

__END__


=head1 NOMBRE

CGI::FastTemplate::Foton - Módulo de facilitación de uso de CGI::FastTemplate

=head1 SINOPSIS

 use CGI::FastTemplate::Foton;

 my $cft = CGI::FastTemplate::Foton->new;

 my $datos_ref = [{CONTENT    => 'simple.tpl'},

                  {TITLE      => 'Ejemplo simple',
		   NUMBER     => '1',
		   BIG_NUMBER => '10'}
		 ];

 print $cft->out($datos_ref);

=head1 DESCRIPCIÓN

Este paquete es una clase derivada de CGI::FastTemplate que facilita su uso.


head1 FUNCIONES

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
