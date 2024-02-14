use Test;
use Date::Utils;

plan 18;

my DoW @dow = 1..7;

for @dow -> $cal-first-dow {
    my DoW @dow = days-of-week $cal-first-dow;
    with $cal-first-dow {
        when $_ == 1 { is @dow, [1, 2, 3, 4, 5, 6, 7] }
        when $_ == 2 { is @dow, [2, 3, 4, 5, 6, 7, 1] }
        when $_ == 3 { is @dow, [3, 4, 5, 6, 7, 1, 2] }
        when $_ == 4 { is @dow, [4, 5, 6, 7, 1, 2, 3] }
        when $_ == 5 { is @dow, [5, 6, 7, 1, 2, 3, 4] }
        when $_ == 6 { is @dow, [6, 7, 1, 2, 3, 4, 5] }
        when $_ == 7 { is @dow, [7, 1, 2, 3, 4, 5, 6] }
    }
}

for @dow -> $cal-first-dow {
    my $i = day-index-in-week 1, :$cal-first-dow;
    with $cal-first-dow {
        when $_ == 1 { is $i, 0 }
        when $_ == 2 { is $i, 6 }
        when $_ == 3 { is $i, 5 }
        when $_ == 4 { is $i, 4 }
        when $_ == 5 { is $i, 3 }
        when $_ == 6 { is $i, 2 }
        when $_ == 7 { is $i, 1 }
    }
}

# test invalid inputs
my $cal-first-dow = 0;
dies-ok {
    day-index-in-week 1, :$cal-first-dow;
}, "Invalid cal-first-dow $cal-first-dow";

$cal-first-dow = 8;
dies-ok {
    day-index-in-week 1, :$cal-first-dow;
}, "Invalid cal-first-dow $cal-first-dow";

my $dow = 0;
dies-ok {
    day-index-in-week $dow, :cal-first-dow(3);
}, "Invalid dow $dow";

$dow = 8;
dies-ok {
    day-index-in-week $dow, :cal-first-dow(3);
}, "Invalid dow $dow";
