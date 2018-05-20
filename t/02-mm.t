use v6.c;
use Test;
use lib 'lib';
use Time::Repeat::MM;

plan 12;

my MM $t1 = MM.new(minute => 0);
my MM $t2 = MM.new("17");

######################################################################

is $t1, $t1.later(minute => 60), "Add one hour, keep the minutes";
is $t2, $t2.later(minute => 60), "Add one hour, keep the minutes";

ok { $t1 < $t2 },                        "00 comes before 17";
ok { $t1.later(minute => 60) lt $t2 },   "00 comes before 17";
ok { $t1.later(minute => 60) >  $t2 }, "1:00 comes after  17";

is $t1, $t1.clone, "The same values";

is   $t1, $t1.add(minute   => 5), "The same object, and value";
isnt $t1, $t1.later(minute => 5), "New object, different value";

is $t1.values, (0, 5),  "The individual values";
is $t2.values, (0, 17), "The individual values";

$t2.later(minute => 10);
is $t2.values, (0, 17), "The individual values";

$t2.add(minute => 10);
is $t2.values, (0, 27), "The individual values";


done-testing;
