package Web::DJWidgets::Widget::TextArea;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   # Remove 'value' and 'type', add 'cols' and 'rows'
   $self->{VALUE_HTML_ATTRS} = [ grep { $_ ne 'value' && $_ ne 'type' }
                                      @{$self->{VALUE_HTML_ATTRS}},
                                 'cols', 'rows' ];
   return $self;
}

sub setup_form {
   my ($self, @args) = @_;

   $self->SUPER::setup_form(@args);
   my ($form, $name, $args) = ($self->{FORM}, $self->{NAME}, $self->{ARGS});
   $self->arg('nonempty_msg', "Empty field. Please fill in.")
         unless defined $self->arg('nonempty_msg');

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
   my $value = $args->{value} || "";
   return <<EOWIDGET;
   <textarea $extra_attrs>$value</textarea>
EOWIDGET
}

1;
