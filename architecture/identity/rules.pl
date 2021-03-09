#!perl
use strict;
my $VERSION="1.02";

my @RULES = qw ( V F VM FM VD FD VF VFM VFD );
my %DATA = ( 
	'V' => 'voorletters-2014.txt', 
	'F' => 'familieletters-2007.txt' ,
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
		s/\#.*//;
		next unless $_ =~ m/\S/;
		my ($k,$v) = m/([A-Z\s+])\s+(\d+\.\d+)%?\s*$/ 
			or die "Could not parse line $. of $file\n";
		$k =~ s/\s//;
		$data->{$key}->{ $k } = $v;
	};
	close(FH);
};

my $N1 = int(100/$RISK_PRIVACY);
my $N2 = int(100/$RISK_FRAUD);

print <<"EOM";
Version: $VERSION

At least $N1 for a fifty fifty change that you share the data shown:

RISK_PRIVACY= $RISK_PRIVACY # Percent

At least $N2 people in your vicintiy for a fifty fifty chance that you can 
borrow a phone (not quite true - as we in an 'F' there are a lot of people who
have the same 'F' -- so perhaps we should; given more options; go light on 
the 'F' and pick 'V' instead if roughly equal).

RISK_FRAUD  = $RISK_FRAUD; # Percent - 

Note:  this does not yet reflect the 'V' issue of the 'Van somethings'.

EOM

print "Pair	selected	best	sans-F\t\tqualifying\n";

open(FH,'pairs-2014.txt') or die $!;
my $miss;

while(<FH>) { 
	m/([A-Z])\s+([A-Z])\s+(\d+\.\d+)%/ or die "Could not parse line $.\n";
	my $pair = $1.$2;
	my %score;

	$score{V} =   $data->{V}->{ $1 };
	$score{VM} =  $data->{V}->{ $1 } / 12;
	$score{VD}=   $data->{V}->{ $1 } / 31;
	$score{VMD} = $data->{V}->{ $1 } / 31 / 12;

	$score{F} =   $data->{F}->{ $2 };
	$score{FM} =  $data->{F}->{ $2 } / 12;
	$score{FD} =  $data->{F}->{ $2 } / 31;
	$score{FMD} = $data->{F}->{ $2 } / 31 / 12;

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
		$score{$_} >=$RISK_PRIVACY && $score{$_} <=$RISK_FRAUD && $_ || ()
	} @best;

	my @acceptable_sans = map { 
		$score{$_} >=$RISK_PRIVACY && $score{$_} <=$RISK_FRAUD && $_ !~ m/F/ && $_  || ()
	} @best;

	my $best = $acceptable[0];

	my $bs = $acceptable_sans[0];
	my $selected = $bs;
	$selected = $best[0] unless $selected;

	if (!$best) {
		$best = $best[0]."*";
		$miss += $3;
	};


	print "$pair\t$selected\t # $best\t$bs\t";
	print "\t".join(" ",@acceptable)."\n";

	if ($DEBUG) {
		print join("\t",@best)."\n";
		map { printf("\t%.2f%%",$score{$_}); } @best;
		print "\n";
	};
};

print "\nMiss: $miss %\n";

