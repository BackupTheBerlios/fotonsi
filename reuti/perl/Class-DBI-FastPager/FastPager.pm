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

Class::DBI::FastPager - Fast pager for Class::DBI

=head1 SYNOPSIS

  package CD::Music;
  use Class::DBI::FastPager;

  package main;
  my @music = CD::Music->paged_search(
      artist => [ 'Ozzy', 'Kelly' ],
      status => { '!=', 'outdated' },
  );

  my @misc = CD::Music->paged_search(
      { artist => [ 'Ozzy', 'Kelly' ],
        status => { '!=', 'outdated' } },
      { order_by  => "reldate DESC" });

=head1 DESCRIPTION

Class::DBI::AbstractSearch is a Class::DBI plugin to glue
SQL::Abstract into Class::DBI.

=head1 METHODS

Using this module adds following methods into your data class.

=over 4

=item paged_search

  $class->paged_search(%where);

Takes a hash to specify WHERE clause. See L<SQL::Abstract> for hash
options.

  $class->paged_search(\%where,\%attrs);

Takes hash reference to specify WHERE clause. See L<SQL::Abstract>
for hash options. Takes a hash reference to specify additional query
attributes. Class::DBI::AbstractSearch uses these attributes:

=over 4

=item *

B<order_by>

Array reference of fields that will be used to order the results of
your query.

=back

Any other attributes are passed to the SQL::Abstract constructor,
and can be used to control how queries are created.  For example,
to use 'AND' instead of 'OR' by default, use:

    $class->paged_search(\%where, { logic => 'AND' });

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt> with some help from
cdbi-talk mailing list, especially:

  Tim Bunce
  Simon Wilcox
  Tony Bowden

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Class::DBI>, L<SQL::Abstract>

=cut
