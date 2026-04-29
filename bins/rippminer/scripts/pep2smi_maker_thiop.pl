#use warnings;
open(FH1,'scripts/aminoacid.smiles');
open(FH2,"$ARGV[0]");
chomp (my $input = <FH2>);
my @inp = split(/\t/,$input);
if($inp[1] == $inp[2])
{
	exit;
}elsif($inp[1] >= $inp[2] and $inp[2]==0)
{
	exit;
}
my $seq = $inp[0]; #sequence
my $xldata = "$inp[1];$inp[2]";
#print "$xldata\n";
my @xldataary = split(/;/,$xldata);
my @crosslinks = ();
$xldataary[0] = $xldataary[0]-1;
$xldataary[1] = $xldataary[1]-1;
my $t = "$xldataary[0]:$xldataary[1]";
#print "$t\n";
push(@crosslinks,$t);
$seq =~ s/\s+//g;
$seq =~ s/\n+//g;
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
		if($smi ne '')
		{
			$hash{$tm[0]} = "NC\@($smi)\@C(=O)";
		}else
		{
			$hash{$tm[0]} = "NC\@\@C(=O)";
		}
		#print "$tm[0]\tN\tC#\t$smi\tC(=O)\n";
		#print "$tm[0]\t$hash{$tm[0]}\n";
		#print "$tm[0]\t$tm[1]\t$smi\t$backb\n";

	}
}
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
$hash{'ARPYR'} = 'c(c3c1)nc(c1)';		#Aromatic Pyridine Ring
$hash{'SAPYR'} = 'C(C3#C1)NC(C1)';		#Saturated Pyridine Ring
$hash{'THIAZ'} = 'c(s1)nc(c1)@C(=O)';
$hash{'THIAZX'} = 'c3(s1)nc(c1)@C(=O)';		#Thiazoline adjacent to CrossLinks.
#$hash{'THIAZ'} = 'C(C1)N=C(S1)@C(=O)';
close(FH1);
my $clc =2;
my $l = 0;
#print "#$seq#\n";
my @tmp =();
foreach my $b(@crosslinks)
{
	my @tm = split(/:/,$b);
	foreach my $t(@tm)
	{
		push(@tmp,$t);
	}
}
@tm = sort {$a <=> $b } @tmp;
#print "@tm","\n";
my $flag=0;
if($tm[0]==0)
{
	$flag=0;
	my $out = smiles_maker($seq,$tm[0],$tm[1],$flag);
	print "$out\n";
}else
{
	$flag=1;
	#print "$tm[0]\n";
	my $part1 = substr($seq,0,$tm[0]);
	my $part2 = substr($seq,$tm[0],length($seq)-$tm[0]);
	#print "$part1\t$part2\n";
	#$part1 = reverse $part1;
	my $out1 = smiles_maker($part1,$tm[0],$tm[1],-1);
	$tm[0] = $tm[0] -length($part1);
	$tm[1] = $tm[1] -length($part1);
	my $out2 = smiles_maker($part2,$tm[0],$tm[1],$flag);
	#print "$out1\n";
	#$out1 =~ s/^O/N/;
	#$out1 =~ s/C\(=O\)N/NC\(=O\)/g;
	#$out1 =~ s/^N/C\(=O\)/;
	#$out1 =~ s/C\(=O\)O$/N/;
	#print "$out1\n";
	$out1 = "N".$out1;
	$out2 =~ s/#/\($out1\)/;
	print "$out2\n";
	#print "$part1\t$part2\n";
}
#my $out = smiles_maker($seq,$tm[0],$tm[1],$flag);
#print "$out\n";
exit;




sub smiles_maker
{
	my @inp1 = @_;
	my $seq = $inp1[0];
	my @tm = ();
	$tm[0] = $inp1[1];
	$tm[1] = $inp1[2];
	my $flag=$inp1[3];
	my @seqfinal = ();
	my $out ='';
	for(my $i=0; $i<length($seq); $i++)
	{
		my $aa = substr($seq,$i,1);
		if($i==$tm[0] and $tm[0]==0 and $flag!=-1)
		{
			next;
		}
		elsif($i==$tm[1] and $flag==0)
		{
			push(@seqfinal,$hash{'ARPYR'});
			$seqfinal[$i-2] =~ s/\@C\(=O\)$//;
		}elsif($i==$tm[1] and $flag!=0)
		{
			push(@seqfinal,$hash{'SAPYR'});
			$seqfinal[$i-2] =~ s/\@C\(=O\)$//;
		}elsif(substr($seq,$i,1) eq 'C' and $i==$tm[0]+1)
		{
			push(@seqfinal,$hash{'THIAZX'});
		}elsif(substr($seq,$i,1) eq 'C' and $i!=$tm[0]+1 and $flag!=-1)
		{
			push(@seqfinal,$hash{'THIAZ'});
			$seqfinal[$i-2] =~ s/\@C\(=O\)$//;		
		}elsif(substr($seq,$i,1) eq 'C' and $i!=$tm[0]+1 and $flag==-1)
		{
			push(@seqfinal,$hash{'THIAZ'});
		}
		elsif($aa eq 'G')
		{
			my $val = $hash{$aa};
			$val=~ s/\(\)//g;
			push(@seqfinal, $val);
		}else
		{
			#print "$aa\t$hash{$aa}\n";
			push(@seqfinal,$hash{$aa});
		}
	}
	#print "$seq\t","@seqfinal","\n";
	if($flag==-1)
	{
		for(my $i=0; $i<length($seq); $i++)
		{
			my @tm1 = split(/\@/,$seqfinal[$i]);
			#print "@tm1","\n";
			$seqfinal[$i] = "$tm1[2]\@$tm1[1]\@$tm1[0]";
			if(substr($seq,$i,1) eq 'C')
			{
				$seqfinal[$i-1]=~ s/^C\(=O\)//;
			}
		}
		@seqfinal = reverse @seqfinal;
		#print "$seq\t","@seqfinal","\n";
	}
	my $smilesfinal = join("",@seqfinal);
	$smilesfinal =~ s/\@//g;
	#print "$smilesfinal";
	if($flag!=-1)
	{
		$out = $smilesfinal."O";
	}else
	{
		$out = $smilesfinal;
	}
	return $out;
}
