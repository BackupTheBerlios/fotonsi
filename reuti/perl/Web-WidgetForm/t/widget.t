#!/usr/bin/perl -w

use strict;
use Test::More tests => 7;
use Test::Deep;

use lib 't';

use Web::WidgetForm;
use Web::Widget;

my $f = Web::WidgetForm->new('f');
$f->define_widgets({'comp' => { focus       => 1,
                                class       => 'foo',
                                widget_type => 'Hidden' },
                    'attrs_test' => { value       => 'mock',
                                      size        => 20,
                                      checked     => 'on',
                                      widget_type => 'Test' } });
my $w  = $f->get_widget_object('comp');
my $w2 = $f->get_widget_object('attrs_test');

# Arguments
is($w->arg('class'), 'foo',                           "arg (get)");
ok(!defined $w->arg('disabled'),                      "arg (set)");
is($w->arg('disabled'), undef,                        " get set value");

# Convenience methods
my $a = { foo => 1, bar => 6 };
my $b = { foo => 8, qux => 9 };
my $c = { foo => 8, bar => 6, qux => 9 };
cmp_deeply($w->merge_args($a, $b), $c,              "merge_args");
my $expected_attrs = 'name="comp" class="foo" type="hidden"';
my $expected_attrs2 = 'class="foo" id="fooid"';
is($w->get_html_attrs, $expected_attrs,             "get_html_attrs");
is($w->get_html_attrs({ class => 'foo', id => 'fooid', size => 4 }),
      $expected_attrs2,                             " extra_args");

my $expected_attrs3 = 'name="attrs_test" size="20" checked';
is($w2->get_html_attrs, $expected_attrs3,           " widget custom attrs");
