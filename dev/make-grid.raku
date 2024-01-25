#!/bin/env raku

use PDF::Lite;
#use PDF::Font::Loader :load-font;
use PDF::Content::Color :ColorName, :&color;
use Date::Utils;
use Abbreviations;

=begin comment
# font files in standard Debian location
my $tb-fil = "/usr/share/fonts/opentype/freefont/FreeSerifBold.otf";
my $hb-fil = "/usr/share/fonts/opentype/freefont/FreeSansBold.otf";
my $h-fil  = "/usr/share/fonts/opentype/freefont/FreeSans.otf";
my $ti-fil = "/usr/share/fonts/opentype/freefont/FreeSerifItalic.otf";
my $t-fil  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my %fonts;
%fonts<tb> = load-font :file($tb-fil);
%fonts<ti> = load-font :file($ti-fil);
%fonts<t>  = load-font :file($t-fil);
%fonts<h>  = load-font :file($h-fil);
%fonts<hb> = load-font :file($hb-fil);
=end comment

use lib <../lib>;
use Calendar;
use Calendar::Subs;
use Calendar::Vars;

my $media = 'Letter';
my $lang  = 'en';
my $debug = 0;
my $year = Date.today.year;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a test PDF calendar using Letter or
      A4 paper in landscape orientation.
    Larger sizes can be provided if necessary.

    Options
        y[ear]=X  - Year [default: $year]
        o[file]=X - Output file name [default: calendar-$year.pdf]
        m[edia]=X - Page format [default: Letter]
        l[ang]=X  - Language (ISO two-letter code) [default: $lang]
        d[ebug]   - Debug
    HERE
    exit
}

my $ofile;
for @*ARGS {
    when /^ :i y[e|ea|ear]? '=' (\d**4) / {
        $year = +$0;
    }
    when /^ :i l[a|an|ang]? '=' (\S+) / {
        $lang = ~$0.lc;
    }
    when /^ :i o[f|fi|fil|file]? '=' (\S+) / {
        $ofile = ~$0;
        unless $ofile ~~ /:i \.pdf$/ {
            $ofile ~= ".pdf";
        }
    }
    when /^ :i m[e|ed|edi|edia]? '=' (\S+) / {
        $media = ~$0;
        unless $media eq 'Letter' or $media eq 'A4' {
            die qq:to/HERE/;
            FATAL: Media choices currently are 'Letter' or 'A4'
                   You entered '$media'.
                   File an issue if you need another format.
            HERE
            exit;
        }
    }
    when /^ :i d / { ++$debug }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

# default title of output pdf
unless $ofile.defined {
    $ofile = "calendar-$year.pdf";
}
my $cal = Calendar.new: :$year, :$lang;

# Do we need to specify 'media-box' on the whole document?
# No, it can be set per page.
my $pdf = PDF::Lite.new;
$pdf.media-box = $media; #'Letter';

# write the desired pages
my $page;
my %data;
# ...
# start the document with the first page
$page = $pdf.add-page;
$cal.write-page-cover: :$page, :%data;

for 1..14 -> $month is copy {
    if $month == 13 {
        my $y = $cal.year + 1;
        $cal = Calendar.new: :year($y), :$lang; 
        $month = 1;
    }
    elsif $month == 14 {
        $month = 2;
    }
   
    $page = $pdf.add-page;
    $cal.write-page-month-top: $month, :$page, :%data;
    $page = $pdf.add-page;
    $cal.write-page-month: $month, :$page, :%data;
}

my $pages = $pdf.Pages.page-count;
# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See PDF calendar for year $year: $ofile";
say "Total pages: $pages";

=finish

sub deg2rad($d) { $d * pi / 180 }
sub make-cal-cover(
    PDF::Lite :$pdf!,
    :$height = LH,
    :$width  = LW,
    :$landscape = True,
    :$debug
) is export {
}

sub make-cal-top-page(
    PDF::Lite :$pdf!,
    :$height = LH,
    :$width  = LW,
    :$landscape = True,
    :$debug,
    # payload
) is export {
}

sub make-cal-page(
    PDF::Lite :$pdf!,
    :$debug,
    # payload
    Calendar :$cal!,
    UInt :$month!, # month number
    
) is export {
    # media-box - width and height of the printed page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page
    my $page = $pdf.add-page;
    my $gfx = $page.gfx;

    # always use landscape orientation
    $gfx.Save;
    $gfx.transform: :translate[LW, 0];
    $gfx.transform: :rotate(deg2rad(90));

    # hard vertical dimensions:
    #   bottom of the 6-week grid above the bottom margin BM
    #   top of the 6-week grid above its bottom
    #   height of the week-day column names

    # font names and sizes:
    #   month/year title - Times-Bold 20 pt
    #   monthly quotes - Times-Italic 15 pt
    #   day text:
    #     line-space-ratio - 1.05
    #     white-on-black day-of-week - Helvetica-Bold 12 pt
    #     holidays, birthdays, etc. - Times-Bood 10 pt, indent 5
    #                               
    #     day number - Helvetica 12 pt (outline for "negative" day numbers)
    #                  offset x - 4 pt from the right of cell
    #                  offset y - 12 * line-space-ratio from top of cell
    #     sun rise/set
    #     moon phase
    #     moon phase symbol 0.3 in from bottom of the cell

    # make the title line (month, year

    # make the sayings line

    # make the grid (dow, then 4, 5, or 6 weeks)
    my $nweeks = weeks-in-month $cal.month;
    my $width  = (LH - 2 * LM)/7; # use full width less two margins
    # leave space for title and cell header row
    my $title-baseline = 72;
    my $grid-top-space = 10;
    my $cell-hdr = 10;
    my $height = (LH - 2 * LM)/6;

    for (20, 40 ... 200)  -> $x {
        for 20, 40, 60 -> $y {
            $gfx.&make-box: :$x, :$y, :$width, :$height;
        }
    }

    # fill each cell appropriately
    #   create a mapping from day-of-week and week-of-month
    #   to cell in the grid




    # must alway restore the CTM
    $gfx.Restore;
}

# subs for gfx calls (I do not understand this!!)
sub make-box($_,
    :$x!, :$y!, :$width!, :$height!,
    :$linewidth = 2,
    :$debug,
    # payload
) is export {
    # given the bottom-left corner, dimensions, etc
    # draw the box
    # must save the CTM
    .Save;

    # transform to the bottom-left corner
    .transform: :translate[$x, $y];
    .Rectangle: 0, 0, $width, $height;
    .CloseStroke;

    # print or draw the data

    # restore the CTM
    .Restore;
}

sub put-text(
    PDF::Lite::Page :$page!, 
    :$debug) is export {

    $page.text: -> $txt {
        $txt.font = $font, 10;
        my $text = "Other text";
	$txt.text-position = 200, 200;
        $txt.say: $text, :align<center>; #, :valign<baseline>;
    }
}
