#!/usr/bin/perl -w

use strict;
use Test::More tests => 6;
use Test::Deep;

use Web::WidgetForm;
use Web::Widget;

my $f = Web::WidgetForm->new('f');
$f->define_widgets({'comp' => { focus => 1,
                                class => 'foo',
                                widget_type => 'Hidden' } });
my $w = $f->get_widget_object('comp');

# Arguments
is($w->arg('class'), 'foo',                           "arg (get)");
ok(!defined $w->arg('disabled'),                      "arg (set)");
is($w->arg('disabled'), undef,                        " get set value");

# Convenience methods
my $a = { foo => 1, bar => 6 };
my $b = { foo => 8, qux => 9 };
my $c = { foo => 8, bar => 6, qux => 9 };
cmp_deeply($w->merge_args($a, $b), $c,              "merge_args");
my $expected_attrs = 'class="foo"';
my $expected_attrs2 = 'class="foo" id="fooid"';
is($w->get_html_attrs, $expected_attrs,             "get_html_attrs");
is($w->get_html_attrs({ class => 'foo', id => 'fooid', size => 4 }),
      $expected_attrs2,                             " extra_args");
