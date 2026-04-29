use warnings;
#To generate SMILES for Cyanobactin.
open(FH1,'scripts/aminoacid.smiles');
chomp(my $seq = $ARGV[0]);
$seq =~ s/\s+//g;
my @crosslinks = ();
while(<FH1>)
{
	chomp;
	my @tm = split(/\t/);
	my $smi = $tm[1];
	if($smi =~ /(C\#\(C\'\(\=O\)O\)N\')/)
	{
		$smi =~ s/(C\#\(C\'\(\=O\)O\)N\')//g;
		my $backb = $1;
		$smi =~ s/\(\)//g;
		$hash{$tm[0]} = "NC\@($smi)\@C(=O)";
		#print "$tm[0]\tN\tC#\t$smi\tC(=O)\n";
		#print "$tm[0]\t$hash{$tm[0]}\n";
		#print "$tm[0]\t$tm[1]\t$smi\t$backb\n";

	}
}
close(FH1);
$hash{'A'} = 'N@C(C)@C(=O)';
$hash{'C'} = 'N@C(CS)@C(=O)';
$hash{'D'} = 'N@C(CC(=O)O)@C(=O)';
$hash{'E'} = 'N@C(C(CC(=O)O))@C(=O)';
$hash{'G'} = 'N@C@C(=O)';
$hash{'L'} = 'N@C(CC(C)C)@C(=O)';
$hash{'M'} = 'N@C(CCSC)@C(=O)';
$hash{'N'} = 'N@C(CC(=O)N)@C(=O)';
$hash{'S'} = 'N@C(CO)@C(=O)';
$hash{'V'} = 'N@C(CC(C))@C(=O)';
$hash{'W'} = 'N@C(CC1=CNC2=CC=CC=C12)@C(=O)';
$hash{'F'} = 'N@C(C(C1=CC=C(C=C1)))@C(=O)';
$hash{'T'} = 'N@C(C(C)O)@C(=O)';
$hash{'V'} = 'N@C(C(C)C)@C(=O)';
$hash{'P'} = 'N(CCC1)C1@C(=O)';
$hash{'I'} = 'N@C(C(C)CC)@C(=O)';
$hash{'K'} = 'N@C(C(CCCN))@C(=O)';
$hash{'R'} = 'N@C(CCCN=C(N)N)@C(=O)';
$hash{'Y'} = 'N@C(CC1=C(C=C(O)C=C1))@C(=O)';
$hash{'H'} = 'N@C(CC1=C(NC=N1))@C(=O)';
#$hash{'METHOXA'} = 'CC1=CN=CO1@C(=O)';
$hash{'METHOXA'} = 'C(O1)=NC(C1(C))@C(=O)';
$hash{'THIAZ'} = 'C(S1)=NC(C1)@C(=O)';
$hash{'OXAZ'} = 'C(O1)=NC(C1)@C(=O)';
my @seqfinal = ();
foreach(my $i=0; $i<length($seq); $i++)
{
	my $aa=substr($seq,$i,1);
	#print "$aa\n";
	if($i==0)
	{
		my $val = $hash{$aa};
		my @first = split(/\@/ ,$val);
		$first[0] =~ s/N/N3/;
		$val = join("@", @first);
		if($aa eq 'G')
		{
			$val=~ s/\(\)//g;
		}
		push(@seqfinal, $val);
	}
	#elsif($i==length($seq)-1)
	#{
	#	my $val = $hash{$aa};
	#	my @last = split(/\@/ ,$val);
	#	$last[2] =~ s/C\(\=O\)$/C3\(\=O\)/;
	#	$val = join("@", @last);
	#	if($val !~ m/C|T|S/)
	#	{
	#		push(@seqfinal, $val);	
	#	}
	#}
	if($aa !~ m/C|T|S|G/ and $i!=0)
	{
		my $val = $hash{$aa};
		push(@seqfinal, $val);
	}
	elsif($aa eq 'T' and $i!=0)
	{
		my $val = $hash{'METHOXA'};
		$seqfinal[$i-1] =~ s/\@C\(=O\)$//;
		push(@seqfinal, $val);
	}elsif($aa eq 'C' and $i!=0)
	{
		my $val = $hash{'THIAZ'};
		$seqfinal[$i-1] =~ s/\@C\(=O\)$//;
		push(@seqfinal, $val);
	}elsif($aa eq 'S' and $i!=0)
	{
		my $val = $hash{'OXAZ'};
		$seqfinal[$i-1] =~ s/\@C\(=O\)$//;
		push(@seqfinal, $val);
	}
	elsif($aa eq 'G' and $i!=0)
	{
		my $val = $hash{$aa};
		$val=~ s/\(\)//g;
		push(@seqfinal, $val);
	}
	#print "@seqfinal","\n";
#<STDIN>;
}
#print "@seqfinal","\n";
#<STDIN>;
my $smilesfinal = join("",@seqfinal);
$smilesfinal =~ s/\@//g;
$smilesfinal =~ s/C\(\=O\)$/C3\(\=O\)/g;
open(OT11,">$ARGV[1]") || die "cant open $ARGV[1]\n";
print OT11 "$smilesfinal\n";
close(OT11);
exit;
