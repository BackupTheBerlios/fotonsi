package Web::Widget::Test;

use base qw(Web::Widget);

sub new {
   my ($self, @args) = @_;

   $self = $self->SUPER::new(@args);
   push @{$self->{EMPTY_HTML_ATTRS}}, 'checked';
   push @{$self->{VALUE_HTML_ATTRS}}, 'size';
   return $self;
}

sub type_data_transform {
   my ($self, $values) = @_;
   $values->{type_Test}++;
}

sub widget_data_transform {
   my ($self, $values) = @_;
   $values->{"widget_$self->{NAME}"} = 'Test::'.$self->{NAME};
}

1;
