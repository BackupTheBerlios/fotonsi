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
	$offset = 0 if $offset < 0;
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
  # ...
  package main;
  # ...
  # basic example
  my @music = CD::Music->paged_search(
      artist => [ 'Ozzy', 'Kelly' ],
      status => { '!=', 'outdated' },
  );
  # attributes example
  my @misc = CD::Music->paged_search(
      { artist => [ 'Ozzy', 'Kelly' ],
        status => { '!=', 'outdated' } },
      { order_by  => "reldate DESC" });
  # paging example (fourth page of 20-element pages)
  my @paged_misc = CD::Music->paged_search(
      { artist => [ 'Ozzy', 'Kelly' ],
        status => { '!=', 'outdated' } },
      { order_by  => "reldate DESC",
        page => 4, nelems => 20 });

=head1 DESCRIPTION

C<Class::DBI::FastPager> is a plugin for C<Class::DBI>, which glues
L<Data::Page> with C<Class::DBI> in a more efficient but less general way than
L<Class::DBI::Pager>.  The latter retrieve all data and then returns the
specified page, but works with any C<Class::DBI> plugin or method. This module
makes paging at SQL level (with LIMIT and OFFSET), so retrieves "desired-data
only" from database.  Results: faster and more efficient search, but only
with L<Class::DBI::AbstractSearch> style searches.


=head1 METHODS

Using this module adds following method into your data class.

=over 4

=item paged_search(%where)

=item paged_search(\%where, \%attrs)

Takes either a hash with the WHERE clause, or a hash reference to specify
WHERE clause (if empty, retrieves all data) and another one to ATTRIBUTES (see
L<SQL::Abstract> for hash options.)

Class::DBI::FastPager uses these attributes:

=over 4

=item *

B<order_by>

Array reference of fields that will be used to order the results of
your query.

=item *

B<page>

Page number to retrieve.

=item *

B<nelems>

Number of elements per page.

=back

Any other attributes are passed to the SQL::Abstract constructor,
and can be used to control how queries are created.  For example,
to use 'AND' instead of 'OR' by default, use:

    $class->paged_search(\%where, { logic => 'AND' });

=head1 AUTHORS

Esteban Manchado Velázquez E<lt>zoso@foton.esE<gt> and Ángel Zuate Suárez
E<lt>angel@foton.esE<gt>, based on L<Class::DBI::AbstractSearch>, by:

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt> with some help from
cdbi-talk mailing list, especially:

  Tim Bunce
  Simon Wilcox
  Tony Bowden

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Class::DBI>, L<SQL::Abstract>, L<Class::DBI::Pager>

=cut
