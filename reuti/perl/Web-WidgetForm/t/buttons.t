#!/usr/bin/perl -w

use strict;
use Test::More tests => 6;
use Test::Deep;

use Web::DJWidgets;

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'button' => { focus => 1,
                                  widget_type => 'Button',
                                  value => 'Button',
                                  readonly => 1 },    # Should be ignored
                    'image'  => { widget_type => 'ImageButton',
                                  src => 'button.png' },
                    'submit' => { widget_type => 'FormButton',
                                  value => 'Submit' },
                    'reset'  => { widget_type => 'FormButton',
                                  value => 'Reset form',
                                  type => 'reset' } });
my $btn = $f->get_widget_object('button');
my $img = $f->get_widget_object('image');
my $submit = $f->get_widget_object('submit');
my $reset = $f->get_widget_object('reset');

ok($f->prop('init') =~ /document.f.button.focus()/,     "focus");

# Attributes
my $expected_attrs = 'name="button" type="button" value="Button"';
is($btn->get_html_attrs, $expected_attrs,               "get_html_attrs");


# Rendering
my $expected_rendering = '<input name="button" type="button" value="Button">';
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

$expected_rendering = '<input name="submit" type="submit" value="Submit">';
$actual_rendering = $submit->render;
$actual_rendering =~ s/^\s+//o;
$actual_rendering =~ s/\s+$//o;
$actual_rendering =~ s/  +/ /o;
is($actual_rendering, $expected_rendering,              " submit");

$expected_rendering = '<input name="reset" type="reset" value="Reset form">';
$actual_rendering = $reset->render;
$actual_rendering =~ s/^\s+//o;
$actual_rendering =~ s/\s+$//o;
$actual_rendering =~ s/  +/ /o;
is($actual_rendering, $expected_rendering,              " reset");
