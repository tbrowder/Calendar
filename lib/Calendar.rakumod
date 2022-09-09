unit class Calendar;

use Date::Names;

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
    has $.saying;
    has $.header;
    has @.lines; # 4..6

    submethod TWEAK {
        my $d = Date.new($!year, $!mnum, 1);
        $!ndays = $d.days-in-month;
        $!dow1  = $d.day-of-week;
    }
}

class Event {
}

method !build-calendar($year) {
    # build all pieces of the calendar based on two input attrs:
    #   year, lang

    # build the pages
    for 0..14 -> $n {
        my $d;
        if $n == 0 {
            $d = Date.new: :year($year-1), :month(12), :day(1);
        }
        elsif $n < 13 {
            $d = Date.new: :year($year), :month($n), :day(1);
        }
        else {
            $d = Date.new: :year($year+1), :month($n-12), :day(1);
        }

        my $p = CalPage.new: :year($d.year), :mnum($d.month);
        @!pages.push: $p;
    }
    
    # build all the days, one per Julian day
    my $cy = Date.new: :$year;


}

method caldata(Int $month?) {
    # Produces output for all months or the specified
    # month identically to the Linux program 'cal'.
    my $dn = Date::Names.new: :lang(self.lang), :dset<dow2>;
    for @!pages[1..12] -> $p {
        my $mname = $dn.mon($p.mnum);
        say "   $mname {self.year}";
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
        my $dow = $p.dow1; # Date.new(self.year, $p.mnum, 1).day-of-week;
        say $dow; #
        my $dim = $p.ndays;
        if $dow == 7 {
            say " 1  2  3  4  5  6  7"
        }
        elsif $dow == 1 {
            say "    1  2  3  4  5  6"
        }
        elsif $dow == 2 {
            say "       1  2  3  4  5"
        }
        elsif $dow == 3 {
            say "          1  2  3  4"
        }
        elsif $dow == 4 {
            say "             1  2  3"
        }
        elsif $dow == 5 {
            say "                1  2"
        }
        elsif $dow == 6 {
            say "                   1"
        }


        # add a blank line after each month
        say();
    }
}

