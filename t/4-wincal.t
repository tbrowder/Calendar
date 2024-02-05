use Test;

use Calendar;

lives-ok { 
    shell "raku -Ilib ./bin/wincal 2>&1 /dev/null";
}, "mode entered, success";

done-testing;
