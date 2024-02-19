unit module Calendar::Seasons;

use Geo::Location;
use JSON::Fast;
use Date::Event:
use LocalTime;

=begin comment
my $jstr = slurp $jf;
my %data = from-json $jstr;
dd %data
Mu %data = {
    "12" => ${:event("Winter"), :time("2024-12-21T09:19:54Z")},
     :lat(30.35616),
}
=end comment

sub get-season-dates(
    :$year!, 
    :$set-id, 
    :$debug 
    --> Hash
) is export {
	
    my %s; # key: Date; 
           #   value: Hash
           #            key: :$set-id | :$id       

    # Get the data from the JSON file 
    my $jf = "./dev/astro-data/seasons-data.json.2024";
    my $jstr = slurp $jf;
    my %data = from-json $jstr, :immutable;

    my $id = 0;
    for %data.keys -> $k {
        if $k ~~ /^\d+$/ {
            # A Date::Event
            ++$id;
            my %h = %data{$k};
            # must be one element
            my $n = %h.elems;
            die "FATAL: Expected one season event, but got $n" if $n > 1;

            my $month = $k;
            say "month: $k" if $debug;
            my ($dt, $name, $short-name);
            for %h.kv -> $k, $v {
                # Spring, Summer, Fall, Winter => DateTime (UTC)
                # event => time
                say "  $k: $v" if $debug;
                $short-name  = $k;
                $dt = $v;
                if $short-name ~~ /:i spring|fall / {
                    $name = "$short-name Equinox";
                }
                else {
                    $name = "$short-name Solstice";
                }
            }
            my DateTime $T .= new: $dt;
            my $e = Date::Event.new: :$id, :Etype(150), :$name, :$short-name;  
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
