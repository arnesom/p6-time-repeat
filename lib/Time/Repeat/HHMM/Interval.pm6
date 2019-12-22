use v6;

use Time::Repeat::HHMM;

unit class Time::Repeat::HHMM::Interval:ver<0.0.2> is export;

our $VERSION = '0.02';

##############################################################################

has HHMM $.start;
has HHMM $.stop;

##############################################################################

multi method new(HHMM $start, HHMM $stop)
{
  return self.bless(start => $start, stop => $stop);
}

multi method new(Str $start, Str $stop)
{
  return self.bless(start => Time::Repeat::HHMM.new($start),
                    stop  => Time::Repeat::HHMM.new($stop) );
}

##############################################################################

method Str
{
  return $.start ~ "-" ~ $.stop;
}

method Numeric
{
  return $.stop - $.start;
}

##############################################################################

our sub merge (Time::Repeat::HHMM::Interval @intervals is copy)
{
  my Time::Repeat::HHMM::Interval @result;

  my $first = @intervals.shift;
  my $start = $first.start;
  my $stop  = $first.stop;
  
  for @intervals.sort -> $interval
  {
    if $interval.start > $stop
    {
      @result.push: Time::Repeat::HHMM::Interval.new($start, $stop);
      $start = $interval.start;
      $stop  = $interval.stop;
    }
    else
    {
      $stop = $interval.stop if $interval.stop > $stop;
    }
  }
  
  @result.push: Time::Repeat::HHMM::Interval.new($start, $stop);
  
  return @result;
}

##############################################################################

=begin pod

=head1 NAME

Time::Repeat::HHMM::Interval - Module for working with literal time intervals.

=head1 VERSION

Version $VERSION

=head1 SYNOPSIS

This module defines the "Time::Repeat::HHMM::Interval" class, dealing with hours
and minutes from a start to and end. It does not support days.

=head1 METHODS

=head2 new

  my $t1 = Time::Repeat::HHMM::Interval.new("1200", "1310");
  my $t2 = Time::Repeat::HHMM::Interval.new(Time::Repeat::HHMM.new("1300"), Time::Repeat::HHMM.new("1355"));

=head1 SUBROUTINES

=head2 merge

Takes a list of Time::Repeat::HHMM::Interval objects and merges them as far as possible, so that
overlapping intervals are combined.

Returns a new list of Time::Repeat::HHMM::Interval objects.

  my Time::Repeat::HHMM::Interval @objects = ($t1, $t2);

  my @result = Time::Repeat::HHMM::Interval::merge(@objects);

  .put for @result;  # -> 1200-1355

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018-2019 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=end pod
