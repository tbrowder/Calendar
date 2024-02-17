#!/usr/bin/env raku

use YAMLish;

my $cf  = "./config.yml".IO.slurp;
my %h   = load-yaml $cf;

say "=== simple config";
for %h.kv -> $k, $v {
    say "key: $k ; value: $v";
}
