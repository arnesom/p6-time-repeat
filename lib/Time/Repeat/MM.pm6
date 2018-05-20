use v6.c;

use Time::Repeat::internal;

unit class Time::Repeat::MM:ver<0.0.1> is export;

our $VERSION = '0.01';

has Int  $.hour   is rw = 0;
has Int  $.minute is rw = 0;

##############################################################################

multi method new (Str $string)
{
  die "Illegal minute value $string, must be two digits" unless $string ~~ $dd;

  my Int $hour         = 0;
  my Int $minute       = $0.Int;
  
  while $minute >= 60
  {
    $minute -= 60; $hour++;
  }

  return self.bless(hour => $hour, minute => $minute);
}

multi method new (:$minute)
{
  die unless $minute ~~ $d-dd;
  
  my Int $hour = 0;

  while $minute >= 60
  {
    $minute -= 60; $hour++;
  }

  return self.bless(hour => $hour, minute => $minute);
}

multi method new (DateTime $t)
{
  return self.bless(hour => $t.hour, minute => $t.minute);
}

##############################################################################

method now
{
  return Time::Repeat::MM.new(DateTime.now);
}

##############################################################################

method later (PosInt :$minute)
{
  my $hh   = $.hour;
  my $min  = $.minute + $minute;
  
  while $min >= 60
  {
    $hh++;
    $min -= 60;
  }

  return Time::Repeat::MM.new(hour => $hh, minute => $min);
}

##############################################################################

method earlier (PosInt :$minute)
{
  my $hh   = $.hour;
  my $min  = $.minute - $minute;
  
  while $min < 0
  {
    $hh--;
    $min += 60;
  }

  return Time::Repeat::MM.new(hour => $hh, minute => $min);
}

##############################################################################

method add (:$minute)
{
  $.minute += $minute;
  
  while $.minute >= 60
  {
    $.hour++;
    $.minute -= 60;
  }
  
  while $.minute < 0
  {
    $.hour--;
    $.minute += 60;
  }

  return self;
}

##############################################################################

method values
{
  return $.hour, $.minute;
}

method Str
{
  return sprintf("%02d", $.minute);
}

method Real
{
  return $.hour * 60 + $.minute;
}

##############################################################################

=begin pod

=head1 NAME

Time::Repeat::MM - Module for working with time intervals.

=head1 VERSION

Version $VERSION

=head1 SYNOPSIS

This module defines the "Time::Repeat::MM" class, dealing with minutes. It also has a
concept of hour, for sorting purposes. Use the "Time::Repeat::HHMM" class if you need
to work with hour values as well.

=head1 SUBROUTINES/Methods

=head2 new

my $t1 = Time::Repeat::MM.new("00"); # A two digit string.
my $t2 = Time::Repeat::MM.new(minute => 0); # A one or two digit number.

Values up to 99 is accepted, and will result in 39 minutes and an hour value of 1.

my $t3 = Time::Repeat::MM.new(DateTime.now)

This will get the current hour and minute values.

=head2 now

The same as "Time::Repeat::MM.new(DateTime.now)".

=head2 later/earlier

These methods will return a copy of the MM object, with the minute value adjusted.

my $t2 = $1.later(minute => 10);
my $t3 = $1.earlier(minute => 10);

Do not use negative values.

=head2 add

This will add the specified minutes to the object itself. This is useful when using
the times as an iterator, as it doesn't make new objects all the time.

$1.add(minute => 10);
$1.add(minute => -10);

Negative values work as well.

=head2 CONTEXT

In string context a two digit string is returned; e.g. "00", "10", "59". In numeric
context the number of miutes is returned (with the hours * 60 added for sorting purposes).

If you need the hour value, use the "values" method.

$t.values; # -> $hour, $minute

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=end pod
