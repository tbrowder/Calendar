use Test;

use Calendar::Seasons;
use UUID::V4;

my $debug = 0;

my $set-id = uuid-v4;
is is-uuid-v4($set-id), True, "good UUID::V4";

my $year = 2024;
my %sns = get-season-dates :$year, :$set-id, :$debug;

for %sns.keys -> $date {
    isa-ok $date, Str;
    for %sns{$date}.kv -> $key, $v {
        isa-ok $key, Str, "key is a Str"; 
        # The key should be: "$set-id|$id"
        my $uid = $key.split('|').head;
        is $uid, $set-id, "uid eq set-id";

        isa-ok $v, Date::Event;
        say "key: '$key'" if $debug;
        say "  value: '$v'" if $debug;
    }
} 

done-testing;

