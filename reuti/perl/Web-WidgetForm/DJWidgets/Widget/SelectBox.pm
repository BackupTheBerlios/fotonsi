package Web::DJWidgets::Widget::SelectBox;

use strict;

use base qw(Web::DJWidgets::Widget::JavascriptComponent);

sub new {
   my ($class, @args) = @_;

   my $self = $class->SUPER::new(@args);
   push @{$self->{VALUE_HTML_ATTRS}}, 'size', 'tabindex', 'accesskey';
   push @{$self->{EMPTY_HTML_ATTRS}}, 'multiple', 'readonly';
   $self->{ARGS}->{options}  ||= [];
   $self->{ARGS}->{selected} ||= [];
   $self->{ARGS}->{selected} = [ $self->{ARGS}->{selected} ]
         unless ref $self->{ARGS}->{selected};
   return $self;
}

sub setup_form {
   my ($self, @args) = @_;

   $self->SUPER::setup_form(@args);
   my ($form, $name, $args) =
      ($self->get_form, $self->get_name, { $self->get_args });

   $args->{focus} && $form->add_prop('init', "\%$name\%.focus();");
   # Compute numbers of selected items if needed (store in
   # selectbox_NAME_items)
   if ($args->{nonempty} || $args->{min_selected_items} ||
       $args->{max_selected_items}) {
       $form->add_prop('before_send', "var selectbox_$name\_items = 0; for (i = 0; i < \%$name\%.options.length; ++i) { if (\%$name\%.options[i].selected) { selectbox_$name\_items++ } } ");
   }
   # No selected items
   if ($args->{nonempty}) {
      $self->arg('nonempty_msg', "Please select at least one value.")
            unless defined $self->arg('nonempty_msg');
      $self->arg('min_selected_items_msg', $self->arg('nonempty_msg'));
      $self->arg('min_selected_items', 1);
      $args->{min_selected_items} = 1;
   }
   # Mininum selected items
   if ($args->{min_selected_items}) {
      $self->arg('min_selected_items_msg', "Please select at least ".$args->{min_selected_items}." item(s)")
            unless defined $self->arg('min_selected_items_msg');
      $form->add_prop('before_send', "if (selectbox_$name\_items < $args->{min_selected_items}) { alert('".$self->html_escape($self->arg('min_selected_items_msg'))."'); return false } ");
   }
   # Maximum selected items
   if ($args->{max_selected_items}) {
      $self->arg('max_selected_items_msg', "Please select at most $args->{max_selected_items} item(s)")
            unless defined $args->{max_selected_items_msg};
      $form->add_prop('before_send', "if (selectbox_$name\_items > $args->{max_selected_items}) { alert('".$self->html_escape($self->arg('max_selected_items_msg'))."'); return false } ");
   }
}

sub validate {
   my ($self, $vars) = @_;

   $vars ||= $self->get_form->get_form_values;
   my @errors = $self->SUPER::validate($vars);
   # Calculate widget values
   my @values = ();
   my $value = $vars->{$self->get_name};
   if (ref $value) {
      @values = @$value;
   } elsif (defined $value) {
      @values = ($value);
   }

   # Number of selected items
   push @errors, $self->arg('min_selected_items_msg')
         if defined $self->arg('min_selected_items') &&
            scalar @values < $self->arg('min_selected_items');
   push @errors, $self->arg('max_selected_items_msg')
         if defined $self->arg('max_selected_items') &&
            scalar @values > $self->arg('max_selected_items');
   # Correct selection
   foreach my $v (@values) {
      my @option_list = @{$self->arg('options')  || []};
      push @errors, $self->arg('incorrect_selection_msg') ||
                    "Incorrect selection"
            unless scalar grep { $_ eq $v }
                               map { $option_list[$_] }
                                   # foreach even index (0, 2, ...)
                                   grep { $_ % 2 == 0 }
                                        (0 .. $#option_list);
   }
   @errors;
}

sub render {
   my ($self, $extra_args) = @_;

   $self->SUPER::render($extra_args);
   my $args = $self->merge_args({ $self->get_args }, $extra_args);
   my $extra_attrs = $self->get_html_attrs($args);
   # A kind of ordered hash
   my @option_list = @{$self->arg('options')  || []};
   my @selected    = @{$self->arg('selected') || []};
   my $options     = join("\n", map { my $i = $_;
                                      "<option value=\"$option_list[$_]\"".
                                         ((grep { $_ eq $option_list[$i] }
                                                @selected)
                                          ? " selected" : "").
                                         ">".
                                         $option_list[$_+1] }
                                    # foreach even index (0, 2, ...)
                                    grep { $_ % 2 == 0 }
                                         (0 .. $#option_list));
   return <<EOWIDGET;
   <select $extra_attrs>
     $options
   </select>
EOWIDGET
}

1;

__END__

=head1 NAME

Web::DJWidgets::Widget::SelectBox - Simple select widget

=head1 SYNOPSIS

 use Web::DJWidgets;

 # Form creation
 $f = Web::DJWidgets->new($name);

 $f->define_widgets({ 'test' => { widget_type => 'SelectBox',
                                  focus => 1,
                                  length => 10,
                                  options => [ 'pepito' => 'palotes',
                                               'ovalue' => 'Other value',
                                               ''       => 'Nothing' ],
                                  selected => [ 'ovalue', '' ] } });

=head1 DESCRIPTION

C<SelectBox> is a simple widget for item selection. It uses internally a
E<lt>selectE<gt> tag.

It uses the HTML attributes C<size>, C<multiple>, C<tabindex>, C<accesskey>
and C<readonly>, plus those of the Javascript-based components
(see L<Web::DJWidgets::Widget::JavascriptComponent>).

=head1 SPECIAL ARGUMENTS

=over 4

=item focus

Makes the widget the focused one when loading the page.

=item nonempty

Forces the widget value not to be empty.

=item nonempty_msg

Error message when the widget is not empty.

=item options

The option list. Note that it B<must> be an I<array> reference to keep
ordering. You can use the C<< => >> operator for readability, as in the
synopsis example.

=item selected

The list of the selected options by default. It's a list of the values of the
options (see synopsis example).

=back

=head1 COPYRIGHT

This class is free. You can redistribute or modify it under the same terms as
Perl itself.

 Copyright 2004 Fotón Sistemas Inteligentes

=head1 AUTHORS

This class was written by Esteban Manchado Velázquez <zoso@foton.es>.
