#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

my $ofile = "draw-cells.pdf";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates drawing cells containing text and graphics.
    HERE
    exit
}

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
my $font = $pdf.core-font('Times-Roman');
# letter, portrait
$page.media-box = [0, 0, 8.5*72, 11*72];

my $height = 1*72;
my $width  = 1.5*72;
my $x0     = 0.5*72;
my $y0     = 8*72;

for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    draw-cell :$page, :x0($x), :$y0, :$width, :$height;
    write-cell-line :$text, :$page, :x0($x), :$y0, :$width, :$height, :$font;
}

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

#==== subroutines
sub write-cell-line(
    # One line of text only
    :$text = "<text>",
    :$page!,
    :$x0!, :$y0!, # the desired text origin
    :$width!, :$height!,
    :$font!,
    :$font-size is copy = 10,
) is export {
    $page.text: {
        # $x0, $y0 MUST be the desired origin for the text
        .text-transform: :translate($x0+0.5*$width, $y0-0.5*$height);
        #.font = .core-font('Helvetica'), 15;
        .font = $font, $font-size;
        .print: $text, :kern, :align<center>, :valign<center>;
    }
}

sub draw-cell(
    # graphics only
    :$page!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    :$borderwidth = 1.5,
) is export {
    my ($w, $h, $bw) = $width, $height, $borderwidth;
    $page.graphics: {
        # Prepare the cell by filling with black then move inside by
        # border width and fill with desired color
        .Save;
        .transform: :translate($x0, $y0);

        # Fill cell with border color and clip to exclude color
        # outside created by the linewidth
        .SetFillGray: 0;
         # rectangles start at their lower-left corner
        .Rectangle: 0, 0-$h, $w, $h;
        .ClosePath;
        .Clip;
        .Fill;

        # Fill cell with background color and clip it inside by the
        # border width
        .SetFillGray: 1;
        .Rectangle: 0+$bw, 0-$h+$bw, $w-2*$bw, $h-2*$bw;
        .Clip;
        .Fill;

        .Restore;
    }
}
