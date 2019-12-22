use v6;

use Time::Repeat::MM;
use Time::Repeat::internal;

unit class Time::Repeat::HHMM:ver<0.0.2> is export;

our $VERSION = '0.02';

##############################################################################

has Int  $.hour        is rw = 0;
has Int  $.minute      is rw = 0;
has Bool $.is-next-day is rw = False;

##############################################################################

multi method new (Str $string)
{
  die "Illegal time $string, must be four digits" unless $string ~~ $dd-dd;

  my Int $hour         = $0.Int;
  my Int $minute       = $1.Int;
  my Bool $is-next-day = False;
  
  while $hour >= 24
  {
    $hour -= 24; die if $is-next-day; $is-next-day = True;
  }

  return self.bless(hour => $hour, minute => $minute, is-next-day => $is-next-day);
}

multi method new (UInt :$hour, UInt :$minute, Bool :$is-next-day = False)
{
  die unless $hour   ~~ $d-dd;
  die unless $minute ~~ $d-dd;

  while $hour >= 24
  {
    $hour -= 24; die if $is-next-day; $is-next-day = True;
  }

  return self.bless(hour => $hour, minute => $minute, is-next-day => $is-next-day);
}

multi method new(DateTime $t)
{
  return self.bless(hour => $t.hour, minute => $t.minute, is-next-day => False);
}

##############################################################################

method now
{
  return Time::Repeat::HHMM.new(DateTime.now);
}

##############################################################################

method later (UInt :$hour = 0, UInt :$minute = 0)
{
  my $hh   = $.hour   + $hour;
  my $min  = $.minute + $minute;
  my $next = $.is-next-day;
  
  while $min >= 60
  {
    $hh++;
    $min -= 60;
  }

  while $hh >= 24
  {
    die if $next;
    $hh -= 24;
    $next = True;
  }

  return Time::Repeat::HHMM.new(hour => $hh, minute => $min, is-next-day => $next);
}

##############################################################################

method earlier (UInt :$hour = 0, UInt :$minute = 0)
{
  my $hh   = $.hour   - $hour;
  my $min  = $.minute - $minute;
  my $next = $.is-next-day;
  
  while $min < 0
  {
    $hh--;
    $min += 60;
  }

  while $hh < 0
  {
    die unless $next;
    $hh += 24;
    $next = False;
  }

  return Time::Repeat::HHMM.new(hour => $hh, minute => $min, is-next-day => $next);
}

##############################################################################

method values
{
  return $.hour, $.minute, $.is-next-day;
}

method Str
{
  return sprintf("%02d%02d", $.hour, $.minute);
}

method Real
{
  return $.is-next-day * 24 * 60 + $.hour * 60 + $.minute;
}

method Numeric
{
  return $.is-next-day * 24 * 60 + $.hour * 60 + $.minute;
}

##############################################################################

method add (:$hour = 0, :$minute = 0)
{
  $.hour   += $hour;
  $.minute += $minute;
  
  while $.minute >= 60
  {
    $.hour++;
    $.minute -= 60;
  }

  while $.hour >= 24
  {
    die if $.is-next-day;
    $.hour -= 24;
    $.is-next-day = True;
  }

  return self;
}

##############################################################################

multi sub repeat-interval (Str $from, PosInt $delta, Str $to) is export
{
  return repeat-interval(Time::Repeat::HHMM.new($from), $delta, Time::Repeat::HHMM.new($to));
}

multi sub repeat-interval (Time::Repeat::HHMM $from, PosInt $delta, Str $to) is export
{
  return repeat-interval($from, $delta, Time::Repeat::HHMM.new($to));
}

multi sub repeat-interval (Time::Repeat::HHMM $from, Int $delta, Time::Repeat::HHMM $to) is export
{
  my @result;
  my Time::Repeat::HHMM $curr = $from;
  
  while $curr <= $to
  {
    @result.push($curr);
    $curr = $curr.later(minute => $delta);
  }

  return @result;
}

##############################################################################

multi sub repeat-atminutes (Str $from, @minutes, Str $to) is export
{
  return repeat-atminutes(Time::Repeat::HHMM.new($from), @minutes, Time::Repeat::HHMM.new($to));
}

multi sub repeat-atminutes (Time::Repeat::HHMM $from, @minutes, Str $to) is export
{
  return repeat-atminutes($from, @minutes, Time::Repeat::HHMM.new($to));
}

multi sub repeat-atminutes (Time::Repeat::HHMM $from, @minutes, Time::Repeat::HHMM $to) is export
{
  die "Unsorted minutes list" unless is-sorted(@minutes);

  my Time::Repeat::HHMM @return;
  my Time::Repeat::HHMM $current = $from;
 
  hour: loop
  {
    for @minutes -> $minute
    {
      $current = $current.clone(minute => $minute);
      
      @return.push($current) if $current >= $from and $current <= $to;

      last hour if $current >= $to;
    }
    $current = $current.later(hour => 1);
   }

  return @return;
}

##############################################################################

multi sub DateTime2HHMM (DateTime $t) is export
{
  return Time::Repeat::HHMM.new(hour => $t.hour, minute => $t.minute);
}

multi sub DateTime2HHMM (DateTime $now, DateTime $base) is export
{
  my $is-next-day = False;

  my $now2  = $now.clone( hour => 0, minute => 0, second => 0);
  my $base2 = $base.clone(hour => 0, minute => 0, second => 0).later(:1day);

  $is-next-day = True if $now2 == $base2;
  
  return Time::Repeat::HHMM.new(hour => $now.hour, minute => $now.minute, is-next-day => $is-next-day);
}

