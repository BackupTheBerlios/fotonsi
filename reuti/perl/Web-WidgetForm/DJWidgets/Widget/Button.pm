package Web::DJWidgets::Widget::Button;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   $self->{EMPTY_HTML_ATTRS} = [ grep { $_ ne 'readonly' }
                                      @{$self->{EMPTY_HTML_ATTRS}} ];
   # Default value
   $self->arg('type', 'button') unless defined $self->arg('type');
   return $self;
}

1;
