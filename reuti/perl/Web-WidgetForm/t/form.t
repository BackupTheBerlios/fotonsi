#!/usr/bin/perl -w

use strict;
use Test::More tests => 42;
use Test::Deep;
use lib 't';

use Web::DJWidgets;
use WWW::FieldValidator;

my $validation_message = 'Please make sure you enter a well formed email address';
my $validation_message2 = 'Please make sure you enter *ander address';
my $v = WWW::FieldValidator->new(WWW::FieldValidator::WELL_FORMED_EMAIL,
                                 $validation_message);
my $regex_v = WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
                                       $validation_message2, 'ander');

my $f = Web::DJWidgets->new;
is ($f, undef,                                   "new - without name");

my $widget_list = { 'testwidget' => { widget_type => 'TextBox',
                                      focus => 1,
                                      nonempty => 1 },
                    't2'         => { validators => $v },
                    't3'         => { validators => [ $v, $regex_v ] },
                    'trans'      => { widget_type => 'Test' } };

# Data definition
$f = Web::DJWidgets->new('testform', { action => 'foo.pl' },
                                      { readonly => 1 });
my $f2 = Web::DJWidgets->new('anotherone');
eval { $f2->define_widgets({ 't'  => { widget_type => 'NonExistent' },
                             'tt' => { nonempty => 0 } }) };
ok ($@ ne "",                                    " non-existent widget type");

eval { $f2->define_widgets({ 'something' => 'bad attributes' }); };
ok ($@ ne "",                                    " wrong widget definition");

is ($f->get_name, 'testform',                    "get_name");
is ($f2->get_name, 'anotherone',                 " f2");
is ($f->define_widgets($widget_list), scalar keys %$widget_list,
                                                 "define_widgets");
cmp_deeply($widget_list, $f->get_widgets,        "get_widgets");
my $form_values = { testwidget => 'a',
                    t2         => 'jander@mander.fander',
                    t3         => 'jander@test.com' };
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
ok(scalar(grep { $_ eq 'readonly' }
               keys %{$f->get_widget_object('t2')->{ARGS}}),
                                                 "widget base args");

# Properties
$f->add_prop('testprop', '%widgetname%.value = "foo"');
is ($f->prop('testprop'), 'document.testform.widgetname.value = "foo"',
                                                 "add_prop substitution");
# By the "init" method in the Test widget
is ($f->prop('def'), "var foo = 'Some definition';",
                                                 " init method");

# Form values
is ($f->get_form_value('t2'), 'jander@mander.fander',
                                                 "get_form_value");
my %got_form_values = $f->get_form_values;
is ($got_form_values{'t2'}, 'jander@mander.fander',
                                                 "get_form_values");

# Validation
is (ref($f->validate_widget('testwidget', {testwidget => ''})), 'ARRAY',
                                                 "validate_widget (nonempty)");
is (ref($f->validate_widget('testwidget', {testwidget => ' '})), 'ARRAY',
                                                 " with a space");
is ($f->validate_widget('testwidget', {testwidget => 'a'}), 1,
                                                 " with content");
is ($f->validate_widget('testwidget'), 1,        " with implicit content");
is (ref($f->validate_widget('t2', {t2 => 'jander'})), 'ARRAY',
                                                 " with WWW::FieldValidator");
is (ref($f->validate_widget('t2', {t2 => 'jander@'})), 'ARRAY',
                                                 "  another one");
is ($f->validate_widget('t2', {t2 => 'jander@mander.com'}), 1,
                                                 "  a valid one");
is ($f->validate_widget('t2'), 1,                "  an implicit valid one");

is (scalar $f->validate_form, 0,                 "validate_form");
my %complete_validation = $f->validate_form({ t2 => 'notvalid@emailaddress',
                                              testwidget => '' });
is ($complete_validation{t2}->[0], $validation_message,
                                                 " not valid (t2)");
is ($complete_validation{t3}->[1], $validation_message2,
                                                 " not valid (t3)");


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
cmp_deeply([ split "&", $f->get_uri_enc_state({ thingy => '30' }) ],
           bag('t2=jander%40mander.fander', 'thingy=30'),
                                                 " with new state");


# Other methods
is($f->html_escape("O'Reilly"), "O&#39;Reilly",       "html_escape");
is($f->html_escape('"Hi", she said'), '&quot;Hi&quot;, she said',
                                                      " double quote");
is($f->html_escape("Back\\slash"), "Back\\slash",     " backslash");
eval { $f->define_widgets({ 'unknown_type' => { widget_type => 'NonExistent' } }); };
ok ($@ ne "",                                    " render nonexistent widget");
eval { is($f->srender_widget('unknown_type'), "",            "srender_widget/bad widget"); };
ok ($@ ne "",                                    " render nonexistent widget");
