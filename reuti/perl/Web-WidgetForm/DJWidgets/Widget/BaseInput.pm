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
   $self->arg('nonempty_msg', "Empty field. Please fill in.")
         unless defined $self->arg('nonempty_msg');

   # Common form rules
   $args->{focus} && $form->add_prop('init', "\%$name\%.focus();");
   $args->{nonempty} && $form->add_prop('before_send', "if (\%$name\%.value.match(/^ *\$/)) { alert('$args->{nonempty_msg}'); \%$name\%.focus(); return false; };");
}

sub validate {
   my ($self, $vars) = @_;

   $vars ||= $self->get_form->get_form_values;
   my @errors = $self->SUPER::validate($vars);
   # Custom validators
   push @errors, $self->arg('nonempty_msg')
         if $self->arg('nonempty') && $vars->{$self->get_name} =~ /^\s*$/;
   @errors;
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
