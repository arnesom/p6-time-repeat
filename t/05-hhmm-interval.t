use v6;
use Test;
use lib 'lib';

use Time::Repeat::HHMM;
use Time::Repeat::HHMM::Interval;

plan 8;

my HHMM $t11 = HHMM.new(hour => 12, minute => 0);
my HHMM $t12 = HHMM.new("1304");

is $t11, "1200";
is $t12, "1304";

my Time::Repeat::HHMM::Interval $i1 = Time::Repeat::HHMM::Interval.new($t11, $t12);

is $i1, "1200-1304";

my HHMM $t21 = HHMM.new(hour => 12, minute => 59);
my HHMM $t22 = HHMM.new("1434");

is $t21, "1259";
is $t22, "1434";
my Time::Repeat::HHMM::Interval $i2 = Time::Repeat::HHMM::Interval.new($t21, $t22);

is $i2, "1259-1434";

my Time::Repeat::HHMM::Interval @to-merge = ($i1, $i2);

my @merged = Time::Repeat::HHMM::Interval::merge(@to-merge);

is @merged.elems, 1;

is @merged[0], "1200-1434";

done-testing;