##############################################################################

# This one will expand "+xx", but will leave "xx" (and the alias ("--xx") as is.

multi sub time-parse ($string) is export
{
  time-parse($string.words);
}

multi sub time-parse (@times) is export
{
  my @return;
  my Bool $plus-inside = False;
  my Int $plus-val;
  
  for @times -> $current
  {
    if $plus-inside
    {
      if $current ~~ $hhmm
      {
        my $from = @return.pop; # Remove it, as it will be included in the repetition.
        @return.append(repeat-interval($from, $plus-val, $current)); # HHMM, Int, Str
        $plus-inside = False;
	next;
      }
      else
      {
        die "Interval with illegal end value $current (should have been '0000')";
      }
    }

    if    $current ~~ $mm       { @return.push(Time::Repeat::MM.new($current)) }
    elsif $current ~~ $time-min { @return.push(Time::Repeat::MM.new($0.Str)) }
    elsif $current ~~ $hhmm     { @return.push(Time::Repeat::HHMM.new($current)) }
    elsif $current ~~ $time-plus
    {
      $plus-val = $0.Int;
      $plus-inside = True;
    }
    else { die "Illegal argument $current; should be '00' or '0000'"; }
  }

  return @return;
}

##############################################################################

# This one will expand both "+xx" and "xx" (and the alias ("--xx").

multi sub time-parse-full ($string) is export
{
  time-parse-full($string.words);
}

multi sub time-parse-full (@times) is export
{
  my @return;
  my Bool $plus-inside  = False;
  my Bool $minus-inside = False;
  my Int $plus-val;
  my @minus-val;
  
  for @times -> $current
  {
    if $plus-inside
    {
      if $current ~~ $hhmm
      {
        my $from = @return.pop; # Remove it, as it will be included in the repetition.
        @return.append(repeat-interval($from, $plus-val, $current)); # HHMM, Int, Str
        $plus-inside = False;
      }
      else
      {
        die "Interval with illegal end value $current (should have been '0000')";
      }
    }
    
    elsif $minus-inside
    {
      if $current ~~ $time-min
      {
        @minus-val.push($0.Int);
      }
      elsif $current ~~ $hhmm
      {
        my $from = @return.pop; # Remove it, as it will be included in the repetition.
        @return.append(repeat-atminutes($from, @minus-val, $current)); # HHMM, Int, Str
        @minus-val = ();
      }
    }

    elsif $current ~~ $hhmm     { @return.push(Time::Repeat::HHMM.new($current)) }
    elsif $current ~~ $time-plus
    {
      $plus-val = $0.Int;
      $plus-inside = True;
    }
    elsif $current ~~ $time-min
    {
      @minus-val.push($0.Int);
      $minus-inside = True;
    }
    else { die "Illegal argument $current; should be '00' or '0000'"; }
  }

  return @return;
}

##############################################################################

=begin pod

=head1 NAME

Time::Repeat::HHMM - Module for working with time intervals.

=head1 VERSION

Version $VERSION

=head1 SYNOPSIS

This module defines the "Time::Repeat::HHMM" class, dealing with hours and minutes. It
also has a day concept for sorting purposes. Use the "Time::Repeat::DateTime" class if
you need to work with day values as well.

Note that the day concept only recognises the current day and the next one. If you add
or subract values outside these days, and exception will be trown.

=head1 SUBROUTINES/Methods

=head2 repeat-interval


=head2 repeat-atminutes

Example: repeat-atminutes("0910", 10, "2410")
Result: "0910 1010 1110 1210 1310 1410 1510 1610 1710 1810 1910 2010 2110 2210 2310 0010".

Note that the upper limit must be specified as "24xx" and so on if it is the next day.
It will be shown correctly, and will sort after the hour values from the original day -
if you need to sort the list.

=head2 new

my $t1 = Time::Repeat::HHMM.new("1200"); # A four digit string.
my $t2 = Time::Repeat::HHMM.new(hour => 12, minute => 0);
my $t3 = Time::Repeat::HHMM.new(DateTime.now)

=head2 now

The same as "Time::Repeat::HHMM.new(DateTime.now)".

=head2 later/earlier

These methods will return a copy of the HHMM object, with the minute and/or hour
values adjusted.

my $t2 = $t1.later(minute => 10);
my $t3 = $t1.later(minute => 10, hour => 1);
my $t4 = $t1.later(hour => 1);
my $t5 = $t1.earlier(minute => 10);

Do not use negative values.

=head2 add

This will add the specified minutes and/or hours to the object itself. This is
useful when using the times as an iterator, as it doesn't make new objects all
the time.

$t1.add(minute => 10);
$t1.add(minute => 5, hour => 1);
$t1.add(hour => 1);

Do not use negative values!

=head2 DateTime2HHMM

This will return a new HHMM object. The call takes two DateTime objects. The
first is used for the minute and hour values, and the second as day base.

my $t1 = Time::Repeat::HHMM::DateTime2HHMM($dt1, $dt2);

The next day flag is set if the first DateTime argument is the day after the
second one.

=head2 time-parse

This will expand "repeat-interval", but will leave "repeat-atminutes" intact.

Intervals are specified as "+xx", and atminutes as "xx" or "--xx".

say time-parse($t1, "+10", $t2, "10", "40", $3");


=head2 time-parse-full

This is basically the same as "Time::Repeat::String.expand-time". It will expand
everything.

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018-2019 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=end pod
