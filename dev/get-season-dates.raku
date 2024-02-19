#!/usr/bin/env raku

use JSON::Fast;
use Date::Event;
# The JSON source file
my $jf = "astro-data/seasons-data.json.2024";

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Produces a hash of Date::Events of season dates
    from a JSON file of such dates for the user's
    lat/lon.
    HERE
    exit
}

my $jstr = slurp $jf;
my %data = from-json $jstr, :immutable;

=begin comment
my $jstr = slurp $jf;
my %data = from-json $jstr;
dd %data
Mu %data = {
    "12" => ${:event("Winter"), :time("2024-12-21T09:19:54Z")},
     :lat(30.35616),
}
=end comment

for %data.keys -> $k { # $mnum, $v {
    if $k ~~ /^\d+$/ {
        my %h = %data{$k};
        say "month: $k";
        for %h.kv -> $k, $v {
            # event => time
            say "  $k: ", $v;
        }
    }
    elsif $k ~~ /lat|lon/ {
        my $v = %data{$k};
        say "$k: ", $v 
    }
    else {
        die "FATAL: Unexpected key '$k'";
    }
}
