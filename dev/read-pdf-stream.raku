#!/usr/bin/env raku

use File::Temp;

my $ifil = "2023-05-13.pdf";

my $ofil;
my $debug = 0;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <input.pdf> [options]

    Runs shell command 'pdftk <input.pdf> output <output.pdf> uncompress'
    where the output file is a temporary pdf file. That
    file is then analyzed by a Raku code to present the text found
    within. That analysis is output to <input.txt>.

    Options:
    HERE

    exit;
}

=begin comment
my @args;
for @*ARGS {
    if $_.IO.r {
    }
    @args.push: $_;
}

die "FATAL: No input.pdf was found" unless $ifil.IO.r;
=end comment

shell "pdftk $ifil output t.pdf uncompress";
say "See uncompressed stream text in file 't.pdf'";
#exit;

my $stream = "";;
my $in-stream = 0;
LINE: for "t.pdf".lines -> $line {
    if $line ~~ /^ stream/ {
        $in-stream = 1;
    }
    elsif $line ~~ /^ endstream/ {
        $in-stream = 0;
    }
    elsif $in-stream {
        note "DEBUG stream chunk: $line";
        $stream ~= $line;
    }
    elsif not $in-stream {
        next LINE;
    }
    else {
        note "DEBUG unexpected line: $line";
    }
}

spurt "t.txt", $stream;
