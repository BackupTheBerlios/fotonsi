package Web::DJWidgets;

use strict;

# $Id: DJWidgets.pm,v 1.15 2005/03/08 20:32:14 zoso Exp $

=head1 NAME

Web::DJWidgets - Web Component System

=head1 SYNOPSIS

 use Web::DJWidgets;

 # Form creation
 $f = Web::DJWidgets->new($name, { class  => 'f',
                                   action => 'somepage.pl' });
 $f = Web::DJWidgets->new($name, { class  => 'f',
                                   action => 'somepage.pl' },
                                 { class    => 'widgetcommonclass',
                                   readonly => '1' });
 $form_name = $f->get_name;

 $f->define_widgets({ 'textbox' => { widget_type => 'TextBox',
                                     focus => 1,
                                     length => 10 } });
 $list = $f->get_widgets;

 # CGI style
 $f->define_form_values({ $cgi->Vars });
 if ($f->validate_form({ $cgi->Vars }) == 0) { ... }
 # Mason style
 $f->define_form_values(\%ARGS);
 if ($f->validate_form(\%ARGS) == 0) { ... }

 # Both styles, if define_form_values is used first
 if ($f->validate_form == 0) { ... }
 # Or.... one by one
 if ($f->validate_widget('textbox', $vars)) { ... }
 # Only if define_form_values is called first
 if ($f->validate_widget('textbox')) { ... }

 %args = $f->get_form_values;       # Already transformed by the widgets
 $arg  = $f->get_form_value('some_var');

 $f->render_widget('textbox', $extra_args);
 print $f->srender_widget('textbox', $extra_args);

 $value = $f->prop($property);
 $value = $f->arg($argument);
 $value = $f->arg($argument, $new_value);

 $f->redirect($url);

Usually only inside components

 $f->add_prop($property, $value);      # Performs special translations

 $f->register_state_variable('current_folder');
 $f->unregister_state_variable('current_folder');

 @varnames = $f->get_state_variables;  # Only names
 %state = $f->get_state;               # Names & values
 $url_chunk = $f->get_uri_enc_state;
 $url_chunk = $f->get_uri_enc_state(variable => 'new value', othervar => 25);

 # Returns "document.my_form_name.some_widget_name"
 $f->get_js_name('some_widget_name');

=head1 DESCRIPTION

Class C<Web::DJWidgets> represents a Web Component System form. By defining
the widgets inside the form, it allows you to validate them, print them out
and check the form properties collected over the widgets (usually Javascript
strings with checkings).

=head1 METHODS

=over 4

=item new($name)

=item new($name, $args)

=item new($name, $args, $base_widget_args)

Returns a new form object with the given name and arguments. The optional
parameter C<$base_widget_args> stores the common widget arguments.

=item get_name

Returns the form name.

=item define_widgets($widgets_hashref)

Defines the form widgets in a hash. The hash keys are the widget form names,
and the values are hashrefs with all the widget arguments.

It calls the C<init> method once for each widget class it encounters, and
C<setup_form> for every widget. It also calls
C<$widget-E<gt>type_data_transform> for every widget type loaded, and
C<$widget-E<gt>widget_data_transform> for every widget, in case you define
first the form values (see below).

Returns the number of processed widgets, or raises an exception if there was
an error.

=item define_form_values($values_hashref)

Defines the received values for the widgets. The widgets then take the proper
value when rendering themselves. It also calls
C<$widget-E<gt>type_data_transform> for every widget type loaded, and
C<$widget-E<gt>widget_data_transform> for every widget loaded, just in case
you defined your widgets before the form values.

=item get_form_value($name)

Returns the form value for the variable C<$name>.

=item get_form_values

Returns all the form values as a hash.

=item get_widgets

Returns a reference to a hash of defined widgets. The structure is the same as
in C<define_widgets>.

=item render_widget($name, $extra_args)

Renders the given widget. If C<$extra_args> is defined, the extra arguments
hash reference is passed to the widget for that particular rendering.

=item srender_widget($name, $extra_args)

The same as above, but the rendered widget is returned instead of printed.

=item arg($name)

=item arg($name, $value)

Returns the value of the argument C<$name>. If C<$value> is given, it's first
assigned to the argument C<$name>.

=item html_escape($value)

Escapes the given characters according to the section "3.2.2 Attributes" of
the HTML 4 Specification. It's useful for pasting values in HTML, like tag
attributes enclosed in quotes.

=item redirect($url)

Redirects to the given URL. It takes into account state variables (see below).
Only works in HTML mode, that is, you can't change the MIME type or output
garbage before calling this method. If you need to, you'll have to roll your
own redirection with your own state variable handling.

=back


=head1 VALIDATION METHODS

Each widget defines its own server validation code so all data is safe. You
can validate the entire form (returning the list of widget names not
validating correctly) or a given widget.

=over 4

=item validate_form

=item validate_form($vars)

This method validates all the form widgets with the given hashref (or with the
registered values if none is given). Returns a hash of widget names not
validated correctly (the values are the error messages array ref), or C<0>
(empty hash) if everything went fine.

=item validate_widget($widgetname)

