use Roles;

unit class Calendar;

use PDF::Lite;
use PDF::Font::Loader :load-font;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Content::Font;
use PDF::Content::Ops :TextMode;
use PDF::Content::Color :ColorName, :color, :rgb;

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

use Date::Names;
use Date::Event;
use Date::Utils;
use Calendar::Subs;
use Calendar::Vars;

class Day     {...} # requires: dow, name, abbrev, lang
class Month   {...} # requires: month, name, abbrev, lang
class Week    {...}
class Event   {...}
#class CalPage {...} # to be replaced by Month

# keys: 0,1..12,13,14
# cal-month zero is the December of the previous year
# cal-month 13 is the January of the following year
#has CalPage @.pages;

# the only user inputs respected at construction:
has $.year          = DateTime.now.year+1; # default is the next year
has $.lang          = 'en';                # US English
has $.cal-first-dow = 7;                   # Sunday
has $.media         = 'Letter';            # or 'A4'

# fill the dow list

# other attributes
has @.days-of-week;
has %.fonts;
has %.dimens;

has $.last; # last month of last year
has $.next; # first month of next year

has $.cover;
has @.appendix;

has Month %months; # keys 1..12
has Day @days;     # Julian days 0..^days-in-year;
has Event @events; #

submethod TWEAK() {
    @!days-of-week = days-of-week $!cal-first-dow;
    %!fonts  = load-fnts;
    %!dimens = dimens  $!media;
    self!build-calendar($!year, $!lang, $!cal-first-dow, @!days-of-week, $!media);
}

class Day does Named {
    #has $.date;
    has $.doy; # day of year 1..N (aka Julian day)
    has $.dow; # day of week 1..N (Sun..Sat)
    has $.month;
    has Event @.events;

    submethod TWEAK {
    }
}

class Week {
    has $.woy;  # week of the year 1..N
    has @.days-of-week; # depends on $cal-first-dow
    has @.days; # keys: 1..7

    submethod TWEAK {
    }
}

class Month does Named {
    #has $.year is required;
    #has $.number is required;     # month number (1..12)
    has $.page; # 0..14
    has $.cal-first-dow;
    has @.days-of-week;
    has $.media; # Letter, A4


    has @.weeks;  # 4..6
    has $.nweeks; # 4..6
    #has $.name;
    #has $.abbrev;
    has %.days;   # keys: 1..N (N = days in the month)

    submethod TWEAK {
        my $d = Date.new: :year($!year), :month($!number);
        # get name from Date::Names
        my $td = Date::Names.new: :lang($!lang);
        $!name = $td.mon($!number);

        # build the weeks
        $!nweeks = weeks-in-month :$!year, :month($!number), :$!cal-first-dow;
    }
}

=begin comment
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
=end comment

class Event is Date::Event {
}

method !build-calendar($year, $lang, $cal-first-dow, @days-of-week, $media) {
    # build all pieces of the calendar based on three input attrs:
    #   year, lang, cal-first-dow, days-of-week, media

    # build the pages (and Months)
    for 0..14 -> $page {
        my $d;
        my $m;
        if $page == 0 {
            $d = Date.new: :year($year-1), :month(12); # default is day 1
        }
        elsif $page < 13 {
            $d = Date.new: :year($year), :month($page);
        }
        else {
            $d = Date.new: :year($year+1), :month($page-12);
        }

        #my $p = CalPage.new: :year($d.year), :mnum($d.month);

        if $page == 0 {
            $m = Month.new: :$page, :number(12), :year($year-1), :$lang,
                            :$cal-first-dow, :@days-of-week;
            %!months{$page} = $m;
        }
        elsif 0 < $page < 13 {
            $m = Month.new: :$page, :number($page), :$year, :$lang,
                            :$cal-first-dow, :@days-of-week;
            %!months{$page} = $m;
        }
        else {
            $m = Month.new: :$page, :number($page-12), :year($year+1), :$lang,
                            :$cal-first-dow, :@days-of-week;
            %!months{$page} = $m;
        }

        # weeks per month???
        for %!months.kv -> $n, $m {
            my $wim = weeks-in-month :$year, :month($m.number), :$cal-first-dow;
            #$m.weeks-in-month: $wim;
            #$m.days-of-week: @days-of-week;
        }

        #@!pages.push: $p; # CalPage
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

        my $d = Day.new: :doy($J), :date($D), :dow($D.day-of-week),
                         :$lang, :number($J);

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
     :$debug
     ) {
}

method write-day-cell(
     PDF::Lite::Page :$page!,
     :$x!, :$y!,
     :$width!, :$height!,
     :%data!,  # includes Day, fonts, Events, etc,
     :$debug
     ) {

     # Translate to x,y as the day cell's upper-left corner
     # Note this method is called from a method where transformation
     #   to internal landscape orientation has already been done.

}

method write-page-cover(
    PDF::Lite::Page :$page!,
    :%data!,  # includes Day, fonts, Events, etc,
    :$debug
) {
    # Note media box was set for the entire document at $pdf definition
    # for this document, always use internal landscape, "right-side up"
    # i.e, NOT upside-down
    my $media = $!media;
    my %dimens = dimens $media;

    if $debug {
        note "DEBUG: media-box: ";
        dd $media;
        note "debug exit";
        exit;
    }

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
        # ONE MORE TRANSLATION IN Y=0 AT TOP OF PAPER
        # THEN Y DIMENS ARE NEGATIVE AFTER THAT
        # LLX, LLY -> LLX, URY
        .transform: :translate(0, $page.media-box[2]);

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

        my ($x,$y) = 0.5 * $w, 0.5 * $h;
        $y = %dimens<cover-year-base>;
        my $text = "The Year {self.year}";
        my $fontsize = 40;
        my $font = %!fonts<tb>;
        .set-font: $font, $fontsize;
        # write year line
        .print: $text, :position[$x,$y],
                       :align<center>, :valign<bottom>;

        # write presentation line
        $y = %dimens<cover-title-base>;
        $fontsize = 20;
        $font = %!fonts<tb>;
        .set-font: $font, $fontsize;
        $text = "A Special Calendar for a Special Person";
        .print: $text, :position[$x,$y], :$font,
                       :align<center>, :valign<bottom>;

        # write info lines
        $y = %dimens<cover-info-base>;
        $fontsize = 15;
        $font = %!fonts<t>;
        .set-font: $font, $fontsize;
        $text = "To Missy with love, from Tom";
        .print: $text, :position[$x,$y], :$font,
                       :align<center>, :valign<bottom>;

        #===================================
        # and, finally, restore the page CTM
        .Restore;
    }
}

