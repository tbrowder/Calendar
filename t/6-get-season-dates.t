use Test;

use Calendar::Seasons;
use UUID::V4;

my $debug = 1;

my $set-id = uuid-v4;
is is-uuid-v4($set-id), True, "good UUID::V4";

my $year = 2024;
my %sns = get-season-dates :$year, :$set-id, :$debug;

for %sns.keys -> $date {
    for %sns{$date}.kv -> $key, $v {
        say "key: '$key'";
        say "  value: '$v'";
    }
} 

done-testing;

