#!/usr/bin/env raku

use lib <../lib>;
use Calendar;

my $year = 2023;
my $c = Calendar.new: :$year;
print "calendar for year: $year";
say $c.year;

