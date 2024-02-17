#!/usr/bin/env raku

use YAMLish;

my $cf = "./config.yml".IO.slurp;
my $h = load-yaml $cf;
say $h.raku;

