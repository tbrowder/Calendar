unit module Classes;

use Text::Utils :normalize-text;

#use NativeCall;
use PDF::Lite;
use Font::FreeType;
use Font::FreeType::Error;
use Font::FreeType::Face;
use Font::FreeType::Glyph;
use Font::FreeType::Outline;
use Font::FreeType::Raw;
use Font::FreeType::Raw::Defs;
use Font::FreeType::CharMap;
use Font::FreeType::SizeMetrics;
use Font::FreeType::BBox;
use PDF::Content::FontObj;
use PDF::Font::Loader :&load-font;
use Method::Also;

constant Dot6 = Font::FreeType::Raw::Defs::Dot6;

my Font::FreeType $ft-shared;

# A convenience class like a struct until FontFactory is published
class MyFont is export {
    has $.file is required; # font definition file (.otf, .ttf)
    has $.size is required; # in PS points
    has $.face;
    has $.ft;               # shared instance of FreeType
    has $.sm;
    has $.sf; # scale factor: fsize / units-per-EM

#    has $.uem;
#    has $.raw;
#    has $.metrics-delegate;
#    has $.scaled-metrics;
#    has $.ft-lib;

    has PDF::Content::FontObj $.fo; # the actual PDF font object for rendering

    submethod TWEAK(Str :$attach-file) {
        unless $ft-shared.defined {
            $ft-shared .= new;
        }
        $!ft   = $ft-shared;
        $!face = $!ft.face: $!file, :load-flags(FT_LOAD_NO_HINTING);
        $!face.set-font-size: $!size;
        $!sm   = $!face.scaled-metrics;
        $!sf   = $!size / $!face.units-per-EM; # scale factor: fsize / units-per-EM
#       $!uem  = $!face.units-per-EM;
#       $!raw  = $!face.raw;

        $!fo   = PDF::Font::Loader.load-font: :file($!file), :!subset;
        # what about the Enc thingy?
        
#        self.attach-file($_) with $attach-file;
    }

=begin comment
    my class Vector {
        # required for handling kerning
        has FT_Vector $!raw;
        has UInt:D $.scale = Dot6;
        submethod TWEAK(FT_Vector:D :$!raw!) {}
        method x { $!raw.x /$!scale }
        method y { $!raw.y /$!scale }
        method gist { $.x ~ ' ' ~ $.y }
    }
=end comment

    method show {
        # TODO: other characteristics are available like italic angle and other
        #       ones seen in Font::AFM
        say "font name: ", $!face.postscript-name;
        say "  font size: ", $!size;
        say "  font height (leading or line height): ", $!sm.height;
        say "  font underline position: ", $!sm.underline-position;
        say "  font underline thickness: ", $!sm.underline-thickness;
    }

    method kern-info(Str $string, :$debug) {
        my @a = $!fo.kern: $string; # unscaled data
        my @c = @a.head.Array; # an array of character groups 
                               # alternating with kern values
        my $u = @a.tail.head;  # an unscaled value: total unkerned width?
        my $k = 0;             # accumulate kern values
        # to scale: $unscaled * $point-size / $units-per-EM;
        for @c -> $v {
            next unless $v ~~ Numeric;
            my $n = $v.Numeric;
            note "DEBUG: yea! found a Numeric: $v" if $debug;
            $k += $n;
        }
        # for now assume it's total kerned width
        # $u, $k, $u+$k
        # scale it
        $u*10/$!face.units-per-EM,
        $k*10/$!face.units-per-EM,
        ($u+$k)*10/$!face.units-per-EM
    }

    #method bbox(Str $string, :$kern, :$debug) {
    #    # LLX is == $string.comb.head.bbox[LLX] (scaled)
    #}

    method left-bearing(Str $string, :$debug) {
        my $lchar = $string.comb.head;
        self.char-left-bearing: $lchar
    }

    method width($string, :$kern, :$debug) {
        # stringwidth - (left-bearing of leftmost
        # glyph) - (right-bearing of right-most glyph)
        my $lc = $string.comb.head;
        my $rc = $string.comb.tail;
        my $sw = self.stringwidth($string, :$kern);
        $sw - self.char-left-bearing($lc) - self.char-right-bearing($rc)
    }

    method right-bearing(Str $string, :$kern, :$from-left, :$debug) {
        # TODO nail this down, what does right-bearing of string really mean?
        #      how is it actually used?

        # more complicated. defined as "distance from
        #   horizontal-advance to right edge of glyph"
        my $rchar = $string.comb.tail;
        my $rb;
        if $from-left {
            # practical definition
            # distance from stringwidth less right bearing of last glyph
            my $sw = self.stringwidth($string, :$kern);
            $rb = $sw - self.char-right-bearing: $rchar;
        }
        else {
            # conventional definition
            # right bearing of last glyph
            $rb = self.char-right-bearing: $rchar;
        }
        $rb
    }

