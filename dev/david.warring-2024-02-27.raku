#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;
use PDF::Content::Page;
use PDF::Content::PageTree;
use PDF::Content::Color :ColorName, :color;

# various font files on Linux
my $ffil  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
die "NOFILE: FreeSerif not found" unless $ffil.IO.r;

my $ofile = "david.warring.pdf";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates drawing cells containing text and graphics
    on the same page using separate blocks.

    It would be handy to call routines within a \$page.graphics
    block. Is that possible?
    HERE
    exit
}


my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
my PDF::Content::FontObj $font = load-font :file($ffil); # FreeSerif
my $font-size = 10;
# letter, portrait
$page.media-box = [0, 0, 8.5*72, 11*72];

my $height = 1*72;
my $width  = 1.5*72;
my $x0     = 0.5*72;
my $y0     = 9*72;
# draw a border around the N cells first
draw-border :$page, :inside(False), :x0($x0+$width), :$y0,
                    :width(3*$width), :$height;
for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    draw-cell :$page, :x0($x), :$y0, :$width, :$height;
    write-text-box :$text, :$page, :x0($x), :$y0, :$width, :$height, :$font;
}

$y0     = 6*72;
# draw a border around the N cells first
draw-border :$page, :inside(False), :x0($x0+$width), :$y0,
                    :width(3*$width), :$height;
for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    mixed-write :$text, :$page, :x0($x), :$y0, :$width, :$height, :$font;
}

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

#==== subroutines
sub mixed-write(
    :$text,
    PDF::Content::Page :$page!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    :$borderwidth = 1.0,
    :$border-color = "black",
    :$background = "white",
    :$font is copy,
    :$font-size is copy = 10,
    :$valign is copy = "bottom",
    :$align is copy  = "left",
) is export {
    $align  = "center";
    $valign = "center";

    my ($w, $h, $bw) = $width, $height, $borderwidth;
    my PDF::Content::Text::Box $text-box;
    $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ :$height # restricts the size of the box

    sub draw-rect($page, $w, $h) {
        $page.graphics: {
            .SetStrokeGray: 0.5;
            .SetLineWidth: 1;
            .Rectangle(0, -$h, $w, $h);
            .Stroke;
        }
    }

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
        .Save;
        .transform: :translate(0, 50);
        draw-rect(.canvas(), $w, $h);
        .Restore;

        # Fill cell with background color and clip it inside by the
        # border width
        .SetFillGray: 1;
        .Rectangle: 0+$bw, 0-$h+$bw, $w-2*$bw, $h-2*$bw;
        .Clip;
        .Fill;

        #==== DAVID!! is there any way to call a sub or method here to further
        #====    modify $page with a text-box instead of the following code?

        # put a text-box here
        .BeginText;
        .SetFillGray: 0;
        .text-position = [0.5*$w, -0.5*$h];
        .print: $text-box;
        .EndText;

        .Restore;
    }
}

sub write-text-box(
    :$text = "<text>",
    PDF::Content::Page :$page! is copy,
    :$x0, :$y0!, # the desired text origin
    :$width!, :$height!,
    :$font!,
    :$font-size is copy = 10,
    :$valign is copy = "bottom",
    :$align is copy  = "left",
) is export {
    $align  = "center";
    $valign = "center";
    my ($w, $h) = $width, $height;
    my PDF::Content::Text::Box $text-box;
    $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ :$height # restricts the size of the box
    $page.graphics: {
        .Save;
        .transform: :translate($x0, $y0);
        # put a text box inside
        .BeginText;
        .text-position = [0.5*$w, -0.5*$h];
        .print: $text-box;
        .EndText;
        .Restore;
    }
}
sub draw-border(
    PDF::Content::Page :$page!,
    Bool :$inside!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    :$borderwidth = 1.0,
    :$border-color = "black",
    :$background = "white",
) is export {
    my ($w, $h, $bw) = $width, $height, $borderwidth;

    $page.graphics: {
        # Prepare the cell by filling with black then move inside
        # (or outside) by border width and fill with desired color
        .Save;
        .transform: :translate($x0, $y0); # upper-left corner

        # Fill cell with border color and clip to exclude color
        # outside (or inside) created by the borderwidth
        .SetFillGray: 0;
         # rectangles start at their lower-left corner
         if $inside {
            .Rectangle: 0, 0-$h, $w, $h;
         }
         else {
            .Rectangle: 0-$bw, 0-$h-$bw, $w+2*$bw, $h+2*$bw;;
         }
        .ClosePath;
        .Clip;
        .Fill;

        # Fill cell with background color and clip it inside
        # (or outside) by the border width
        .SetFillGray: 1;
         if $inside {
            .Rectangle: 0+$bw, 0-$h+$bw, $w-2*$bw, $h-2*$bw;
         }
         else {
            .Rectangle: 0, 0-$h, $w, $h;
         }
        .Clip;
        .Fill;

        .Restore;
    }
}

sub draw-cell(
    # graphics only
    PDF::Content::Page :$page!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    :$borderwidth = 1.0,
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
        .Rectangle(0, 0-$h, $w, $h);
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