method write-page-month-top(
    $mnum,
    PDF::Lite::Page :$page!,
    :%data,  # includes Day, fonts, Events, etc,
    :$debug
) {
    my $media = $!media;
    my %dimens = dimens $media;

    # Note media box was set for the entire document at $pdf
    # definition for this document, always use internal landscape,
    # "right-side up" i.e, NOT upside-down
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
        # ONE MORE TRANSLATION IN Y=0 AT TOP OF PAPER
        # THEN Y DIMENS ARE NEGATIVE AFTER THAT
        # LLX, LLY -> LLX, URY
        .transform: :translate(0, $page.media-box[2]);

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

        my ($x,$y) = 0.5 * $w, 0.5 * $h;
        my ($font, $fontsize);

        $y = %dimens<cover-year-base>;
        my $text = "(maybe put birthdays and anniversaries here)";
        $fontsize = 15;
        $font = %!fonts<t>;
        .set-font: $font, $fontsize;
        # write year line
        .print: $text, :position[$x,$y],
                       :align<center>, :valign<bottom>;

        #===================================
        # and, finally, restore the page CTM
        .Restore;
    }
}

method write-dow-cell-labels(
    $mnum,
    PDF::Lite::Page :$page!,
    :$debug
) {
    my $m    = %!months{$mnum}; # the Month
    my $dn   = Date::Names.new: :$!lang;
    my $font = %!fonts<hb>,

    my $g = $page.gfx;

    # always save the CTM
    $g.Save;
    # move to x,y of upper-left of the set
    my $x = %!dimens<sm>;
    my $y = %!dimens<month-cal-top>;

    $g.transform: :translate($x, $y);

    my $cxc = %!dimens<cell-width>; # center of any cell from its left side (x)
    my $text;

    $x = 0;
    $y = 0;
    for $m.days-of-week.kv -> $i, $downum {
        #print "DEBUG: dow cell $i, x = $x";
        # we're at the upper-left corner, draw the box
        my $dindex = day-index-in-week $downum, :cal-first-dow($m.cal-first-dow);
        my $dnum = $m.days-of-week[$dindex];
        # get the name
        $text = $dn.dow($dnum);

        # show the text at the center of the box
        my @BBox = [0, 0,  %!dimens<cell-width>,  %!dimens<dow-height>];
        my $form =  $page.xobject-form: :@BBox;
        $form.graphics: {
            .Save;
            # color the entire form
            .FillColor = rgb(0, 0, 0); #color Black;
            .Rectangle: |@BBox;
            .paint: :fill, :stroke;
            .FillColor = rgb(1, 1, 1); #color White;
            # add some sample text
            my $cx = 0.5 * (@BBox[2] - @BBox[0]);
            my $cy = 0.5 * (@BBox[3] - @BBox[1]);
            .text: {
                .font = $font, %!dimens<dow-height>-1;
                .print: $text, :position[$cx, $cy], :align<center>, :valign<center>;
            }
            .Restore;
        }

        $page.graphics: {
            .Save;
            my $cx = $x + 0.5 * %!dimens<cell-width>;
            my $cy = $y - 0.5 * %!dimens<cell-height>;
            .transform: :translate($cx, $cy);
            .do($form);
            .Restore;
        }
        $x += %!dimens<cell-width>;
    }
    #say();

    # Don't forget to restore the CTM
    $g.Restore

}

