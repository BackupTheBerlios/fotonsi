#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;
use Test::Deep;

use Web::DJWidgets;

my $f = Web::DJWidgets->new('f');
my $empty_msg = "You can't leave it empty, fuck!";
$f->define_widgets({'comp' => { class => 'foo',
                                widget_type => 'TextArea',
                                nonempty => 1,
                                nonempty_msg => $empty_msg,
                                value => 'somevalue',
                                maxlength => 40,   # Should be ignored
                                cols => 50,
                                rows => 7,
                                readonly => 1 } });
my $w = $f->get_widget_object('comp');

# Form properties
ok($f->prop('before_send') =~ /if \(document.f.comp.value.match\(\/\^ \*\$\/\)\) { alert\('$empty_msg'\); document.f.comp.focus\(\); return false; };/,
                                                      "nonempty");

# HTML attributes
my $expected_attrs = 'name="comp" class="foo" cols="50" rows="7" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");


# Rendering
my $expected_rendering = "<textarea $expected_attrs>somevalue</textarea>";
my $actual_rendering = $w->render;
$actual_rendering =~ s/^\s*//o;
$actual_rendering =~ s/\s*$//o;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            "render");


# Validation
$f->define_form_values({ comp => '' });
my %errors = $f->validate_form;
is($errors{comp}->[0], $empty_msg,                    "validation");
