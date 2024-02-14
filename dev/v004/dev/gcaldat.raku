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

use Test::Output;
my @lines = [];
for 0..14 -> $n is copy {
    if $n < 1 {
        my $m = 12;
        my $y = $year - 1;
        #my $stdout = stdout-from { run 'cal', $m, $y; }
        #my $stdout = stdout-from { shell "cal $m $y"; };
        #my $stdout = output-from( &shell("cal $m $y") );
        #my $stdout;
        #shell "cal $m $y", :out($stdout);
        my &code = sub { shell("cal $m $y") };
        my $stdout = stdout-from &code;
        
        my @tlines = $stdout.lines;
        note $_ for @tlines;
        @lines.push: flat @tlines;
        #note "DEBUG: early exit"; exit;
    }
    elsif $n > 12 {
        $n -= 12;
        my $stdout = stdout-from { shell "cal $n {$year+1}"; }
        my @tlines = $stdout.lines;
        @lines.push: |@tlines;
    }
    else {
        my $stdout = stdout-from { shell "cal $n $year"; }
        my @tlines = $stdout.lines;
        @lines.push: |@tlines;
    }
}

my $ofil = "caldata.$year";
my $fh = open $ofil, :w;
for @lines -> $line {
    $fh.say: $line;
}
$fh.close;
say "See file $ofil";

