#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;
use PDF::Content::Page;
use PDF::Content::PageTree;
use PDF::Content::Color :ColorName, :color;

use lib <../lib>;
#use PDF-Subs;
use PageProcs;

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
my $border-color = "Black";
my $border-width = 1.5;
my $fill-color = "White";
my $font-color = "Black";
my ($y0, $llx, $lly, $x-origin, $y-origin, $text, $align, $valign);
$align = "center";
$valign = "center";

# top margin of row of cells
$y0     = 9*72;
$lly = $y0 - $height;
$y-origin = $lly + 0.5 * $height;
# draw a border around the N cells first
# draw-box's start point is the lower-left corner of the desired box
draw-box :$page, :inside(False), :llx($x0+$width), :lly($y0-$height),
                 :width(3*$width), :$height;
for 1..3 -> $i {
    $llx = $x0 + $i * $width;
    $x-origin = $llx + 0.5 * $width;
    my $text = "Number $i";
    draw-box :$page, :$llx, :$lly, :$width, :$height, :$border-width,
             :$border-color, :$fill-color;
    put-text :$text, :$page, :$x-origin, :$y-origin, :$font, :$font-size,
             :$align, :$valign, :$font-color;
}

$y0     = 6*72;
$lly = $y0 - $height;
$y-origin = $lly + 0.5 * $height;
# draw a border around the N cells first
# draw-box's start point is the lower-left corner of the desired box
draw-box :$page, :inside(False), :llx($x0+$width), :lly($y0-$height),
                 :width(3*$width), :$height;
for 1..3 -> $i {
    $llx = $x0 + $i * $width;
    $x-origin = $llx + 0.5 * $width;
    my $text = "Number $i";
    draw-box :$page, :$llx, :$lly, :$width, :$height, :$border-width,
             :$border-color, :$fill-color;
    put-text :$text, :$page, :$x-origin, :$y-origin, :$font, :$font-size,
             :$align, :$valign, :$font-color;
}

$y0     = 3*72;
$lly = $y0 - $height;
$y-origin = $lly + 0.5 * $height;
# draw a border around the N cells first
# draw-box's start point is the lower-left corner of the desired box
draw-box :$page, :inside(False), :llx($x0+$width), :lly($y0-$height),
                 :width(3*$width), :$height;
for 1..3 -> $i {
    $llx = $x0 + $i * $width;
    $x-origin = $llx + 0.5 * $width;
    my $text = "Number $i";
    draw-box :$page, :$llx, :$lly, :$width, :$height, :$border-width,
             :$border-color, :$fill-color;
    put-text :$text, :$page, :$x-origin, :$y-origin, :$font, :$font-size,
             :$align, :$valign, :$font-color;
}

finish-page :$page; # .Restore

$pdf.save-as: $ofile;
say "See output file: ", $ofile;
