#!/usr/bin/env raku

use Number::More :ALL;

use lib "./lib";
#use Classes;
use Psubs;
use Print;

my $ffdir  = "/usr/share/fonts/opentype/freefont";
my $ffil   = "$ffdir/FreeSerif.otf";
my $ffilB  = "$ffdir/FreeSerifBold.otf";
my $fsize = 10;

my $year = DateTime.new(now).year;
my $debug = 0;
my $print = False;
my $show  = False;
# other settings are in a hash
my %opt;
# defaults
%opt<y> = $year;
%opt<tm> = 36;
%opt<bm> = 36;
%opt<lm> = 36;
%opt<rm> = 36;
%opt<ma> = 36; # margins 1/2 inch
%opt<landscape> = False;
%opt<sb> = False;
%opt<bw> = 3; # default Cell border width
%opt<fs> = $fsize;
%opt<ffil> = $ffil;
%opt<ffilB> = $ffilB;
%opt<media> = 'Letter';

my $ofil = "missys-bday-ann-lists.pdf";

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <mode> [<options...> debug]

    Creates Missy's birthday and anniversary lists.

    Modes:
      show  - pretty print in ASCII to stdout (default with 'go')
      print - create the lists on beautiful PDF pages

    Options:
      y=X  - where X is the desired year (default: %opt<y>)
      fs=X - where X is the desired font size (default: %opt<fs>)
      bw=X - where X is the desired cell border width font size (default: %opt<bw>)
      sb   - show cell border (default: %opt<sb>)
      la   - use landscape orientation (default: %opt<landscape>)
      ma=X - X is the page margin (default: %opt<ma>)
      pa=X - X is the paper type (default: %opt<media>)

    Other options:
      tm=X - X is page top margin (default: %opt<tm>)
      bm=X - X is page bottom margin (default: %opt<bm>)
      lm=X - X is page left margin (default: %opt<lm>)
      rm=X - X is page right margin (default: %opt<rm>)
    HERE
    exit
}

my ($text, $page, $text-obj);
my $media = 'Letter';
my $landscape = False;

for @*ARGS {
    # modes
    when /^:i g|sh / {
        $show = True; # or 'go'; ok
    }
    when /^:i pr / {
        $print = True;
    }
    # options
    when /^:i l/ {
        $landscape = True;
        %opt<la> = $landscape;
    }
    when /^:i d/ {
        ++$debug;
    }
    when /^ 'y=' (20\d\d) $/ {
        $year = ~$0;
        %opt<y> = $year;
    }
    when /^ (20\d\d) $/ {
        $year = ~$0;
        %opt<y> = $year;
    }
    when /^ 'pa=' (\S+) $/ {
        my $m = ~$0;
        if $m ~~ /^:i (l|a) / {
            $m = ~$0.lc;
            %opt<pa> = $m eq 'l' ?? 'Letter' !! 'A4';
        }
        else {
            die "FATAL: Unknown paper type '$_', use 'Letter' or 'A4'";
        }
    }
    default {
        die "FATAL: Unknown argument '$_'";
    }
}

my $data-file = "missys-ann-bday-list-{$year}.data";
my $yr = import-data $data-file, :$year, :$debug;

if $show {
    # show a prettier list on stdout
    show-list $yr, :$year;
}
elsif $print {
    # print a beautiful PDF document
    print-list $yr, :$ofil, :$year, :%opt, :$debug;
    say "See output file: $ofil";
}
else {
    say "No mode was selected."
}

=finish

my $pdf = PDF::Lite.new;
$pdf.media-box = %(PageSizes.enums){$media};
$page   = $pdf.add-page;

my %h;
make-page :$pdf, :$page, :$font, :$fontB,
          :$media, :%h, :landscape(False);

$pdf.save-as: $ofil;
say "See output file: $ofil";

