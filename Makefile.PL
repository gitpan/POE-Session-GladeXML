#!/usr/bin/perl

use ExtUtils::MakeMaker;

sub MY::postamble {
   package MY;
   "\npredist: all\n" .
   "\tcvs2cl\n" .
   "\t\$(MAKE) manifest\n" .
   "\t\$(MAKE) tardist\n"
}

WriteMakefile(
   MAKEFILE => 'Makefile',
   VERSION_FROM => 'lib/POE/Session/GladeXML.pm',
   NAME => 'POE::Session::GladeXML',
   PREREQ_PM => {
      'POE' => '0.23',
      'Gtk::GladeXML' => '0.7008',
   },
   dist => {
      COMPRESS     =>'gzip',
      SUFFIX       =>'gz',
      DIST_DEFAULT => 'predist',
   },
);
