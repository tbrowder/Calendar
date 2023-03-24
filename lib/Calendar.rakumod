unit class Calendar;

use PDF::Lite;
use Date::Names;
use Date::Event;
use Date::Utils;
use Calendar::Subs;

class Day     {...}
class Week    {...}
class Month   {...}
class CalPage {...}
class Event   {...}

# keys: 0,1..12,13,14
# month zero is the December of the previous year
# month 13 is the January of the following year
has CalPage @.pages;

has Day @.days; # keys: 1..N (N = days in the year)

# the only two user inputs respected at construction:
has $.year = DateTime.now.year+1; # default is the next year
has $.lang = 'en'; # US English

# other attributes
has $.last; # last month of last year
has $.next; # first month of next year

has $.cover;
has @.appendix;

submethod TWEAK() {
    self!build-calendar($!year);
}

class Day {
    has $.name;
    has $.abbrev;
    has $.doy; # day of year 1..N (aka Julian day)
    has $.dow; # day of week 1..N (Sun..Sat)
    has $.month;
    has Event @.events;
}

class Week {
    has $.woy;  # week of the year 1..N
    has %.days; # keys: 1..7
}

class Month {
    has $.name;
    has $.abbrev;
    has %.days; # keys: 1..N (N = days in the month)
}

class CalPage {
    has $.year is required;
    has $.mnum is required;     # month number (1..12)

    has $.ndays;    # days in month
    has $.dow1;     # dow of day 1 (1..7, Mon..Sun)

    has $.prevpage; # yyyy-mm
    has $.nextpage; # yyyy-mm
    has $.quotattion;
    has $.header;
    has @.weeks;  # 4..6
    has $.nweeks; # 4..6

    submethod TWEAK {
        my $d = Date.new($!year, $!mnum, 1);
        $!ndays = $d.days-in-month;
        $!dow1  = $d.day-of-week;
        $!nweeks = weeks-in-month $d;
    }
}

class Event is Date::Event {
}

method !build-calendar($year) {
    # build all pieces of the calendar based on two input attrs:
    #   year, lang

    # build the pages
    for 0..14 -> $n {
        my $d;
        if $n == 0 {
            $d = Date.new: :year($year-1), :month(12); # default is day 1
        }
        elsif $n < 13 {
            $d = Date.new: :year($year), :month($n);
        }
        else {
            $d = Date.new: :year($year+1), :month($n-12);
        }

        my $p = CalPage.new: :year($d.year), :mnum($d.month);
        @!pages.push: $p;
    }

    # build all the days, one per Julian day
    my $cy = Date.new: :$year;
}

method caldata(@months? is copy, :$debug) {
    # Produces output for all months or the specified
    # months identically to the Linux program 'cal'.
    my $dn = Date::Names.new: :lang(self.lang), :dset<dow2>;

    my @p;
    if @months.defined and (0 < @months[*] < 13) {
        @months .= sort({$^a <=> $^b});
        @p = @!pages[@months];
    }
    else {
        @p = @!pages[0..14];
    }
    my $end = @p.end;
    for @p.kv -> $i, $p {
        # the standard cal header spans
        # 7x2 + 6 = 20 characters
        # month and year are centered
        my $mname = $dn.mon($p.mnum);
        my $hdr = "$mname {$p.year}";
        my $leading = ' ' x ((22 - $hdr.chars) div 2) - 1;
        #note "DEBUG: \$leading = |$leading|";
        say $leading ~ $hdr;
        for <7 1 2 3 4 5 6> {
            my $dow = $dn.dow($_);
            if $_ != 6 {
                print "$dow ";
                next;
            }
            say "$dow";
        }

        # add one line of days of the week: 4, 5, or 6 weeks
        # note our calendars are sun..sat, thus 7, 1..6
        my $dow = $p.dow1;  # day of the week for the first day of the month
        my $dim = $p.ndays; # days in the month

        # TODO refactor the common code if possible:
        if $dow == 7 {
            say " 1  2  3  4  5  6  7";
            my $next = 8;
            my $dremain = $dim - 7;

            # TODO BEGIN common code block
            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
            # TODO END common code block
        }
        elsif $dow == 1 {
            say "    1  2  3  4  5  6";
            my $next = 7;
            my $dremain = $dim - 6;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 2 {
            say "       1  2  3  4  5";
            my $next = 6;
            my $dremain = $dim - 5;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 3 {
            say "          1  2  3  4";
            my $next = 5;
            my $dremain = $dim - 4;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 4 {
            say "             1  2  3";
            my $next = 4;
            my $dremain = $dim - 3;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 5 {
            say "                1  2";
            my $next = 3;
            my $dremain = $dim - 2;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;;
        }
        elsif $dow == 6 {
            say "                   1";
            my $next = 2;
            my $dremain = $dim - 1;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }

        # add a blank line after each month
        # except the last
        say() unless $i == $end;;
    }
}

sub show-events-file(:$debug) is export {
    # lists resources CSV file contents to stdout
    my @lines = %?RESOURCES<calendar-events.csv>.lines;
    for @lines {
        say $_
    }
}

method create-cal(:$year!, :$debug) { # is export {
    # Create a 12-month PDF landscape calendar.
    #my @months = Calendar.new: $year;
    my @months = self.new: :$year;
    my $pdf  = PDF::Lite.new;
  
    cover-page :$pdf;
    for @months -> $month {
        month-page :$pdf, :$month;
    }
}

sub cover-page(:$pdf, :$debug) {
}

sub info-page(:$pdf!, :$debug) {
    # Either a blank page or data associated
    # with a month.
}

sub month-page(:$pdf!, :$month!, :$debug) {
    # Create a single page, landscape, with grid for a six-week month.
    # This page is on the bottom with either a blank or information
    # page on the top. At the print shop use the "pamphlet" format
    # and start with a cover page. 

    # always print this page, even if it's blank
    info-page :$pdf, :$debug;

    my $page = $pdf.add-page;

}

sub fed-holidays(:$debug) {
    # US Federal holidays
    # 
}

