unit class Calendar:ver<0.0.1>:auth<cpan:TBROWDER>;

class Day   {...}
class Week  {...}
class Month {...}

has Month @.months; # 0..11
has $.year = DateTime.now.year;

class Day {
    has $.name;
}

class Week {
    has $.woy; # week of the year 1..N
}
class Month {
    has $.name;
    has $.abbrev;
}


