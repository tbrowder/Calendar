unit module Psub;

use PDF::Lite;
use Text::Utils :normalize-text;

use Classes;

sub import-data($data-file, :$year!, :$debug --> Year) is export {
    # Given the speciallly-formatted data file convert the
    # data to a list of month data tables for output to PDF.
    use Date::Names;

    my $y;                   # Year object
    my $d = Date::Names.new; # English date name data
    my $month;               # 1..12, current month number
    my $name;                # current month name
    my $m;                   # current month object

    for $data-file.IO.lines {
        # a double check to ensure we're using the intended year
        when /^ year':' \h* (20 \d\d) \h* $/ {
            my $n = +$0;
            die "FATAL: Expected year $year, but got $n" if $n != $year;
            $y = Year.new: :year($year);
        }

        when /^ month':' \h* (\d+) \h* $/ {
            my $n = +$0;
            die "FATAL: Expected months 1 through 12 but got $n" if not (0 < $n < 13);

            # if we already have a month, add it to the Year 
            # before starting a new one
            if $m.defined {
                $y.add-month: $m;
            }
           
            # the next month
            $month = $n;
            $name  = $d.mon($n);
            $m     = Month.new: :$month, :$name;
        }

        # a real data line. a Line object
        when /^ \h*
              (\d[\d]?)
                  \h* '|'
              (<-[|]>*)
                  '|'
              (<-[|]>*)
              $/ {

            note "DEBUG: line = '$_'" if 0 and $debug;
            my $s1 = +$0; # day
            my $s2 = ~$1; # birthday
            my $s3 = ~$2; # anniversary

            die "FATAL: Expected days 1 through 31 but got $s1" if not (0 < $s1 < 32);
            die "FATAL: Unexpected empty day" if not ($s1.defined and $s1 ~~ /\S/);

            my ($c1, $c2, $c3);      # current line cells

            # day is cell 1 of 3
            $c1 = Cell.new: :text($s1);

            # cells 2 and 3 of 3

            # cell 2, birthdays
            $c2 = Cell.new;
            if $s2.defined and $s2 ~~ /\S/ {
                # break it down, expect: text yyyy
                $s2 = normalize-text $s2;
                my @w = $s2.words;
                note "\@w = {@w.raku}" if 0 and $debug;
                my $year1 = @w.pop.Int;
                my $ydiff = 0;
                if $year1 > 0 {
                    # age
                    $ydiff = $year - $year1;
                }
                my $s = @w.join(' ');
                $s ~= " ($ydiff)" if $ydiff;
                note "\$s = '$s'" if 0 and $debug;

                $c2.set-text($s);
            }

            # cell 3, anniversaries
            $c3 = Cell.new;
            if $s3.defined and $s3 ~~ /\S/ {
                # break it down, expect: text yyyy
                $s3 = normalize-text $s3;
                my @w = $s3.words;
                note "\@w = {@w.raku}" if 0 and $debug;
                my $year1 = @w.pop.Int;
                my $ydiff = 0;
                if $year1 > 0 {
                    $ydiff = $year - $year1;
                }
                my $s = @w.join(' ');
                $s ~= " ($ydiff years)" if $ydiff;
                note "\$s = '$s'" if 0 and $debug;

                $c3.set-text($s);
            }

            # assemble the Line
            my $L = Line.new;
            $L.add-cell: $c1;
            $L.add-cell: $c2;
            $L.add-cell: $c3;

            # add the line to the table
            $m.add-line: $L, :$debug;

        } # end of a Line definition
        default {
            say "Ignoring line '$_'";
        }

    } # end of lines loop

    # add the last month
    $y.add-month: $m;

    $y
}

sub show-list(Year $yr, :$year!, :$debug) is export {
    my ($nc1, $nc2, $nc3) = $yr.nchars[0], $yr.nchars[1], $yr.nchars[2];
    # now pretty print
    say "year: $year";
    for $yr.months -> $m {
        say $m.name;
        print "day | ";
        print sprintf "%-*.*s | ", $nc2, $nc2, "Birthdays";
        print sprintf "%-*.*s", $nc3, $nc3, "Anniversaries";
        say();
        for $m.lines.kv -> $i, $L {
            my $s1 = $L.cells[0].text;
            my $s2 = $L.cells[1].text;
            my $s3 = $L.cells[2].text;
            print sprintf " %-2.2s | ", $s1;
            print sprintf "%-*.*s | ", $nc2, $nc2, $s2;
            print sprintf "%-*.*s", $nc3, $nc3, $s3;
            say();
        }
        say()
    }
} # sub show-list(Year $yr, :$year!, :$debug) is export {

=begin comment

Look at the mailing label in xmas for an algorithm
start.

=end comment

#| subs to be used to produce PDF files
sub create-cal-event-page(
    :$debug,
    ) is export {

    =begin comment
    Given a list of month blocks and their WxH
    dimensions, print them on a page in multiple
    columns, 1..n, n+1..m, m+1..p
    =end comment

}


=finish
# use later, with rework, for calendar
sub create-cal-event-month(
    :$listdata,
    :$pdfpage,
    :$day,
    :$month, #= month number
    DocFont :$text,
    DocFont :$title,
    :$debug,
    ) is export {

    =begin comment
    Given a list of birthdays and anniversaries
    for one calendar month and a given year,
    produce a PDF chunk tailored to the size of
    the data, fonts, and font sizes.

    make it look something like this

    month
    day   | birthdays  | anniversaries
      1   |  joe {age} | sally & sam {years}
      4   |  sue {age} |
    =end comment
}
