#!/bin/env raku

use Data::Dump;

use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Glyph;
use Font::FreeType::Raw::Defs;
use Font::FreeType::SizeMetrics;

my $fdir = "/usr/share/fonts/opentype/freefont";
my $ffil = "{$fdir}/FreeSerif.otf";

use lib <../lib>;
#use FontFactory::Classes;
use FontFactory::DocFont; #Classes;
use FontFactory::FF-Subs;

my $text-in = "The Piano.";

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <some-string> 

    Converts a string of text to a list of glyph objects
    using font file '$ffil';

    The default string is:

        $text-in
    HERE
    exit
}

my $all-glyphs = 0;
my $max-show   = 0;
my $debug = 0;
for @*ARGS {
    when /^:i d / {
        ++$debug;
    }
    when /^:i go / {
        ; # ok
    }
    default {
        $text-in = $_;
    }
}

say "DEBUG: input text: $text-in";

my $ft = Font::FreeType.new;
my $f = $ft.face: $ffil, :load-flags(FT_LOAD_NO_HINTING);
my $fb = $f.bounding-box;

if $debug {
   say "== Getting attributes and metrics...";
   say "    font file name: $ffil";
   say "    family-name: ", $f.family-name;
   say "    postscript-name: ", $f.postscript-name;
   say "    underline-position: ", $f.underline-position;
   say "    underline-thickness: ", $f.underline-thickness;
   say "    units-per-EM: ", $f.units-per-EM;
   say "    bounding-box (FontBBoX): ",
               sprintf("%d %d %d %d", $fb.x-min, $fb.y-min, $fb.x-max, $fb.y-max);
   say "    ascender: ", $f.ascender;
   say "    descender: ", $f.descender;
   say "    font-format: ", $f.font-format;
   say "    is-scalable: ", $f.is-scalable;
   say "    has-fixed-sizes: ", $f.has-fixed-sizes; # bitmap
   say "    is-fixed-width:", $f.is-fixed-width;
   say "    is-sfnt: ", $f.is-sfnt;
   say "    has-horizontal-metrics: ", $f.has-horizontal-metrics;
   say "    has-vertical-metrics: ", $f.has-vertical-metrics;
   say "    has-kerning: ", $f.has-kerning;
   say "    has-glyph-names: ", $f.has-glyph-names;
   say "    has-reliable-glyph-names: ", $f.has-reliable-glyph-names;
   say "    is-bold: ", $f.is-bold;
   say "    is-italic: ", $f.is-italic;
   say "    num-glyphs: ", $f.num-glyphs;
   #if $f.named-infos {
   #    say "    named-infos: ", $f.named-infos;
   #}
}

my $text = $text-in;
my $size = 12.3;
say "    setting font size to $size points";

$f.set-font-size: $size;

# new module with function to get the metrics
my %chars = get-glyphs $f;

say "Processing text '$text'";
my @chars = $text.comb;

my $i = 0;
my $width = 0;
for @chars.kv -> $i, $c {
    my $glyph;
    if %chars{$c}:exists {
        $glyph = %chars{$c};
    }
    else {
        note %chars.raku;
        die "FATAL: no glyph found for char '$c'";
    }
    my $lchar  = $c;
    my $rchar  = @chars[$i+1] // 0;
    my $g = $glyph;

    my $cw = $g.char-width;
    my $w = $g.width;
    my $h = $g.height;
    say "  char $i is '$c', its char width is $cw, its height is $h";

    say "        horizontal-advance (Adobe width) ", $g.horizontal-advance;
    say "        left-bearing ", $g.left-bearing;
    say "        right-bearing ", $g.right-bearing;
    say "        is-outline ", $g.is-outline;
    say "        format ", $g.format;
    say "        bbox (char BBoX): ", sprintf("%f %f %f %f", 
                                      $g.llx, $g.lly, $g.urx, $g.ury);
    if $f.has-kerning and $rchar {
        my $v = $f.kerning: $lchar, $rchar;
        my $x = $v.x;
        my $y = $v.y;
        say "        kerning<x:y> '$lchar' -> '$rchar' : ", sprintf("%f %f", $x, $y);
    }
}

if $debug {
    my $i = 0;
    for %chars.keys.sort -> $c {
        ++$i;

        my $glyph = %chars{$c};
        my $g = $glyph;
        my $dec-code = $g.char-code;
        my $hex-code = $dec-code.base(16);
        say "   char |$c|, decimal code = $dec-code, hex code = x$hex-code"; 

        last if $max-show and $i >= $max-show;
    }
    say "DEBUG early exit";
    exit;
}

