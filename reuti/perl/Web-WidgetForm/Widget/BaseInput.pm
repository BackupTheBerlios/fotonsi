package Web::Widget::BaseInput;

use strict;

use base qw(Web::Widget::JavascriptComponent);

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

   # Common form rules
   $args->{focus} && $form->add_prop('init', "\%$name\%.focus();");
   $args->{nonempty} && $form->add_prop('before_send', "if (\%$name\%.value.match(/^ *\$/)) { alert('".($args->{nonempty_msg} || "Error: empty field. Please fill in.")."'); \%$name\%.focus(); return false; };");
   $args->{before_send_extra} && $form->add_prop('before_send', $args->{before_send_extra});
}

sub render {
   my ($self, $extra_args) = @_;

   $self->SUPER::render;
   my $extra_attrs = $self->get_html_attrs;
   return <<EOWIDGET;
   <input $extra_attrs>
EOWIDGET
}

1;
