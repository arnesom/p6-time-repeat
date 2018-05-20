use v6.c;
use Test;
use lib 'lib';
use Time::Repeat::String;

plan 18;

is repeat-interval("1200",   10,  "1301"),
   repeat-interval("1200", "+10", "1301"),
   "Interval as expected, with or without '+'";
   
is repeat-interval("1200", 10, "1301"),
   <1200 1210 1220 1230 1240 1250 1300>,
   "Interval as expected, list";

is repeat-interval("1200", 10, "1301").Str,
   "1200 1210 1220 1230 1240 1250 1300",
   "Interval as expected, string";

is repeat-atminutes("2200", (10, 33), "2500"),
   <2210 2233 2310 2333 2410 2433>,
   "Interval as expected, string";

dies-ok { repeat-atminutes("2200", (40, 10), "2500") },
   "Wrong order of minute values";

is expand-time(<1000 1010 1020 1030 1050>), "1000 1010 1020 1030 1050",
   "Simple pass-through, list";

is expand-time("1000 1010 1020 1030 1050"), "1000 1010 1020 1030 1050",
   "Simple pass-through, string";

is expand-time(<1031 --00 --30 1805>),
   "1100 1130 1200 1230 1300 1330 1400 1430 1500 1530 1600 1630 1700 1730 1800",
   "Minutes past each hour";

is expand-time(<1000 +5 1201>),
   "1000 1005 1010 1015 1020 1025 1030 1035 1040 1045 1050 1055 1100 1105 1110 1115 1120 1125 1130 1135 1140 1145 1150 1155 1200",
   "Interval";

is expand-time(<1200 +5 1301 --10 1600>),
   "1200 1205 1210 1215 1220 1225 1230 1235 1240 1245 1250 1255 1300 1310 1410 1510",
   "The end of one can be the start of the next one";

is expand-time(<1200 +5 1301 --10 --25 1600>),
   "1200 1205 1210 1215 1220 1225 1230 1235 1240 1245 1250 1255 1300 1310 1325 1410 1425 1510 1525",
   "One more.";

dies-ok { expand-time(<1200 +5 +6 1300>) }, "Error, only one '+x' allowed";

dies-ok { expand-time(<1200 +5 --10 1300>) },  "Error, do not mix '+x' and '--y'";

dies-ok { expand-time(<1200 --10 +10 1300>) }, "Error, do not mix '+x' and '--y'";

dies-ok { expand-time(<1200 --40 --10 1600>) }, "Wrong order of minute values";

is expand-time(<1200 --10 1309 --15 1800>), "1210 1315 1415 1515 1615 1715",
   "Border value '1309' not in result";

is expand-time(<1000 +10 1901>), repeat-interval("1000", 10, "1901"),
   "expand-time & repeat-interval agrees";

is expand-time(<1000 --10 --40 1901>), repeat-atminutes("1000", (10, 40), "1901"),
   "expand-time & repeat-atminutes agrees";

done-testing;
