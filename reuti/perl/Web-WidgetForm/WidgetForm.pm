package Web::WidgetForm;

use strict;

# $Id: WidgetForm.pm,v 1.4 2004/02/23 22:40:54 zoso Exp $

=head1 NAME

Web::WidgetForm - Web Component System

=head1 SYNOPSIS

 use Web::WidgetForm;

 $f = Web::WidgetForm->new($name, { class => 'f' });
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
 if ($f->validate_widget('textbox', $value)) { ... }
 # Only if define_form_values is called first
 if ($f->validate_widget('textbox')) { ... }

 $f->render_widget('textbox', $extra_args);
 print $f->srender_widget('textbox', $extra_args);

 # Usually only inside components
 $f->add_prop($property, $value);

 $value = $f->prop($property);

=head1 DESCRIPTION

Class C<Web::WidgetForm> represents a Web Component System form. By defining
the widgets inside the form, it allows you to validate them, print them out
and check the form properties collected over the widgets (usually Javascript
strings with checkings).

=head1 METHODS

=over 4

=item new($name, $args)

Returns a new form object with the given name and arguments.

=item define_widgets($widgets_hashref)

Defines the form widgets in a hash. The hash keys are the widget form names,
and the values are hashrefs with all the widget arguments.

Returns the number of processed widgets.

=item define_form_values($values_hashref)

Defines the received values for the widgets. The widgets then take the proper
value when rendering themselves. Defining the values this way also allows the
programmer to write filtering routines depending on the widget type.

=item get_widgets

Returns a reference to a list of defined widgets.

=item validate_form
=item validate_form($vars)

This method validates all the form widgets with the given hashref (or with the
registered values if none is given). Returns the list of widget names not
validated correctly, or C<0> if everything went fine.

=item validate_widget($widgetname)
=item validate_widget($widgetname, $value)

Validates the widget C<$widgetname> with the value C<$value> (or with the
registered value if only one argument is given). Returns C<1> if the widget
validated correctly, C<0> if not, and C<undef> if the widget is not defined.

=item render_widget($name, $extra_args)

Renders the given widget. If C<$extra_args> is defined, the extra arguments
hash reference is passed to the widget for that particular rendering.

=item srender_widget($name, $extra_args)

The same as above, but the rendered widget is returned instead of printed.

=item add_prop($prop, $value)

Adds the content C<$value> to the property C<$prop>, using a special
interpolation to reference other widgets safely.

=item prop($prop)

Returns the stored value for the given property C<$prop>.

=back

=head1 COPYRIGHT

This class is free. You can redistribute or modify it under the same terms as
Perl itself.

 Copyright 2002 Fotón Sistemas Inteligentes

=head1 AUTHORS

This class was written by Esteban Manchado Velázquez <zoso@foton.es>.

=cut

our $VERSION = '0.1';

sub new {
   my $proto = shift ;
   my $class = ref($proto) || $proto;
   my $name = shift || return undef;
   my $self  = { NAME => $name,
                 WIDGETS => {},
                 WIDGET_CLASSES => {},
                 PROPS => {},
                 CACHED_WIDGET_OBJECTS => {},
               };
   bless ($self, $class);
   return $self;
}

sub define_widgets {
   my ($self, $widgets) = @_;
   my $cnt = 0;
   foreach my $w (keys %$widgets) {
      $self->{WIDGETS}->{$w} = $widgets->{$w};
      my $object = $self->get_widget_object($w);
      if (defined $object) {
         $cnt++;
         my $class = $self->{WIDGETS}->{$w}->{widget_type};
         if (not defined $self->{WIDGET_CLASSES}->{$class}) {
            $self->{WIDGET_CLASSES}->{$class} = 1;
            $object->init;
         }
         $object->setup_form;
      } else {
         delete $widgets->{$w};
      }
   }
   $cnt;
}

sub define_form_values {
   my ($self, $values) = @_;
   $self->{VALUES} = { %$values };
}

sub get_form_value {
   my ($self, $name) = @_;
   return $self->{VALUES}->{$name};
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

   $self->{WIDGETS}->{$widgetname}->{widget_type} ||= "TextBox";
   my $class = $self->{WIDGETS}->{$widgetname}->{widget_type};
   eval "use Web::Widget::$class";
   if ($@) {
      print STDERR "Can't load Web Widget '$widgetname' (type '$class'): $@";
      return undef;
   }
   $self->{CACHED_WIDGET_OBJECTS}->{$widgetname} = eval "Web::Widget::$class->new(\$self, \$widgetname, \$self->{WIDGETS}->{\$widgetname})";
   if ($@) {
      print STDERR "Can't create widget of type '$class'\: $@";
      return undef;
   }
   $self->{CACHED_WIDGET_OBJECTS}->{$widgetname};
}

sub validate_form {
   my ($self, $vars) = @_;

   $vars = $self->{VALUES} if $#_ == 0;      # $vars not given
   return grep { ! $self->validate_widget($_, $vars->{$_}) } 
               keys %{$self->{WIDGETS}};
}

sub validate_widget {
   my ($self, $widget, $value) = @_;

   $value = $self->{VALUES}->{$widget} if $#_ == 1;   # $value not given
   return undef unless defined $self->{WIDGETS}->{$widget};
   return $self->get_widget_object($widget)->validate($value) ? 1 : 0;
}

sub render_widget {
   my ($self, $widget, $extra_args) = @_;
   return unless defined $self->{WIDGETS}->{$widget};
   print $self->srender_widget(@_);
}

sub srender_widget {
   my ($self, $widget, $extra_args) = @_;
   return undef unless exists $self->{WIDGETS}->{$widget};
   $self->render_widget($extra_args);
}

sub add_prop {
   my ($self, $prop, $value) = @_;

   $value =~ s/\%([a-z_][a-z0-9_]*)\%/document.$self->{NAME}.$1/gi;
   $self->{PROPS}->{$prop} .= $value;
}

sub prop {
   my ($self, $prop) = @_;
   $self->{PROPS}->{$prop};
}

sub DESTROY {
   my $self = shift ;
}

1;
