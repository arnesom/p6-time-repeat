use v6.c;

use Time::Repeat::internal;

unit module Time::Repeat::String:ver<0.0.1>;

our $VERSION = '0.01';

##############################################################################

multi sub repeat-interval (Str $from, $delta is copy, Str $to) is export
{
  my $current = $from;
  my $stop    = $to;
  my @return;
  
  $current ~~ $hhmm; my $current-h = $0; my $current-m = $1;
  $stop    ~~ $hhmm; my $stop-h    = $0; my $stop-m    = $1;

  $delta = $0 if $delta ~~ $time-plus;
  @return.push($current);

  loop
  {
    $current-m += $delta;
    while $current-m >= 60
    {
      $current-h += 1;
      $current-m -= 60;
    }
      
    last if $current-h > $stop-h;

    if $current-h == $stop-h
    {
      last if $current-m > $stop-m;
    }

    @return.push(hhmm($current-h, $current-m));
  }
  
  return @return;
}

##############################################################################

multi sub repeat-atminutes (Str $from, @minutes, Str $to) is export
{
  die "Unsorted minutes list" unless is-sorted(@minutes);

  my $current = $from;
  my $stop    = $to;
  my @return;

  $current ~~ $hhmm; my $current-h = $0; my $current-m = $1;
  $stop    ~~ $hhmm; my $stop-h    = $0; my $stop-m    = $1;

  my $start-h = $current-h;
  my $start-m = $current-m;

  hour: loop
  {
    for @minutes -> $minute
    {
      ## Not started yet ?

      if $current-h == $start-h
      {
        next if $minute < $start-m;
      }

      ## The end ?

      last hour if $current-h > $stop-h;

      if $current-h == $stop-h
      {
        last hour if $minute > $stop-m
      }

      @return.push(hhmm($current-h, $minute));
    }

    $current-h += 1;
  }
   
  return @return;
}

##############################################################################

multi sub expand-time($times) is export
{
  expand-time($times.words);
}

##############################################################################

multi sub expand-time(@times is copy) is export
{
  my @result;
  my $current = @times.shift;
  die "Illegal argument, must be 'hhmm'" unless $current ~~ $hhmm;
  
  my $is-expand = False;

  outer: loop
  {
    if @times[0] && @times[0] ~~ $time-plus | $time-min
    {
      my @to-expand = $current;
  
      inner: loop
      {
        $current = shift(@times);
	@to-expand.push($current);
	if $current ~~ $hhmm
	{
	  @result.append(_do-expand(@to-expand));

          last outer unless @times;
	  $current = shift(@times) unless @times[0] ~~ $time-plus | $time-min;
	  next outer;
        }
      }
    }

    if @times[0]
    {
      @result.push($current);
      $current = @times.shift;
      next outer;
    }
    else
    {
      @result.push($current);
      last outer;
    }
  }
  
  return @result;
}

##############################################################################

my sub _do-expand (@times is copy)
{
  my $from = @times.shift;
  my $to    = @times.pop;

  if @times[0] ~~ $time-plus
  {
    my $delta = $0;

    die "XXXX +yy ZZZZ with more than one zz-part" unless @times.elems == 1;
      # As we have no use for more than one "+X" value.

    return repeat-interval($from, $delta, $to);
  }

  ## 1000 --00 --15 --30 --45 1800

  elsif @times[0] ~~ $time-min
  {
    # 1. Get the list of minutes; 00, 15, 30, 45.

    my @minutes-list;

    for @times -> $elem
    {
      die "Expected --xx; got $elem" unless $elem ~~ $time-min;
      @minutes-list.push($0);
    }

    return repeat-atminutes($from, @minutes-list, $to);
  }
}

##############################################################################

my sub hhmm ($h, $m)
{
  return sprintf("%02d%02d", $h, $m);
}

##############################################################################

=begin pod

=head1 NAME

Time::Repeat::String - Procedures for working with time intervals.

=head1 VERSION

Version $VERSION

=head1 SYNOPSIS

Use this module if you have an aversion for objects. If you don't have such
a problem, use 'Time::Repeat::HHMM' and 'Time::Repeat::MM' instead.

=head1 SUBROUTINES

<time> is a four digit string, e.g. "0000", "1510", and "2410". Note that times
after midnight must be specified as "24xx", "25xx" and so on. They will be reported
back in the same way. Use "Time::Repeat:HHMM" instead if correct reporting is an
issue (as it should be).

=head2 repeat-interval(<time>, 10, <time>);

This will give a list of times, from the first one with 10 minutes added until
the upper limit has been reached.

Example: repeat-interval("1010", 60, "1910")
Result: "1010 1110 1210 1310 1410 1510 1610 1710 1810 1910"

Example: repeat-interval("1010", 60, "1200"); # Note that the upper limit isn't included in thew result list.
Result: "1010, 1110" 

=head2 repeat-atminutes(<time>, 10, <time>);

This will give a list of times, from the first one and then every 10 minutes past the
hour until the upper limit has been reached. 

Example: repeat-atminutes("1200", 10, "1409")
Result: "1210, 1310".

Example: repeat-atminutes("0910", 10, "2410")
Result: "0910 1010 1110 1210 1310 1410 1510 1610 1710 1810 1910 2010 2110 2210 2310 2410".

=head2 repeat-atminutes(<time>, (10, 40), <time>);

As the previous one, but with times every 10 and 40 minutes past the hour. The list can
have several items, but they must be specified in sorted order (or the call will throw an
error).

Example: repeat-atminutes("1215", (10, 40) "1400") # Note that neither the lower nor upper limits are in the rsult.
Result: "1240 1310 1340".

=head2 expand-time

This is a parsing procedure. Give it a list of itesm or a space separated text string.

"repeat-interval" is specified as "+xx", and "repeat-atminutes" is specified as one or more "--xx",
in sorted order.

Example: expand-time("1000 +5 1100")
Result: "1000 0005 1010 1015 1020 1025 1030 1035 1040 1045 1050 1055 1100".

Example: expand-time("1000 --10 1409")
Result: "1010 1110 1210 1310".

Example: expand-time("1215 --10 --40 1400")
Result: "1240 1310 1340".

They can be combined.

Example: expand-time("1201 +10 1300 --00 1700") # 1300 is both an upper limit (for +10) and a lower limit (for --00).
Result: 1201 1211 1221 1231 1241 1251 1300 1400 1500 1600 1700".

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=end pod

##############################################################################
