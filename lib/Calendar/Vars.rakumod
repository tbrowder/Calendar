unit module Calendar::Vars;

# Various constants used for landscape calendar
# production (in PS points, 72 per inch). Note 
# the pages are printed in portrait orientation
# but generated internally in landscape. Blank
# pages are generated so the "pamphlet" mode
# can be used with Office Depot print services.

my $lw  =   8.5 * 72;      # Letter width in portrait orientation
my $lh  =  11   * 72;      # Letter height in portrait orientation
my $a4w = 210   * 72/25.4; # A4 width in portrait orientation
my $a4h = 297   * 72/25.4; # A4 height in portrait orientation
my $sm  =   0.4 * 72;      # side margins
my $gb b=     . * 72;  
our %Letter is export = [
    width  => $lw,
    height => $lh,
    sm     => 0.4*72,
    tm     => 0.4*72,
    bm     => 0.4*72,
];
our %A4 is export = [
    width  => $a4w,
    height => $a4h,
    sm     => 0.4*72,
    tm     => 0.4*72,
    bm     => 0.4*72,
];

# paper dimens
constant \LW is export =  8.5 * 72; # width in portrait orientation
constant \LH is export = 11.0 * 72; # height in portrait orientation

# page margins
constant \GM is export = 0.1 * 72; # gutter margin for binding
constant \LM is export = 0.4 * 72;
constant \RM is export = 0.4 * 72;
constant \TM is export = 0.4 * 72;
constant \BM is export = 0.4 * 72;
