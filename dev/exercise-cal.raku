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
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Exercises Calendar and its classes

    Options
        o[file]=X - Output file name [default: calendar2.pdf]

        d[ebug]   - Debug
    HERE
    exit
}

for @*ARGS {
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

my $cal = Calendar.new: :year(2023);
my $month = $cal.month: 1;
say $month;
