package Web::DJWidgets::Widget::TextBox;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{VALUE_HTML_ATTRS}}, 'size', 'maxlength';
   $self->arg('type', 'text');      # Fixed value
   return $self;
}

1;
