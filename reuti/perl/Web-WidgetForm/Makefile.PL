use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Web::DJWidgets',
    'VERSION_FROM'	=> 'DJWidgets.pm', # finds $VERSION
    'PMLIBDIRS'         => ['Widget', '.'],
    'ABSTRACT_FROM'     => 'DJWidgets.pm',
    'PREREQ_PM'         => { 'Test::Deep' => 0.082,
                             'Test::More' => 0.47,
                             'WWW::FieldValidator' => 1.06 },
    'AUTHOR'            => 'Esteban Manchado Velázquez <zoso@foton.es>'
);
