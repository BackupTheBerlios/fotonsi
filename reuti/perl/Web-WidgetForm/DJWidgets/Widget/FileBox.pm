package Web::DJWidgets::Widget::FileBox;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   # Default value
   $self->arg('type', 'file') unless defined $self->arg('type');
   return $self;
}

sub setup_form {
   my ($self, @args) = @_;

   $self->SUPER::setup_form(@args);
   my ($form, $name, $args) = ($self->{FORM}, $self->{NAME}, $self->{ARGS});
   $self->arg('nonempty_msg', "Please select a file")
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

1;
