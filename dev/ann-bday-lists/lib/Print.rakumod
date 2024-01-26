unit module Print;

use Number::More :ALL;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Raw::Defs;
use Font::FreeType::Glyph;
use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Content::Text::Block;
#use PDF::Font::Loader:ver<0.7.8> :load-font;
use PDF::Content::FontObj;

use Classes;
use Psubs;

=begin comment
my $font  = load-font :file($ffil);
my $fontB = load-font :file($ffilB);
my %m = %(PageSizes.enums);
my @m = %m.keys.sort;
=end comment

sub print-list(Year $yr, :$year!, :$ofil!, :%opt!, :$debug) is export {
    my $f  = MyFont.new: :file(%opt<ffil>), :size(%opt<fs>), :$debug;
    my $fB = MyFont.new: :file(%opt<ffilB>), :size(%opt<fs>), :$debug;
    my $media = %opt<media>;

    if 1 and $debug {
        note qq:to/HERE/;
        Font info:
          has kerning: {$f.face.has-kerning}
        HERE

        my $s = "Fore aWard"; # <== a great kern test!!
        my @k = $f.kern-info: $s; #, :$debug;
        my $u = $f.stringwidth: $s; #, :$debug;
        my $k = $f.stringwidth: $s, :kern; #, :$debug;
        my ($tb, $bb, $h) = -100, -100, -100;
        ($tb, $bb, $h) = $f.vertical-metrics: $s;

        my ($uw, $kw) = -100, -100;
        $uw = $f.width: $s, :!kern;
        $kw = $f.width: $s, :kern;

        my ($lb, $rb, $rbu) = -100, -100, -100;
        my ($rbl, $rbul) = -100, -100;
        $lb = $f.left-bearing: $s;
        $rbu = $f.right-bearing: $s, :!kern;
        $rb = $f.right-bearing: $s, :kern;

        $rbul = $f.right-bearing: $s, :!kern, :from-left;
        $rbl = $f.right-bearing: $s, :kern, :from-left;

        note qq:to/HERE/;
        DEBUG: 
            scaled string metrics for string '$s'
              non-kerned 
                  stringwidth: $u
                  width:       $uw
              kerned 
                  stringwidth: $k
                  width:       $kw

              left-bearing:    $lb
              right-bearing:   $rbu # non-kerned
              right-bearing:   $rb  # kerned
              right-bearing:   $rbul # non-kerned (from left)
              right-bearing:   $rbl  # kerned (from left)
              top-bearing:     $tb
              bottom-bearing:  $bb
              height:          $h 

        Early exit.
        HERE
        exit;
    }

    my $pdf = PDF::Lite.new;
    $pdf.media-box = %(PageSizes.enums){$media};
    my $page;

    # start writing
    # first adjust for cell stringwidths
    $yr.calculate-maxwidth: $f, :$debug;
    if 0 and $debug {
        say "Cell max stringwidths:";
        .say for $yr.maxwid;
    }

    # now print in portrait format one column of months
    if 0 and $debug {
        print "DEBUG: orientation: ";
        if %opt<landscape> ~~ /True/ {
            say "Landscape";
        }
        else {
            say "Portrait";
        }
    }

    # divide the list of months into equal chunks to
    # print on a page

    #my ($nc1, $nc2, $nc3) = $yr.nchars[0], $yr.nchars[1], $yr.nchars[2];
    # now pretty print
    say "year: $year";

    # decide how many months on one page
    my $nrows-per-page = 2;
    my $ncols-per-page = 1;
    my $nmons-per-page = $nrows-per-page * $ncols-per-page;

    my $npages-needed = 12 div $nmons-per-page;
    say "Need {$npages-needed} pages at {$nmons-per-page} months per page";

    # first page
    $page = $pdf.add-page;
    my $page-mons = 0;
    my $npages    = 0;
    my $topy = 11*72 - 36; # page height less top margin
    my $boty = 36; # bottom margin
    my $delta-x = 0; # horizontal space between month boxes
    my $delta-y = 0; # vertical space between month boxes
    MONTH: for $yr.months -> $m {
        my $mnum = $m.number;

        ROW: for 0..^$nrows-per-page -> $row {
        my $rnum = $row+1;

        ++$page-mons;
        COLUMN: for 0..^$ncols-per-page -> $col {
        my $cnum = $col+1;

        #==================
        # print on the page
        #==================
        # get the proper x,y for the top-left corner of the Month object
        my $w = 0; # $m.width;  # width of month box
        my $h = 0; # $m.height; # height of month box
        ($w, $h) = $m.print: $f, $fB; # does not render unless $page is defined

        my $x = 36; 
        # start x depends on column (0..^$ncols)
        $x += $col * ($w + $delta-x);

        my $y = 0;  
        # start y depends on position in the page (0..^$page-mons)



        #==================
        # results
        if $page-mons == $nmons-per-page {
            ++$npages;
        }

        print qq:to/HERE/;
            {$m.name}
                page-mons = $page-mons
                npages    = $npages
        HERE

        # finished one page; start a new page unless finished
        if $npages == $npages-needed {
            say "Finished printing all months";
            last MONTH;
        }

        if $page-mons == $nmons-per-page {
            say "  Adding a new page";
            $page = $pdf.add-page;
            $page-mons = 0;
        }
        
        =begin comment
        print "day | ";
        print sprintf "%-*.*s | ", $nc2, $nc2, "Birthdays";
        print sprintf "%-*.*s", $nc3, $nc3, "Anniversaries";
        say();
        for $m.lines.kv -> $i, $L {
            my $s1 = $L.cells[0].text;
            my $s2 = $L.cells[1].text;
            my $s3 = $L.cells[2].text;
            print sprintf " %-2.2s | ", $s1;
            print sprintf "%-*.*s | ", $nc2, $nc2, $s2;
            print sprintf "%-*.*s", $nc3, $nc3, $s3;
            say();
        }
        say()
        =end comment

        } # end COLUMN loop
        } # end ROW loop
    } # end MONTH loop


    # see sub show...

    $pdf.save-as: $ofil;
}

