#!/usr/bin/perl -w

use strict;
use Test::More tests => 13;
use Test::Deep;

use Web::WidgetForm;
use WWW::FieldValidator;

my $v = WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL, 'Please make sure you enter a well formed email address');

my $f = Web::WidgetForm->new;
is ($f, undef,                                   "Form without name");

my $widget_list = { 'testwidget' => { widget_type => 'TextBox',
                                      focus => 1,
                                      nonempty => 1 },
                    't2'         => { validators => $v } };

# Data definition
$f = Web::WidgetForm->new('testform');
my $f2 = Web::WidgetForm->new('anotherone');
is ($f2->define_widgets({'t'  => { widget_type => 'NonExistent' },
                         'tt' => { nonempty => 0 } }), 1,
                                                 " wrong widget definition");
is ($f->define_widgets($widget_list), 2,         "define_widgets");
cmp_deeply($widget_list, $f->get_widgets,        "get_widgets");
$f->define_widget_values({ testwidget => 'a',
                           t2         => 'jander@mander.fander' });

# Properties
$f->add_prop('testprop', '%widgetname%.value = "foo"');
is ($f->prop('testprop'), 'document.testform.widgetname.value = "foo"',
                                                 "add_prop substitution");

# Validation
is ($f->validate_widget('testwidget', ''),  0,   "validate_widget (nonempty)");
is ($f->validate_widget('testwidget', ' '), 0,   " with a space");
is ($f->validate_widget('testwidget', 'a'), 1,   " with content");
is ($f->validate_widget('testwidget'), 1,        " with implicit content");
is ($f->validate_widget('t2', 'jander'),    0,   " with WWW::FieldValidator");
is ($f->validate_widget('t2', 'jander@'),   0,   "  another one");
is ($f->validate_widget('t2', 'jander@mander.com'), 1,
                                                 "  a valid one");
is ($f->validate_widget('t2'), 1,                "  an implicit valid one");
