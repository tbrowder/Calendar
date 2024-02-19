unit module Calendar::Seasons;

use Geo::Location;
use JSON::Fast;
use Date::Event;
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
	
    my %sns; # key: Date; 
             #   value: Hash
             #            key: :$set-id | :$id       

    # Get the data from the JSON file 
    my $jf = "./dev/astro-data/seasons-data.json.2024";
    my $jstr = slurp $jf;
    my %data = from-json $jstr, :immutable;

    my $n = 0;
   
    for %data.keys -> $k {
        if $k ~~ /^\d+$/ {
            # A Date::Event
            ++$n;
            my $id = "s$n"; 
            my $uid = "$set-id|$id";
            my %h = %data{$k};
            #say dd %h; next;

            # should be two elements (event, time)
            my $ne = %h.elems;
            die "FATAL: Expected two items, but got $n" if $ne !== 2;

            my $month = $k;
            say "month: $k" if $debug;

            # event => value (Spring, Summer, Fall, Winter)
            my $short-name = %h<event>;
            # time  => DateTime (UTC)
            my $time = DateTime.new: %h<time>;
            my $date = Date.new: :year($time.year), :month($time.month), 
                                 :day($time.day);
            my $name;
            if $short-name ~~ /:i spring|fall / {
                $name = "$short-name Equinox";
            }
            else {
                $name = "$short-name Solstice";
            }

            my $e = Date::Event.new: :$id, :Etype(150), :$set-id,
                                     :$name, :$short-name, :$time;  
            say $e.raku if $debug;
            %sns{$date}{$uid} = $e;
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
    %sns
}
