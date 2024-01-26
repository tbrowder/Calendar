#!/usr/bin/env raku

# Debian Open Type fonts packages: 
#   tex-gyre
#   urw-base35
#   freefont

use File::Find;
use Data::Dump::Tree;
use Data::Dump;

use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Glyph;
use Font::FreeType::Outline;
use Font::FreeType::Raw::Defs;
use Font::FreeType::SizeMetrics;

my $urwdir = "/usr/share/fonts/opentype/urw-base35";
my @urw = find :dir($urwdir), :name(/\.otf$/);
#say "font file $_" for @urw;
#exit;

=begin comment
my $font1 = "../t/fonts/DejaVuSerif.ttf";

# for testing
#my $font2 = "../t/fonts/DejaVuSerif.t1a";
#my $font3 = "../t/fonts/DejaVuSerif.ufm";
my $fontfilex = "../t/fonts/DejaVuSerif.afm";
=end comment

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | show-all-glyphs [debug]

    Tests use of Font::FreeType using font files of interest
    as input.
    HERE
    exit
}

my $all-glyphs = 0;
my $max-show   = 0;
my $debug = 0;
for @*ARGS {
    when /^:i s|a $/ {
        ++$all-glyphs;
    }
    when /^ 'max=' (\d+) $/ {
        $max-show = +$0;
    }
    when /^:i d / {
        ++$debug;
    }
    when /^:i g / {
        ; # ok
    }
    default {
        die "FATAL: Unrecognized arg '$_'";
    }
}

if 0 and $debug {
    say "all-glyphs = ", $all-glyphs;
    say "max-ahow = ", $max-show;
    say "DEBUG exit"; exit;
}

# only need one instance of FontFreeType
my $ft = Font::FreeType.new;

for @urw -> $fpath {
    my $ffil = $fpath.IO.absolute;
    say "Using file: $ffil";
    my $f = $ft.face: $ffil, :load-flags(FT_LOAD_NO_HINTING);

    #=begin comment
    # the available attrs
    say "    font file name: $ffil";
    say "    family-name: ", $f.family-name;
    say "    postscript-name: ", $f.postscript-name;
    say "    underline-position: ", $f.underline-position;
    say "    underline-thickness: ", $f.underline-thickness;
    say "    units-per-EM: ", $f.units-per-EM;
    my $fb = $f.bounding-box;
    say "    bounding-box (FontBBoX): ", sprintf("%d %d %d %d", 
             $fb.x-min, $fb.y-min, $fb.x-max, $fb.y-max);
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

    my $text = "To Wit";
    my $size = 12.3;
    say "    setting font size to $size points";
    #$f.set-font-size: $size;
    $f.set-font-size: 12, 12, 72, 72; #$size;

    # new module with function to get the metrics

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

    if $all-glyphs {
        my $mapped = True;
        my @charmap;
        my @chardata;
        my $i = 0;
        $f.forall-chars: :!load, :flags(FT_LOAD_NO_HINTING), -> 
                                     Font::FreeType::Glyph:D $_ {
            # apparently not all chars have an outline
            my $bbox = $_.is-outline ?? $_.outline.bbox !! False;

            # get other characteristics
            my $char-code = .char-code;
            my $index     = .index;

            my $char      = $char-code.chr;
            my $hex       = $char-code.base(16);
            my $decimal   = $char-code;
            my $uniname   = $char.uniname;
       
            # save the map as is for now
            @charmap[$index] = $char;

            =begin comment
            # don't need this here
            if $mapped {
                say join("\t", 'x' ~ .char-code.base(16) ~ '[' ~ .index ~ ']',
                     '/' ~ (.name//''),
                     $char.uniname,
                     $char.raku);
            }
            say "    x$hex   $char-code  $index  $uniname   $char";
            =end comment

            say "    x$hex   $char-code  $index  $uniname   $char";
            my $s = "    x$hex   $char-code  $index  $uniname   $char";
            @chardata[$i] = $s;
            say $i if $debug;
            ++$i;
        }

        say "\@charmap size: ", @charmap.elems;
        say "\@chardata size: ", @chardata.elems;
        if $max-show {
            my $j = 0;
            for @chardata -> $line {
                say $line;
                ++$j;
                last if $j == $max-show;
            }
            say "max-show = ", $max-show;
        }
        =begin comment
        else {
            .say for @chardata;
        }
        =end comment

        say "Exit after showing glyphs...";

        exit;
    }

    say "Processing text '$text'";
    my Array $charcodes;
    my Array $chars; # c
    $f.for-glyphs: $text, -> $g {
        say "    ==== glyph attributes =====";
        say "    char name (Str) '{$g.Str}'  glyph name '{$g.name // 'not defined'}'"; 
        next if 0;

        say "        width {$g.width}, height {$g.height}"; 
        say "        index ", $g.index;
        say "        char-code ", $g.char-code;
        say "        char-code.ord ", $g.char-code.ord;
        say "        text '$text'";
        say "        text.ords (ords are char-codes) ", $text.ords.raku;
        say "        text.ords.elems ", $text.ords.elems;
        say "        text.comb.gist ", $text.comb.gist;

        if not $charcodes.defined {
            $charcodes = $text.ords.eager.Array;
            $chars     = $text.comb.eager.Array;
        }
        say "        charcodes remaining to process ", $charcodes.gist;
        my $left  = $charcodes.head;
        my $right = $charcodes[1] // 0;
        my $lchar = $chars.head;
        my $rchar = $chars[1] // 0;
        say "        this charcode is ", $left;
        say "        next charcode is ", $right ?? $right !! 'none';
        say "        left char  ", $lchar; #$left.Str;
        say "        right char ", $rchar ?? $rchar !! 'none';

        $charcodes.shift if $charcodes.elems;
        $chars.shift     if $chars.elems;

        say "        horizontal-advance ", $g.horizontal-advance;
        say "        left-bearing ", $g.left-bearing;
        say "        right-bearing ", $g.right-bearing;
        say "        is-outline ", $g.is-outline;
        my $b = $g.outline.bbox;
        say "        bbox (char BBoX): ", 
                     sprintf("%f %f %f %f", $b.x-min, $b.y-min, $b.x-max, $b.y-max);
        $left = $f.glyph-name-from-index: $g.index;
        say "        \@charmaps[\$f.charmaps[{$g.index}]] = $left";

        if $f.has-kerning and $rchar {
            #$left .= Str;
            #$right .= Str;
            #my $v = $f.kerning: $left.Str, $right.Str;
            my $v = $f.kerning: $lchar, $rchar;
            my $x = $v.x; # * $sf;
            my $y = $v.y; # * $sf;

            say "        kerning x, y '$lchar', '$rchar': ", sprintf("%f %f", $x, $y);
        }
    } 
    say "Showing only the first font.";
    last;
}
say "Exit at the very end!";

