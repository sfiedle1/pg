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

is(ValidPoly(\@poly1), 1, "ValidPoly: not a valid polynomial");
is(ValidPoly(\@poly2), 0, "ValidPoly: is a valid polynomial");

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


# Test PolyMult

my @prod1_exp = (-2,-2,21,7,-10);
my @prod1 = PolyMult(\@poly1,\@poly4);
is_deeply(\@prod1_exp,\@prod1, "PolyMult: multiply two quadratics");

use Data::Dumper;

my @prod2_exp = (-2,4,-3,6,40,25);
my @prod2 = PolyMult(\@poly4,\@poly3);
is_deeply(\@prod2_exp,\@prod2, "PolyMult: multiply a quadratic and a cubic");

# Test SynDiv

# Use the product of known terms.

my @poly5a = (1,5);
my @poly5b = (1,-2,-3);
my @prod5 = PolyMult(\@poly5a,\@poly5b);

my @quot5 = SynDiv(\@prod5,\@poly5a);

# the result of SynDiv is the remainder.
my $rem5 = pop(@quot5);

is_deeply(\@poly5b,\@quot5, "SynDiv: use synthetic division to find the quotient.");
is(0,$rem5, "SynDiv: use synthetic division to find the remainder");

my @poly6a = (1,-3);
my @poly6b = (2,0,4,-6);
my @rem = (2);
my @prod6 = PolyMult(\@poly6a,\@poly6b);
my @prodsum = PolyAdd(\@prod6,\@rem);

my @quot6 = SynDiv(\@prodsum,\@poly6a);
# the result of SynDiv is the remainder.
my $rem6 = pop(@quot6);

is_deeply(\@poly6b,\@quot6, "SynDiv: use synthetic division to find the quotient.");
is($rem[0],$rem6, "SynDiv: use synthetic division to find the remainder");

# Test LongDiv

# First create a polynomial that is the product of two smaller polynomials.

my $poly7a = [2,3,-1];
my $poly7b = [-2,4,2,7];
my @prod7 = PolyMult($poly7a,$poly7b);


my ($quot7,$rem7) = LongDiv(\@prod7,$poly7a);

is_deeply($poly7b, $quot7, "LongDiv: use Long Division to find the quotient.");
is_deeply($rem7,[0,0],"LongDiv: use Long Division to find the remainder.");

# Create a polynomial division with a remainder

my $poly8a = [2,3,-1];
my $poly8b = [-2,4,2,7];
my $poly8c = [4,3];
my @poly8prod = PolyMult($poly8a,$poly8b);
my @poly8 = PolyAdd(\@poly8prod,$poly8c);

my ($quot8,$rem8) = LongDiv(\@poly8,$poly8a);

is_deeply($poly8b, $quot8, "LongDiv: use Long Division to find the quotient.");
is_deeply($rem8,$poly8c,"LongDiv: use Long Division to find the remainder.");

# The following is needed for the rest of the tests via the sgn subroutine.
loadMacros("PGcommonFunctions.pl");

my @poly9 = (1,2,-5,1);
is(2,UpBound(\@poly9),"UpBound: find the upper bound of a polynomial");
is(-4,LowBound(\@poly9),"UpBound: find the lower bound of a polynomial");

my @poly10 = (4,0,13,-130);
is(3,UpBound(\@poly10),"UpBound: find the upper bound of a polynomial with non-unit leading coefficient");
is(-1,LowBound(\@poly10),"UpBound: find the lower bound of a polynomial with non-unit leading coefficient");

is("x^{3}+2 x^{2}-5 x+1 ",PolyString(\@poly9),"PolyString: testing the stringify function");
is("4 x^{3}+13 x-130 ",PolyString(\@poly10),"PolyString: testing the stringify function");

my ($pos,$neg) = Descartes(\@poly9);

is(2,$pos,"Descartes: the number of positive roots");
is(1,$neg,"Descartes: the number of negative roots");

done_testing;
