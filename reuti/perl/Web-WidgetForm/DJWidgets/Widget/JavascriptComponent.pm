package Web::DJWidgets::Widget::JavascriptComponent;

use strict;

use base qw(Web::DJWidgets::Widget);

our @js_event_attrs = ('onfocus', 'onblur', 'onselect', 'onchange', 'onclick',
                       'ondblclick', 'onmousedown', 'onmouseup',
                       'onmouseover', 'onmousemove', 'onmouseout',
                       'onkeypress', 'onkeydown', 'onkeyup');

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{VALUE_HTML_ATTRS}}, @js_event_attrs;
   return $self;
}

sub setup_form {
   my ($self, @args) = @_;

   $self->SUPER::setup_form(@args);
   foreach my $attr (@js_event_attrs) {
      $self->{HTML_ATTRS}->{$attr} .= $self->{ARGS}->{$attr}
            if defined $self->{ARGS}->{$attr};
   }
}

1;
