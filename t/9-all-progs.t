use Test;

use Calendar;

my $debug = 0;
my ($mode, $prog, $proc, $out, $err, $res, @args, @opts);

#======================================================
$prog = "./bin/wincal";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :$out, :$err;
}, "running prog '$prog', success";

#======================================================
$prog = "./bin/makecal";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :$out, :$err;
}, "running prog '$prog', success";

#======================================================
$prog = "./sbin/draw-grid.raku";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :$out, :$err;
}, "running prog '$prog', success";

#======================================================
$prog = "./sbin/make-grid.raku";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :$out, :$err;
}, "running prog '$prog', success";

done-testing;

