package Web::DJWidgets::Widget::RadioButton;

use strict;

use base qw(Web::DJWidgets::Widget::BaseInput);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{EMPTY_HTML_ATTRS}}, 'readonly';
   # Default value
   $self->arg('type', 'radio') unless defined $self->arg('type');
   return $self;
}

sub validate {
   my ($self, $vars) = @_;

   $vars ||= $self->get_form->get_form_values;
   my @errors = $self->SUPER::validate($vars);
   my $value = $vars->{$self->get_name};
   # It can only be one value
   if (ref $value) {
      push @errors, $self->arg('only_one_value_msg') || "Radio buttons can't have more than one value";
      return @errors;
   }

   # Correct selection
   my @option_list = @{$self->arg('options')};
   push @errors, $self->arg('incorrect_selection_msg') || "Incorrect selection"
         unless grep { $_ eq $value }
                     map { $option_list[$_] }
                         # foreach even index (0, 2, ...)
                         grep { $_ % 2 == 0 }
                              (0 .. $#option_list);

   @errors;
}

sub render {
   my ($self, $extra_args) = @_;

   $self->SUPER::render($extra_args);
   my $args = $self->merge_args({ $self->get_args }, $extra_args);
   my $extra_attrs = $self->get_html_attrs;
   my @option_list = @{$self->arg('options')};

   my @indexes = grep { $_ % 2 == 0 }        # foreach even index (0, 2, ...)
                      (0 .. $#option_list);
   if (defined $args->{only_render_option}) {
      # Print only the chosen one
      @indexes = grep { $option_list[$_] eq $args->{only_render_option} }
                      @indexes;
   }
   return join("\n", map { "<input $extra_attrs value=\"$option_list[$_]\"".
                              (defined $args->{selected} &&
                                 $option_list[$_] eq $args->{selected} ?
                                 " checked" : "").
                              ">".
                              $option_list[$_+1] }
                         @indexes);
}

1;
