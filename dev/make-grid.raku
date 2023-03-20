#!/bin/env raku

use PDF::Lite;
use PDF::Font::Loader;

use lib "./lib";
use Subs;

my enum Paper <Letter A4>;
my $debug   = 0;
my $left    = 1 * 72; # inches => PS points
my $right   = 1 * 72; # inches => PS points
my $top     = 1 * 72; # inches => PS points
my $bottom  = 1 * 72; # inches => PS points
my $margin  = 1 * 72; # inches => PS points
my Paper $paper  = Letter;

# title of output pdf
my $ofile = "calendar.pdf";

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
# in landscape orientation
my $height =  8.5 * 72;
my $width  = 11.0 * 72;

for @*ARGS {
    when /^ :i o[file]? '=' (\S+) / {
        $ofile = ~$0;
    }
    when /^ :i l[eft]? '=' (\S+) / {
        $left = +$0 * 72;
    }
    when /^ :i r[ight]? '=' (\S+) / {
        $right = +$0 * 72;
    }
    when /^ :i t[op]? '=' (\S+) / {
        $right = +$0 * 72;
    }
    when /^ :i b[ottom]? '=' (\S+) / {
        $bottom = +$0 * 72;
    }
    when /^ :i m[argin]? '=' (\S+) / {
        $margin = +$0 * 72;
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

# do we need to specify 'media-box'?
my $pdf = PDF::Lite.new;
$pdf.media-box = 'Letter';
my $font  = $pdf.core-font(:family<Times-RomanBold>);
my $font2 = $pdf.core-font(:family<Times-Roman>);

=begin  omment
$page.rotate = 90; # result?
my $pages = 1;
=end  omment

my $pages = 0;
# write the desired pages
# ...
# start the document with the first page
my PDF::Lite::Page $page = $pdf.add-page;
++$pages;
make-page :$page;

$pdf.add-page;
++$pages;
make-page :$page; #, :rotate(True);

$pdf.add-page;
++$pages;
make-page :$page;

# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See outout pdf: $ofile";
say "Total pages: $pages";

sub make-page(
    PDF::Lite::Page :$page!,
    :$long-dimen = 11 * 72,
    :$short-dimen = 8.5 * 72,
    :$rotate = 0,
    :$debug
) is export {
    # media-box - width and height of the printed page
    # crop-box  - region of the PDF that is displayed or printed
    # trim-box  - width and height of the printed page
    #$page.TrimBox = Letter; #media-box = Letter; #[0, 0, $w, $h];

    if $rotate {
        $page.rotate;
    }
    $page.text: -> $txt {

        my $cx = $short-dimen * 0.5; # for the given media-box
        my $cy = $long-dimen * 0.5; # for the given media-box

	# y=0 is at bottom of the media box
	# x=0 is at the left of the media box

	# in this block, we place text at various
	# positions on the page, possibly varying
	# the font and font size as well as
	# its alignment

        $txt.font = $font, 40;

        my $text = "Some text";
	$txt.text-position = 40, $long-dimen-40;
        # output aligned text
        $txt.say: $text, :align<left>, :valign<top>;
    }
}

sub make-landscape(
    PDF::Lite::Page :$page!,
    :$debug
    ) is export {
}
