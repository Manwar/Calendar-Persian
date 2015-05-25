package Calendar::Persian;

$Calendar::Persian::VERSION = '0.16';

=head1 NAME

Calendar::Persian - Interface to Persian Calendar.

=head1 VERSION

Version 0.16

=cut

use Data::Dumper;
use Term::ANSIColor::Markup;
use Date::Persian::Simple;

use Moo;
use namespace::clean;

use overload q{""} => 'as_string', fallback => 1;

has year  => (is => 'rw', predicate => 1);
has month => (is => 'rw', predicate => 1);
has date  => (is => 'ro', default   => sub { Date::Persian::Simple->new });

sub BUILD {
    my ($self) = @_;

    $self->date->validate_year($self->year)   if $self->has_year;
    $self->date->validate_month($self->month) if $self->has_month;

    unless ($self->has_year && $self->has_month) {
        $self->year($self->date->year);
        $self->month($self->date->month);
    }
}

=head1 DESCRIPTION

The Persian  calendar  is  solar, with the particularity that the year defined by
two  successive,  apparent  passages    of  the  Sun  through the vernal (spring)
equinox.  It  is based  on precise astronomical observations, and moreover uses a
sophisticated intercalation system, which makes it more accurate than its younger
European  counterpart,the Gregorian calendar. It is currently used in Iran as the
official  calendar  of  the  country. The  starting  point of the current Iranian
calendar is  the  vernal equinox occurred on Friday March 22 of the year A.D. 622.
Persian Calendar for the month of Farvadin year 1390.

    +---------------------------------------------------------------------------------------------------------------+
    |                                             Farvardin   [1394 BE]                                             |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |    Yekshanbeh |     Doshanbeh |    Seshhanbeh | Chaharshanbeh |   Panjshanbeh |         Jomeh |       Shanbeh |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |                                                                                               |             1 |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |             2 |             3 |             4 |             5 |             6 |             7 |             8 |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |             9 |            10 |            11 |            12 |            13 |            14 |            15 |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |            16 |            17 |            18 |            19 |            20 |            21 |            22 |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |            23 |            24 |            25 |            26 |            27 |            28 |            29 |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+
    |            30 |            31 |                                                                               |
    +---------------+---------------+---------------+---------------+---------------+---------------+---------------+

=head1 SYNOPSIS

    use strict; use warnings;
    use Calendar::Persian;

    # prints current month calendar
    print Calendar::Persian->new, "\n";
    print Calendar::Persian->new->current, "\n";

    # prints persian month calendar for the first month of year 1394.
    print Calendar::Persian->new({ month => 1, year => 1394 }), "\n";

    # prints persian month calendar in which the given gregorian date falls in.
    print Calendar::Persian->new->from_gregorian(2015, 1, 14), "\n";

    # prints persian month calendar in which the given julian date falls in.
    print Calendar::Persian->new->from_julian(2457102.5), "\n";

=head1 PERSIAN MONTHS

    +-------+-------------------------------------------------------------------+
    | Month | Persian Name                                                      |
    +-------+-------------------------------------------------------------------+
    |     1 | Farvardin                                                         |
    |     2 | Ordibehesht                                                       |
    |     3 | Xordad                                                            |
    |     4 | Tir                                                               |
    |     5 | Amordad                                                           |
    |     6 | Sahrivar                                                          |
    |     7 | Mehr                                                              |
    |     8 | Aban                                                              |
    |     9 | Azar                                                              |
    |    10 | Dey                                                               |
    |    11 | Bahman                                                            |
    |    12 | Esfand                                                            |
    +-------+-------------------------------------------------------------------+

