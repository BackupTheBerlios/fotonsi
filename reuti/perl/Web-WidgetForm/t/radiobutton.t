#!/usr/bin/perl -w

use strict;
use Test::More tests => 6;
use Test::Deep;

use Web::DJWidgets;

my $incorrect_sel_msg = "Incorrect selection, pal";
my $one_value_msg = "Please select only one value";

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'comp' => { widget_type => 'RadioButton',
                                readonly => 1,
                                incorrect_selection_msg => $incorrect_sel_msg,
                                only_one_value_msg      => $one_value_msg,
                                options  => [ one     => 'One',
                                              another => 'Another one',
                                              third   => 'Third eye',
                                              ''      => 'Empty' ] } });
my $w = $f->get_widget_object('comp');


# Attributes
my $expected_attrs = 'name="comp" type="radio" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");


# Validation
$f->define_form_values({ comp => 'new_option' });
cmp_deeply($f->validate_widget('comp'), [ $incorrect_sel_msg ],
                                                      "validation");
$f->define_form_values({ comp => [ 'several', 'options' ] });
cmp_deeply($f->validate_widget('comp'), [ $one_value_msg ],
                                                      " more than one value");


# Rendering
my $expected_rendering =
'<input name="comp" type="radio" readonly value="one">One
<input name="comp" type="radio" readonly value="another">Another one
<input name="comp" type="radio" readonly value="third">Third eye
<input name="comp" type="radio" readonly value="">Empty';
my $actual_rendering = $f->srender_widget('comp');
$actual_rendering =~ s/^\s*//go;
$actual_rendering =~ s/\s*$//go;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            "render");

$expected_rendering =
'<input name="comp" type="radio" readonly value="third">Third eye';
$actual_rendering = $f->srender_widget('comp',
                                       { only_render_option => 'third' });
is($actual_rendering, $expected_rendering,            "render");

# Don't confuse options and labels
$actual_rendering = $f->srender_widget('comp',
                                       { only_render_option => 'One' });
is($actual_rendering, '',                             "render");
