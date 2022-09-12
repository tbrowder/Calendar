#!/usr/bin/env raku

use lib <../lib>;
use Calendar;

my $c = Calendar.new;
print "calendar for year: ";
say $c.year;

