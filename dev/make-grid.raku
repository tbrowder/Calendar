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
make-portrait :$page;

$pdf.add-page;
++$pages;
make-landscape :$page;

$pdf.add-page;
++$pages;
make-landscape :$page;

# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See outout pdf: $ofile";
say "Total pages: $pages";

sub make-portrait(
    PDF::Lite::Page :$page!,
    :$debug
) is export {

    my $centerx = 11*0.5*72; # when page has been rotated
    $page.text: -> $txt {
        my ($text, $baseline);

	# in this block, we place text at various
	# positions on the page, possibly varying
	# the font and font size as well as
	# its alignment
	
	# y=0 is at bottom of the media box
	# x=0 is at the left of the media box

        $baseline = 7*72;
        $txt.font = $font, 16;

        $text = "Some text";
        $txt.text-position = 0, $baseline; # baseline height is determined here
        # output aligned text
        $txt.say: $text, :align<center>, :position[$centerx];
    }
}

sub make-landscape(
    ) is export {
}

