use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Web-WidgetForm',
    'VERSION_FROM'	=> 'lib/WidgetForm.pm', # finds $VERSION
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/WidgetForm.pm',
       AUTHOR     => ' <zoso@foton.es>') : ()),
);
