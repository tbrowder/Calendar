use Test;
use Date::Utils;

plan 28;

my ($year, $month, Date $date);

$year  = 2023;
$date  = Date.new: $year, 1, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 2, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 3, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 4, 1;
is weeks-in-month($date), 6;

$date  = Date.new: $year, 5, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 6, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 7, 1;
is weeks-in-month($date), 6;

$date  = Date.new: $year, 8, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 9, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 10, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 11, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 12, 1;
is weeks-in-month($date), 6;

## 2026
$year  = 2026;
$date  = Date.new: $year, 1, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 2, 1;
is weeks-in-month($date), 4;

$date  = Date.new: $year, 3, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 4, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 5, 1;
is weeks-in-month($date), 6;

$date  = Date.new: $year, 6, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 7, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 8, 1;
is weeks-in-month($date), 6;

$date  = Date.new: $year, 9, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 10, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 11, 1;
is weeks-in-month($date), 5;

$date  = Date.new: $year, 12, 1;
is weeks-in-month($date), 5;

# more general testing
$year = 2024;
$date  = Date.new: $year, 1, 1;

is weeks-in-month($date), 5;

my $cal-first-dow = 3; #
is weeks-in-month($date, :$cal-first-dow), 6;

# Test invalid DoW inputs
$cal-first-dow = 8;
dies-ok {
    weeks-in-month($date, :$cal-first-dow);
}, "Invalid cal-first-dow $cal-first-dow";

$cal-first-dow = 0;
dies-ok {
    weeks-in-month($date, :$cal-first-dow);
}, "Invalid cal-first-dow $cal-first-dow";
