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

done-testing;
