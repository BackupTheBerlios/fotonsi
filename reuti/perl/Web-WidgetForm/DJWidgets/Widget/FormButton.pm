package Web::DJWidgets::Widget::FormButton;

use strict;

use base qw(Web::DJWidgets::Widget::Button);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   # Default value (check actual arguments passed to this method, not the
   # value received from the 'Button' widget type)
   $self->arg('type', 'submit') unless defined $args[2]->{'type'};
   return $self;
}

1;