    # stringwidth is a method of FontObj (with kerning!)
    method stringwidth(Str $string, :$kern, :$debug) {
        # distance from origin to point where next glyph's
        # origin will be
        if $kern {
            $!sf * $!fo.stringwidth: $string, :$kern;
        }
        else {
            $!sf * $!fo.stringwidth: $string;
        }
    }

    method char-left-bearing(Str $string, :$debug) {
        my $s = $string.comb.head;
        my $sw = self.stringwidth: $s;
        my $lb = 0;
        $!face.for-glyphs($s, { 
            my $bb = .bbox;
            $lb    = $bb.x-min; # .left-bearing;
        });
        $lb
    }
    method char-right-bearing(Str $string, :$debug) {
        my $s = $string.comb.head;
        my $sw = self.stringwidth: $s;
        my $rb = 0;
        $!face.for-glyphs($string, { 
            my $bb = .bbox;
            $rb = $sw - $bb.x-max;
        });
        $rb
    }

    method char-width(Str $string, :$debug) {
        my $s = $string.comb.head;
        my $sw = self.stringwidth: $s;
        my $w = 0;
        $!face.for-glyphs($string, { 
            my $bb = .bbox;
            $w = $bb.x-max - $bb.x-min;
        });
        $w
    }

    # vertical metrics will require iterating over the glyphs of the
    # string
    method vertical-metrics(Str $string, :$debug --> List) {
        my ($top, $bot) = 0, 0;
        $!face.for-glyphs($string, { 
            my $bb = .bbox;
            my $y = $bb.y-max; # .top-bearing;
            my $h = .height;
            my $b = $y - $h; # bottom bearing
            $top = $y if $y > $top;
            $bot = $b if $b < $bot;
        });
        $top, $bot, $top-$bot
    }

=begin comment
    method stringwidth(Str $string, :$kern, :$debug) {
        =begin comment
        # from David Warring:
        sub stringwidth($face, $string, $point-size = 12) {
            my $units-per-EM = $face.units-per-EM;
            my $unscaled = sum $face.for-glyphs($string, { .metrics.hori-advance });
            return $unscaled * $point-size / $units-per-EM;
        }
        =end comment

        my $k = 0;
        if $kern {
            my @chars = $string.comb;
            my $left = @chars.shift;
            my FT_UInt $Lidx = $!raw.FT_Get_Char_Index($left.ord);
            for @chars -> $right {
                my FT_UInt $Ridx = $!raw.FT_Get_Char_Index($right.ord);
                note "DEBUG left char index = $Lidx" if $debug;
                note "DEBUG right char index = $Ridx" if $debug;
                my FT_Vector $vec .= new;
                my UInt $mode = $!metrics-delegate === $!scaled-metrics 
                                ?? FT_KERNING_UNFITTED !! FT_KERNING_UNSCALED;
                ft-try {$!raw.FT_Get_Kerning($Lidx, $Ridx, 
                    $mode, $vec);};
                note "left: $left" if $debug;
                note "right: $right" if $debug;
                # get kern from the pair via a Vector
                my $delta = $!face.kerning($left, $right);
                #note "DEBUG delta = '{$delta.raku}' debug exit"; exit;
                $k += $delta.x; # horizontal kerning

                # swap right to left 
                $left = $right;
                $Lidx = $Ridx;
            }
            note "total kern values: $k" if $debug;
        } # end if $kern proc

        my $unscaled = sum $!face.for-glyphs($string, {
                               .metrics.hori-advance
                           });
        if $debug {
            my $uk = self.kern-info: $string;
            note qq:to/HERE/;
            DEBUG kerning
                input string:   '$string'
                unkerned width: $unscaled
                kerned width:   $uk
            HERE
        }
        my $strwid = $unscaled * $!size / $!face.units-per-EM;
        if $kern {
            $strwid += $k;
        }
        $strwid
    }
=end comment

} # Class MyFont

# Considering table placement, the zero
# reference is its top left corner where
# the object is translated.
role Dimen is export {
    # text dimens based on font and its size
    has $.w; # stringwidth
    has $.h; # height (leading or line height)

    # border dimens
    has $.lbw = 3; # left border width
    has $.rbw = 3; # right border width
    has $.tbh = 3; # top border height
    has $.bbh = 3; # bottom border height

    # setters
    method lbw($v) { $!lbw = $v }
    method rbw($v) { $!rbw = $v }
    method tbh($v) { $!tbh = $v }
    method bbh($v) { $!bbh = $v }

    method width {
        $!lbw + $!w + $!rbw
    }
    method height {
        $!tbh + $!h + $!bbh
    }

    method print-border($linewidth = 0, :$x!, :$y!, :$page!, :$debug) {
        # x,y is at the top-left corner
        $page.graphics: {
            .Save;
            .transform: :translate($x, $y);
            .SetStrokeGray(0);
            .SetLineWidth($linewidth);

            # draw ccw
            .MoveTo(0, 0);
            .LineTo(0, -self.height);
            .LineTo(self.width, 0);
            .LineTo(0, self.height);
            .CloseStroke;
            .Restore;
        }
    }
} # role Dimen

