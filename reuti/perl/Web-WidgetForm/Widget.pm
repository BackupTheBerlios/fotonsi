package Web::Widget;

use strict;

# $Id: Widget.pm,v 1.3 2004/02/12 23:16:06 zoso Exp $

=head1 NAME

Web::Widget - Base Web Widget

=head1 SYNOPSIS

 use Web::Widget;

 $o = Web::Widget->new($form, $name, $args);
 $o->init;        # Called automatically once for every widget type
 $o->setup_form;  # Called automatically for every widget instance

 print $o->render;

 if ($o->validate($value)) {
    # Do something
 } else {
    # Invalid data
 }

=head1 DESCRIPTION

The class C<Web::Widget> is the base class for every Web Component System
widget.

=head1 METHOD

=over 4

=item new($form, $name, $args)

Creates a new component, associated to the given form, with the given name and
the given arguments.

=item init

Initializes the widget I<type>. It's called automatically by the form once for
every widget type.

=item setup_form

Fills the associated form properties for the current widget. It's called
automatically for every widget.

=item render($opt_args)

Renders the widget and returns the result. If C<$opt_args> is given, those
arguments are added/replaced for that particular rendering.

=item validate($value)

Validates the widget with the given value. This validation is a "server
validation", of course, when the actual data have arrived.

=back

=head1 COPYRIGHT

This class is free. You can redistribute or modify it under the same terms as
Perl itself.

 Copyright 2004 Fotón Sistemas Inteligentes

=head1 AUTHOR

This class was written by Esteban Manchado Velázquez <zoso@foton.es>.

=cut

sub new {
   my $proto = shift ;
   my $class = ref($proto) || $proto;
   my ($form, $name, $args) = @_;
   my $self  = { FORM => $form,
                 NAME => $name,
                 ARGS => $args
               };
   bless ($self, $class);
   return $self;
}

sub init {
   my ($self) = @_;
}

sub setup_form {
   my ($self) = @_;

   my ($form, $name, $args) = ($self->{FORM}, $self->{NAME}, $self->{ARGS});

   # Common rules
   $form->add_prop('init', "\%$name\%.focus();") if $args->{focus};
   $form->add_prop('before_send', "if (\%$name\%.value) { alert('".($args->{nonempty_msg} || "Error: empty field. Please fill in.")."'); \%$name\%.focus(); return 0 };")
         if $args->{nonempty};
   # $form->add_prop('before_send', "\%$args->{depends}\%;")
         # if $args->{depends};
}

sub render {
   my ($self, $opt_args) = @_;
   my $current_args = $self->merge_args($self->{ARGS}, $opt_args);
   "<input type='hidden' name='".$self->escape("'", $self->{NAME}).
         "' value='".$self->escape("'", $current_args->{value})."'".
         (defined $current_args->{class} ?
               "class='".$self->escape("'", $current_args->{class})."'" : "").
         ">";
}

sub validate {
   my ($self, $value) = @_;

   # First of all, test with given validators
   defined $self->{ARGS}->{validators} && do {
      $self->{ARGS}->{validators} = [ $self->{ARGS}->{validators} ]
            unless ref $self->{ARGS}->{validators} eq 'ARRAY';
      foreach my $v (@{$self->{ARGS}->{validators}}) {
         $v->validate($value) || return 0;
      }
   };
   return 0 if $value =~ /^\s*$/ && $self->{ARGS}->{nonempty};
   1;
}

sub merge_args {
   my ($self, @arg_list) = @_;
   my $args = {};
   foreach my $a (@arg_list) {
      $args = { %$args, %$a };
   }
   $args;
}

sub escape {
   my ($self, $quote_char, $value) = @_;
   $value =~ s/\\/\\\\/go;
   $value =~ s/$quote_char/\\$quote_char/g;
   return $value;
}

sub DESTROY {
   my $self = shift ;
}

1;
