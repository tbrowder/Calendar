use Test;
use Test::Output;

use Calendar;

my ($year, $o);

$year = DateTime.now.year + 1;
$o = Calendar.new;
is $o.year, $year;
is $o.lang, 'en';

$o = Calendar.new: :year(2033);
is $o.year, 2033;
is $o.lang, 'en';

$o = Calendar.new: :year(2023), :lang('es');
is $o.year, 2023;
is $o.lang, 'es';

lives-ok {
    $o.caldata;
}

{
    $o = Calendar.new: :year(2023);
    my $stdout = stdout-from { $o.caldata :year(2023) };

    my @lines1 = $stdout.lines;
    my @lines2 = "t/data/caldat.2023".IO.lines;

    my $n1 = @lines1.elems;
    my $n2 = @lines2.elems;
    
    is $n1, $n2;
}

done-testing;