method box($g, :$x, :$y, :$height, :$width) {
    my $color = rgb(0, 0, 0); # black
    $g.Save;
    $g.FillColor   = $color;
    $g.StrokeColor = $color; #rgb(0.0, 0.0, 0.0); # black
    $g.LineWidth   = 0;
    $g.transform: :translate($x, $y);
    $g.MoveTo: $x, $y;
    $g.LineTo: $x, $y-$height;
    $g.LineTo: $x+$width, $y-$height;
    $g.LineTo: $x+$width, $y;
    $g.ClosePath;
    #$g.Stroke;
    $g.FillStroke;
    $g.Restore;
}

method write-page-month(
    $mnum,
    PDF::Lite::Page :$page!,
    :%data!,  # includes Day, fonts, Events, etc,
    :%Days,   # 1..365|366 for the calendar year
    :$debug
) {

    my $cell-label-fontsize = 14;
    my $cell-label-height   = 15;
    my $cell-fontsize = 15;

    my $media = $!media;
    my %dimens = dimens $media;
    my $m = %!months{$mnum}; # the Month

    # Note media box was set for the entire document at $pdf definition
    # for this document, always use internal landscape, "right-side up"
    # i.e, NOT upside-down

    # alternative method for .graphics use:
    =begin comment
    $page.graphics: -> $g {
        $g.<method>;
    }
    =end comment

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
        # ONE MORE TRANSLATION IN Y=0 AT TOP OF PAPER
        # THEN Y DIMENS ARE NEGATIVE AFTER THAT AS WE ARE AT
        # THE UPPER LEFT CORNER OF THE PAGE:  LLX, LLY -> LLX, URY
        .transform: :translate(0, $page.media-box[2]);

        $w = $page.media-box[3] - $page.media-box[1];
        $h = $page.media-box[2] - $page.media-box[0];

        # layout dimensional values for the page based on media size
        #   day column widths are:
        #        total width
        #      - side margins
        #      / 7
        my $xleft   = 0;
        my $col-wid = 0;
        #   week heights are:
        #        binding-offset
        #      - top margin
        #      - month title
        #      - space
        #      - saying
        #      - space
        #      - dow titles
        #      - bottom margin
        #      / 6

        # fill page as desired, e.g.,
        # $cx = 0.5 * $w;
        # $cy = 0.5 * $h;
        # my @position = [$cx, $cy];
        # my @box = .print: $text, :@position, :$font,
        #           :align<center>, :valign<center>;
        # make other calls with the page CTM
        # ...
        #===================================

        my ($x,$y) = 0.5 * $w, 0.5 * $h;
        my ($font, $fontsize);

        $y = %dimens<month-name-base>;
        my $text = $m.name;
        $fontsize = 20;
        $font = %!fonts<tb>;
        .set-font: $font, $fontsize;
        # write month line
        .print: $text, :position[$x,$y],
                       :align<center>, :valign<bottom>;

        # write the sayings line
        $font = %!fonts<ti>;
        $fontsize = 15;
        .set-font: $font, $fontsize;
        $y = %dimens<month-quote-base>;
        $text = @sayings[$m.number];
        .print: $text, :position[$x,$y],
                       :align<center>, :valign<bottom>;


        =begin comment
        # all below need the same width in total
        my $cal-width  = $w - (2 * %dimens<sm>);
        my $cell-width = $cal-width / 7.0;
        my $dn = Date::Names.new: :$!lang, :dset<dow3>;
        $font = %!fonts<tb>;
        $fontsize = 10;
        .set-font: $font, $fontsize;
        $x = %dimens<sm>;
        $y = %dimens<month-cal-top>;
        my $lwidth = ($w - (2 * %dimens<sm>)) / 7.0;
        =end comment

        # write the dow labels line
        self.write-dow-cell-labels: $mnum, :$page;

        =begin comment
             , :$x, :$y, :$cal-width, :$cell-width,
             :fontsize($cell-fontsize), :$page, :%data, :%!fonts,
             :$cell-height, :$debug;
        =end comment


        # write the weeks
        for $m.weeks -> $w {
            # set upper-left position

            for $w.days -> $d {
                # set upper-left position

                # write the day cell
                self.write-day-cell();
            }
        }



        #===================================
        # and, finally, restore the page CTM
        .Restore;
    }
}
