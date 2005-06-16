#!/usr/bin/perl -w

# Configuration template simple processor

use strict;

my $inputTemplate = shift;
my $varsFile      = shift;

# Usage information on error
if (!defined $inputTemplate or !defined $varsFile) {
   print STDERR "Usage: process_conf_template <input_template> <vars_file>\n";
   print STDERR "Where input_template is a file with macros like %(SOME_VAR)\n";
   print STDERR 'and vars_file is a file with lines like "SOME_VAR = some value"\n';
   exit(1);
}

# Load the variables into 'vars'
my %vars = ();
open F, $varsFile or die "Can't open '$varsFile' for reading\n";
while (<F>) {
   next if /^\s*#/;
   if (/^(.+?)\s*=\s*(.+)$/) {
      $vars{$1} = $2;
   }
}
close F;

# Open template file, and write to stdout after substituting
open F, $inputTemplate or die "Can't open '$inputTemplate' for reading\n";
while (<F>) {
   s/%\(([a-z_]+)\)/exists $vars{$1} ? $vars{$1} : $1/goie;
   print ;
}
close F;
