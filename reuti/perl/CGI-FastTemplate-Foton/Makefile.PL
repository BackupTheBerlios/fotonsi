use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'CGI::FastTemplate::Foton',
    'VERSION_FROM'	=> 'CGI/FastTemplate/Foton.pm', # finds $VERSION
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'CGI/FastTemplate/Foton.pm',
       AUTHOR     => 'Esteban Manchado <zoso@foton.es>, Javier Arbelo <jarbelo@foton.es>, Eduardo Navarro <eduardo@foton.es>') : ()),
);
