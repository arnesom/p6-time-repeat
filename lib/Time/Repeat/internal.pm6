use v6.c;

unit module Time::Repeat::internal:ver<0.0.2>;

our $VERSION = '0.02';

##############################################################################

constant $d-dd      is export = /^(\d ** 1..2)$/;
constant $dd-dd     is export = /^(\d\d)(\d\d)$/;
constant $dd        is export = /^(\d\d)$/;
constant $mm        is export = /^(<[0..5]><[0..9]>)$/;
constant $hhmm      is export = /^(<[012]><[0..9]>)(<[0..5]><[0..9]>)$/;
constant $time-plus is export = /^\+(\d+)$/;
constant $time-min  is export = /^\-\-(\d\d)$/;
constant $integer   is export= /^\d+$/;

subset PosInt of Int is export where * > 0 ;
  # Use the builtin "UInt" where * >= 0

##############################################################################

sub is-sorted (@list) is export
{
  return True if [<] @list;
  return False;
}

##############################################################################

=begin pod

=head1 NAME

Time::Repeat::internal - Common internal stuff for the public modules.

=head1 VERSION

Version $VERSION

=head1 AUTHOR Arne Sommer, C<< <arne at perl6.eu> >>

=head1 BUGS

Please report any bugs or feature requests by creating Issues at
L<https://github.com/arnesom/p6-time-repeat.git>. Thank you in advance for any input.

=head1 LICENSE AND COPYRIGHT

Copyright 2018-2019 Arne Sommer. This library is free software; you can redistribute it
and/or modify it under the terms of the the Artistic License (2.0). You may obtain
a copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>.

=end pod

##############################################################################
