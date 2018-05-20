use v6.c;
use Test;
use lib 'lib';
use Time::Repeat::DateTime;

plan 17;

my DateTime $now      = DateTime.now.truncated-to('second'); # As second fractions screw up later.
my DateTime $tomorrow = $now.later(days => 1);

ok { $now < $tomorrow }, "Today comes before tomorrow";

dies-ok { repeat-interval($now, "XL", $tomorrow) }, "Illegal delta value";

dies-ok { repeat-atminutes($now, "XL", $tomorrow) }, "Illegal minute value";
dies-ok { repeat-atminutes($now, (0, "XL", 30), $tomorrow) }, "Illegal minute value";
dies-ok { repeat-atminutes($now, (0, 30, 10), $tomorrow) }, "Wrong order of minute values";

my @lazy1 = repeat-interval($now, 60); # 60 minutes.
my @lazy2 = repeat-interval($now, Duration.new(60*60) ); # 60 minutes.

ok { @lazy1[24] == $tomorrow }, "24 hours later, number";
is   @lazy1[24],   $tomorrow,   "24 hours later, string";

ok { @lazy2[24] == $tomorrow }, "24 hours later, number";
is   @lazy2[24],   $tomorrow,   "24 hours later, string";


# say @lazy2[^25];


my @list1 = @lazy1[^25];
my @list2 = repeat-interval($now,   60,  $tomorrow);
my @list3 = repeat-interval($now, "+60", $tomorrow);
my @list4 = repeat-interval($now, Duration.new(60*60), $tomorrow);

is @list1.elems, 25, "25 elements, lazy+slice";
is @list2.elems, 25, "25 elements, upper limit";

is @list1[0], @list2[0], "First element equal";

is-deeply @list1, @list2, "The same 25 elements";
is-deeply @list1, @list3, "The same 25 elements";
is-deeply @list1, @list4, "The same 25 elements";

my @list11 = repeat-interval($tomorrow, 60, $now);
my @list12 = @list1.reverse;

is @list11.elems, 25, "25 elements, reversed";
is-deeply @list11, @list12, "The same 25 elements";

done-testing;
