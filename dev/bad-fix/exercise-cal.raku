#!/bin/env raku

use PDF::Lite;
use PDF::Font::Loader;
use PDF::Content::Color :ColorName, :&color;
use Date::Utils;

use lib <../lib>;
use Calendar;
use Calendar::Vars;


# title of output pdf
my $ofile = "calendar.pdf";

my $debug = 0;
my $year = DateTime.now.year;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Exercises 'Calendar' and its classes

    Options
        y=YYYY    - Create for year YYYY [default: {$year}]
        o[file]=X - Output file name [default: calendar-{$year}.pdf]

        d[ebug]   - Debug
    HERE
    exit
}

for @*ARGS {
    when /^:i y[ear]? '=' (\d**4) $/ {
        $year = +$0;
    }
    when /^ :i o[file]? '=' (\S+) / {
        $ofile = ~$0;
    }
    when /^ :i d / { ++$debug }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

my $cal = Calendar.new: :year($year);

dd $cal;

=finish
