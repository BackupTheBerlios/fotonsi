package Web::Widget::Test;

use base qw(Web::Widget);

sub new {
   my ($self, @args) = @_;

   $self = $self->SUPER::new(@args);
   push @{$self->{EMPTY_HTML_ATTRS}}, 'checked';
   push @{$self->{VALUE_HTML_ATTRS}}, 'size', 'onchange';
   return $self;
}

sub type_data_transform {
   my ($self, $values) = @_;
   $values->{type_Test}++;
}

sub get_calc_html_attrs {
   my ($self, $args) = @_;
   my %base_attrs = $self->SUPER::get_calc_html_attrs($args);
   $base_attrs{onchange} .= $self->get_form->get_js_name($self->get_name).".value = ''; ";
   return (%base_attrs, i_dont_exist_in_html_attrs => 'no, really');
}

sub widget_data_transform {
   my ($self, $values) = @_;
   $values->{"widget_$self->{NAME}"} = 'Test::'.$self->{NAME};
}

1;
