package Web::WidgetForm;

use strict;

# $Id: WidgetForm.pm,v 1.7 2004/04/14 11:48:18 zoso Exp $

=head1 NAME

Web::WidgetForm - Web Component System

=head1 SYNOPSIS

 use Web::WidgetForm;

 # Form creation
 $f = Web::WidgetForm->new($name, { class  => 'f',
                                    action => 'somepage.pl' });
 $f = Web::WidgetForm->new($name, { class  => 'f',
                                    action => 'somepage.pl' },
                                  { class    => 'widgetcommonclass',
                                    readonly => '1' });

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

=item new($name)
=item new($name, $args)
=item new($name, $args, $base_widget_args)

Returns a new form object with the given name and arguments. The optional
parameter C<$base_widget_args> stores the common widget arguments.

=item define_widgets($widgets_hashref)

Defines the form widgets in a hash. The hash keys are the widget form names,
and the values are hashrefs with all the widget arguments.

Returns the number of processed widgets.

=item define_form_values($values_hashref)

Defines the received values for the widgets. The widgets then take the proper
value when rendering themselves. It also calls
C<$widget-E<gt>type_data_transform> for every widget type loaded, and
C<$widget-E<gt>widget_data_transform> for every widget loaded.

=item get_form_value($name)

Returns the form value for the variable C<$name>.

=item get_form_values

Returns all the form values as a hash.

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

=item arg($name)
=item arg($name, $value)

Returns the value of the argument C<$name>. If C<$value> is given, it's first
assigned to the argument C<$name>.

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

   $self->{WIDGETS}->{$widgetname}->{widget_type} ||= "TextBox";
   my $class = $self->{WIDGETS}->{$widgetname}->{widget_type};
   my $total_class = "Web::Widget::$class";
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
   $self->get_widget_object($widget)->render($extra_args);
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

sub arg {
   my ($self, $name, $value) = @_;
   $self->{ARGUMENTS}->{$name} = $value if (scalar @_ > 2);
   $self->{ARGUMENTS}->{$name};
}

sub DESTROY {
   my $self = shift ;
}

1;
