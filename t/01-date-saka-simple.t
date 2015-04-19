#!/usr/bin/perl

use 5.006;
use Test::More tests => 4;
use strict; use warnings;
use Date::Saka::Simple;

is(Date::Saka::Simple->new({year => 1937, month => 1, day => 1}), '1, Chaitra 1937');
is(Date::Saka::Simple->new({year => 1937, month => 1, day => 1})->to_julian, 2457103.5);
is(Date::Saka::Simple->new({year => 1937, month => 1, day => 1})->day_of_week, 0);
is(Date::Saka::Simple->new({year => 1937, month => 1, day => 29})->to_gregorian, '2015-04-19');
