use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'CGI::FastTemplate::Foton',
    'VERSION_FROM'	=> 'Foton.pm', # finds $VERSION
    'DISTNAME'		=> 'CGI-FastTemplate-Foton',
    'PREREQ_PM'    => {
                             'CGI::FastTemplate' => '0.01' 
		      },
    'AUTHORS'		=> 'Esteban Manchado Velazquez <zoso@foton.es>, Javier Arbelo <jarbelo@foton.es>, Eduardo Navarro <eduardo@foton.es>',
);
