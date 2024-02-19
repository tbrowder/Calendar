unit module Calendar::Seasons;

use Geo::Location;
use JSON::Fast;
use Date::Event:

=begin comment
my $jstr = slurp $jf;
my %data = from-json $jstr;
dd %data
Mu %data = {
    "12" => ${:event("Winter"), :time("2024-12-21T09:19:54Z")},
     :lat(30.35616),
}
=end comment

sub get-seasons-dates(
    :$year!, 
    :$set-id, 
    :$debug 
    --> Hash
) is export {
	
    my %h;

    # Get the data from the JSON file 
    my $jf = "./dev/astro-data/seasons-data.json.2024";
    my $jstr = slurp $jf;
    my %data = from-json $jstr, :immutable;

    for %data.keys -> $k {
        if $k ~~ /^\d+$/ {
            # A Date::Event
            my %h = %data{$k};
            # must be one element
            my $n = %h.elems;
            die "FATAL: Expected one season event, but got $n" if $n > 1;

            my $month = $k;
            say "month: $k" if $debug;
            my ($s, $dt);
            for %h.kv -> $k, $v {
                # Spring, Summer, Fall, Winter => DateTime (UTC)
                # event => time
                say "  $k: $v" if $debug;
                $s  = $k;
                $dt = $v;
            }
            my $e = Date::Event.new: 
        }
        elsif $k ~~ /lat|lon/ {
            # Needed for info (notes)
            my $v = %data{$k};
            say "$k: $v" if $debug;
        }
        else {
            die "FATAL: Unexpected key '$k'";
        }
    }
}
