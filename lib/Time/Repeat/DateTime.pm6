use v6;

use Time::Repeat::internal;

unit module Time::Repeat::DateTime:ver<0.0.2>;

our $VERSION = '0.02';

##############################################################################
#
# <DateTime> 10 <DateTime>
#

multi sub repeat-interval (DateTime $from, $delta, DateTime $to) is export
{
  my $tz = $from.timezone;
  
  my $delta-sec;

  given $delta
  {
    when Duration
    {
      $delta-sec   = $delta.Int;
    }
    when $integer
    {
      $delta-sec   = $delta * 60;
    }
    when $time-plus
    {
      $delta-sec   = $0 * 60;
    }
    default
    {
      die "Illegal delta value: $delta";
    }
  }
 
  ## Convert everything to seconds. The start and end times as Unix timestamps
  ## (seconds since epoch).

  my $current-sec = $from.posix;
  my $to-sec      = $to.posix;
  my @result; 

  ## Reverse ?

  my $reverse = False;
  
  if $to-sec <  $current-sec
  {
    ($to-sec, $current-sec) =  ($current-sec, $to-sec);
    $reverse = True;
  }

  ## Loop through the seconds until we reach or pass the upper limit.

  while $current-sec <= $to-sec
  {
    @result.push(DateTime.new($current-sec, timezone => $tz));
      # Save the time as a DateTime object.
      
    $current-sec += $delta-sec;
  }

  return @result.reverse if $reverse;

  return @result;
}

multi sub repeat-interval (DateTime $from, Duration $delta) is export
{
  my $tz = $from.timezone;
  return ($from, { DateTime.new($^a.posix + $delta.Int, timezone => $tz) } ... Inf);
}

multi sub repeat-interval (DateTime $from, Int $delta) is export
{
  my $tz = $from.timezone;
  return ($from, { DateTime.new($^a.posix + $delta * 60, timezone => $tz) } ... Inf);
}

##############################################################################
#
# <DateTime> --10 --40 <DateTime>
#

multi sub repeat-atminutes (DateTime $from, $minute, DateTime $to) is export
{
  my @list = ($minute);
  repeat-atminutes($from, @list, $to);
}

multi sub repeat-atminutes (DateTime $from, @minutes, DateTime $to) is export
{
  die "Unsorted minutes list" unless is-sorted(@minutes);
  
  my @minutes-ok;

  for @minutes -> $minutes
  {
    if $minutes ~~ $integer
    {
      @minutes-ok.push($minutes);
    }
    elsif $minutes ~~ $time-min
    {
      @minutes-ok.push($0);
    }
    else
    {
      die "Illegal minute value: $minutes";
    }
  }

  my DateTime @return;
  my DateTime $current = $from.clone;

  hour: loop
  {
    for @minutes-ok -> $minutes
    {
      $current = $current.clone(minute => $minutes);
      
      @return.push($current) if $current => $from and $current <= $to;

      last hour if $current >= $to;
    }
    $current = $current.later(hours => 1);
   }

  return @return;
}

##############################################################################

=begin pod

=head1 NAME

Time::Repeat::DateTime - Module for working with time intervals.

=head1 VERSION

Version $VERSION

=head1 SYNOPSIS

Note that DateTime objects support fractional second values. Use
"DateTime.now.truncated-to('second');" instead of "DateTime.now" to get
whole seconds. This module doesn't cope with fractional seconds, and will
silently truncate them.

=head1 SUBROUTINES/Methods

=head2 repeat-interval

Note that the interval is in minutes. If you want seconds, use a Duration object.

You can leave out the upper limit, and get a lazy list. You are then resposible
yourself for deciding when to stop, either by checking the values or the number.

my @dt1 = Time::Repeat::DateTime.repeat-interval($dt, $delta);

for @dt1 -> $dt
{
  last if $dt ...;
  ...
}

my @dt2 = @dt1[^100];

Note that any fractional seconds part will be truncated, from the second
value onwards.

=head2 repeat-atminutes

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018-2019 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=end pod
