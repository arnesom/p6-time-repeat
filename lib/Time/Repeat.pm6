unit module Time::Repeat:ver<0.0.2>:auth<Arne Sommer>;

die "Use Time::Repeat::****, and not the empty module 'Time::Repeat'.";

=begin pod

=head1 NAME

Time::Repeat::**** - Modules for working with time intervals.

=head1 VERSION

Version 0.0.2

=head1 SYNOPSIS

This distribution supplies the follwing modules:

  use Time::Repeat::String;         # Work with text strings
  use Time::Repeat::HHMM;           # Work with HHMM objects (hour and minutes), defined in the module
  use Time::Repeat::HHMM::Interval; # Work with intervals, based on HHMM objects
  use Time::Repeat::MM;             # Work with MM objects (minutes), defined in the module
  use Time::Repeat::DateTime;       # Work with DateTime objects
  
=head1 SUBROUTINES

All the modules (except MM and HHMM::Interval) have the following two procedures. See the
indvividual module documentation for a list of other procedures and methods they provide.

<time> is one of:

=item A text string (e.g. "1200")

=item An HHMM object (e.g. HHMM.new("1200"))

=item A DateTime object (e.g DateTime.now())

=head2 repeat-interval(<time>, 10, <time>);

This will give a list of times, from the first one with 10 minutes added until
the upper limit has been reached.

=head2 repeat-atminutes(<time>, 10, <time>);

This will give a list of times, from the first one and then every 10 minutes past the
hour until the upper limit has been reached. 

=head2 repeat-atminutes(<time>, (10, 40), <time>);

As the previous one, but with times every 10 and 40 minutes past the hour. The list can
have several items, but must be specified in sorted order (or the call will throw an
error).

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018-2019 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=end pod
