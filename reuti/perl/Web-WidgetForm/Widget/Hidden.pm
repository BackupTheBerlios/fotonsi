package Web::Widget::Hidden;

use strict;

use base qw(Web::Widget);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{HTML_VALID_ATTRS}}, 'type', 'value';
   return $self;
}

1;
