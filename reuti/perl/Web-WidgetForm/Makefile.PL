use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Web::WidgetForm',
    'VERSION_FROM'	=> 'WidgetForm.pm', # finds $VERSION
    'PMLIBDIRS'         => ['Widget', '.'],
    'ABSTRACT_FROM'     => 'WidgetForm.pm',
    'AUTHOR'            => 'Esteban Manchado Velázquez <zoso@foton.es>'
);
