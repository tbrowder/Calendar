unit module Calendar::Vars;

use PDF::Lite;
use PDF::Font::Loader :load-font;

# font files in standard Debian location
my $t-fil   = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $tb-fil  = "/usr/share/fonts/opentype/freefont/FreeSerifBold.otf";
my $ti-fil  = "/usr/share/fonts/opentype/freefont/FreeSerifItalic.otf";
my $tbi-fil = "/usr/share/fonts/opentype/freefont/FreeSerifBoldItalic.otf";

my $h-fil   = "/usr/share/fonts/opentype/freefont/FreeSans.otf";
my $hb-fil  = "/usr/share/fonts/opentype/freefont/FreeSansBold.otf";

sub load-fnts(--> Hash) is export {
    my %fonts;
    %fonts<t>   = load-font :file($t-fil);
    %fonts<tb>  = load-font :file($tb-fil);
    %fonts<ti>  = load-font :file($ti-fil);
    %fonts<tbi> = load-font :file($tbi-fil);
    %fonts<h>   = load-font :file($h-fil);
    %fonts<hb>  = load-font :file($hb-fil);
    %fonts
}

# Various constants used for landscape calendar production (in PS
# points, 72 per inch). Note the pages are printed in portrait
# orientation but generated internally in landscape. Blank pages are
# generated so the "pamphlet" mode can be used with Office Depot or
# UPS print services. (print Portrait orientation, flip on long side)

my $Lw  =   8.5 * 72;      # Letter width in portrait orientation
my $Lh  =  11   * 72;      # Letter height in portrait orientation

my $A4w = 210   * 72/25.4; # A4 width in portrait orientation
my $A4h = 297   * 72/25.4; # A4 height in portrait orientation

my $sm  =   0.4 * 72;      # side margins

# vertical dimensions for the "bottom" calendar page
#   gutter is on top edge (and on the bottom edge for the "top" page)
my $g   =   0.0 * 72;      # gutter (binding margin)
my $tm  =   0.4 * 72;      # top margin (in addition to gutter)
my $bm  =   0.4 * 72;      # bottom margin (may be reduced, no hole needed)

sub dimens($media where { $_ ~~ /Letter|A4/ } --> Hash) is export {

    # vertical dimensions common to both media types for the current design
    my %h = [
        # dimensions are from y = top edge of the paper
        # (binding space is included)
        cover-year-base  => -277,
        cover-title-base => -314,
        cover-info-base  => -355,

        month-name-base  =>  -68,
        month-quote-base =>  -90,
        month-cal-top    => -102,
        dow-height       =>   15,
        binding-height   =>   15,
    ];

    # horizontal and vertical dimensions by media type
    if $media eq 'Letter' {
        %h<width>  = $Lw;
        %h<height> = $Lh;
        %h<sm>     = $sm; # left and right side margins
        %h<tm>     = $tm; # top margin (adjust for binding depending
                          # on page being top or bottom)
        %h<bm>     = $bm; # bottom margin (adjust for page selection as
                          # top margin)
        %h<cell-width>  =  ($Lw - (2*$sm)) / 7.0;
        %h<cell-height> =  ($Lh + %h<month-cal-top> - %h<dow-height> - $bm) / 6.0;

    }
    elsif $media eq 'A4' {
        %h<width>  = $A4w;
        %h<height> = $A4h;
        # start with same values as Letter, may change later
        %h<sm>     = $sm;
        %h<tm>     = $tm;
        %h<bm>     = $bm;
        %h<cell-width>  =  ($A4w - (2*$sm)) / 7.0;
        %h<cell-height> =  ($A4h + %h<month-cal-top> - %h<dow-height> - $bm) / 6.0;
    }
    else {
        die "FATAL: Unexpected '$_'";
    }

    %h
}

=begin comment
our %dimens is export = [
    cover-year-base  => -277, # from y=top edge of paper
    cover-title-base => -314, # from y=top edge of paper
    cover-info-base  => -355, # from y=top edge of paper

    month-name-base  => -68,
    month-quote-base => -90,
    month-cal-top    => -102,
    dow-height       => 15,  #
];

our %Letter is export = [
    width  => $Lw,
    height => $Lh,
    sm     => $sm,
    tm     => $tm,
    bm     => $bm,
];

our %A4 is export = [
    width  => $A4w,
    height => $A4h,
    sm     => $sm,
    tm     => $tm,
    bm     => $bm,
];
=end comment

# Other constants
#

# Default list of "sayings" indexed by month number. Grace Lee's
# favorites.  Source: King James version of the Bible, verses from the
# book of Proverbs Note the lines may need to have a shortened version
# or smaller font.
our @sayings is export =
0,
"For by me [the Lord] thy days shall be multiplied, and the years of thy life shall be increased. (Proverbs 9:10)",
"The fear of the Lord is the beginning of knowledge, but fools despise wisdom and instruction. (Proverbs 1:7)",
"Trust in the Lord with all thine own heart and lean not unto thine own understanding. (Proverbs 3:5)",
"In all thy ways acknowledge him and he shall direct thy paths. (Proverbs 3:6)",
"Keep company with the wise and you will become wise. (Proverbs 13:20)",
"The road the righteous travel is like the sunrise, getting brighter and brighter until daylight has come. (Proverbs 4:18)",
"Plan carefully what you do and whatever you do will turn out right. (Proverbs 4:26)",
"Let love and faithfulness never leave you; bind them around your neck, write them on the tablet of your heart. (Proverbs 3:3)",
"Hatred stirs up dissension, but love covers over all wrongs. (Proverbs 10:12)",
"Be generous, and you will be prosperous.  Help others, and you will be helped. (Proverbs 11:25)",
"A heart at peace gives life to the body.... (Proverbs 14:30)",
"A gentle answer turns away wrath, but a harsh word stirs up anger. (Proverbs 15:1)",
;
