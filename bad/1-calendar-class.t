use Test;

use Calendar;

my ($year, $o);

$year = DateTime.now.year + 1;
$o = Calendar.new;
is $o.year, $year;
is $o.lang, 'en';
is $o.media, 'Letter';

$o = Calendar.new: :year(2027);
is $o.year, 2027;
is $o.lang, 'en';
is $o.media, 'Letter';

$o = Calendar.new: :year(2023), :lang('es'), :media<A4>;
is $o.year, 2023;
is $o.lang, 'es';
is $o.media, 'A4';

my ($proc, $res, @lines, @lines2, $errcode);
dies-ok {
    $proc = run "./bin/make-cal", "y=2028", :out, :err;
    $errcode = $proc.errcode;
    cmp-ok $errcode, '>', 0, "good";
}, "no mode entered, fail";

lives-ok { 
    $proc = run "./bin/make-cal", "pdf", :out, :err;
    $errcode = $proc.errcode;
    is $errcode, 1, "good";
}, "pdf mode entered, success";

done-testing;
=finish

lives-ok { 
    shell "raku -Ilib ./bin/make-cal c 2>&1 /dev/null";
}, "mode entered, success";

lives-ok { 
    shell "raku -Ilib ./bin/make-cal c m=2,3 2>&1 /dev/null";
}, "caldata, two months";

{
    my $of = "/tmp/data";
    lives-ok { 
        shell "raku -Ilib ./bin/make-cal c y=2023 > $of";
    };

    my @lines1 = $of.IO.lines;
    my @lines2 = "t/data/caldat.2023".IO.lines;

    my $n1 = @lines1.elems;
    my $n2 = @lines2.elems;
    
    is $n1, $n2, "same number of lines: $n1 vs $n2";

    for 0..^$n1 -> $i {
        is @lines1[$i].trim-trailing, @lines2[$i].trim-trailing;
    }
}

done-testing;
