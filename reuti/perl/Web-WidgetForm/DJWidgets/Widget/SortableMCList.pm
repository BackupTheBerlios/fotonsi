package Web::DJWidgets::Widget::SortableMCList;
use strict;

use base qw(Web::DJWidgets::Widget::MultiColList);

sub render {
    my ($self, $args) = @_;
    $args ||= { $self->get_args };

    my $sort_col = $self->_get_sort_col;
    my $sort_idx = ($sort_col < 0 ? -$sort_col : $sort_col)-1;
    ref $args->{'cols'} eq 'ARRAY' || die "No columns defined (incorrect 'cols' argument)";
    my $sort_key = $args->{'cols'}->[$sort_idx]->{key};
    my $name = $self->get_name;
    my ($asc_order_img, $desc_order_img) = ($args->{asc_order_img},
                                            $args->{desc_order_img});

    my @new_cols = @{$args->{cols}};
    my $form_name = $self->get_form->get_name;
    for (my $i = 0; $i <= $#new_cols; ++$i) {
        defined $new_cols[$i]->{html_title} ||
                defined $new_cols[$i]->{title} || die "No title for column ".($i+1);
        $new_cols[$i]->{html_title} ||= "<a href=\"#\" onclick=\"document.$form_name.$name\_sort.value = ".(($i+1) * ($i+1 == $sort_col ? -1 : 1))."; document.$form_name.submit(); return false\">$new_cols[$i]->{title} ".($sort_idx == $i && $asc_order_img ? "<img border=\"0\" ".($i+1 == $sort_col ? "alt=\"v\" src=\"$asc_order_img\"" : "alt=\"^\" src=\"$desc_order_img\"").">" : "")."</a>";
    }

    my $sort_sub = $sort_col > 0 ? sub { $a->{$sort_key} cmp $b->{$sort_key} } :
                                   sub { $b->{$sort_key} cmp $a->{$sort_key} };
    my @sorted_data = sort $sort_sub @{$args->{'data'}};
    $self->SUPER::render({ %$args, data => \@sorted_data,
                                   cols => \@new_cols }) . "<input type=\"hidden\" name=\"$name\_sort\" value=\"$sort_col\">"
}

sub _get_sort_col {
    my ($self) = @_;
    $self->get_value('_sort') || 1;
}

1;
