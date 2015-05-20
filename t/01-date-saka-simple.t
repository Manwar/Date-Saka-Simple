#!/usr/bin/perl

use 5.006;
use Test::More tests => 10;
use strict; use warnings;
use Date::Saka::Simple;

is(Date::Saka::Simple->new({year => 1937, month => 1, day => 1}), '01, Chaitra 1937');
is(Date::Saka::Simple->new({year => 1937, month => 1, day => 1})->to_julian, 2457103.5);
is(Date::Saka::Simple->new({year => 1937, month => 1, day => 1})->day_of_week, 0);
is(Date::Saka::Simple->new({year => 1937, month => 1, day => 29})->to_gregorian, '2015-04-19');

is(Date::Saka::Simple->new({year => 1932, month => 12, day => 1})->add_days(10)->as_string, '11, Phalguna 1932');
is(Date::Saka::Simple->new({year => 1932, month => 12, day => 11})->minus_days(5)->as_string, '06, Phalguna 1932');

is(Date::Saka::Simple->new({year => 1932, month => 6, day => 10})->add_months(2)->as_string, '10, Kartika 1932');
is(Date::Saka::Simple->new({year => 1932, month => 6, day => 10})->minus_months(1)->as_string, '10, Sravana 1932');

is(Date::Saka::Simple->new({year => 1932, month => 6, day => 10})->add_years(2)->as_string, '10, Bhadra 1934');
is(Date::Saka::Simple->new({year => 1932, month => 6, day => 10})->minus_years(1)->as_string, '10, Bhadra 1931');
