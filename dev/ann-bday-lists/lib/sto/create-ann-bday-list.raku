#!/usr/bin/env raku

use Text::Utils :strip-comment, :normalize-text;

my $year = DateTime.new(now).year;

my $debug = 0;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | yyyy  [debug]

    Creates a printed list of Missy's birthdays and anniversaries from
      specially-formatted .data files. 

    Note the output will list the current year unless the desired
    year is entered instead of 'go'.
    HERE
    exit
}

for @*ARGS {
    when /^g/ {
        ; # ok
    }
    when /^d/ {
        ++$debug
    }
    when /^20 (\d\d) $/ {
        $year = +$0;
    }
}

my $data = "missys-ann-bday-list-{$year}.data";

my %data;
my $mon;
for $data.IO.lines {
    when /^ year':' \h* (20 \d\d) \h* $/ {
        my $n = +$0;
        die "FATAL: Expected year $year, but got $n" if $n != $year;
    }
    when /^ month':' \h* (\d+) \h* $/ {
        my $n = +$0;
        die "FATAL: Expected months 1 through 12 but got $n" if not (0 < $n < 13);
        $mon = $n;
    }

    # a real data line
    when /^ \h* (\d[\d]?) \h* '|' (.+) '|' (.+) / {
        my $n  = +$0;
        my $s1 = ~$1;
        my $s2 = ~$2;

        die "FATAL: Expected days 1 through 31 but got $n" if not (0 < $n < 32);
        if $s1.defined and $s1 ~~ /\S/ {
            # break it down, expect: text yyyy
            $s1 = normalize-text $s1;
            my @w = $s1.words;
            note "\@w = {@w.raku}" if $debug;
            my $year1 = @w.tail.Int;
        }
        if $s2.defined and $s2 ~~ /\S/ {
            # break it down, expect: text yyyy
            $s2 = normalize-text $s2;
            my @w = $s2.words;
            note "\@w = {@w.raku}" if $debug;
            my $year1 = @w.tail.Int;
        }
    }
    default {
        say "Ignoring line '$_'";
    }
}

