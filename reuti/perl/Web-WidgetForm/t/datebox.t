#!/usr/bin/perl -w

use strict;
use Test::More tests => 6;
use Test::Deep;

use Web::DJWidgets;

my $f = Web::DJWidgets->new('f');
$f->define_widgets({'comp' => { widget_type => 'DateBox',
                                value => 'somevalue', } });
my $w = $f->get_widget_object('comp');

ok($f->prop('header') =~ /calendar-/,                 "header");
ok($f->srender_widget('comp') =~ /showCalendar/,      "render");

# Conversion
my ($date_machine, $date_human) = ('2004-02-10', '10/02/2004');
is($date_machine, $w->human_date_to_machine($date_human),
                                                      "human_date_to_machine");
is($date_human, $w->machine_date_to_human($date_machine),
                                                      "machine_date_to_human");

# Data transform
$f->define_form_values({ comp => $date_human });
is($f->get_form_value('comp'), $date_machine,         "widget_data_transform");

# Validation
is($f->validate_form, 0,                              "validate");
