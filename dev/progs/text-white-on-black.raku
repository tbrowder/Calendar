#!/bin/env raku

use PDF::API6;
#use PDF::Lite;
use PDF::Content::Page :PageSizes;
#use PDF::Content::Font;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::Ops :TextMode;

my PDF::API6 $pdf .= new;
# preview of title of output pdf
my $ofile = "text-white-on-black.pdf";

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;
my $media = 'Letter';
$pdf.media-box = %(PageSizes.enums){$media};
my $font = $pdf.core-font(:family<Times-Roman>, :weight<bold>); # good

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    HERE
    exit
}

my ($text, $page);
$page = $pdf.add-page;
my $cx = 0.5 *  8.5 * 72.0;
my $cy = 0.5 * 11.0 * 72.0;

$page.graphics: {
    .Save;
    .FillColor = color Black;
    # llx, lly, width, height (or vice versa: height, width)
    .Rectangle($cx-50, $cy-50, 100, 100);
    .Fill;
    .text: {
        .font = $font, 20;
        .FillColor = color White;
        .LineWidth = 0;
        .text-position = $cx, $cy;
        .print: "Filled, solid", :align<center>, :position[$cx, $cy], :valign<center>;
    }
    .Restore;
}

=begin comment
$page.graphics: {
    #.FillColor = color Black;
    #.Rectangle($cx-50, $cy-50, $cx+50, $cy+50);
    #.Fill;
    .text: {
        .font = $font, 20;
        .FillColor = color Black; #White;
        .LineWidth = 0;
        #.text-position = $cx, $cy;
        .print: "Filled, solid", :align<center>, :position[$cx, $cy], :valign<center>;
    }
}
=end comment

# finish the document
$pdf.save-as: $ofile;
say "See output file: $ofile";

=finish

# subroutines
sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$text!,
              :$font!,
              :$media,
              :$landscape,
              :$upside-down,
) is export {

    # using make-page, modified, from PDF::Document.make-page
    # always save the CTM
    $page.media-box = %(PageSizes.enums){$media};
    $page.graphics: {
        # always save the CTM
        .Save;

        my ($cx, $cy);
        my ($w, $h);
        if $landscape {
            if not $upside-down {
                # Normal landscape
                # translate from: lower-left corner to: lower-right corner
                # LLX, LLY -> URX, LLY
                .transform: :translate($page.media-box[2], $page.media-box[1]);
                # rotate: left (ccw) 90 degrees
                .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
            else {
                # $upside-down: invert the page image
                # translate from: lower-left corner to: upper-left corner
                # LLX, LLY -> LLX, URY
                .transform: :translate($page.media-box[0], $page.media-box[3]);
                # rotate: right (cw) 90 degrees
                .transform: :rotate(-90 * pi/180); # right (cw) 90 degrees
                # lengths should be the same
                $w = $page.media-box[3] - $page.media-box[1];
                $h = $page.media-box[2] - $page.media-box[0];
            }
        }
        else {
            $w = $page.media-box[2] - $page.media-box[0];
            $h = $page.media-box[3] - $page.media-box[1];
        }

        $cx = 0.5 * $w;
        $cy = 0.5 * $h;
        my @position = [$cx, $cy];
        my @box = .print: $text, :@position, :$font,
        :align<center>, :valign<center>;

        # and restore the CTM
        .Restore;
    }

    =begin comment
    my ($cx, $cy);
    if $media {
        # use the page media-box
        $page.media-box = %(PageSizes.enums){$media};
        $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
        $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);
    }
    else {
        $cx = 0.5 * ($pdf.media-box[2] - $pdf.media-box[0]);
        $cy = 0.5 * ($pdf.media-box[3] - $pdf.media-box[1]);
    }

    $page.graphics: {
        #my @box = .say: "Second page", :@position, :$font, :align<center>, :valign<center>;
        .print: $text, :position[$cx, $cy], :$font, :align<center>, :valign<center>;
    }
    =end comment
}
