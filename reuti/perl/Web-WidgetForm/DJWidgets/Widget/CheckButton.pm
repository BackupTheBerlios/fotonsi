package Web::DJWidgets::Widget::CheckButton;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{EMPTY_HTML_ATTRS}}, 'readonly', 'checked';
   # Default value
   $self->arg('type', 'checkbox') unless defined $self->arg('type');
   return $self;
}

sub get_calc_html_attrs {
   my ($self, $args) = @_;

   return ($self->SUPER::get_calc_html_attrs($args),
           (defined $args->{selected} && $args->{selected} ?
              (checked => undef) : ()));
}

sub validate {
   my ($self, $vars) = @_;

   $vars ||= $self->get_form->get_form_values;
   my @errors = $self->SUPER::validate($vars);
   my $value = $vars->{$self->get_name};
   # It can only be one value
   if (ref $value) {
      push @errors, $self->arg('only_one_value_msg') || "Radio buttons can't have more than one value";
      return @errors;
   }

   @errors;
}

sub render {
   my ($self, $extra_args) = @_;

   $self->SUPER::render($extra_args);
   my $args = $self->merge_args({ $self->get_args }, $extra_args);
   my $extra_attrs = $self->get_html_attrs($args);
   my $label = $args->{label};

   return <<EOWIDGET;
   <input $extra_attrs>$label
EOWIDGET
}

1;
