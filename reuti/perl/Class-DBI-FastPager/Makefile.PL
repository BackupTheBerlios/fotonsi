use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Class::DBI::FastPager',
    'VERSION_FROM'	=> 'FastPager.pm', # finds $VERSION
    'PREREQ_PM'		=> {
                              'Data::Page' => 1.02,
                           },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'FastPager.pm',
       AUTHOR     => 'Esteban Manchado Velázquez <zoso@foton.es>') : ()),
);
