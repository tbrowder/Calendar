#!/usr/bin/env raku

use Text::Utils :strip-comment, :normalize-text;

my @ifils = <
    birthdays.txt
    anniversaries.txt
>;

use lib '.';
use Yevent;

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
if $arg ~~ /^ (20 \d\d) $/ {
    $year = +$0;
}

my $ofil = "missys-ann-bday-list-{$year}.data";

my @events;
my @hdrs1;
my @hdrs2;

for @ifils.kv -> $j, $f {
    my @lines = $f.IO.lines;
    my $hdrs  = @lines.shift;
    my @hdrs  = $hdrs.split(',');
    for @hdrs.kv -> $i, $field is copy {
        $field = normalize-text $field;
        if $j == 0 {
            @hdrs1[$i] = $field;
        }
        elsif $j == 1 {
            @hdrs2[$i] = $field;
        }
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

# @hdrs1 and @hdrs2 should be the same
die "hdrs are different" if @hdrs1.elems != @hdrs2.elems;
for 0..^@hdrs1.elems -> $i {
    die "hdrs are differnt at index $i" if @hdrs1[$i] ne @hdrs2[$i];
}

say "Read data okay.";

# %e - a hash of Yevents keyed by month and day
# %e<mon><day><ann>[]
#            <bday>[]
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

    my $typ = $e.type;
    if $typ ~~ /:i a / {
        unless %e{$mon}{$day}<ann>:exists {
            %e{$mon}{$day}<ann> = [];
        }
        %e{$mon}{$day}<ann>.push: $e;
    }
    elsif $typ ~~ /:i b / {
        unless %e{$mon}{$day}<bday>:exists {
            %e{$mon}{$day}<bday> = [];
        }
        %e{$mon}{$day}<bday>.push: $e;
    }
}

say "The \%e hash is filled.";

my @mons = %e.keys.sort({ $^a <=> $^b }); 
# say "  $_" for @mons;

my $fh = open $ofil, :w;

$fh.say: "year: $year";

for @mons -> $mon {

    $fh.say: "month: $mon";
    say "Working month $mon";

    my @days = %e{$mon}.keys.sort({ $^a <=> $^b }); 

    #say "  $_" for @days;
    # separate into birthdays and anniversaries for each day
    DAY: for @days -> $day {
        my @a = %e{$mon}{$day}<ann>:exists  ?? @(%e{$mon}{$day}<ann>)
                                            !! [];
        my @b = %e{$mon}{$day}<bday>:exists ?? @(%e{$mon}{$day}<bday>) 
                                            !! [];
        my $na = @a.elems;
        my $nb = @b.elems;
        my $n  = max $na, $nb;
 	
        next DAY if not $n;

       
        # here is the data for a table 
        #   lay out the table in a text file:

        # month: N
        # 1 | name yyyy | name yyyy
        
        #say "  Working day $day";
        for 0..^$n -> $i {
            my ($col1, $col2) = "", "";
            my $t = $i + 1;
            # put birthdays in column 1
            if $nb >= $t {
                $col1 = " {@b[$i].name} {@b[$i].year} ";
            }
            if $na >= $t {
                $col2 = " {@a[$i].name} {@a[$i].year} ";
            }
            say "  '$col1' | '$col2'";
            $fh.say: " $day | $col1 | $col2 ";
        }
    }
}

$fh.close;

say "The \%e hash sorts as desired.";
say "See the data output file '$ofil'";

=finish

say "Ready to produce the list as strings before typesetting it.";

# for each month
#   for each day
#      write two columns
#         col1  col2
#         bday  ann



