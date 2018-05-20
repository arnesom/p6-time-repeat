use v6.c;
use Test;
use lib 'lib';
use Time::Repeat::HHMM;

plan 15;

my HHMM $t1 = HHMM.new(hour => 12, minute => 0);
my HHMM $t2 = HHMM.new("1202");
my HHMM $t3 = $t2.later(hour => 12);

is $t1.hour, 12, "The hour part of '1200'";

is $t1.values, (12, 0, False), "The individual values";
   
is $t1, "1200", "The time";

is $t1, $t1.clone, "The same values";

is $t1.later(hour => 1), "1300", "One hour after 1200";

ok { $t1 < $t2 }, "1200 comes before 1202";

nok $t1.is-next-day, "Today";
ok  $t3.is-next-day, "The next day";

is repeat-interval(HHMM.new("1200"), 10, HHMM.new("1301")).Str,
   "1200 1210 1220 1230 1240 1250 1300",
   "Interval as expected, string";

is repeat-interval(HHMM.new("1200"), 10, HHMM.new("1301")),
   <1200 1210 1220 1230 1240 1250 1300>,
   "Interval as expected, list";
   
dies-ok { repeat-interval(HHMM.new("1200"), (10, 40), HHMM.new("1301")) }, "Only one interval value";

is repeat-atminutes(HHMM.new("2200"), (10, 33), HHMM.new("2500")),
   <2210 2233 2310 2333 0010 0033>,
   "Interval as expected, HHMM";

is repeat-atminutes("2200", (10, 33), "2500"),
   <2210 2233 2310 2333 0010 0033>,
   "Interval as expected, string";

is repeat-atminutes(HHMM.new("2200"), (10, 33), HHMM.new("2500")),
   repeat-atminutes("2200", (10, 33), "2500"),
   "HHMM and string values give the same result";

dies-ok { repeat-atminutes(HHMM.new("2200"), (33, 10), HHMM.new("2400")) }, "Wrong order of minute values";
   
done-testing;
