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
    if $debug {
        $out ?? (say "out: '$out'") !! (say "empty :out");
        $err ?? (say "err: '$err'") !! (say "empty :err");
    }
}, "running prog '$prog'";

#======================================================
$prog = "./bin/make-cal";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    if $debug {
        $out ?? (say "out: '$out'") !! (say "empty :out");
        $err ?? (say "err: '$err'") !! (say "empty :err");
    }
}, "running prog '$prog'";

#======================================================
$prog = "./sbin/draw-cells.raku";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    if $debug {
        $out ?? (say "out: '$out'") !! (say "empty :out");
        $err ?? (say "err: '$err'") !! (say "empty :err");
    }
}, "running prog '$prog'";

#======================================================
$prog = "./sbin/make-grid.raku";
lives-ok { 
    $proc = run "raku", "-Ilib", $prog, :out, :err;
    $out = $proc.out.slurp(:close);
    $err = $proc.err.slurp(:close);
    if $debug {
        $out ?? (say "out: '$out'") !! (say "empty :out");
        $err ?? (say "err: '$err'") !! (say "empty :err");
    }
}, "running prog '$prog'";

done-testing;

