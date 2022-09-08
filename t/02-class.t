use Test;
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

# able to produce same output as Linux 'cal' program for 2023
lives-ok {
    $o.caldata
}

done-testing;
