package Web::Widget;

use strict;

# $Id: Widget.pm,v 1.10 2004/04/16 11:15:18 zoso Exp $

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

=head1 METHODS

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

=item arg($name)

=item arg($name, $value)

Returns the value of the argument C<$name>. If C<$value> is given, it's first
assigned to the argument C<$name>.

=item render($opt_args)

Renders the widget and returns the result. If C<$opt_args> is given, those
arguments are added/replaced for that particular I<rendering>. B<NOTE:> the
optional arguments are used only for the rendering, not for setting-up the
form. Its main use is to support multiple form elements with the same name.

=item validate($value)

Validates the widget with the given value. This validation is a "server
validation", of course, when the actual data have arrived.

=item type_data_transform($form_values)

Transform the form received data in some way that makes sense to the widget
type. It's usually called to e.g.: convert human-readable dates to
machine-readable ones, or to change some form values depending on the form
button pushed.

It's called automatically by the form when some data is loaded, once for every
widget type loaded.

=item widget_data_transform($form_values)

Transform the form received data in some way that makes sense to the widget.
It's usually called to e.g.: convert human-readable dates to machine-readable
ones, or to change some form values depending on the form button pushed.

It's called automatically by the form when some data is loaded, once for every
widget loaded.

=back

=head1 CONVENIENCE METHODS

=over 4

=item get_html_attrs

=item get_html_attrs($html_attrs_hash)

=item get_html_attrs($html_attrs_hash, $valid_html_attrs_list)

Returns the HTML attributes for the tag, filtering them with the valid HTML
attributes list. If C<$html_attrs_hash> or C<$valid_html_attrs_list> are not
given, the internal defaults are used.

=item merge_args($arg_hash1, $arg_hash2, $arg_hash3, ...)

Merges the given argument hashes, returning the result. When the same key
appears more than once, the last value takes precedence.

=item get_value

=item get_value($suffix)

Returns a value for the widget, first by looking at the form arguments and
then, if no value is found, looking at the default value given in the widget
properties. If no arguments are given, the form key C<$name> and the widget
property C<value> are used (where C<$name> is the name of the widget). On the
other hand, if C<$suffix> is given, the form key C<$name$suffix> and the
widget property C<value$suffix> are used.

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
                 ARGS => $args,
                 HTML_VALID_ATTRS => ['class', 'id', 'disabled'],
                 HTML_ATTRS => {},
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

   # Common HTML attributes
   $self->{HTML_ATTRS}->{name} = $name;
   foreach my $empty_attr ('readonly', 'disabled', 'selected', 'checked') {
      $self->{HTML_ATTRS}->{$empty_attr} = undef if $args->{$empty_attr};
   }
   foreach my $value_attr ('class', 'id', 'tabindex', 'accesskey',
                           'src', 'alt', 'size', 'maxlength') {
      $self->{HTML_ATTRS}->{$value_attr} = $args->{$value_attr}
            if defined $args->{$value_attr};
   }
}

sub arg {
   my ($self, $name, $value) = @_;
   $self->{ARGS}->{$name} = $value if (scalar @_ > 2);
   $self->{ARGS}->{$name};
}

sub render {
   my ($self, $opt_args) = @_;
   my $current_args = $self->merge_args($self->{ARGS}, $opt_args);
   "<input type='hidden' name='".$self->html_escape($self->{NAME}).
         "' value='".$self->html_escape($current_args->{value} || '')."' ".
         $self->get_html_attrs.
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

sub type_data_transform {
   my ($self, $form_values) = @_;
   # No default transform
}

sub widget_data_transform {
   my ($self, $form_values) = @_;
   # No default transform
}




sub get_html_attrs {
   my ($self, $html_attrs, $html_valid_attrs) = @_;
   $html_attrs       ||= $self->{HTML_ATTRS};
   $html_valid_attrs ||= $self->{HTML_VALID_ATTRS};
   my %attrs_hash = %$html_attrs;
   my @r = ();
   foreach my $attr (@$html_valid_attrs) {
      if (exists $attrs_hash{$attr}) {
         if (defined $attrs_hash{$attr}) {
            push @r, "$attr=\"".$self->html_escape($attrs_hash{$attr})."\"";
         } else {
            push @r, $attr;
         }
      }
   }
   join(" ", @r);
}

sub merge_args {
   my ($self, @arg_list) = @_;
   my $args = {};
   foreach my $a (@arg_list) {
      $args = { %$args, %$a } if defined $a;
   }
   $args;
}

sub html_escape {
   my ($self, $value) = @_;
   return $self->{FORM}->html_escape($value);
}

sub get_value {
   my ($self, $suffix) = @_;
   $suffix ||= "";

   my $value = $self->{FORM}->get_form_value($self->{NAME}.$suffix);
   return defined $value ? $value : $self->{ARGS}->{"value$suffix"};
}

sub DESTROY {
   my $self = shift ;
}

1;
