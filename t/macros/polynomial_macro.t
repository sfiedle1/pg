use warnings;
use strict;

package main;

use Test::More;
use Test::Exception;

## the following needs to include at the top of any testing  down to TOP_MATERIAL

BEGIN {
	die "PG_ROOT not found in environment.\n" unless $ENV{PG_ROOT};
	$main::pg_dir = $ENV{PG_ROOT};
}

use lib "$main::pg_dir/lib";

require("$main::pg_dir/t/build_PG_envir.pl");

## END OF TOP_MATERIAL

loadMacros("PGpolynomialmacros.pl");

# test ValidPoly functions

# PS: Not sure that ValidPoly is working,  but no OPL problems seem
# to call it.  I think it is making sure that there is no leading 0 in the
# polynomial and was planned to be added to routines.

my @poly1 = (1,3,-2); # x^2+3x-2
my @poly2 = (0,2,3);  # 0x^2+2x+3

is(ValidPoly(\@poly2), 0, "ValidPoly: not a valid polynomial");
# is(ValidPoly(\@poly2), 1, "ValidPoly: is a valid polynomial");

# Test PolyAdd

my @poly3 = (1,0,4,5); # x^3 + 0x^2+4x+5
my @poly4 = (-2,4,5); # -2x^2+4x+5

my @polyadd1_exp = (-1,7,3); # -x^2+7x+3
my @polyadd1 = PolyAdd(\@poly1,\@poly4);
my @polyadd1a = PolyAdd(\@poly4,\@poly1);

my @polyadd2_exp = (1,1,7,3);
my @polyadd2 = PolyAdd(\@poly1,\@poly3);

is_deeply(\@polyadd1_exp, \@polyadd1, "PolyAdd: add two quadratics");
is_deeply(\@polyadd1_exp, \@polyadd1a, "PolyAdd: add two quadratics in reverse order");
is_deeply(\@polyadd2_exp, \@polyadd2, "PolyAdd: add two polys with different degrees");

# Test PolySub

my @polysub1_exp = (3,-1,-7);
my @polysub1 = PolySub(\@poly1,\@poly4);

my @polysub2_exp = (1,-1,1,7);
my @polysub2 = PolySub(\@poly3,\@poly1);

is_deeply(\@polysub1_exp, \@polysub1, "PolySub: subtract two quadratics");
is_deeply(\@polysub2_exp, \@polysub2, "PolySub: subtract two polys with different degrees");




done_testing;
