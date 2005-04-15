package Web::DJWidgets::Widget::MultiColList;
use strict;

use base qw(Web::DJWidgets::Widget);

sub render {
    my ($self, $args) = @_;
    $args ||= { $self->get_args };

    my $cabecera = join("\n", map {
                                    if ($_->{html_title}) {
                                        "<td>$_->{html_title}</td>"
                                    }
                                    elsif ($_->{title_url} || $_->{title_js}) {
                                        my $url = $_->{title_url} || '#';
                                        "<td><a ".($_->{title_js} ? "onclick=\"$_->{title_js}\"" : "")." href=\"$url\">$_->{title}</a></td>"
                                    }
                                    else {
                                        "<td>$_->{title}</td>"
                                    }
                                  }
                                  @{$args->{'cols'}});

    my $data_row_attrs = $self->get_html_attrs($args->{'data_row_attrs'} || {},
                                               ['class']);

    my $datos = join("\n", map {
                                   my $row = $_;
                                   "<tr $data_row_attrs>\n".
                                   (join("\n",
                                         map {
                                             defined $_->{closure} ? "<td>".$_->{closure}->($row)."</td>" : "<td>$row->{$_->{key}}</td>"
                                         } @{$args->{'cols'}})).
                                   "\n</tr>"
                               }
                               @{$args->{'data'}});

    my $table_attrs = $self->get_html_attrs($args->{'table_attrs'} || {},
                                            ['class']);
    my $title_row_attrs = $self->get_html_attrs($args->{'title_row_attrs'} || {},
                                                ['class']);

    return <<EOW;
    <table $table_attrs>
        <tr $title_row_attrs>
            $cabecera
        </tr>
        $datos
    </table>
EOW
}

1;