=item validate_widget($widgetname, $vars)

Validates the widget C<$widgetname> with the form values C<$vars> (or with the
registered values if only one argument is given). Returns an array reference
containing the list of validation errors, if the widget didn't validate
correctly, C<1> if everything went fine, and C<-1> if the widget is not
defined.

=back


=head1 PROPERTIES METHODS

Properties are special buffers where values are stored. These values are
usually Javascript content, compiled from every form widget. The most common
use is storing Javascript code to initialize the form, check the form before
submitting, etc.

=over 4

=item add_prop($prop, $value)

Adds the content C<$value> to the property C<$prop>, using a special
interpolation to reference other widgets safely.

The problem with Javascript is that you can't write generic code easily,
because you must know the name of the form the <input> is in. So, a special
substitution on C<$value> is done, so that you can refer to the HTML control
C<foo> with C<%foo%>. That will translate as
C<document.E<lt>I<formname>E<gt>.foo>.

=item prop($prop)

Returns the stored value for the given property C<$prop>.

=back


=head1 STATE VARIABLES METHODS

State variables are form variables that "define" in some way the form state,
e.g.: a variable storing the current filter in a search, or the current
directory or ordering in a web-based file manager. It's useful telling the
form which ones are state variables because that way the form can perform
redirections without losing the state values (and other widgets know them too,
so they can also perform redirections without losing important information).

=over 4

=item register_state_variable($varname)

=item unregister_state_variable($varname)

Register and unregister state variables. State variables are only counted
once, so if you try to register one of them more than once, the second try is
ignored.

=item get_state_variables

Returns the list of state variable names.

=item get_state

Returns a hash with the state variable names and values.

=item get_uri_enc_state

=item get_uri_enc_state($new_state_values)

Returns a URI encoded string with the state information. If the hashref
C<$new_state_values> is given, the new values take precedence, and the result
is the URI-encoded I<new> state.

=back


=head1 MISC METHODS

=over 4

=item get_js_name($widget_name)

Returns the "Javascript name" to access the given widget, that is,
C<document.E<lt>formnameE<gt>.E<lt>widgetnameE<gt>>.

=back

=head1 COPYRIGHT

This class is free. You can redistribute or modify it under the same terms as
Perl itself.

 Copyright 2004 Fotón Sistemas Inteligentes

=head1 AUTHORS

This class was written by Esteban Manchado Velázquez <zoso@foton.es>.

=cut

use URI::Escape;

our $VERSION = '0.1';

sub new {
   my $proto = shift ;
   my $class = ref($proto) || $proto;
   my $name             = shift || return undef;
   my $args             = shift || {};
   my $base_widget_args = shift || {};
   my $self  = { NAME => $name,
                 WIDGETS => {},
                 WIDGET_CLASSES => {},
                 PROPS => {},
                 CACHED_WIDGET_OBJECTS => {},
                 ARGUMENTS => $args,
                 BASE_WIDGET_ARGS => $base_widget_args,
                 STATE_VARS => [],
               };
   bless ($self, $class);
   return $self;
}

sub get_name {
   my ($self) = @_;
   return $self->{NAME};
}

sub define_widgets {
   my ($self, $widgets) = @_;
   my $cnt = 0;
   foreach my $w (keys %$widgets) {
      ref $widgets->{$w} eq 'HASH' || die "Attributes for widget '$w' is not a hashref";
      $self->{WIDGETS}->{$w} = $widgets->{$w};
      my $object = $self->get_widget_object($w);
      defined $object || do {
          delete $self->{WIDGETS}->{$w};    # Delete, just in case
          die "Can't define widget '$w' (is widget type '$widgets->{$w}->{widget_type}' defined?)";
      };
      my $class = $object->arg('widget_type');
      if (not defined $self->{WIDGET_CLASSES}->{$class}) {
         $self->{WIDGET_CLASSES}->{$class} = 1;
         $object->init;
         $object->type_data_transform($self->{VALUES});
      }
      $object->setup_form;
      $object->widget_data_transform($self->{VALUES});
      $cnt++;
   }
   $cnt;
}

sub define_form_values {
   my ($self, $values) = @_;
   $self->{VALUES} = { %$values };

   # And now, call type_data_transform once for every widget type,
   # widget_data_transform for every widget
   my %widget_class = ();
   foreach my $name (keys %{$self->{WIDGETS}}) {
      my $w = $self->get_widget_object($name);
      if (!exists $widget_class{$w->arg('widget_type')}) {
         $w->type_data_transform($self->{VALUES});
         $widget_class{$w->arg('widget_type')} = 1;
      }
      $w->widget_data_transform($self->{VALUES});
   }
}

sub get_form_value {
   my ($self, $name) = @_;
   return $self->{VALUES}->{$name};
}

sub get_form_values {
   my ($self) = @_;
   return %{$self->{VALUES}};
}

sub get_widgets {
   my ($self) = @_;
   return { %{$self->{WIDGETS}} };
}

