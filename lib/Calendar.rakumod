unit class Calendar;

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
    has $.yname;    # yyyy-mm
    has $.mname;    # full month name, e.g., September
    has $.prevpage; # yyyy-mm
    has $.nextpage; # yyyy-mm
    has $.saying;
    has $.header;
    has @.lines; # 4..6
}

class Event {
}

method !build-calendar($year) {
    # build all pieces of the calendar based on two input attrs:
    #   year, lang

    # build the pages
    my $d = Date.new: :year($year-1), :month(12), :day(31);
    for 0..14 {
        my $p = CalPage.new;
        @!pages.push: $p;
    }
    
    # build all the days, one per Julian day
    my $cy = Date.new: :$year;


}

method caldata(Int $month?) {
    # Produces output for all months or the specified
    # month identically to the Linux program 'cal'.
    for @!pages[1..12] -> $p {
    }
}

