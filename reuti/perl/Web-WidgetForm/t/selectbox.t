#!/usr/bin/perl -w

use strict;
use Test::More tests => 12;
use Test::Deep;

use Web::DJWidgets;

my $nonempty_msg = "You can't leave the select box non-empty, dumbhead";

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'comp' => { focus => 1,
                                widget_type => 'SelectBox',
                                size     => 40,
                                readonly => 1,
                                nonempty => 1,
                                nonempty_msg => $nonempty_msg,
                                options  => [ one     => 'One',
                                              another => 'Another one',
                                              third   => 'Third eye',
                                              ''      => 'Empty' ] },
                    'sel_test' => { widget_type => 'SelectBox',
                                    options => [ first => 'First one',
                                                 sec   => 'Second',
                                                 last  => 'Last option' ],
                                    selected => [ 'first', 'last' ],
                                    min_selected_items => 1,
                                    min_selected_items_msg => 'min_items',
                                    max_selected_items => 2,
                                    max_selected_items_msg => 'max_items',
                                    incorrect_selection_msg => 'inc_sel' },
                    'sel_test_scalar' => { widget_type => 'SelectBox',
                                           options => [ one => 'One option',
                                                        other => 'Second' ],
                                           selected => 'other' } });
my $w = $f->get_widget_object('comp');


# Attributes
my $expected_attrs = 'name="comp" size="40" readonly';
is($w->get_html_attrs, $expected_attrs,               "get_html_attrs");


# Rendering
my $expected_rendering = '<select name="comp" size="40" readonly>
 <option value="one">One
<option value="another">Another one
<option value="third">Third eye
<option value="">Empty
 </select>';
my $actual_rendering = $f->srender_widget('comp');
$actual_rendering =~ s/^\s*//go;
$actual_rendering =~ s/\s*$//go;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            "render");

$expected_rendering = '<select name="sel_test">
 <option value="first" selected>First one
<option value="sec">Second
<option value="last" selected>Last option
 </select>';
$actual_rendering = $f->srender_widget('sel_test');
$actual_rendering =~ s/^\s*//go;
$actual_rendering =~ s/\s*$//go;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            " selected items");

$expected_rendering = '<select name="sel_test_scalar">
 <option value="one">One option
<option value="other" selected>Second
 </select>';
$actual_rendering = $f->srender_widget('sel_test_scalar');
$actual_rendering =~ s/^\s*//go;
$actual_rendering =~ s/\s*$//go;
$actual_rendering =~ s/  +/ /go;
is($actual_rendering, $expected_rendering,            " selected items (scalar)");


# Validation
$f->define_form_values({ comp => '' });
is($f->validate_widget('comp'), 1,                    "validate");
$f->define_form_values({ another_comp => '' });
my $error = $f->validate_widget('comp');
is(scalar @$error, 1,                                 " # errors");
is($error->[0], $nonempty_msg,                        " nonempty");
$f->define_form_values({ comp => ['', 'third'] });
is($f->validate_widget('comp'), 1,                    " several values");
# {min,max}_selected_items
$f->define_form_values({ sel_test => [ 'first' ] });
is($f->validate_widget('sel_test'), 1,                " # selected items");
$f->define_form_values({ some_comp => 'value' });
cmp_deeply($f->validate_widget('sel_test'), ['min_items'],
                                                      " min_selected_items");
$f->define_form_values({ sel_test => [ 'first', 'sec', 'last' ] });
cmp_deeply($f->validate_widget('sel_test'), ['max_items'],
                                                      " max_selected_items");
$f->define_form_values({ sel_test => 'doesntexist' });
cmp_deeply($f->validate_widget('sel_test'), ['inc_sel'],
                                                      " incorrect selection");
