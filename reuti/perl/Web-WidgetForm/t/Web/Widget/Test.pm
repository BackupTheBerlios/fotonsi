package Web::Widget::Test;

use base qw(Web::Widget);

sub type_data_transform {
   my ($self, $values) = @_;
   $values->{type_Test}++;
}

sub widget_data_transform {
   my ($self, $values) = @_;
   $values->{"widget_$self->{NAME}"} = 'Test::'.$self->{NAME};
}

1;
