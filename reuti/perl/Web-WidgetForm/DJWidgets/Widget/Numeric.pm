package Web::DJWidgets::Widget::Numeric;

use strict;

use base qw(Web::DJWidgets::Widget::TextBox);

sub init {
    my ($self) = @_;

    $self->get_form->add_prop('header', <<'NSBB');
        <script>
            function djw_numeric_focus (target) {
                target.value = target.value.replace(/\./g, '');
            }

            function djw_numeric_blur (target) {
                var re = /(\d+)(,\d+)/;
                var m;
                if (m = re.exec(target.value)) {
                    i = m[1];
                    d = m[2];
                }
                else {
                    i = target.value;
                    d = ''
                }

                target.value = i.
                    split('').reverse().join('').
                    replace(/.{1,3}/g, function (n) { return '.' + n }).substr(1).
                    split('').reverse().join('') 
                    + d;
            }
        </script>
NSBB
}

sub get_html_attrs
{
    my ($self, $args) = @_;

    $args = { %$args };
    $args->{'value'} = $self->_fmt_mac_to_human($self->arg('value'));
    return $self->SUPER::get_html_attrs($args);;
}


sub setup_form {
    my ($self, @args) = @_;
 
    $self->SUPER::setup_form(@args);
    my ($form, $name, $args) = ($self->{FORM}, $self->{NAME}, $self->{ARGS});

    if (not defined $self->arg('invalid_number_msg')) {
        $self->arg('invalid_number_msg', "Invalid number.");
    }

    my $n = $self->get_html_name;
    my $m = $self->arg('invalid_number_msg');
    $self->get_form->add_prop('before_send', <<TAL);
        var djw_numeric_re_valid = /^[0-9.]+(,\\d+)?\$/;
        if (! djw_numeric_re_valid.exec($n.value)) {
            alert('$m: ' + $n.value);
            $n.focus();
            return false;
        }
TAL

    $self->arg('value', $args->{value});
}

sub widget_data_transform {
    my ($self, $form_values) = @_;
    my $name = $self->get_html_name;
    $form_values->{$name} = $self->_fmt_human_to_mac($form_values->{$name});
}

sub get_calc_html_attrs {
    my ($self, $args) = @_;
    return (
        ($self->SUPER::get_calc_html_attrs($args)),
        onblur => 'djw_numeric_blur(this)',
        onfocus => 'djw_numeric_focus(this)');
}

sub validate {
    my ($self, $vars) = @_;

    $vars ||= $self->get_form->get_form_values;
    my @errors = $self->SUPER::validate($vars);

    my $val = $vars->{$self->get_html_name};
    if (not ($val =~ /^\d+\.?\d*$/)) {
        push @errors, $self->arg('invalid_number_msg'),
    }
    return @errors;
}


sub _fmt_mac_to_human {
    my ($self, $val) = @_;
    my ($int, $dec);

    if ($val =~ /(\d+)\.(\d+)/) {
        $int = $1;
        $dec = ",$2";
    }
    else {
        $int = $val;
        $dec = "";
    }

    my $rev = join("", reverse(split //, $int));
    $rev =~ s/(.{1,3})/.$1/g; 
    return join("", reverse(split //, substr($rev,1))) . $dec;
}

sub _fmt_human_to_mac {
    my ($self, $n) = @_;
    $n =~ s/\.//g;
    $n =~ s/,/\./g;
    return $n;
}

1;
