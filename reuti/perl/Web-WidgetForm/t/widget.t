#!/usr/bin/perl -w

use strict;
use Test::More tests => 13;
use Test::Deep;

use lib 't';

use Web::DJWidgets;
use Web::DJWidgets::Widget;

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'comp' => { focus       => 1,
                                class       => 'foo',
                                widget_type => 'Hidden' },
                    'attrs_test' => { value       => 'mock',
                                      value_child => 'mocking_child',
                                      size        => 20,
                                      checked     => 'on',
                                      suffix      => 'important',
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
my $expected_attrs  = 'name="comp" class="foo" type="hidden"';
my $expected_attrs2 = 'name="comp" class="foo" id="fooid"';
is($w->get_html_attrs, $expected_attrs,             "get_html_attrs");
is($w->get_html_attrs({ class => 'foo', id => 'fooid', size => 4 }),
      $expected_attrs2,                             " extra_args");

my $expected_attrs3 = 'name="attrs_test" size="20" onchange="document.f.attrs_test.value = &#39;&#39;; " checked';
is($w2->get_html_attrs, $expected_attrs3,           " widget custom attrs");


# Rendering
my $rendering = $w->render({ class => 'bar' });
my $expected_rendering = '<input name="comp" class="bar" type="hidden">';
$rendering =~ s/^\s*//go;
$rendering =~ s/\s*$//go;
is ($rendering, $expected_rendering,                " additional arguments");

$rendering = $w2->render({ '.onchange'   => "alert('I have changed!'); " });
$rendering =~ s/^\s*//go;
$rendering =~ s/\s*$//go;
$expected_rendering = '<input name="attrs_test" size="20" onchange="document.f.attrs_test.value = &#39;&#39;; alert(&#39;I have changed!&#39;); " checked>';
is ($rendering, $expected_rendering,                " add attributes");

# Values
is($w2->get_value, 'mock',                          "get_value");
is($w2->get_value('_child'), 'mocking_child',       " suffix");
$f->define_form_values({ attrs_test => 'real_mock',
                         attrs_test_child => 'real mocking child' });
is($w2->get_value, 'real_mock',                     " from form values");
is($w2->get_value('_child'), 'real mocking child',  " suffix/from form values");
