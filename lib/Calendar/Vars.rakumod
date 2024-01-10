unit module Calendar::Vars;

# Various constants used for landscape calendar
# production (in PS points, 72 per inch). Note 
# the pages are printed in portrait orientation
# but generated internally in landscape. Blank
# pages are generated so the "pamphlet" mode
# can be used with Office Depot print services.

my $Lw  =   8.5 * 72;      # Letter width in portrait orientation
my $Lh  =  11   * 72;      # Letter height in portrait orientation

my $A4w = 210   * 72/25.4; # A4 width in portrait orientation
my $A4h = 297   * 72/25.4; # A4 height in portrait orientation

my $sm  =   0.4 * 72;      # side margins
my $g   =   0.0 * 72;      # gutter
my $tm  =   0.4 * 72;      # top margin
my $bm  =   0.4 * 72;      # bottom margin (may reduce, no hole needed)

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

