use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Web::WidgetForm',
    'VERSION_FROM'	=> 'WidgetForm.pm', # finds $VERSION
    'PMLIBDIRS'         => ['Widget', '.'],
    'ABSTRACT_FROM'     => 'WidgetForm.pm',
    'PREREQ_PM'         => { 'Test::Deep' => 0.082,
                             'Test::More' => 0.47,
                             'WWW::FieldValidator' => 1.06 },
    'AUTHOR'            => 'Esteban Manchado Velázquez <zoso@foton.es>'
);
