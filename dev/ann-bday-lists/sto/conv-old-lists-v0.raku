#!/usr/bin/env raku

use Text::Utils :strip-comment, :normalize-text;

my @ifils = <
    birthdays.txt
    anniversaries.txt
>;


use lib '.';
use Yevent;

my $ofil = "ann-bday-list.csv";
my $year = DateTime.new(now).year;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | yyyy

    Creates a consolidated CSV list of birthdays and anniversaries from
      specially-formatted intermediate ws-separated text files converted
      from the original, specially-formatted text files.

    Note the output will list the current year unless the desired
    year is entered instead of 'go'.
    HERE
    exit
}

my $arg = @*ARGS.head;
if $arg ~~ /^20 (\d\d) $/ {
    $year = +$0;
}

my @events;
for @ifils -> $f {
    my @lines = $f.IO.lines;
    my $hdrs  = @lines.shift;
    my @hdrs  = $hdrs.split(',');
    for @hdrs.kv -> $i, $field is copy {
        $field = normalize-text $field;
        @hdrs[$i] = $field;
    }

    for @lines -> $line is copy {
        $line = strip-comment $line;
        next if $line !~~ /\S/;
        my @data = $line.split(',');
        for @data.kv -> $i, $field is copy {
            $field = normalize-text $field;
            @data[$i] = $field;
        }
        my $e = Yevent.new: |@data;
        @events.push: $e;
    }
}

say "Read data okay.";

# %e - a hash of Yevents keyed by date 
# %e<date><ann>[]
#         <bday>[]
my %e; 

for @events -> $e {
    my $day        = $e.day;
    my $mon-abbrev = $e.mon;
    my $mon;
    with $mon-abbrev {
        when /:i jan / { $mon = 1 }
        when /:i feb / { $mon = 2 }
        when /:i mar / { $mon = 3 }
        when /:i apr / { $mon = 4 }
        when /:i may / { $mon = 5 }
        when /:i jun / { $mon = 6 }
        when /:i jul / { $mon = 7 }
        when /:i aug / { $mon = 8 }
        when /:i sep / { $mon = 9 }
        when /:i oct / { $mon = 10 }
        when /:i nov / { $mon = 11 }
        when /:i dec / { $mon = 12 }
        default {
            die "FATAL: Unknown month abbreviation '$_'";
        }
    }

    # the <date> is formed by $year-$mon-$day
    my $d = Date.new: $year, $mon, $day;
    my $typ = $e.type;
    if $typ ~~ /:i a / {
        unless %e{$d}<ann>:exists {
            %e{$d}<ann> = [];
        }
        %e{$d}<ann>.push: $e;
    }
    elsif $typ ~~ /:i b / {
        unless %e{$d}<bday>:exists {
            %e{$d}<bday> = [];
        }
        %e{$d}<bday>.push: $e;
    }

}

say "The \%e hash is filled.";

my @d = %e.keys.sort; 
# say "  $_" for @d;

say "The \%e hash sorts as desired.";
say "Ready to produce the list as strings before typesetting it.";

# for each month
#   for each day
#      write two columns
#         col1  col2
#         bday  ann


