#!/usr/bin/env raku

use PDF::API6;
use PDF::Lite;
use PDF::Font::Loader :load-font;
#use PDF::Content::Color :ColorName, :&color;
#use PDF::Content::Page :PageSizes;
use Date::Utils;
use Abbreviations;
use Compress::PDF;

use Calendar;
use PageProcs;
use Calendar::Subs;
use Calendar::Vars;

my $media = 'Letter';

my $lang  = 'en';
my $debug = 0;
my $nmonths;
my $do-events = 0;
my $year = Date.today.year;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a test PDF calendar using Letter or
      A4 paper in landscape orientation.
    Larger sizes can be provided if necessary.

    Options
        y[ear]=X  - Year [default: $year]
        o[file]=X - Output file name [default: calendar-$year.pdf]
        m[edia]=X - Page format [default: Letter]
        l[ang]=X  - Language (ISO two-letter code) [default: $lang]
        d[ebug]   - Debug
        n[mon]    - Number of months to show [default: all]
        e[event]  - Write CSV file of known events by date
    HERE
    exit
}

my $ofile;
for @*ARGS {
    when /^ :i y[e|ea|ear]? '=' (\d**4) / {
        $year = +$0;
    }
    when /^ :i l[a|an|ang]? '=' (\S+) / {
        $lang = ~$0.lc;
    }
    when /^ :i n[m|mu|mun]? '=' (\d+) / {
        $nmonths = +$0;
    }
    when /^ :i e[v|ve|ven|vent]? / {
        ++$do-events;
    }
    when /^ :i o[f|fi|fil|file]? '=' (\S+) / {
        $ofile = ~$0;
        unless $ofile ~~ /:i \.pdf$/ {
            $ofile ~= ".pdf";
        }
    }
    when /^ :i m[e|ed|edi|edia]? '=' (\S+) / {
        $media = ~$0.tc;
        unless $media eq 'Letter' or $media eq 'A4' {
            die qq:to/HERE/;
            FATAL: Media choices currently are 'Letter' or 'A4'
                   You entered '$media'.
                   File an issue if you need another format.
            HERE
            exit;
        }
    }
    when /^ :i d / { ++$debug }
    when /^ :i g / {
        $nmonths = 0; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

# default title of output pdf
unless $ofile.defined {
    $ofile = "calendar-$year.pdf";
}
my $cal = Calendar.new: :$year, :$lang;
if $do-events {
    $cal.write-year-events;
}

#=finish

# Do we need to specify 'media-box' on the whole document?
# No, it can also be set per page.
my $pdf = PDF::Lite.new;

# write the desired pages
my PDF::Lite::Page $page;
my %data;
# ...

my $nstart = 1;
my $nend   = 14;
my $nm     =  0;
if $nmonths.defined {
    $nm = $nmonths;
}

# nm=0 is special: jan only, no cover page
if  $nm > 0 {
    # start the document with the first page
    $page = $pdf.add-page;
    $cal.write-page-cover: :$page, :%data;
}

if $nm == 0 {
    $nstart = $nend = 2;
}

for $nstart..$nend -> $month is copy {
    if $month == 13 {
        my $y = $cal.year + 1;
        $cal = Calendar.new: :year($y), :$lang;
        $month = 1;
    }
    elsif $month == 14 {
        $month = 2;
    }

    if $nm > 0 {
        $page = $pdf.add-page;
        $cal.write-page-month-top: $month, :$page, :%data;
    }
    $page = $pdf.add-page;
    $cal.write-page-month: $month, :$page, :%data;
}

my $pages = $pdf.Pages.page-count;
# save the whole thing with name as desired
$pdf.save-as: "$ofile.tmp";
compress "$ofile.tmp", :outpdf($ofile), :force;
unlink "$ofile.tmp" unless $debug;
say "See PDF calendar for year $year: $ofile";
say "Total pages: $pages";
