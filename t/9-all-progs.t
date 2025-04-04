use Test;

use Calendar;

my $debug = 1;

my ($mode, $prog, $proc, $out, $err, $res, @args, @opts);

#======================================================
$prog = "./bin/wincal";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    say "out: '$out'" if 1 and $debug;
    say "err: '$err'" if 1 and $debug;
}, "running prog '$prog'";

#======================================================
$prog = "./bin/makecal";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    say "out: '$out'" if 0 and $debug;
    say "err: '$err'" if 0 and $debug;
}, "running prog '$prog'";

#======================================================
$prog = "./sbin/draw-grid.raku";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    say "out: '$out'" if 0 and $debug;
    say "err: '$err'" if 0 and $debug;
}, "running prog '$prog'";

#======================================================
$prog = "./sbin/make-grid.raku";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    say "out: '$out'" if 0 and $debug;
    say "err: '$err'" if 0 and $debug;
}, "running prog '$prog'";

done-testing;

