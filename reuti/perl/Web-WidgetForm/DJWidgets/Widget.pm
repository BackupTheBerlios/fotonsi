package Web::DJWidgets::Widget;

use strict;

# $Id: Widget.pm,v 1.6 2005/01/24 13:22:35 setepo Exp $

=head1 NAME

Web::DJWidgets::Widget - Base Web Widget

=head1 SYNOPSIS

 use Web::DJWidgets::Widget;

 $o = Web::DJWidgets::Widget->new($form, $name, $args);
 $o->init;        # Called automatically once for every widget type
 $o->setup_form;  # Called automatically for every widget instance

 $name = $o->get_name;
 $form = $o->get_form;
 %args = $o->get_args;

 print $o->render;

 my @errors = $o->validate($value);
 if (scalar @errors) {
    # Invalid data
 } else {
    # Do something useful
 }

 $o->get_value;            # Get widget value
 $o->get_value($suffix);   # Get form value NAME$suffix or arg(value$suffix)

 $o->get_form_value($varname);

=head1 DESCRIPTION

The class C<Web::DJWidgets::Widget> is the base class for every Web Component
System widget.

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

=item get_name

Returns the widget name.

=item get_form

Returns the form object the widget is in.

=item get_args

Returns the widget argument hash.

=item arg($name)

=item arg($name, $value)

Returns the value of the argument C<$name>. If C<$value> is given, it's first
assigned to the argument C<$name>.

=item render($opt_args)

Renders the widget and returns the result. If C<$opt_args> is given, those
arguments are added/replaced for that particular I<rendering>. B<NOTE:> the
optional arguments are used only for the rendering, not for setting-up the
form. Its main use is to support multiple form elements with the same name.

=item validate($vars)

Validates the widget with the given variables. This validation is a "server
validation", of course, when the actual data have arrived. It returns a list
of validation errors for the given values. The list is empty if the widget
validates correctly.

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

=item get_calc_html_attrs

=item get_calc_html_attrs($args)

Returns the calculated attributes hash. Calculated attributes are the ones
obtained through widget arguments B<not> of the same name, or form arguments.
E.g. (part of) the attribute B<onchange>, based on some attribute
B<sync_to_widget>.

=back

=head1 CONVENIENCE METHODS

=over 4

=item get_html_attrs

=item get_html_attrs($args)

=item get_html_attrs($args, $value_html_attrs_list)

=item get_html_attrs($args, $value_html_attrs_list, $empty_html_attrs_list)

Returns the HTML attributes for the component, filtering them with the valid
HTML attributes list ("value" attributes and "empty" attributes). If
C<$html_attrs_hash>, C<$value_html_attrs_list> or C<$empty_html_attrs_list>
are not given, the internal defaults are used.

=item merge_args($arg_hash1, $arg_hash2, $arg_hash3, ...)

Merges the given argument hashes, returning the result. When the same key
appears more than once, the last value takes precedence.

=item get_value

=item get_value($suffix)

Returns a value for the widget, first by looking at the form arguments and
then, if no value is found, looking at the default value given in the widget
properties. If no arguments are given, the form key C<$name> (C<$name> being
the name of the widget) and the widget property C<value> are used (where
C<$name> is the name of the widget). If C<$suffix> is given, the form key
C<$name$suffix> and the widget property C<value$suffix> are used.

=item get_form_value($name)

Returns the value for the form variable C<$name>.

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
                 ARGS => { %$args },      # Copy arguments
                 EMPTY_HTML_ATTRS => ['disabled'],
                 VALUE_HTML_ATTRS => ['name', 'class', 'id'],
               };
   bless ($self, $class);
   return $self;
}

sub init {
   my ($self) = @_;
}

sub setup_form {
   my ($self) = @_;

   # Common form setup
   my $before_send_extra = $self->arg('before_send_extra');
   $before_send_extra && $self->get_form->add_prop('before_send', $before_send_extra);
}

sub get_name {
   $_[0]->{NAME};
}

sub get_form {
   $_[0]->{FORM};
}

sub get_args {
   %{$_[0]->{ARGS}};
}

sub arg {
   my ($self, $name, $value) = @_;
   $self->{ARGS}->{$name} = $value if (scalar @_ > 2);
   $self->{ARGS}->{$name};
}

sub render {
   my ($self, $opt_args) = @_;

   my ($form, $name, $args) = ($self->get_form, $self->get_name,
                               { $self->get_args });
   $args = $self->merge_args($args, $opt_args);

   "<input ".$self->get_html_attrs($args).">";
}

sub validate {
   my ($self, $vars) = @_;

   $vars ||= $self->get_form->get_form_values;
   my @errors;
   # Test with given validators. Overriden methods will add their own
   # validators
   defined $self->{ARGS}->{validators} && do {
      $self->{ARGS}->{validators} = [ $self->{ARGS}->{validators} ]
            unless ref $self->{ARGS}->{validators} eq 'ARRAY';
      foreach my $v (@{$self->{ARGS}->{validators}}) {
         push @errors, $v->get_feedback
               unless $v->validate($vars->{$self->get_name});
      }
   };
   @errors;
}

sub type_data_transform {
   my ($self, $form_values) = @_;
   # No default transform
}

sub widget_data_transform {
   my ($self, $form_values) = @_;
   # No default transform
}




sub get_calc_html_attrs {
   my ($self, $args) = @_;
   # No default calculated attributes
   return ();
}

sub get_html_attrs {
   my ($self, $args, $value_html_attrs, $empty_html_attrs) = @_;
   $args             ||= $self->{ARGS};
   $value_html_attrs ||= $self->{VALUE_HTML_ATTRS};
   $empty_html_attrs ||= $self->{EMPTY_HTML_ATTRS};

   my %html_attrs = (name => $self->{NAME},
                     $self->get_calc_html_attrs($args));

   # Filter the calculated attribute list to build the final attribute string
   my @r = ();
   foreach my $attr (@$value_html_attrs) {
      if (exists $html_attrs{$attr} || defined $args->{$attr} ||
                                       defined $args->{"=$attr"}) {
         my $value = defined $args->{"=$attr"} ? $args->{"=$attr"} :
                                                 $html_attrs{$attr};
         $value .= ($args->{$attr} || "");      # add to attribute values
         push @r, "$attr=\"".$self->html_escape($value)."\"";
      }
   }
   foreach my $attr (@$empty_html_attrs) {
      if (exists $html_attrs{$attr} || $args->{$attr}) {
         push @r, $attr;
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
   $suffix = "" unless defined $suffix;

   my $value = $self->get_form_value($self->{NAME}.$suffix);
   return defined $value ? $value : $self->{ARGS}->{"value$suffix"};
}

sub get_form_value {
   my ($self, $varname) = @_;
   return $self->get_form->get_form_value($varname);
}

sub DESTROY {
   my $self = shift ;
}

1;
