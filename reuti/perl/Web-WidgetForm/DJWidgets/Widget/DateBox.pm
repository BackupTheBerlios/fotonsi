package Web::DJWidgets::Widget::DateBox;

use strict;

use base qw(Web::DJWidgets::Widget::TextBox);

use POSIX;

sub new {
    my ($class, $form, $name, $args) = @_;

    $args->{value} = POSIX::strftime '%d/%m/%Y', localtime
            if $args->{value} eq 'NOW()';
    $args->{value} = $class->machine_date_to_human($args->{value})
            if $args->{value} =~ /-/;
    $class->SUPER::new($form, $name, $args);
}

sub init {
    my ($self, @args) = @_;

    $self->SUPER::init(@args);
    my $idioma = $self->arg('lang') || 'en';
    my $base_url = $self->arg('base_url_js') || $self->get_form->arg('base_url_js') ||'/js';
    $self->get_form->add_prop('header', <<"EOC");
      <link rel="stylesheet" type="text/css" media="all" href="$base_url/calendar-green.css"/>
      <script type="text/javascript" src="$base_url/calendario.js"></script>
      <script type="text/javascript" src="$base_url/calendar-$idioma.js"></script>
EOC
}

sub machine_date_to_human {
    $_[1] =~ /(....)-(..?)-(..?)/;
    "$3/$2/$1";
}

sub human_date_to_machine {
    $_[1] =~ m|(..?)/(..?)/(....)|;
    return undef unless $1;
    "$3-$2-$1";
}

sub widget_data_transform {
    my ($self, $form_values) = @_;
    my $name = $self->get_name . ($self->arg('suffix') || '');
    $form_values->{$name} = $self->human_date_to_machine($form_values->{$name});
}

sub validate {
    my ($self, $vars) = @_;

    $vars ||= $self->get_form->get_form_values;
    my @errors = $self->SUPER::validate($vars);
    my $value = $vars->{$self->get_name . ($self->arg('suffix') || '')};
    push @errors, $self->arg('incorrect_date_msg') || 'Incorrect date'
            unless $value =~ /\d{4}-\d\d?-\d\d?/;

    @errors;
}

sub datebox_id {
    "datebox_id_".$_[0]->get_name;
}

sub get_calc_html_attrs {
    my ($self, $args) = @_;
    return ($self->SUPER::get_calc_html_attrs($args),
            size => 10,
            maxlength => 10,
            id => $self->datebox_id);
}

sub render {
    my ($self, $extra_args) = @_;

    $self->SUPER::render($extra_args);
    my $args = $self->merge_args({ $self->get_args }, $extra_args);
    my $extra_attrs = $self->get_html_attrs;
    my $id = $self->datebox_id;

    return <<EOW;
    <input type="text" $extra_attrs/>
    <input type="button" value="..." onclick="return showCalendar('$id', '%d/%m/%Y');"/>
EOW
}

1;
