use Test;
use Date::Utils;

plan 13;

my $comp = 7;
for 1..7 -> $dow {
    is days-in-week1($dow, :cal-first-dow(1)), $comp--;
}
is days-in-week1(7, :cal-first-dow(7)), 7; 
is days-in-week1(1, :cal-first-dow(7)), 6;

# Test invalid DoW inputs
my $cal-first-dow = 8;
dies-ok {
    days-in-week1(7, :$cal-first-dow); 
}, "Invalid cal-first-dow $cal-first-dow";

$cal-first-dow = 0;
dies-ok {
    days-in-week1(7, :$cal-first-dow); 
}, "Invalid cal-first-dow $cal-first-dow";

$cal-first-dow = 3;
my $dow = 8;
dies-ok {
    days-in-week1($dow, :$cal-first-dow); 
}, "Invalid dow $dow";

$dow = 0;
dies-ok {
    days-in-week1($dow, :$cal-first-dow); 
}, "Invalid dow $dow";

