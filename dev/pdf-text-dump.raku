#!/usr/bin/env raku

use PDF::API6;
use PDF::Page;

class TextDecoder {
    use PDF::Content::Ops :OpCode;
    use PDF::Font::Loader;
    use PDF::Font::Loader::Dict;
    use Method::Also;
    has Hash @!save;
    has PDF::Content::Font $!font;
    has PDF::Content::FontObj $!font-obj;
    has $.current-font;
    has Numeric $.font-size = 10;
    has Int $!artifact;
    has Int $!reversed-chars;
    has Numeric $!ty;
    has Lock:D $.lock .= new;
    has Bool $.quiet;
    has $.text is built = '';

    method current-font {
        $!font-obj //= $!lock.protect: {
            unless $!font.font-obj ~~ PDF::Content::FontObj:D {
                my Bool $core-font = PDF::Font::Loader::Dict.is-core-font: :dict($!font);
                PDF::Font::Loader.load-font: :dict($!font), :$core-font, :$!quiet;
            }
            $!font.font-obj;
        }
    }

    method callback {
        sub ($op, *@args) {
            my $method = OpCode($op).key;
            self."$method"(|@args)
                if self.can($method);
        }
    }
    method BeginMarkedContent($,$?) is also<BeginMarkedContentDict> {
        given $*gfx.tags.open-tags.tail -> $tag {
            $!artifact++ if $tag.name eq 'Artifact';
            $!reversed-chars++ if $tag.name eq 'ReversedChars';
        }
    }
    method EndMarkedContent() {
        with $*gfx.tags.closed-tag -> $tag {
            $!artifact-- if $tag.name eq 'Artifact';
            $!reversed-chars-- if $tag.name eq 'ReversedChars';
        }
    }
    method Save()      {
        @!save.push: %( :$!font, :$!font-size, :$!font-obj );
    }
    method Restore()   {
        if @!save {
            given @!save.pop {
                $!font = .<font>;
                $!font-obj = .<font-obj>;
                $!font-size = .<font-size>;
            }
        }
    }
    method SetFont($, $!font-size) {
        $!font-obj = Nil;
        $!font = $_ with $*gfx.font-face;
    }
    method SetGraphicsState($gs) {
        if $gs<Font>:exists {
            $!font-obj = Nil;
            $!font = $*gfx.font-face;
            $!font-size = $*gfx.font-size;
        }
    }
    method !save-text(Str $s) {
        $!text ~= $!reversed-chars ?? $s.flip !! $s; 
    }
    method !set-ty { $!ty = .[5] / .[3] given $*gfx.TextMatrix; }
    method ShowText($_) {
        unless $!artifact {
            self!set-ty;
            my $text = $.current-font.decode($_, :str);
            self!save-text: $text;
        }
    }
    method ShowSpaceText(List $_) {
        unless $!artifact {
            self!set-ty;
            my Str $last := ' ';
            my @chunks = .map: {
                when Str {
                    $last := $.current-font.decode($_, :str);
                }
                when $_ <= -120 && !($last ~~ /\s$/) {
                    # assume implicit space
                    ' '
                }
                default { Empty }
            }

            self!save-text: @chunks.join;
        }
    }
    method TextNextLine(|) is also<TextMoveSet MoveShowText MoveSetShowText> {
        # treat these as explict newlines
        unless $!artifact {
            self!save-text: "\n";
        }
    }
    method TextMove($x, $y) {
        # treat a significant vertical shift from the
        # last text positioning as an explict newline
        unless $!artifact {
            with $!ty {
                my $new-ty = self!set-ty;
                my $leading = ($_ - $new-ty) / $!font-size;
                self!save-text: "\n"
                    unless -.3 <= $leading <= .3;
            }
        }
    }
}

sub MAIN(Str $pdf-file, Bool :$quiet, :@search) {
    my PDF::API6 $pdf .= open: $pdf-file;

    $*ERR = class { method print(|) {};};

    my $page-num = 0;
    for $pdf.iterate-pages -> PDF::Page $page {
        note "** PAGE: {++$page-num} **";
        my TextDecoder $text-decoder .= new: :$quiet;
        my &callback = $text-decoder.callback;
        my PDF::Content $gfx = $page.gfx: :&callback;
        $page.render;
        #say $text-decoder.text;
        my $txt = $text-decoder.text;
        say $txt;
        #last if $page-num > 2; 
    }
}
