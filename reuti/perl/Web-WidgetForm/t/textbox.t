#!/usr/bin/perl -w

use strict;
use Test::More tests => 5;
use Test::Deep;

use Web::WidgetForm;

my $f = Web::WidgetForm->new('f');
my $empty_msg = "You can't leave it empty, fuck!";
$f->define_widgets({'comp' => { focus => 1,
                                class => 'foo',
                                widget_type => 'TextBox',
                                nonempty => 1,
                                nonempty_msg => $empty_msg,
                                value => 'somevalue',
                                maxlength => 40,
                                readonly => 1 } });
my $w = $f->get_widget_object('comp');

ok($f->prop('before_send') =~ /if \(document.f.comp.value.match\(\/\^ \*\$\/\)\) { alert\('$empty_msg'\); document.f.comp.focus\(\); return false; };/,
                                                      "nonempty");
ok($f->prop('init') =~ /document.f.comp.focus()/,     "focus");
ok($f->srender_widget('comp') =~ /class="foo"/,       " render");

my $expected_attrs = 'name="comp" class="foo" type="text" value="somevalue" maxlength="40" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");

# Validation
$f->define_form_values({ comp => '' });
my %errors = $f->validate_form;
is($errors{comp}->[0], $empty_msg,                    "validation");
