#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;
use Test::Deep;

use Web::WidgetForm;

my $f = Web::WidgetForm->new('f');
$f->define_widgets({'comp' => { focus => 1,
                                class => 'foo',
                                widget_type => 'TextBox',
                                nonempty => 1,
                                value => 'somevalue',
                                maxlength => 40,
                                readonly => 1 } });
my $w = $f->get_widget_object('comp');

ok($f->prop('before_send') =~ /if \(document.f.comp.value.match\(\/\^ \*\$\/\)\) { alert\('Error: empty field. Please fill in.'\); document.f.comp.focus\(\); return false; };/,
                                                      "nonempty");
ok($f->prop('init') =~ /document.f.comp.focus()/,     "focus");
ok($f->srender_widget('comp') =~ /class="foo"/,       " render");

my $expected_attrs = 'name="comp" class="foo" type="text" value="somevalue" maxlength="40" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");
