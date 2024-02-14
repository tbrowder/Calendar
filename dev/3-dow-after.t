use Test;
use Date::Utils;

plan 8;

my ($year, Date $date, $nth, $dow, Date $d);

$year  = 2023;
$date  = Date.new: $year, 1, 1;
$dow   = 1; # Monday

$nth   = 1; # first
$d = nth-day-of-week-after-date :$date, :$nth, :day-of-week($dow);
is $d, Date.new: $year, 1, 2;
$d = nth-dow-after-date :$date, :$nth, :$dow;
is $d, Date.new: $year, 1, 2;

$nth   = 5; # fifth
$d = nth-day-of-week-after-date :$date, :$nth, :day-of-week($dow);
is $d, Date.new: $year, 1, 30;
$d = nth-dow-after-date :$date, :$nth, :$dow;
is $d, Date.new: $year, 1, 30;

$date  = Date.new: $year, 1, 6;
$dow   = 5; # Friday 
$nth   = 7; # seventh
$d = nth-day-of-week-after-date :$date, :$nth, :day-of-week($dow);
is $d, Date.new: $year, 2, 24;
$d = nth-dow-after-date :$date, :$nth, :$dow;
is $d, Date.new: $year, 2, 24;

# Test invalid DoWs

$dow = 8; 
dies-ok {
    $d = nth-dow-after-date :$date, :$nth, :$dow;
}, "Invalid DoW $dow";

$dow = 0; 
dies-ok {
    $d = nth-dow-after-date :$date, :$nth, :$dow;
}, "Invalid DoW $dow";