#| Classes
class Cell does Dimen is export {
    has $.text = "";

    method nchars {
        $!text.chars
    }

    # setter
    method set-text($v) { $!text = $v }

    method print-text(:$font!, :$font-size!, :$x!, :$y!, :$page!, :$debug) {
        $page.graphics: {
            .Save;
            # We're at the top left corner;
            # translate to the bottom left of the text area
            # which is ($x + $!lbw, $y - $!h + $!bbh
            .transform: :translate($x + $!lbw, $y - $!h + $!bbh);
            .SetStrokeGray(0);

            # ready to print
            .print: $!text, :position[0, 0], :$font, :$font-size,
                            :align<left>, :kern; #, default: :valign<bottom>;
            .Restore;
        }
    }
} # class Cell

class Line does Dimen is export {
    has Cell @.cells;
    method add-cell(Cell $v) {
        @!cells.push: $v
    }
}

class Month is export {
    has $.number; # 1..12
    has $.name;

    #has $.width;  # print height at font and size
    #has $.height; # print width at font and size

    has @.nchars = 0, 0, 0; # max chars per cell
    has @.maxwid = 0, 0, 0; # max w (stringwidth) per cell
    has Line @.lines;
    method add-line(Line $L, :$debug) {
        for $L.cells.kv -> $i, $c {
            # ignore cell 0 which is a number
            next if $i == 0;
            if $c.nchars > @!nchars[$i] {
                @!nchars[$i] = $c.nchars;
            }
        }
        @!lines.push: $L;
    }

    method print(MyFont $font, 
                 MyFont $fontB,
                 :$x = 0, :$y = 0, 
                 :$width is copy = 0,
                 PDF::Lite::Page :$page, 
                 :$debug --> List) {

        # Given the x,y of the top-left corner, print the Month box
        # at its default size. Return the width and height of that
        # box in points.
        #
        # If the input width is > 0, that width is considered a fixed
        # width.
        my $height = 0;

        # translate to the top-left corner
        # track Month max width and height
        #   print the month name (if $page.defined)
        #   determine its height as lineheight plus delta-y to following Line top
        #   add height to month height
        
        #   track max Cell width for all Lines
        #   for each Line
        #     determine its height as lineheight + top/bottom border space
        #     add height to month height

        #     for each Cell
        #       determine its width as stringlength kerned + left/right border space
        #       add width as max Line Cell width if so

        #       draw its grid lines (if $page.defined)
        #       render its text left-justified (if $page.defined)

        #   return final width, height 
        $width, $height
    }

    method calc-maxwid(MyFont $font, :$debug) {
        for @!lines.kv -> $i, $L {
            for $L.cells.kv -> $i, $c {
                # first cell has number, fake it
                my $s;
                $i == 0 ?? ($s = "Day") !! ($s = $c.text);
                my $w = $font.stringwidth: $s;
                if $w > @!maxwid[$i] {
                    @!maxwid[$i] = $w;
                }
            }
        }
    }
}

class Year is export {
    has $.year where { $_ > 2018 };
    has Month @.months;
    has @.nchars; # max chars per cell
    has @.maxwid; # max w (stringwidth) per cell
    has @.titles; # column (cell) titles

    submethod TWEAK {
        @!titles = "Day", "Birthdays", "Anniversaries";
        for @!titles.kv -> $i, $v {
            @!nchars[$i] = $v.chars;
            @!maxwid[$i] = 0;
        }
    }

    method add-month(Month $m, :$debug) {
        # update nchars
        for $m.nchars.kv -> $i, $v {
            if $v > @!nchars[$i] {
                @!nchars[$i] = $v
            }
        }
        @!months.push: $m;
    }

    method calculate-maxwidth(MyFont $font, :$debug) {
        for @!months.kv -> $i, $m {
            $m.calc-maxwid: $font;
            for $m.maxwid.kv -> $i, $w {
                if $w > @!maxwid[$i] {
                    @!maxwid[$i] = $w;
                }
            }
        }
    }

    # for typesetting
    # given a range of Month objects and a font and font size,
    #   calculate the 
} # class Year
