#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;
use Test::Deep;

use Web::Widget;

my $w = Web::Widget->new(undef, 'comp', { focus => 1, class => 'foo' });

# Convenience methods
is($w->escape("'", "O'Reilly"), "O\\'Reilly",       "escape");
is($w->escape('"', '"Hi", she said'), '\\"Hi\\", she said',
                                                    " double quote");
is($w->escape("'", "Back\\slash"), "Back\\\\slash", " backslash");
my $a = { foo => 1, bar => 6 };
my $b = { foo => 8, qux => 9 };
my $c = { foo => 8, bar => 6, qux => 9 };
cmp_deeply($w->merge_args($a, $b), $c,                 "merge_args");