=head1 PERSIAN DAYS

    +-------+---------------+---------------------------------------------------+
    | Index | Persian Name  | English Name                                      |
    +-------+---------------+---------------------------------------------------+
    |     0 | Yekshanbeh    | Sunday                                            |
    |     1 | Doshanbeh     | Monday                                            |
    |     2 | Seshhanbeh    | Tuesday                                           |
    |     3 | Chaharshanbeh | Wednesday                                         |
    |     4 | Panjshanbeh   | Thursday                                          |
    |     5 | Jomeh         | Friday                                            |
    |     6 | Shanbeh       | Saturday                                          |
    +-------+---------------+---------------------------------------------------+

=head1 CONSTRUCTOR

It expects month and year optionally.By default it gets current Persian month and
year.

=head1 METHODS

=head2 current()

Returns current month of the Persian calendar.

=cut

sub current {
    my ($self) = @_;

    return $self->_calendar($self->date->year, $self->date->month);
}

=head2 from_gregorian($year, $month, $day)

Returns persian month calendar in which the given gregorian date falls in.

=cut

sub from_gregorian {
    my ($self, $year, $month, $day) = @_;

    my $date = $self->from_julian($self->gregorian_to_julian($year, $month, $day));

    return $self->_calendar($date->year, $date->month);
}

=head2 from_julian($julian_date)

Returns persian month calendar in which the given julian date falls in.

=cut

sub from_julian {
    my ($self, $julian_date) = @_;

    my $date = $self->date->from_julian($julian_date);
    return $self->_calendar($date->year, $date->month);
}

sub as_string {
    my ($self) = @_;

    return $self->_calendar($self->year, $self->month);
}

#
#
# PRIVATE METHODS

sub _calendar {
    my ($self, $year, $month) = @_;

    my $date = Date::Persian::Simple->new({ year => $year, month => $month, day => 1 });
    my $start_index = $date->day_of_week;
    my $days = $self->date->days_in_persian_month_year($month, $year);

    my $line1 = '<blue><bold>+' . ('-')x111 . '+</bold></blue>';
    my $line2 = '<blue><bold>|</bold></blue>' .
                (' ')x45 . '<yellow><bold>' .
                sprintf("%-11s [%04d BE]", $self->date->persian_months->[$month], $year) .
                '</bold></yellow>' . (' ')x45 . '<blue><bold>|</bold></blue>';
    my $line3 = '<blue><bold>+';

    for(1..7) {
        $line3 .= ('-')x(15) . '+';
    }
    $line3 .= '</bold></blue>';

    my $line4 = '<blue><bold>|</bold></blue>' .
                join("<blue><bold>|</bold></blue>", @{$self->date->persian_days}) .
                '<blue><bold>|</bold></blue>';

    my $calendar = join("\n", $line1, $line2, $line3, $line4, $line3)."\n";
    if ($start_index % 7 != 0) {
        $calendar .= '<blue><bold>|</bold></blue>               ';
        map { $calendar .= "                " } (2..($start_index %= 7));
    }
    foreach (1 .. $days) {
        $calendar .= sprintf("<blue><bold>|</bold></blue><cyan><bold>%14d </bold></cyan>", $_);
        if ($_ != $days) {
            $calendar .= "<blue><bold>|</bold></blue>\n" . $line3 . "\n"
                unless (($start_index + $_) % 7);
        }
        elsif ($_ == $days) {
            my $x = 7 - (($start_index + $_) % 7);
            $calendar .= '<blue><bold>|</bold></blue>               ';
            if (($x >= 2) && ($x != 7)) {
                map { $calendar .= ' 'x16 } (1..$x-1);
            }
        }
    }

    $calendar = sprintf("%s<blue><bold>|</bold></blue>\n%s\n", $calendar, $line3);

    return Term::ANSIColor::Markup->colorize($calendar);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Calendar-Persian>

=head1 BUGS

Please report any bugs or feature requests to C<bug-calendar-persian at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Persian>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Persian

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Calendar-Persian>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Calendar-Persian>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Calendar-Persian>

=item * Search CPAN

L<http://search.cpan.org/dist/Calendar-Persian/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011 - 2015 Mohammad S Anwar.

This  program  is  free software; you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a copy of the full
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

1; # End of Calendar::Persian
