#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;
use Test::Deep;

use Web::DJWidgets;

my $f = Web::DJWidgets->new('f');
my $empty_msg = "You can't leave it empty, fuck!";
$f->define_widgets({'comp' => { focus => 1,
                                widget_type => 'FileBox',
                                nonempty => 1,
                                nonempty_msg => $empty_msg,
                                readonly => 1 } });
my $w = $f->get_widget_object('comp');

ok($f->prop('before_send') =~ /if \(document.f.comp.value.match\(\/\^ \*\$\/\)\) { alert\('$empty_msg'\); document.f.comp.focus\(\); return false; };/,
                                                      "nonempty");
ok($f->prop('init') =~ /document.f.comp.focus()/,     "focus");

my $expected_attrs = 'name="comp" type="file" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");

# Validation
$f->define_form_values({ comp => '' });
my %errors = $f->validate_form;
is($errors{comp}->[0], $empty_msg,                    "validation");
