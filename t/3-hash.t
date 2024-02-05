use Test;

#use Calendar;

my %a{Date};
my $year  = 2024;
my $month = 2;

my $u1 = 1;
my $u2 = 2;
my $d;

lives-ok {
    for 1..4 {
        my $k = $_.Str;
        my $ID = $u1 ~ $k;
        $d = Date.new: :$year, :$month, :day($_);
        %a{$d}{$ID} = $_;
    }
}

lives-ok {
    for 3..6 {
        my $d = Date.new: :$year, :$month, :day($_);
        my $k = $_.Str;
        my $ID = $u2 ~ $k;
        $d = Date.new: :$year, :$month, :day($_);
        %a{$d}{$ID} = $_
    }
}

lives-ok {
    for %a.keys.sort -> $k {
        dd %a{$k};
    }
}

lives-ok {
    for %a.keys.sort -> $k {
        say "date: $k";
        for %a{$k}.keys -> $k2 {
            say "  value: ", %a{$k}{$k2};
        }
    }
}

done-testing;
