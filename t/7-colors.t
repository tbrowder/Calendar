use Test;

use PDF::Content::Color :ColorName, :rgb;
use PageProcs;

my ($res, $color);

$color = "black";
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
