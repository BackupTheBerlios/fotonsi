package Web::DJWidgets::Widget::Hidden;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   $self->arg('type', 'hidden');
   return $self;
}

1;
