#!/usr/bin/env raku

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} yyyy
    Creates a test file for the 'make-cal' program for the input year
    using sequential calls to the *nix program 'cal'. The output of
    that is the text file 'caldat.yyyy'.
    HERE
    exit;
}

my $year;
my $debug = 0;
for @*ARGS {
    when /^d/ { ++$debug }
    when /^ (\d**4) / {
        $year = +$0;
        die "FATAL: Input year must be greater than 2019. You entered '$year'" if $year < 2019;;
    }
    default {
        die "FATAL: Unknown input arg '$_'.";
    }
}

say "Creating 'cal' test calendar for year $year";
my $y = DateTime.new: :$year;
my $ybefore = DateTime.new: :year($year - 1);
my $yafter  = DateTime.new: :year($year + 1);
say "Year before: {$ybefore.year}";
say "Year       : {$y.year}";
say "Year after : {$yafter.year}";
