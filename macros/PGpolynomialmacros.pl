=head1 PGpolynomialmacros.pl DESCRIPTION

Originally written in 2002 by Mark Schmitt for his Honors Algebra class.

=cut

=head3 ValidPoly(~~@PolynomialCoeffs)

=over

=item Input: An array representing a polynomial

=item A boolean (0 or 1) if the polynomial is valid (the leading coefficient is not 0)

=back

=cut

sub ValidPoly {
	my ($xref) = @_;
	my @arr = @{$xref};
	if   ($arr[0] != 0) { return 1; }
	else                    { return 0; }
}

=head3 PolyAdd(~~@Polyn1,~~@Polyn2)

=over

=item Input: references to two arrays

=item Output: an array representing the sum of the two arrays.

=back

=cut

sub PolyAdd {
	my ($xref, $yref) = @_;
	my @local_x = @{$xref};
	my @local_y = @{$yref};
	if ($#local_x < $#local_y) {
		while ($#local_x < $#local_y) { unshift @local_x, 0; }
	} elsif ($#local_y < $#local_x) {
		while ($#local_y < $#local_x) { unshift @local_y, 0; }
	}
	my @sum;
	foreach my $i (0 .. $#local_x) {
		$sum[$i] = $local_x[$i] + $local_y[$i];
	}
	return @sum;
}

=head3 C<PolySub(~~@Polyn1,~~@Polyn2)>

=over

=item Input: references to two arrays

=item Output: an array representing the difference of the two arrays.

=back

=cut

sub PolySub {
	my ($xref, $yref) = @_;
	my @local_x = @{$xref};
	my @local_y = @{$yref};
	if ($#local_x < $#local_y) {
		while ($#local_x < $#local_y) { unshift @local_x, 0; }
	} elsif ($#local_y < $#local_x) {
		while ($#local_y < $#local_x) { unshift @local_y, 0; }
	}
	my @diff;
	foreach my $i (0 .. $#local_x) {
		$diff[$i] = $local_x[$i] - $local_y[$i];
	}
	return @diff;
}

=head3 C<PolyMult(~~@coefficientArray1,~~@coefficientArray2)>

=over

=item Input: references to two arrays

=item Output: an array representing the product of the two arrays.

=back

=cut

sub PolyMult {
	my ($xref, $yref) = @_;
	my @local_x = @{$xref};
	my @local_y = @{$yref};
	my @result;
	foreach my $i (0 .. $#local_x + $#local_y) { $result[$i] = 0; }
	foreach my $i (0 .. $#local_x) {
		foreach my $j (0 .. $#local_y) {
			$result[ $i + $j ] = $result[ $i + $j ] + $local_x[$i] * $local_y[$j];
		}
	}
	return @result;
}

=head3 @quotient = SynDiv(~~@dividend,~~@divisor)

=over

=item Input: reference to two arrays, the first is the dividend, the second the divisor.

=item Output: An array which is the quotient. Note: the remainder is not returned.

=back

=cut

sub SynDiv {
	my ($dividendref, $divisorref) = @_;
	my @dividend = @{$dividendref};
	my @divisor  = @{$divisorref};
	my @quotient;
	$quotient[0] = $dividend[0];
	foreach my $i (1 .. $#dividend) {
		$quotient[$i] = $dividend[$i] - $quotient[ $i - 1 ] * $divisor[1];
	}
	return @quotient;
}

=head3 (@quotient,@remainder) = LongDiv($dividendref,$divisorref)

=over

=item Input: reference to two arrays, the first is the dividend, the second the divisor.

=item Output: arrayrefs of the quotient and remainder respectively.

=back

=cut

sub LongDiv {
	my ($dividendref, $divisorref) = @_;
	my @dividend = @{$dividendref};
	my @divisor  = @{$divisorref};
	my @quotient;
	my @remainder;
	foreach my $i (0 .. $#dividend - $#divisor) {
		$quotient[$i] = $dividend[$i] / $divisor[0];
		foreach my $j (1 .. $#divisor) {
			$dividend[ $i + $j ] = $dividend[ $i + $j ] - $quotient[$i] * $divisor[$j];
		}
	}
	foreach my $i ($#dividend - $#divisor + 1 .. $#dividend) {
		$remainder[ $i - ($#dividend - $#divisor + 1) ] = $dividend[$i];
	}
	return (\@quotient, \@remainder);
}

=head3 UpBound(~~@polynomial)

=over

=item Input: a reference to an array containing the coefficients, in descending order, of a polynomial.

=item Output: the lowest positive integral upper bound to the roots of the polynomial.

=back

=cut

sub UpBound {
	my $polyref = $_[0];
	my @poly    = @{$polyref};
	my $bound   = 0;
	my $test    = 0;
	my @result;
	while ($test < @poly) {
		$bound++;
		$test   = 0;
		my @div    = (1, -$bound);
		my @result = &SynDiv(\@poly, \@div);
		foreach my $i (0 .. $#result) {
			if (sgn($result[$i]) == sgn($result[0]) || $result[$i] == 0) {
				$test++;
			}
		}
	}
	return $bound;
}

=head3 LowBound(~~@polynomial)

=over

=item Input: a reference to an array containing the coefficients, in descending order, of a polynomial.

=item Output: the greatest negative integral upper bound to the roots of the polynomial.

=back

=cut

sub LowBound {
	my $polyref = $_[0];
	my @poly    = @{$polyref};
	my $bound   = 0;
	my $test    = 0;
	while ($test == 0) {
		$test  = 1;
		$bound = $bound - 1;
		my @div   = (1, -$bound);
		my @res   = &SynDiv(\@poly, \@div);
		foreach my $i (1 .. int(($#res - 1) / 2)) {
			if (sgn($res[0]) * sgn($res[ 2 * $i ]) == -1) {
				$test = 0;
			}
		}
		foreach my $i (1 .. int($#res / 2)) {
			if (sgn($res[0]) * sgn($res[ 2 * $i - 1 ]) == 1) {
				$test = 0;
			}
		}
	}
	return $bound;
}

=head3 PolyString(~~@coefficientArray,x)

This returns a string representation of an array input as an arrayref.

Example: C<PolyString([1,0,-3,2])> returns C<x^{3}-3x+2>

=cut

sub PolyString {
	my $temp   = $_[0];
	my @poly   = @{$temp};
	my $string = '';
	foreach my $i (0 .. $#poly) {
		my $j = $#poly - $i;
		if ($j == $#poly) {
			if ($poly[$i] > 0) {
				if ($poly[$i] != 1) {
					$string = $string . "$poly[$i] x^{$j}";
				} else {
					$string = $string . "x^{$j}";
				}
			} elsif ($poly[$i] == 0) {
			} elsif ($poly[$i] == -1) {
				$string = $string . "-x^{$j}";
			} else {
				$string = $string . "$poly[$i] x^{$j}";
			}
		} elsif ($j > 0 && $j != 1) {
			if ($poly[$i] > 0) {
				if ($poly[$i] != 1) {
					$string = $string . "+$poly[$i] x^{$j}";
				} else {
					$string = $string . "+x^{$j}";
				}
			} elsif ($poly[$i] == 0) {
			} elsif ($poly[$i] == -1) {
				$string = $string . "-x^{$j}";
			} else {
				$string = $string . "$poly[$i] x^{$j}";
			}
		} elsif ($j == 1) {
			if ($poly[$i] > 0) {
				if ($poly[$i] != 1) {
					$string = $string . "+$poly[$i] x";
				} else {
					$string = $string . "+x";
				}
			} elsif ($poly[$i] == 0) {
			} elsif ($poly[$i] == -1) {
				$string = $string . "-x";
			} else {
				$string = $string . "$poly[$i] x";
			}
		} else {
			if ($poly[$i] > 0) {
				$string = $string . "+$poly[$i] ";
			} elsif ($poly[$i] == 0) {
			} else {
				$string = $string . "$poly[$i] ";
			}
		}
	}
	return $string;
}

sub PolyFunc {
	my $temp = $_[0];
	my @poly = @{$temp};
	my $func = "";
	foreach my $i (0 .. $#poly) {
		my $j = $#poly - $i;
		if   ($poly[$i] > 0) { $func = $func . "+$poly[$i]*x**($j)"; }
		else                 { $func = $func . "$poly[$i]*x**($j)"; }
	}
	return $func;
}

=head3 ($maxpos,$maxneg) = Descartes(~~@poly)

Descartes Rules of signs.

=over

=item Input: a reference to an array containing the coefficients, in descending order, of a polynomial.

=item Output: the maximum number of postive and negative roots.

=back

=cut

sub Descartes {
	my $temp = $_[0];
	my @poly = @{$temp};
	my $pos  = 0;
	my $neg  = 0;
	foreach my $i (1 .. $#poly) {
		if    (sgn($poly[$i]) * sgn($poly[ $i - 1 ]) == -1) { $pos++; }
		elsif (sgn($poly[$i]) * sgn($poly[ $i - 1 ]) == 1)  { $neg++; }
	}
	return ($pos, $neg);
}

1;
