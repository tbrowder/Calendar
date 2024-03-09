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
use HowtoGFX;

# various font files on Linux
my $ffil  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
die "NOFILE: FreeSerif not found" unless $ffil.IO.r;

my $debug = 0;
my $ofile = "howtoGFX.pdf";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates drawing cells containing text and graphics on the
    same page using separate blocks.

    HERE
    exit
}

my PDF::Lite $pdf .= new;
$pdf.media-box = [0, 0, 8.5*72, 11.0*72];

my PDF::Content::FontObj $font = load-font :file($ffil); # FreeSerif
my $font-size = 10;
my PDF::Lite::Page $page;
for 1..3 {
    $page = $pdf.add-page;
    new-page :$page, :landscape(True), :$font, :media<letter>, :$debug;
}

$pdf.save-as: $ofile;
my $np = $pdf.page-count;
say "See output file: ", $ofile;
say "Page count: $np";
