package Web::DJWidgets::Widget::ImageButton;

use strict;

use base qw(Web::DJWidgets::Widget::Button);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{VALUE_HTML_ATTRS}}, 'src', 'alt';
   # Default value (check actual arguments passed to this method, not the
   # value received from the 'Button' widget type)
   $self->arg('type', 'image') unless defined $args[2]->{'type'};
   return $self;
}

1;
