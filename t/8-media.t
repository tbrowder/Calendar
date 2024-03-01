use Test;

use PDF::API6; # method specialize
use PDF::Lite; # PDFTiny is not yet exported;
use PDF::Content::Page :PageSizes;

use PageProcs;

my PDF::Lite $doc .= new;
my $page = $doc.page;

does-ok $page, PDF::Lite::Page, "A good \$page";
my ($res, $media, @media, $name, @Media);

@media = "letter", "a4";

for @media -> $media is copy {
    $media .= tc;
    $name = "Letter";
    with $media {
        when /^ :i (letter|a4) $/ {
            $name = ~$0.tc;
        }
        default {
            die "FATAL: Unhandled media type '$_''";
        }
    }
    isa-ok $media, Str, "is a known media type Str ($name)"; #Array; # $page.media-box,

    @Media = get-media($media);
    isa-ok @Media, Array, "\@Media, is an Array (name: $name)";
    $page.media-box = @Media;
    isa-ok $page.media-box, Array, "is an Array: \$page.media-box (name: $name)";

    is $page.media-box[0], 0;
    is $page.media-box[1], 0;

    if $name ~~ /:i Letter/ {
        is $page.media-box, [0, 0, 612, 792], "media-box array values (name: $name)";
        is $page.media-box[2], 612;
        is $page.media-box[3], 792;
    }
    elsif $name ~~ /:i A4/ {
        is $page.media-box, [0,0, 595, 842], "media-box array values name: $name";
        is $page.media-box[2], 595;
        is $page.media-box[3], 842;
    }

}

done-testing;

=finish

$media = "letter";
$res = get-rgb $color;
isa-ok $res, Array;
is $res[1], 0;
is $res.elems, 3;
is $res.head, 0;
is $res.tail, 0;

$color = "lime";
$res = get-rgb $color;
isa-ok $res, Array;
is $res[1], 1;
is $res.elems, 3;
is $res.head, 0;
is $res.tail, 0;

done-testing;
