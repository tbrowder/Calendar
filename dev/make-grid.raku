#!/bin/env raku

use PDF::Lite;
use PDF::Font::Loader;
use PDF::Content::Color :ColorName, :&color;

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

# defaults for US Letter paper
# in portrait orientation
constant $WIDTH  =  8.5 * 72;
constant $HEIGHT = 11.0 * 72;

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
my $landscape =True;
make-cal-page :$pdf;

make-cal-page :$pdf;

my $pages = $pdf.Pages.page-count;
# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See outout pdf: $ofile";
say "Total pages: $pages";


sub deg2rad($d) { $d * pi / 180 }
sub make-cal-page(
    PDF::Lite :$pdf!,
    :$height = $HEIGHT,
    :$width  = $WIDTH,
    :$landscape = True,
    :$debug
) is export {
    # media-box - width and height of the printed page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page
    #$page.TrimBox = Letter; #media-box = Letter; #[0, 0, $w, $h];
    my $page = $pdf.add-page;


    my $gfx = $page.gfx; #.graphics;
    if $landscape {
	# TODO: check for valid angle
        $gfx.Save;
        $gfx.transform: :translate[$width, 0];
        $gfx.transform: :rotate(deg2rad(90));
    }

    for (20, 40 ... 200)  -> $x {
        for 20, 40, 60 -> $y {
            $gfx.&make-box: :$x, :$y, :width(20), :height(20);
        }
    }

    if $landscape {
        $gfx.Restore;
    }

    =begin comment
    with $gfx {

        my $gfx2 = $page.gfx; #.graphics;
    }
    =end comment
}


# subs for gfx calls (I do not understand this!!)
sub make-box($_,
    :$x!, :$y!, :$width!, :$height!,
    :$linewidth = 2,
) {
    # given the bottom-left corner, dimensions, etc
    # draw the box
    .Save;
    # transform to the bottom-left corner
    .transform: :translate[$x, $y];
    .Rectangle: 0, 0, $width, $height;
    .CloseStroke;
    .Restore;
}

sub put-text(PDF::Lite::Page :$page!, :$debug) {
    $page.text: -> $txt {
        $txt.font = $font, 10;
        my $text = "Other text";
	$txt.text-position = 200, 200;
        $txt.say: $text, :align<center>; #, :valign<baseline>;
    }
}
