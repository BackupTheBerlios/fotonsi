package Web::Widget::TextBox;

use strict;

use base qw(Web::Widget::JavascriptComponent);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{HTML_VALID_ATTRS}}, 'type', 'value', 'readonly', 'tabindex',
                                      'accesskey', 'size', 'maxlength';
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
   my ($name,         $value,           $extra_attrs) =
      ($self->{NAME}, $self->get_value, $self->get_html_attrs);
   $value ||= "";
   return <<EOWIDGET;
   <input type="text" name="$name" value="$value" $extra_attrs>
EOWIDGET
}

1;
