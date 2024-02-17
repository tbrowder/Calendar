use Test;
use YAMLish;

plan 9;

my $str;
my %config = load-yaml $str;

is %config<lang>, "en";
is %config<lat>, 30.486092;
is %config<lon>, -86.43761; 
is %config<seasons>, True;
is %config<dst>, True;
is %config<holidays-us>, True;
is %config<holidays-misc>, True;
is %config<sunrise-set>, False;
is %config<moon-phase>, False;

BEGIN {
$str = q:to/HERE/;
# key: value
lang: en
# location: City Hall, Gulf Breeze, Florida, US
lat: 30.486092
lon: -86.43761 
seasons: yes
dst: yes
holidays-us: yes
holidays-misc: yes
sunrise-set: no
moon-phase: no
HERE
}

