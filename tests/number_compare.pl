#!/usr/local/bin/perl
   eval 'exec perl -S $0 "$@"'
      if $runnning_under_some_shell;

########################################################################
#
# Simple program to emulate numdiff
# It compares two files which must have the same number of lines
# ignoring small numeric differences or/and different numeric formats
#
# The user can specify an absolute tolerance for the comparisons
#
# It exits with status 0 if the files are considered the same
# otherwise status is 1.
# The actual differences are NOT printed
#
########################################################################

use strict;
use File::Compare;
use Getopt::Long;

# Process arguments. Must be at least two files
if (scalar @ARGV < 2) {
  &usage;
}
# Tolerance is optional
my $tolerance = 0.0000000000001;
my $result = GetOptions (
  "t=s" => \$tolerance
  );

my $fileA = $ARGV[0];
my $fileB = $ARGV[1];
die "$!" unless (-e $fileA && -e $fileB);

#print "DEBUG:  f1=$fileA, f2=$fileB, tol=$tolerance\n";

use File::Compare 'cmp';

sub munge($) {
    my $line = $_[0];
    for ($line) {
        s/^\s+//;   # Trim leading whitespace.
        s/\s+$//;   # Trim trailing whitespace.
    }
    return ($line);
}

my $delta = $tolerance;

if (not cmp($fileA, $fileB, sub {abs(munge $_[0] - munge $_[1])>$delta} ))
{
    #print "FLOAT: fileA and fileB are considered the same. HOORA\n";
    exit 0;
}

# Comparison failed. Check if the files have different number of lines
my $linesA = 0;
my $linesB = 0;
open (FILE, $fileA) or die "Can't open $fileA: $!";
$linesA++ while (<FILE>);
close FILE;

open (FILE, $fileB) or die "Can't open $fileB: $!";
$linesB++ while (<FILE>);
close FILE;

if ($linesA != $linesB) {
   print STDERR "Files do not have the same number of lines\n";
}

exit 1;  # Files considered different


###################################################
sub usage {
   print <<USAGE;

Usage: $0 [-t tolerance] file1 file2

USAGE
   exit 1
}
