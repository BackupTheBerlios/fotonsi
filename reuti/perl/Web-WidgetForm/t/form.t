#!/usr/bin/perl -w

use strict;
use Test::More tests => 32;
use Test::Deep;
use lib 't';

use Web::WidgetForm;
use WWW::FieldValidator;

my $v = WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL, 'Please make sure you enter a well formed email address');

my $f = Web::WidgetForm->new;
is ($f, undef,                                   "Form without name");

my $widget_list = { 'testwidget' => { widget_type => 'TextBox',
                                      focus => 1,
                                      nonempty => 1 },
                    't2'         => { validators => $v },
                    'trans'      => { widget_type => 'Test' } };

# Data definition
$f = Web::WidgetForm->new('testform', { action => 'foo.pl' },
                                      { readonly => 1 });
my $f2 = Web::WidgetForm->new('anotherone');
is ($f2->define_widgets({'t'  => { widget_type => 'NonExistent' },
                         'tt' => { nonempty => 0 } }), 1,
                                                 " wrong widget definition");
is ($f->define_widgets($widget_list), scalar keys %$widget_list,
                                                 "define_widgets");
cmp_deeply($widget_list, $f->get_widgets,        "get_widgets");
my $form_values = { testwidget => 'a',
                    t2         => 'jander@mander.fander' };
$f->define_form_values($form_values);

# Data transform
is ($f->get_form_value('type_Test'), 1,          "type_data_transform");
is ($f->get_form_value('widget_trans'), 'Test::trans',
                                                 "widget_data_transform");

# Form arguments
is ($f->arg('action'), 'foo.pl',                 "argument (get)");
is ($f->arg('class', 'bar'), 'bar',              "argument (set)");
is ($f->arg('class'), 'bar',                     " get the set value");

# Base widget arguments
ok(grep { $_ eq 'readonly' } keys %{$f->get_widget_object('t2')->{ARGS}},
                                                 "widget base args");

# Properties
$f->add_prop('testprop', '%widgetname%.value = "foo"');
is ($f->prop('testprop'), 'document.testform.widgetname.value = "foo"',
                                                 "add_prop substitution");

# Form values
is ($f->get_form_value('t2'), 'jander@mander.fander',
                                                 "get_form_value");
my %got_form_values = $f->get_form_values;
is ($got_form_values{'t2'}, 'jander@mander.fander',
                                                 "get_form_values");

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


# State variables
is (scalar $f->get_state_variables, 0,           "initial state variables");
$f->register_state_variable('thingy');
cmp_deeply([ $f->get_state_variables ], bag('thingy'),
                                                 "register_state_variable");
$f->register_state_variable('thingy');
cmp_deeply([ $f->get_state_variables ], bag('thingy'),
                                                 " repeated variables");
$f->register_state_variable('another_thingy');
cmp_deeply([ $f->get_state_variables ], bag('another_thingy', 'thingy'),
                                                 " another variable");
$f->unregister_state_variable('another_thingy');
cmp_deeply([ $f->get_state_variables ], bag('thingy'),
                                                 "unregister_state_variable");
$f->unregister_state_variable('another_thingy');
cmp_deeply([ $f->get_state_variables ], bag('thingy'),
                                                 " unexistent");

$f->register_state_variable('t2');
cmp_deeply({ $f->get_state }, { t2     => 'jander@mander.fander',
                                thingy => undef },
                                                 "get_state");
cmp_deeply([ split "&", $f->get_uri_enc_state ],
           bag('t2=jander%40mander.fander', 'thingy='),
                                                 "get_uri_enc_state");


# Other methods
is($f->html_escape("O'Reilly"), "O&#39;Reilly",       "html_escape");
is($f->html_escape('"Hi", she said'), '&quot;Hi&quot;, she said',
                                                      " double quote");
is($f->html_escape("Back\\slash"), "Back\\slash",     " backslash");
