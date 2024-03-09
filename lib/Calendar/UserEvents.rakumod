unit module Calendar::UserEvents;

use Date::Event;
use CSV-Autoclass;

sub get-season-dates(
    :$year!,
    :$set-id,
    :$debug
    --> Hash
) is export {

    my %ssn; # key: Date;
             #   value: Hash
             #            key: :$set-id | :$id

    # Get the data from the JSON file
    my $jstr;
    with $year {
        when /2021/ { $jstr = $ssn2021 }
        when /2022/ { $jstr = $ssn2022 }
        when /2023/ { $jstr = $ssn2023 }
        when /2024/ { $jstr = $ssn2024 }
        when /2025/ { $jstr = $ssn2025 }
        when /2026/ { $jstr = $ssn2026 }
        when /2027/ { $jstr = $ssn2027 }
        when /2028/ { $jstr = $ssn2028 }
        when /2029/ { $jstr = $ssn2029 }
        default {
            die "FAIL: Unexpected year '$_'";
        }
    }

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
            # correct for local time
            my $timezone = 'cst';
            my $tz = DateTime::US.new: :$timezone;
            $time = $tz.to-localtime :utc($time);

            my $date = Date.new: :year($time.year), :month($time.month),
                                 :day($time.day);

            my $name;
            if $short-name ~~ /:i spring|fall / {
                $name = "$short-name Equinox";
                $short-name = "1st day of $short-name";
            }
            else {
                $name = "$short-name Solstice";
                $short-name = "1st day of $short-name";
            }

            my $e = Date::Event.new: :$id, :Etype(150), :$set-id,
                                     :$name, :$short-name, :$time;
            say $e.raku if $debug;
            %ssn{$date}{$uid} = $e;
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
    %ssn
} # sub

$ssn2021 = q:to/HERE/;
{
  "6": { "event": "Summer", "time": "2021-06-21T03:31:32Z" }, "3": {
    "event": "Spring", "time": "2021-03-20T09:37:05Z" }, "9": { "event": "Fall",
    "time": "2021-09-22T19:20:30Z" }, "location": "Niceville", "12": {
    "event": "Winter", "time": "2021-12-21T15:58:54Z" }
}
HERE

$ssn2022 = q:to/HERE/;
{
  "12": { "event": "Winter", "time": "2022-12-21T21:47:33Z" }, "3": {
    "event": "Spring", "time": "2022-03-20T15:32:53Z" }, "6": {
    "event": "Summer", "time": "2022-06-21T09:13:18Z" }, "9": {
    "event": "Fall", "time": "2022-09-23T01:03:41Z" }, "lat": 30.35616,
  "lon": -87.17095
}
HERE

$ssn2023 = q:to/HERE/;
{
  "12": { "event": "Winter", "time": "2023-12-22T03:27:06Z" }, "3": {
    "event": "Spring", "time": "2023-03-20T21:24:14Z" }, "6": {
    "event": "Summer", "time": "2023-06-21T14:57:11Z" },
  "9": { "event": "Fall", "time": "2023-09-23T06:49:36Z" }, "lat": 30.35616,
  "lon": -87.17095
}
HERE

$ssn2024 = q:to/HERE/;
{ "12": { "event": "Winter", "time": "2024-12-21T09:19:54Z" }, "3": {
    "event": "Spring", "time": "2024-03-20T03:06:04Z" }, "6": { "event": "Summer",
    "time": "2024-06-20T20:50:23Z" }, "9": { "event": "Fall",
    "time": "2024-09-22T12:43:12Z" }, "lat": 30.35616, "lon": -87.17095
}
HERE

$ssn2025 = q:to/HERE/;
{ "12": { "event": "Winter", "time": "2025-12-21T15:02:36Z" }, "3": {
    "event": "Spring", "time": "2025-03-20T09:01:03Z" }, "6": { "event": "Summer",
    "time": "2025-06-21T02:41:49Z" }, "9": { "event": "Fall",
    "time": "2025-09-22T18:19:00Z" }, "lat": 30.35616, "lon": -87.17095
}
HERE

$ssn2026 = q:to/HERE/;
{
  "12": { "event": "Winter", "time": "2026-12-21T20:49:39Z" }, "3": {
    "event": "Spring", "time": "2026-03-20T14:45:02Z" }, "6": { "event": "Summer",
    "time": "2026-06-21T08:24:21Z" }, "9": { "event": "Fall",
    "time": "2026-09-23T00:04:56Z" }, "lat": 30.35616, "lon": -87.17095
}
HERE

$ssn2027 = q:to/HERE/;
{
  "12": { "event": "Winter", "time": "2027-12-22T02:41:41Z" }, "3": {
    "event": "Spring", "time": "2027-03-20T20:24:18Z" }, "6": { "event": "Summer",
    "time": "2027-06-21T14:10:06Z" }, "9": { "event": "Fall",
    "time": "2027-09-23T06:00:43Z" }, "lat": 30.35616, "lon": -87.17095
}
HERE

$ssn2028 = q:to/HERE/;
{
  "12": { "event": "Winter", "time": "2028-12-21T08:19:30Z" }, "3": {
    "event": "Spring", "time": "2028-03-20T02:16:32Z" }, "6": { "event": "Summer",
    "time": "2028-06-20T20:00:57Z" }, "9": { "event": "Fall",
    "time": "2028-09-22T11:44:31Z" }, "lat": 30.35616, "lon": -87.17095
}
HERE

$ssn2029 = q:to/HERE/;
{
  "12": { "event": "Winter", "time": "2029-12-21T14:13:45Z" }, "3": {
    "event": "Spring", "time": "2029-03-20T08:01:03Z" }, "6": { "event": "Summer",
    "time": "2029-06-21T01:47:43Z" }, "9": { "event": "Fall",
    "time": "2029-09-22T17:37:17Z" }, "lat": 30.35616, "lon": -87.17095
}
HERE
