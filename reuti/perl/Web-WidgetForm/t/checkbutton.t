#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;
use Test::Deep;

use Web::DJWidgets;

my $one_value_msg = "Please select only one value";

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'comp' => { widget_type => 'CheckButton',
                                readonly => 1,
                                label => 'White label',
                                only_one_value_msg      => $one_value_msg } });
my $w = $f->get_widget_object('comp');


# Attributes
my $expected_attrs = 'name="comp" type="check" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");


# Validation
$f->define_form_values({ comp => [ 'several', 'options' ] });
cmp_deeply($f->validate_widget('comp'), [ $one_value_msg ],
                                                      " more than one value");


# Rendering
my $expected_rendering = '<input name="comp" type="check" readonly>White label';
my $actual_rendering = $f->srender_widget('comp');
$actual_rendering =~ s/^\s*//go;
$actual_rendering =~ s/\s*$//go;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            "render");

$expected_rendering = '<input name="comp" type="check" readonly checked>White label';
$actual_rendering = $f->srender_widget('comp', { selected => 1 });
$actual_rendering =~ s/^\s*//go;
$actual_rendering =~ s/\s*$//go;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            "render");
