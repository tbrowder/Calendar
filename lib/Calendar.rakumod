unit class Calendar;

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Content::Font;

=begin comment
use Date::Christmas;
use Date::Easter;
use Date::Event;
use DateTime::US;
use Holidays::US::Federal;
use LocalTime;
use module Astro::Sunrise;
# use module DST
=end comment

=begin comment
# use module Holidays::US::Federal
sub fed-holidays(:$debug) {
    # US Federal holidays
}
=end comment

use PDF::Lite;
use Date::Names;
use Date::Event;
use Date::Utils;
use Calendar::Subs;
use Calendar::Vars;

class Day     {...}
class Week    {...}
class Month   {...}
class CalPage {...}
class Event   {...}

# keys: 0,1..12,13,14
# month zero is the December of the previous year
# month 13 is the January of the following year
has CalPage @.pages;


# the only two user inputs respected at construction:
has $.year = DateTime.now.year+1; # default is the next year
has $.lang = 'en'; # US English

# other attributes
has $.last; # last month of last year
has $.next; # first month of next year

has $.cover;
has @.appendix;

has Month %months; # keys 1..12
has Day @days;     # Julian days 0..^days-in-year;
has Event @events; #

submethod TWEAK() {
    self!build-calendar($!year);
}

class Day {
    has $.name;
    has $.abbrev;
    has $.date;
    has $.doy; # day of year 1..N (aka Julian day)
    has $.dow; # day of week 1..N (Sun..Sat)
    has $.month;
    has Event @.events;

    submethod TWEAK {
    }
}

class Week {
    has $.woy;  # week of the year 1..N
    has %.days; # keys: 1..7

    submethod TWEAK {
    }
}

class Month {
    has $.year is required;
    has $.number is required;     # month number (1..12)

    has @.weeks;  # 4..6
    has $.nweeks; # 4..6
    has $.name;
    has $.abbrev;
    has %.days;   # keys: 1..N (N = days in the month)

    submethod TWEAK {
        my $d = Date.new: :year($!year), :month($!number);
    }
}

class CalPage {
    has $.year is required;
    has $.mnum is required;     # month number (0, 1..12, 13, 14)

    has $.ndays;    # days in month
    has $.dow1;     # dow of day 1 (1..7, Mon..Sun)

    has $.prevpage; # yyyy-mm
    has $.nextpage; # yyyy-mm
    has $.quotation;
    has $.header;
    has @.weeks;    # 4..6
    has $.nweeks;   # 4..6

    submethod TWEAK {
        my $d    = Date.new($!year, $!mnum, 1);
        $!ndays  = $d.days-in-month;
        $!dow1   = $d.day-of-week;
        $!nweeks = weeks-in-month $d; # a multi sub from Date::Utils

        # fill in the weeks (see Date::Utils and other related modules)

        my $mlast = $d.pred.month;
        my $mnext = $d.last-date-in-month.succ.month;
        my $ylast = $d.pred.year;
        my $ynext = $d.last-date-in-month.succ.year;

        $!prevpage = "$ylast-{sprintf('%02d', $mlast)}";
        $!nextpage = "$ynext-{sprintf('%02d', $mnext)}";
    }
}

class Event is Date::Event {
}

method !build-calendar($year) {
    # build all pieces of the calendar based on two input attrs:
    #   year, lang

    # build the pages
    for 0..14 -> $n {
        my $d;
        if $n == 0 {
            $d = Date.new: :year($year-1), :month(12); # default is day 1
        }
        elsif $n < 13 {
            $d = Date.new: :year($year), :month($n);
        }
        else {
            $d = Date.new: :year($year+1), :month($n-12);
        }

        my $p = CalPage.new: :year($d.year), :mnum($d.month);
        # weeks per month

        @!pages.push: $p;
    }

    # build all the days, one per Julian day
    my $cy = Date.new: :$year;
    my $D = $cy;
    for 1 .. $cy.days-in-year -> $J {

        =begin comment
        has $.name;   # ??
        has $.abbrev; # ??
        has $.date;
        has $.doy; # day of year 1..N (aka Julian day)
        has $.dow; # day of week 1..N (Sun..Sat)
        has $.month;
        has Event @.events;
        =end comment

        my $d = Day.new: :doy($J), :date($D), :dow($D.day-of-week);

        @!days.push: $d;

        $D += 1;
    }

}

=begin comment
$month = 2;
$cal.write-cover: :$pdf;
$cal.write-month-top-page: $month, :$pdf;
$cal.write-month: $month, :$pdf;
=end comment

method write-calendar() {
    # fonts needed
    my $fftb = "/usr/share/fonts/opentype/freefont/FreeSerifBold.otf";
    my $ffhb = "/usr/share/fonts/opentype/freefont/FreeSansBold.otf";
    my $ffh  = "/usr/share/fonts/opentype/freefont/FreeSans.otf";
    my $ffti = "/usr/share/fonts/opentype/freefont/FreeSerifItalic.otf";

}

method write-week(
     PDF::Lite::Page :$page!,
     :$x!, :$y!,
     :$width!, :$height!,
     :%data!,  # includes Day, fonts, Events, etc,
     :%fonts!,
     :$debug
     ) {
}

method write-day-cell(
     PDF::Lite::Page :$page!,
     :$x!, :$y!,
     :$width!, :$height!,
     :%data!,  # includes Day, fonts, Events, etc,
     :%fonts!,
     :$debug
     ) {

     # translate to x,y as the day cell's upper-left corner
     # Note this method is called from a method where tranformation
     #   to internal landscape orientation has already been done.

}

method write-page-cover(
    PDF::Lite::Page :$page!,
    :%data!,  # includes Day, fonts, Events, etc,
    :%fonts!,
    :$debug
) {
    # note media box was set for the entire document at $pdf definition
    # for this document, always use internal landscape, "right-side up"
    # i.e, NOT upside-down
    $page.graphics: {
        # always save the CTM
        .Save;
        #===================================

        my ($w, $h);
        #if $landscape {
        #    if not $upside-down {
        # Normal landscape
        # translate from: lower-left corner to: lower-right corner
        # LLX, LLY -> URX, LLY
        .transform: :translate($page.media-box[2], $page.media-box[1]);
        # rotate: left (ccw) 90 degrees
        .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
        $w = $page.media-box[3] - $page.media-box[1];
        $h = $page.media-box[2] - $page.media-box[0];

        # fill page as desired, e.g.,
        # $cx = 0.5 * $w;
        # $cy = 0.5 * $h;
        # my @position = [$cx, $cy];
        # my @box = .print: $text, :@position, :$font,
        #           :align<center>, :valign<center>;
        # make other calls with the page CTM
        # ...
        #===================================
        #===================================
        # and, finally, restore the page CTM
        .Restore;
    }
}

method write-page-month-top(
    $mnum,
    PDF::Lite::Page :$page!,
    :%data,  # includes Day, fonts, Events, etc,
    :%fonts,
    :$debug
    ) {
}

method write-page-month(
    $mnum,
    PDF::Lite::Page :$page!,
    :%data!,  # includes Day, fonts, Events, etc,
    :%fonts!,
    :$debug
    ) {
}
