package Class::DBI::FastPager;

use strict;
use vars qw($VERSION @EXPORT);
$VERSION = 0.01;

require Exporter;
*import = \&Exporter::import;
@EXPORT = qw(paged_search);

use SQL::Abstract;
use Data::Page;

sub paged_search {
    my $class = shift;
    my $where = (ref $_[0]) ? $_[0]          : { @_ };
    my $attr  = (ref $_[0]) ? $_[1]          : {};
    my $order = ($attr)     ? delete($attr->{order_by}) : undef;
    $where = { 1 => \" = 1" } unless %$where;

    # order is deprecated, but still backward compatible
    if ($attr && exists($attr->{order})) {
	$order = delete($attr->{order});
    }

    $class->can('retrieve_from_sql') or do {
	require Carp;
	Carp::croak("$class should inherit from Class::DBI >= 0.90");
    };
    my $sql = SQL::Abstract->new(%$attr);
    my($phrase, @bind) = $sql->where($where, $order);
    $phrase =~ s/^\s*WHERE\s*//oi;
    # pager info
    if (defined $attr->{nelems}) {
        my $phrase_without_order = $phrase;
        $phrase_without_order =~ s/\s*ORDER BY.*//oi;
        my $total_elems = $class->sql_SearchSQL('COUNT(*)', $class->table,
                                                $phrase_without_order)->select_val(@bind);
        my $page = Data::Page->new($total_elems,
                                   $attr->{nelems}, $attr->{page});
        my ($offset, $limit) = ($page->first - 1, $page->entries_per_page);
        $phrase .= " LIMIT $limit OFFSET $offset";
    }
    return $class->retrieve_from_sql($phrase, @bind);
}

1;

__END__

=head1 NAME

Class::DBI::FastPager - A fast pager for Class::DBI

=head1 SYNOPSIS

  package My::Class::ClassDBI;
  use Class::DBI::FastPager;
  # ...
  package main;
  # ...
  My::Class::ClassDBI->paged_search($params_where, $attrs);

=head1 DESCRIPTION

Class::DBI::FastPager is a plugin for Class::DBI, which glues Data::Page with Class::DBI in a more efficient way (we think so!). 
Other pagers retrieve all data and then returns the pages specified. This module makes paging at SQL level (with LIMIT and OFFSET), so retrieves "desired-data only" from database. 
Results: faster and more efficient search.


=head1 METHODS

Using this module adds following method into your data class.

=over 4

=item paged_search

  $class->paged_search(\%where,\%attrs);

Takes hash reference to specify WHERE (if ignored, retrieves all data) clause and another one to ATTRIBUTES. Attributes: page (itself) and nelems (number of elements per page).

=head1 AUTHOR

Esteban Manchado Velázquez (zoso@foton.es) and Ángel Zuate Suárez (angel@foton.es)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Class::DBI>, L<SQL::Abstract>. L<Class::DBI::Pager>

=cut