sub print-month($page, Month :$month!, :$x!, :$y!, :$debug) is export {
    # x,y of the top-left corner, translate to it
    $page.graphics: {
        .Save;
        .transform: :translate($x, $y);
        # do the work

        # finished
        .Restore;
    }
}

sub print-figure($page, :$font!, :$x!, :$y!, :$debug) is export {
    # x,y of the top-left corner, translate to it
    $page.graphics: {
        .Save;
        .transform: :translate($x, $y);
        # do the work
        # select a font and scale of, say, 72 points
        # draw an origin and baseline
        # print a 'g', draw its bbox, x-advance, bearings, width,
        #   height
        .transform: :translate(20, -90);
        .MoveTo: -10,0;
        .LineTo: 70,0; # baseline, x-axis
        .MoveTo: 0,-10;
        .LineTo: 0,80; # y-axis
        .print: "g", :position[0, 0], :$font, :font-size(72);
                            # :align<left>, :kern; #, default: :valign<bottom>;

        # on another baseline
        .transform: :translate(0, -90);
        .MoveTo: -10,0;
        .LineTo: 70,0; # baseline, x-axis
        # print  'We' without kerning
        # to its right print the 'We' with kerning
        .print: "We", :position[0, 0], :$font, :font-size(72);
        .print: "We", :position[30, 0], :$font, :font-size(72), :kern;

        # on another baseline 
        # show the 'f' non-ligatures adjacent to their ligatures

        # finished
        .Restore;
    }
}

sub hex2string(@hex, :$debug --> Str) is export {
    # converts a list of Unicode hex char code numbers to a string
    my $s;
    for @hex -> $h {
        my $ord = hex2dec $h;
        $s ~= $ord.chr;
    }
    $s
}

sub dec2string(@dec, :$debug --> Str) is export {
    # converts a list of Unicode char code decimal numbers to a string
    my $s;
    for @dec -> $ord {
        $s ~= $ord.chr;
    }
    $s
}

sub get-ligatures(:$hex, :$debug --> Hash) is export {
    # Returns a hash of non-ligatures and their decimal 
    # Unicode char codes (or hex codes if desired)
    =begin comment
    ff  =>       |   U+fb00      | 64256
    ffi =>       |   U+fb03      | 64259
    ffl =>       |   U+fb04      | 64260
    fi  =>       |   U+fb01      | 64257
    fl  =>       |   U+fb02      | 64258
    =end comment
    my %h;
    if $hex {
        %h<ff>  = 0xfb00;
        %h<ffi> = 0xfb03;
        %h<ffl> = 0xfb04;
        %h<fi>  = 0xfb01;
        %h<fl>  = 0xfb02;
    }
    else {
        %h<ff>  = 64256;
        %h<ffi> = 64259;
        %h<ffl> = 64260;
        %h<fi>  = 64257;
        %h<fl>  = 64258;
    }
    %h
}

