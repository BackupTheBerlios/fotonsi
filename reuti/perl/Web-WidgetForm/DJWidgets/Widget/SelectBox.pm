package Web::DJWidgets::Widget::SelectBox;

use strict;

use base qw(Web::DJWidgets::Widget::JavascriptComponent);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{VALUE_HTML_ATTRS}}, 'type', 'size', 'multi', 'tabindex',
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
   my $args = $self->merge_args({ $self->get_args }, $extra_attrs);
   my $extra_attrs = $self->get_html_attrs($args);
   # A kind of ordered hash
   my @option_list = @{$self->arg('options')};
   my $options     = join("\n", map { "<option value=\"$option_list[$_]\">".
                                         $option_list[$_+1] }
                                    grep { $_ % 2 == 0 } (0 .. $#option_list));
   return <<EOWIDGET;
   <select $extra_attrs>
     $options
   </select>
EOWIDGET
}

1;