sub get_widget_object {
   my ($self, $widgetname) = @_;

   # Cached object
   return $self->{CACHED_WIDGET_OBJECTS}->{$widgetname}
         if defined $self->{CACHED_WIDGET_OBJECTS}->{$widgetname};
   return undef
         if !defined $self->{WIDGETS}->{$widgetname};

   $self->{WIDGETS}->{$widgetname}->{widget_type} ||= "TextBox";
   my $class = $self->{WIDGETS}->{$widgetname}->{widget_type};
   my $total_class = "Web::DJWidgets::Widget::$class";
   eval "use $total_class";
   if ($@) {
      print STDERR "Can't load Web Widget '$widgetname' (type '$class'): $@";
      return undef;
   }
   $self->{CACHED_WIDGET_OBJECTS}->{$widgetname} = $total_class->new($self, $widgetname, { %{$self->{BASE_WIDGET_ARGS}}, %{$self->{WIDGETS}->{$widgetname}} });
   if ($@) {
      print STDERR "Can't create widget of type '$class'\: $@";
      return undef;
   }
   $self->{CACHED_WIDGET_OBJECTS}->{$widgetname};
}

sub render_widget {
   my ($self, $widget, $extra_args) = @_;
   print srender_widget(@_);
}

sub srender_widget {
   my ($self, $widget, $extra_args) = @_;
   my $w = $self->get_widget_object($widget);
   defined $w || do {
      my $msg = "srender_widget: Can't find widget '$widget'. Defined widgets are: ".join(", ", map { "'$_'" } keys %{$self->{WIDGETS}});
      print STDERR $msg;
      die $msg;
   };
   $w->render($extra_args);
}

sub arg {
   my ($self, $name, $value) = @_;
   $self->{ARGUMENTS}->{$name} = $value if (scalar @_ > 2);
   $self->{ARGUMENTS}->{$name};
}

sub html_escape {
   my ($self, $value) = @_;
   $value = "" unless defined $value;
   $value =~ s/&/&amp;/go;
   $value =~ s/"/&quot;/go;
   $value =~ s/'/&#39;/go;
   return $value;
}

sub redirect {
   my ($self, $url) = @_;

   print qq(<form name="webwidgetsredirectform" method="post" action="$url">\n);
   foreach my $var ($self->get_state_variables) {
      print qq(<input type="hidden" name="$var" value=").$self->html_escape($self->{VALUES}->{$var}).qq(">\n);
   }
   print <<EOFORM;
   <script>
      document.webwidgetsredirectform.submit();
   </script>
   <noscript>
      <input type="submit" name="button" value="Click here">
   </noscript>
</form>
EOFORM
   1;
}


## VALIDATION METHODS

sub validate_form {
   my ($self, $vars) = @_;

   $vars ||= $self->{VALUES};
   my %errors = ();
   foreach my $w (keys %{$self->{WIDGETS}}) {
      my $result = $self->validate_widget($w, $vars);
      if (ref($result) eq 'ARRAY') {
         $errors{$w} = $result;
      } elsif ($result == -1) {
         $errors{$w} = [ 'Internal error: non-existent widget' ];
      } elsif ($result != 1) {
         $errors{$w} = [ "Internal error: widget validation returned $result" ];
      }
   }
   %errors;
}

sub validate_widget {
   my ($self, $widget, $vars) = @_;

   $vars ||= $self->{VALUES};
   return -1 unless defined $self->{WIDGETS}->{$widget};
   my @errors = $self->get_widget_object($widget)->validate($vars);
   return scalar @errors ? [ @errors ] : 1;
}


## PROPERTIES METHODS

sub add_prop {
   my ($self, $prop, $value) = @_;

   $value =~ s/\%([a-z_][a-z0-9_]*)\%/$self->get_js_name($1)/gie;
   $self->{PROPS}->{$prop} .= $value;
}

sub prop {
   my ($self, $prop) = @_;
   $self->{PROPS}->{$prop};
}


## STATE VARIABLES METHODS

sub register_state_variable {
   my ($self, $varname) = @_;
   push @{$self->{STATE_VARS}}, $varname
         unless grep { $_ eq $varname } @{$self->{STATE_VARS}};
}

sub unregister_state_variable {
   my ($self, $varname) = @_;
   $self->{STATE_VARS} = [ grep { $_ ne $varname }
                                @{$self->{STATE_VARS}} ];
}

sub get_state_variables {
   my ($self) = @_;
   return @{$self->{STATE_VARS}};
}

sub get_state {
   my ($self) = @_;
   return map { ($_, $self->{VALUES}->{$_}) } @{$self->{STATE_VARS}};
}

sub get_uri_enc_state {
   my ($self, $new_state) = @_;
   $new_state = { %{$self->{VALUES}}, %{$new_state || {}} };
   return join("&", map { $_ . "=" . uri_escape($new_state->{$_} || "") }
                        @{$self->{STATE_VARS}});
}


## MISC METHODS

sub get_js_name {
   my ($self, $widget_name) = @_;
   my $w = $self->get_widget_object($widget_name);
   $widget_name = $w->get_html_name if defined $w;
   return "document.$self->{NAME}.$widget_name";
}


sub DESTROY {
   my $self = shift ;
}

1;
