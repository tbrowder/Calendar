unit class Calendar;

class Day   {...}
class Week  {...}
class Month {...}

has Month %.months; # keys: 1..12
has Day   %.days; # keys: 1..N (N = days in the year)

# the only two user inputs respected at construction:
has $.year = DateTime.now.year;
has $.lang = 'en'; # US English

# other attributes
has $.last; # last month of last year
has $.next; # first month of next year

submethod TWEAK() {
    self!build-calendar($!year);
}

class Day {
    has $.name;
    has $.abbrev;
    has $.doy; # day of year 1..N (aka Julian day)
    has $.dow; # day of week 1..N (Sun..Sat)
    has $.month;
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

method !build-calendar($year) {
    # build all pieces of the calendar based on two input attrs:
    #   year, lang

    # build all the days, one per Julian day
}
