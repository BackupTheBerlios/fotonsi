package Web::DJWidgets::Widget::BaseInput;

use strict;

use base qw(Web::DJWidgets::Widget::JavascriptComponent);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{VALUE_HTML_ATTRS}}, 'type', 'value', 'tabindex',
                                      'accesskey';
   push @{$self->{EMPTY_HTML_ATTRS}}, 'readonly';
   return $self;
}

sub setup_form {
   my ($self, @args) = @_;

   $self->SUPER::setup_form(@args);
   my ($form, $name, $args) = ($self->{FORM}, $self->{NAME}, $self->{ARGS});
   $args->{focus} && $form->add_prop('init', "\%$name\%.focus();");
}

sub render {
   my ($self, $extra_args) = @_;

   $self->SUPER::render($extra_args);
   my $args = $self->merge_args({ $self->get_args }, $extra_args);
   my $extra_attrs = $self->get_html_attrs($args);
   return <<EOWIDGET;
   <input $extra_attrs>
EOWIDGET
}

1;
