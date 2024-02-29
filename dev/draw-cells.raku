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
use PDF-Subs;

# various font files on Linux
my $ffil  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
die "NOFILE: FreeSerif not found" unless $ffil.IO.r;

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
my PDF::Content::FontObj $font = load-font :file($ffil); # FreeSerif
my $font-size = 10;
# letter media
#$page.media-box = [0, 0, 8.5*72, 11*72];
# landscape
start-page :$page, :landscape(True), :media<Letter>; 

# cell dimensions
my $height = 1*72;
my $width  = 1.5*72;
# left margin of the row of cells
my $x0     = 0.5*72;
# top margin of row of cells
my $y0     = 9*72;
my $border-color = "black";
my $border-width = 1.5;
my $fill-color = "white";
my $font-color = "black";
# draw a border around the N cells first
# draw-box's start point is the lower-left corner of the desired box
my ($llx, $lly, $x-origin, $y-origin, $text, $align, $valign);
draw-box :$page, :inside(False), :llx($x0+$width), :lly($y0-$height),
                 :width(3*$width), :$height;

$lly = $y0 - $height;
$y-origin = $lly + 0.5 * $height;
$align = "center";
$valign = "center";

for 1..3 -> $i {
    $llx = $x0 + $i * $width;
    $x-origin = $llx + 0.5 * $width;

    my $text = "Number $i";
    draw-box :$page, :$llx, :$lly, :$width, :$height, :$border-width,
             :$border-color, :$fill-color;
    put-text :$text, :$page, :$x-origin, :$y-origin, :$font, :$font-size, 
             :$align, :$valign, :$font-color;
}

=begin comment
$y0     = 6*72;
# draw a border around the N cells first
$page = draw-border :$page, :inside(False), :x0($x0+$width), :$y0,
                    :width(3*$width), :$height;
for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
}

$y0     = 3*72;
# draw a border around the N cells first
$page = draw-border :$page, :inside(False), :x0($x0+$width), :$y0,
                    :width(3*$width), :$height;
for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
}
=end comment
finish-page :$page; # .Restore 

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

=finish

#==== subroutines
sub draw-border(
    PDF::Content::Page :$page!,
    Bool :$inside = True,,
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
    $page
}

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
    --> PDF::Content::Page
) is export {
    $align  = "center";
    $valign = "center";

    my ($w, $h, $bw) = $width, $height, $borderwidth;
    my PDF::Content::Text::Box $text-box;
    $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ :$height # restricts the size of the box

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

        # put a text-box
        .BeginText;
        .SetFillGray: 0;
        .text-position = [0.5*$w, -0.5*$h];
        .print: $text-box;
        .EndText;

        .Restore;
    }
    $page
}

=begin comment
sub mixed-write-sub-call(
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
    write-text-box :$text, :is-fragment, :$page, :x0(0.5*$width), :y0(0.5*$height),
                              :$width, :$height, :$font, :align<center>,
                               :valign<center>;
}
=end comment

sub write-text-box(
    :$text = "<text>",
    :$is-fragment = False,
    PDF::Content::Page :$page! is copy,
    :$x0, :$y0!, # the desired text origin
    :$width!, :$height!,
    :$font!,
    :$font-size is copy = 10,
    :$valign is copy = "bottom",
    :$align is copy  = "left",
    #--> PDF::Content::Page
) is export {
    $align  = "center";
    $valign = "center";
    my ($w, $h) = $width, $height;
    my PDF::Content::Text::Box $text-box;
    $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ :$height # restricts the size of the box
    die "Tom, fix this" if $is-fragment;
    if  $is-fragment {
        # handle it...
        $page = PDF::Content::PageTree.page-fragment;
    }

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
