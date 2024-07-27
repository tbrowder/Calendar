#!/usr/bin/env raku

my $ifil = "hw-visa.txt";

for $ifil.IO.lines -> $line {
    # split lines on, e.g., |04/1304/12 .* 08262702 .*  .10|
    # regex: [\d\d '/' \d**4 '/' \d\d] .* [\d**8 '-'? [$ with commas]  '.'\d\d |      
    # [\d\d '/' \d**4 '/' \d\d]

    my @w = $line.split(/[\d\d '/' \d**4 '/' \d\d] /, :v, :skip-empty);
    my $s;

    if 0 {
        for @w {
            if $_ ~~ Match {
                print "{$_.Str} ";
            }
            else {
                say $_;
            }
        }
        next;
    }

    while @w {
        my $a = @w.shift;
        if $a ~~ Match {
            my $b = @w.shift if @w.elems;
            say "{$a.Str} $b";
        }
        else {
            say $a;
        }
    }
}
