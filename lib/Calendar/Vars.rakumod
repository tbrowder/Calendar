unit module Calendar::Vars;

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
my $g   =   0.0 * 72;      # gutter
my $tm  =   0.4 * 72;      # top margin
my $bm  =   0.4 * 72;      # bottom margin (may reduce, no hole needed)

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

# Other constants
#

# Default list of "sayings" indexed by month number. Grace Lee's favorites.
# Source: King James version of the Bible, verses from the book of Proverbs
# Note the lines may need to have a shortened version or smaller font.
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
