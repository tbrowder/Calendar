#!/bin/env raku

use v6;
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :rgb; #:ColorName, :color;

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
$page.media-box = [0, 0, 8.5*72, 11*72];

my $height = 72;
my $width  = 100;
my $x0     = 36;
my $y0     = 5*72;

$page.graphics: {
    .transform: :translate($x0, $y0);
    for 0..6 -> $i {
        my $x = $i * $width;
        my $text = $i.Str;
        draw-cell $text, :$page, :x0($x), :$y0, :$width, :$height;
    }
}

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

#==== subroutines
sub draw-cell(
    $text = "<text>",
    :$page!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    ) is export {
    #=begin comment
    $page.graphics: {
        .Save;
        .transform: :translate($x0, $y0);
        # color the entire form
        #.FillColor   = rgb(1, 1, 1); #color White
        .FillColor = rgb(0, 0, 0); #color Black
        .Rectangle: $x0, $y0-$height, $width, $height;
        .Fill; #paint: :fill, :stroke;
        .Restore;
    }
    #=end comment
    # add some sample text
    if $text ne "0"  {
        #$page.text: {
        $page.graphics: {
            .font = .core-font('Helvetica'), 15;
            .transform: :translate($x0, $y0);
            .print: $text, :position[50, 25-0.5*14],
                :align<center>, :valign<center>;
        }
    }
}
