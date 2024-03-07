#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;
use PDF::Content::Page;
use PDF::Content::PageTree;
use PDF::Content::Color :ColorName, :color;

use lib <./lib>;
use Howto;

# various font files on Linux
my $ffil  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
die "NOFILE: FreeSerif not found" unless $ffil.IO.r;

my $ofile = "howto.pdf";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates drawing cells containing text and graphics
    on the same page using separate blocks.

    HERE
    exit
}

my PDF::Lite $pdf .= new;
my PDF::Content::FontObj $font = load-font :file($ffil); # FreeSerif
my $font-size = 10;
my PDF::Lite::Page $page;
for 1..3 {
    $page = $pdf.add-page;
    new-page :$page, :landscape(True);;
}

$pdf.save-as: $ofile;
my $np = $pdf.page-count;
say "See output file: ", $ofile;
say "Page count: $np";

=begin comment
# letter, portrait
$page.media-box = [0, 0, 8.5*72, 11*72];
$page = start-page :$page, :landscape(True);

my $height = 1*72;
my $width  = 1.5*72;
my $x0     = 0.5*72;
my $y0     = 7*72;

# draw a border around the N cells first
draw-box :$page, :inside(False), :llx($x0+$width), :lly($y0-$height),
                    :width(3*$width), :$height;
for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    draw-box :$page, :llx($x), :lly($y0-$height), :$width, :$height;
    put-text :$text, :$page, :x-origin($x+0.5*$width), :y-origin($y0-0.5*$height), 
                     :$width, :$font, :align<center>, :valign<center>;
}

#$page = finish-page :$page;
=end comment

#==== subroutines
=finish

sub start-page(
    PDF::Content::Page :$page!,
    :$landscape = False,
    --> PDF::Content::Page
) is export {
}
sub finish-page(
    PDF::Content::Page :$page!,
) is export {
}

sub put-text(
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
    $page.gfx: {
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

sub draw-box(
    PDF::Content::Page :$page!,
    Bool :$inside!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    :$borderwidth = 1.0,
    :$border-color = "black",
    :$background = "white",
) is export {
    my ($w, $h, $bw) = $width, $height, $borderwidth;

    $page.gfx: {
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
