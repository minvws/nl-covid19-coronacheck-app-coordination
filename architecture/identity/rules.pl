#!perl
use strict;

my @RULES = qw ( V F VM FM VD FD VF VFM VFD );
my %DATA = ( 
	'V' => 'voorletters-2014.txt', 
	'F' => 'familieletters-2014.txt' ,
	'VF' => 'pairs-2014.txt' 
);

my $RISK_PRIVACY= 0.1; # Percent - so at least 1000 for a fifty fifty change
my $RISK_FRAUD  = 0.3; # Percent - so 333 people in your vicintiy for a fifty fifty borrow chance
my $data;
my $DEBUG;

while(my ($key, $file) = each %DATA) 
{
	open(FH,$file) or die "Could not open $file: $!\n";
	while(<FH>) { 
		my ($k,$v) = m/([A-Z\s+])\s+(\d+\.\d+)%/ or die "Could not parse line $. of $file\n";
		$k =~ s/\s//;
		$data->{$key}->{ $k } = $v;
	};
};

print "Pair	best	";
print "\tqualifying\n";

open(FH,'pairs-2014.txt') or die $!;

while(<FH>) { 
	m/([A-Z])\s+([A-Z])\s+(\d+\.\d+)%/ or die "Could not parse line $.\n";
	my $pair = $1.$2;
	my %score;

	$score{V} =   $data->{V}->{ $1 };
	$score{VM} =  $data->{V}->{ $1 } / 12;
	$score{VD}=   $data->{V}->{ $1 } / 31;
	$score{VDM} = $data->{V}->{ $1 } / 31 / 12;

	$score{F} =   $data->{F}->{ $2 };
	$score{FM} =  $data->{F}->{ $2 } / 12;
	$score{FD} =  $data->{F}->{ $2 } / 31;
	$score{VDM} = $data->{F}->{ $2 } / 31 / 12;

	$score{VF} =  $3;
	$score{VFD} = $3 / 31;
	$score{VFM} = $3 / 12;
	$score{VFMD} =$3 / 31 / 12;

	my @best = sort { 
		abs($score{$a} - ($RISK_PRIVACY + $RISK_FRAUD) / 2)
	 <=>
		abs($score{$b} - ($RISK_PRIVACY + $RISK_FRAUD) / 2) 
	} keys %score;

	my @acceptable = map { 
		$score{$_} >=$RISK_PRIVACY && $score{$_} <=$RISK_FRAUD && $_ 
	} @best;

	my $best = $acceptable[0];
	$best = $best[0]."*" unless $best;

	print "$pair\t$best\t";
	print "\t".join(" ",@acceptable)."\n";

	if ($DEBUG) {
		print join("\t",@best)."\n";
		map { printf("\t%.2f%%",$score{$_}); } @best;
		print "\n";
	};
};
