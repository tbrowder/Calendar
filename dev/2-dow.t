use Test;
use Date::Utils;

plan 8;

my ($year, $month, $nth, $dow, Date $d);

$year  = 2023;
$month = 3; # March
$dow   = 1; # Monday
$nth   = 1; # first

$d = nth-day-of-week-in-month :$year, :$month, :$nth, :day-of-week($dow);
is $d, Date.new: $year, $month, 6;
$d = nth-dow-in-month :$year, :$month, :$nth, :$dow;
is $d, Date.new: $year, $month, 6;

$nth   = 3; # third
$d = nth-day-of-week-in-month :$year, :$month, :$nth, :day-of-week($dow);
is $d, Date.new: $year, $month, 20;
$d = nth-dow-in-month :$year, :$month, :$nth, :$dow;
is $d, Date.new: $year, $month, 20;

$nth   = -3; # last
$d = nth-day-of-week-in-month :$year, :$month, :$nth, :day-of-week($dow);
is $d, Date.new: $year, $month, 27;
$d = nth-dow-in-month :$year, :$month, :$nth, :$dow;
is $d, Date.new: $year, $month, 27;

# Test invalid DoW inputs
$dow = 8;
dies-ok {
    $d = nth-day-of-week-in-month :$year, :$month, :$nth, :day-of-week($dow);
}, "Invalid DoW $dow";

dies-ok {
    $d = nth-day-of-week-in-month :$year, :$month, :$nth, :day-of-week($dow);
}, "Invalid DoW $dow";

