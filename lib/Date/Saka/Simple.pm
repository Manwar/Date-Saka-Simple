package Date::Saka::Simple;

$Date::Saka::Simple::VERSION = '0.03';

=head1 NAME

Date::Saka::Simple - Represents Saka date.

=head1 VERSION

Version 0.03

=cut

use 5.006;
use Data::Dumper;
use Time::localtime;

use Moo;
use namespace::clean;

use overload q{""} => 'as_string', fallback => 1;

=head1 DESCRIPTION

Represents the Saka date.

=cut

has year  => (is => 'rw', predicate => 1);
has month => (is => 'rw', predicate => 1);
has day   => (is => 'rw', predicate => 1);

with 'Date::Utils::Saka';

sub BUILD {
    my ($self) = @_;

    $self->validate_year($self->year)   if $self->has_year;
    $self->validate_month($self->month) if $self->has_month;
    $self->validate_day($self->day)     if $self->has_day;

    unless ($self->has_year && $self->has_month && $self->has_day) {
        my $today = localtime;
        my $year  = $today->year + 1900;
        my $month = $today->mon + 1;
        my $day   = $today->mday;
        my ($y, $m, $d) = $self->gregorian_to_saka($year, $month, $day);
        $self->year($y);
        $self->month($m);
        $self->day($d);
    }
}

=head1 SYNOPSIS

    use strict; use warnings;
    use Date::Saka::Simple;

    # prints today's saka date
    print Date::Saka::Simple->new, "\n";

    my $date = Date::Saka::Simple->new({ year => 1937, month => 1, day => 1 });
    print "Date: $date\n";

    # prints equivalent Julian date
    print $date->to_julian, "\n";

    # prints equivalent Gregorian date
    print $date->to_gregorian, "\n";

    # prints day of the week index (0 for Ravivara, 1 for Somvara and so on.
    print $date->day_of_week, "\n";

=head1 METHODS

=head2 to_julian()

Returns julian date equivalent of the Saka date.

=cut

sub to_julian {
    my ($self) = @_;

    return $self->saka_to_julian($self->year, $self->month, $self->day);
}

=head2 to_gregorian()

Returns gregorian date (yyyy-mm-dd) equivalent of the Saka date.

=cut

sub to_gregorian {
    my ($self) = @_;

    my @date = $self->julian_to_gregorian($self->to_julian);
    return sprintf("%04d-%02d-%02d", $date[0], $date[1], $date[2]);
}

=head2 day_of_week()

Returns day of the week, starting 0 for Ravivara, 1 for Somvara and so on.

    +---------+-----------+-----------------------------------------------------+
    | Weekday | Gregorian | Saka                                                |
    +---------+-----------+-----------------------------------------------------+
    |    0    | Sunday    | Ravivara                                            |
    |    1    | Monday    | Somvara                                             |
    |    2    | Tuesday   | Mangalavara                                         |
    |    3    | Wednesday | Budhavara                                           |
    |    4    | Thursday  | Brahaspativara                                      |
    |    5    | Friday    | Sukravara                                           |
    |    6    | Saturday  | Sanivara                                            |
    +---------+-----------+-----------------------------------------------------+

=cut

sub day_of_week {
    my ($self) = @_;

    return $self->jwday($self->to_julian);
}

=head2 add_days()

Add given number of days to the Saka date.

=cut

sub add_days {
    my ($self, $no_of_days) = @_;

    die("ERROR: Invalid day count.\n") unless ($no_of_days =~ /^\-?\d+$/);

    my ($year, $month, $day) = $self->to_gregorian();
    ($year, $month, $day) = Add_Delta_Days($year, $month, $day, $no_of_days);
    ($year, $month, $day) = $self->gregorian_to_saka($year, $month, $day);

    $self->year($year);
    $self->month($month);
    $self->day($day);
}

=head2 minus_days()

Minus given number of days from the Saka date.

=cut

sub minus_days {
    my ($self, $no_of_days) = @_;

    die("ERROR: Invalid day count.\n") unless ($no_of_days =~ /^\d+$/);

    return $self->add_days(-1 * $no_of_days);
}

=head2 add_months()

=cut

sub add_months {
    my ($self, $no_of_months) = @_;

    die("ERROR: Invalid month count.\n") unless ($no_of_months =~ /^\d+$/);

    if (($self->month + $no_of_months) > 12) {
        while (($self->month + $no_of_months) > 12) {
            my $_month = 12 - $self->month;
            $self->year($self->year + 1);
            $self->month(1);
            $no_of_months = $no_of_months - ($_month + 1);
        }
    }

    $self->month($self->month + $no_of_months);
}

=head2 minus_months()

Minus given number of months from the Saka date.

=cut

sub minus_months {
    my ($self, $no_of_months) = @_;

    die("ERROR: Invalid month count.\n") unless ($no_of_months =~ /^\d+$/);

    if (($self->month - $no_of_months) < 1) {
        while (($self->{mm} - $no_of_months) < 1) {
            my $_month = $no_of_months - $self->month;
            $self->year($self->year - 1);
            $no_of_months = $no_of_months - $self->month;
            $self->month(12);
        }
    }

    $self->month($self->month - $no_of_months);
}

=head2 add_years()

Add given number of years to the Saka date.

=cut

sub add_years {
    my ($self, $no_of_years) = @_;

    die("ERROR: Invalid year count.\n") unless ($no_of_years =~ /^\d+$/);

    $self->year($self->year + $no_of_years);
}

=head2 minus_years()

Minus given number of years from the Saka date.

=cut

sub minus_years {
    my ($self, $no_of_years) = @_;

    die("ERROR: Invalid year count.\n") unless ($no_of_years =~ /^\d+$/);

    $self->year($self->year - $no_of_years);
}

sub as_string {
    my ($self) = @_;

    return sprintf("%d, %s %d", $self->day, $self->saka_months->[$self->month], $self->year);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Date-Saka-Simple>

=head1 BUGS

Please report any bugs / feature requests to C<bug-date-saka-simple at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Saka-Simple>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Saka::Simple

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Saka-Simple>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Saka-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Saka-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Saka-Simple/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Date::Saka::Simple
