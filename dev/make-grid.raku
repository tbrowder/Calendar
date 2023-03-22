#!/bin/env raku

use PDF::Lite;
use PDF::Font::Loader;
use PDF::Content::Color :ColorName, :&color;

use lib <../lib>;
use Calendar::Vars;

# title of output pdf
my $ofile = "calendar.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a test PDF

    Options
        o[file]=X - Output file name [default: calendar.pdf]

        d[ebug]   - Debug
    HERE
    exit
}

for @*ARGS {
    when /^ :i o[file]? '=' (\S+) / {
        $ofile = ~$0;
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

# Do we need to specify 'media-box' on the whole document?
# No, it can be set per page.
my $pdf = PDF::Lite.new;
$pdf.media-box = 'Letter';
my $font  = $pdf.core-font(:family<Times-RomanBold>);
my $font2 = $pdf.core-font(:family<Times-Roman>);

# write the desired pages
# ...
# start the document with the first page
make-cal-cover :$pdf;

make-cal-top-page :$pdf;
make-cal-page :$pdf;

make-cal-top-page :$pdf;
make-cal-page :$pdf;

my $pages = $pdf.Pages.page-count;
# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See outout pdf: $ofile";
say "Total pages: $pages";


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
    :$height = LH,
    :$width  = LW,
    :$landscape = True,
    :$debug,
    # payload
    :$month, # class holding all date info to be printed
    
) is export {
    # media-box - width and height of the printed page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page
    my $page = $pdf.add-page;

    my $gfx = $page.gfx; #.graphics;
    if $landscape {
        $gfx.Save;
        $gfx.transform: :translate[$width, 0];
        $gfx.transform: :rotate(deg2rad(90));
    }

    # make the title line (month, year

    # make the sayings line

    # make the grid (dow, then 4, 5, or 6 weeks)
    for (20, 40 ... 200)  -> $x {
        for 20, 40, 60 -> $y {
            $gfx.&make-box: :$x, :$y, :width(20), :height(20);
        }
    }

    if $landscape {
        $gfx.Restore;
    }
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
    .Save;
    # transform to the bottom-left corner
    .transform: :translate[$x, $y];
    .Rectangle: 0, 0, $width, $height;
    .CloseStroke;
    # print or draw the data
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
