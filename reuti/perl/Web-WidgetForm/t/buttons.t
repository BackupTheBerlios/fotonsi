#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;
use Test::Deep;

use Web::DJWidgets;

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'button' => { focus => 1,
                                  widget_type => 'Button',
                                  readonly => 1 },    # Should be ignored
                    'image'  => { widget_type => 'ImageButton',
                                  src => 'button.png' } });
my $btn = $f->get_widget_object('button');
my $img = $f->get_widget_object('image');

ok($f->prop('init') =~ /document.f.button.focus()/,     "focus");

# Attributes
my $expected_attrs = 'name="button" type="button"';
is($btn->get_html_attrs, $expected_attrs,               "get_html_attrs");


# Rendering
my $expected_rendering = '<input name="button" type="button">';
my $actual_rendering = $btn->render;
$actual_rendering =~ s/^\s+//o;
$actual_rendering =~ s/\s+$//o;
$actual_rendering =~ s/  +/ /o;
is($actual_rendering, $expected_rendering,              "render");

$expected_rendering = '<input name="image" type="image" src="button.png">';
$actual_rendering = $img->render;
$actual_rendering =~ s/^\s+//o;
$actual_rendering =~ s/\s+$//o;
$actual_rendering =~ s/  +/ /o;
is($actual_rendering, $expected_rendering,              " imagebutton");