=begin comment
my $fm = $f.scaled-metrics;
say "=== new scaled metrics:";
# attributes of $fm:
say "x-scale: ", $fm.x-scale;
say "y-scale: ", $fm.y-scale;
say "x-ppem: ", $fm.x-ppem;
say "y-ppem: ", $fm.y-ppem;
say "ascender: ", $fm.ascender;
say "descender: ", $fm.descender;
say "height: ", $fm.height;
say "max-advance: ", $fm.max-advance;
say "underline-position: ", $fm.underline-position;
say "underline-thickness: ", $fm.underline-thickness;
say "bbox: ", $fm.bounding-box; # an array
say "=== end of new scaled metrics:";
# scale factor * units-per-EM = font-size
# thus: scale factor = font-size / units-per-EM
my $sf = $size/$f.units-per-EM;
say "    scale factor: ", $sf;
say "    adjusted face values:";
say "        underline-position: ", $sf*$f.underline-position;
say "        underline-thickness: ", $sf*$f.underline-thickness;
say "        bounding-box (FontBBoX): ", sprintf("%f %f %f %f", 
                                         $sf*$fb.x-min, $sf*$fb.y-min, 
                                         $sf*$fb.x-max, $sf*$fb.y-max);
say "        ascender: ", $sf*$f.ascender;
say "        descender: ", $sf*$f.descender;
=end comment

=begin comment
# moved to /lib/FontFactory/Subs.rakumod
sub get-glyphs(Font::FreeType::Face:D $f,  :$debug --> Hash) is export {
    my %glyphs;

    $f.forall-glyphs: :!load, :flags(FT_LOAD_NO_HINTING), -> Font::FreeType::Glyph:D $g {
        my $char = $g.char-code.chr;
        my $uni  = $g.char-code.chr.uniname;
        my $dec  = $g.char-code;
        my $hex  = $g.char-code.base(16);

        my $bbox = $g.outline.bounding-box;
        my $llx  = $bbox.x-min;
        my $lly  = $bbox.y-min;
        my $urx  = $bbox.x-max;
        my $ury  = $bbox.y-max;

        # save ALL glyph data in a Char object
        %glyphs{$char} = Char.new(
            :left-bearing($g.left-bearing),
            :right-bearing($g.right-bearing),
            :horizontal-advance($g.horizontal-advance // 0),
            :vertical-advance($g.vertical-advance // 0),
            :width($g.width),
            :height($g.height),
            :format($g.format),
            :uniname($uni),
            :$dec,
            :$hex,
            :name($g.name // 0),
            :Str($g.Str), # unicode character
            :is-outline($g.is-outline),
            :$llx,
            :$lly,
            :$urx,
            :$ury,
        );
    }

    %glyphs;

} # end of sub
=end comment

=finish


my Array @char-codes;
@char-codes = $text.ords.eager.Array;
for @char-codes -> $char-code {
    # the char-codes are ords
    # from the ord get:
    #   its face charmap index
    #   glyph object
}

=begin comment
$f.for-glyphs: $text, -> $g {
    say "    ==== glyph attributes =====";
    say "    char name (Str) '{$g.Str}'  glyph name '{$g.name // 'not defined'}'"; 
    next if 0;

    say "        width {$g.width}, height {$g.height}"; 
    say "        index ", $g.index;
    say "        char-code ", $g.char-code;
    say "        char-code.ord ", $g.char-code.ord;
    say "        text '{$text}'";;
    say "        text.ords (ords are char-codes) ", $text.ords.raku;
    say "        text.ords.elems ", $text.ords.elems;
    say "        text.comb.gist ", $text.comb.gist;

    if not $charcodes.defined {
        $charcodes = $text.ords.eager.Array;
    }
    say "        charcodes remaining to process ", $charcodes.gist;
    my $left  = $charcodes.head;
    my $right = $charcodes[1] // 0;
    say "        this charcode is ", $left;
    say "        next charcode is ", $right ?? $right !! 'none';
    say "        left char  ", $left.chr;
    say "        right char ", $right.chr !~~ /\S/ ?? $right.chr !! 'none';

    $charcodes.shift if $charcodes.elems;

    say "        horizontal-advance ", $g.horizontal-advance;
    say "        left-bearing ", $g.left-bearing;
    say "        right-bearing ", $g.right-bearing;
    say "        is-outline ", $g.is-outline;
    my $b = $g.outline.bounding-box;
    say "        bbox (char BBoX): ", sprintf("%f %f %f %f", 
                     $b.x-min, $b.y-min, $b.x-max, $b.y-max);
    $left = $f.glyph-name-from-index: $g.index;
    say "        \@charmaps[\$f.charmaps[{$g.index}\}] = $left";

    if $f.has-kerning and $right {
        $left .= Str;
        $right .= Str;
        my $v = $f.kerning: $left, $right;
        my $x = $v.x;
        my $y = $v.y;
        say "        kerning x, y '$left', '$right':", sprintf("%f %f", $x, $y);
    }
} 
say "Showing only the first font.";
=end comment

say "Exit at the very end!";