# subroutines are in lib/Psubs.rakumod
sub make-page(
              @lines,
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$font!,
              :$font-size = 10,
              :$fontB!,
              :$media!,
              :$landscape = False,
              :%h!, # data
) is export {
    my ($cx, $cy);

    =begin comment
    my $up = $font.underlne-position;
    my $ut = $font.underlne-thickness;
    note "Underline position:  $up";
    note "Underline thickness: $ut";
    =end comment

    # portrait
    # use the page media-box
    $page.media-box = %(PageSizes.enums){$media};
    my $w = $page.media-box[3] - $page.media-box[1];
    my $h = $page.media-box[2] - $page.media-box[0];
    $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
    $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);

    my (@bbox, @position);
    $page.graphics: {
        .Save;
        if $landscape {
            .transform: :translate($page.media-box[2], $page.media-box[1]);
            .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
            # is this right? yes, the media-box values haven't changed,
            # just its orientation with the transformations
            $w = $page.media-box[3] - $page.media-box[1];
            $h = $page.media-box[2] - $page.media-box[0];
            $cx = $w * 0.5;
        }

        # get the font's values from FreeFont
        my ($leading, $height, $dh);
        $leading = $height = $dh = $sm.height; #1.3 * $font-size;

        # use 1-inch margins left and right, 1/2-in top and bottom
        # left
        my $Lx = 0 + 72;
        my $x = $Lx;
        # top baseline
        my $Ty = $h - 36 - $dh; # should be adjusted for leading for the font/size
        my $y = $Ty;

        # start at the top left and work down by leading
        #@position = [$lx, $by];
        #my @bbox = .print: "Fourth page (with transformation and rotation)",
        #                   :@position, :$font,
        #                   :align<center>, :valign<center>;

        =begin comment
        # print a page title
        my $ptitle = "FontFactory Language Samples for Font: $font-name";
        @position = [$cx, $y];
        @bbox = .print: $ptitle, :@position,
                        :font($title-font), :font-size(16), :align<center>, :kern;
                        #, :valign<bottom>;
        if 1 {
            note "DEBUG: \@bbox with :align\<center>: {@bbox.raku}";
        }
        =end comment

        =begin comment
        # TODO file bug report: @bbox does NOT recognize results of
        #   :align (and probably :valign)
        # y positions are correct, must adjust x left by 1/2 width
        .MoveTo(@bbox[0], @bbox[1]);
        .LineTo(@bbox[2], @bbox[1]);
        =end comment

        my $bwidth = @bbox[2] - @bbox[0];
        my $bxL = @bbox[0] - 0.5 * $bwidth;
        my $bxR = $bxL + $bwidth;

        =begin comment
        # wait until underline can be centered easily

        # underline the title
        # underline thickness, from docfont
        my $ut = $sm.underline-thickness; # 0.703125;
        # underline position, from docfont
        my $up = $sm.underline-position; # -0.664064;
        .Save;
        .SetStrokeGray(0);
        .SetLineWidth($ut);
        # y positions are correct, must adjust x left by 1/2 width
        .MoveTo($bxL, $y + $up);
        .LineTo($bxR, $y + $up);
        .CloseStroke;
        .Restore;
        =end comment

        # show the text font value
        $y -= 2* $dh;

        $y -= 2* $dh;

        for %h.keys.sort -> $k {
            my $country-code = $k.uc;
            my $lang = %h{$k}<lang>;
            my $text = %h{$k}<text>;

            # print the dashed in one piece
            my $dline = "-------------------------";
            @bbox = .print: $dline, :position[$x, $y], :$font, :$font-size,
                            :align<left>, :kern; #, default: :valign<bottom>;

            # use the @bbox for vertical adjustment [1, 3];
            $y -= @bbox[3] - @bbox[1];

            #  Country code / Language: {$k.uc} / German
            @bbox = .print: "{$k.uc} - Language: $lang", :position[$x, $y],
                    :$font, :$font-size, :align<left>, :!kern;

            # use the @bbox for vertical adjustment [1, 3];
            $y -= @bbox[3] - @bbox[1];

            # print the line data in two pieces
            #     Text:     $text
            @bbox = .print: "Text: $text", :position[$x, $y],
                    :$font, :$font-size, :align<left>, :kern;

            # use the @bbox for vertical adjustment [1, 3];
            $y -= @bbox[3] - @bbox[1];
        }
        # add a closing dashed line
        # print the dashed in one piece
        my $dline = "-------------------------";
        @bbox = .print: $dline, :position[$x, $y], :$font, :$font-size,
                :align<left>, :kern; #, default: :valign<bottom>;

        #=== end of all data to be printed on this page
        .Restore; # end of all data to be printed on this page
    }
}

sub print-month(
    :$page,
    :$year,
    :%h, # data: font size, line height, etc.
    ) is export {
    =begin comment
    Given the data for a month of birthdays and anniversaries,
    print it use FreeSerif and FreeSerifBold.
    =end comment

}
