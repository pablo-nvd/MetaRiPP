use warnings;
open(FH1,'scripts/aminoacid.smiles');
my $seq = $ARGV[0]; #sequence
my $xldata = $ARGV[1];
$xldata =~ s/;$//;
#print "$xldata\n";
my @xldataary = split(/;/,$xldata);
my @crosslinks = ();
foreach my $xl(@xldataary)
{
	my @tm = split(/,/,$xl);
	$tm[0] = $tm[0]-1;
	$tm[1] = $tm[1]-1;
	my $t = "$tm[0]:$tm[1]";
	#print "$t\n";
	push(@crosslinks,$t);
}
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
$hash{'F'} = 'NC@(C(C1=CC=C(C=C1)))@C(=O)';
$hash{'T'} = 'NC@(C(C)O)@C(=O)';
$hash{'V'} = 'NC@(C(C)C)@C(=O)';
$hash{'P'} = "N(CCC1)C1C(=O)";
$hash{'I'} = 'NC@(C(C)CC)@C(=O)';
$hash{'K'} = 'NC@(C(CCCN))@C(=O)';
$hash{'R'} = 'NC@(CCCN=C(N)N)@C(=O)';
$hash{'Y'} = 'NC@(CC1=C(C=C(O)C=C1))@C(=O)';
$hash{'H'} = 'NC@(CC1=C(NC=N1))@C(=O)';
$hash{'W'} = 'N@C(CC1=CNC2=CC=CC=C12)@C(=O)';
$hash{'M'} = 'N@C(CCSC)@C(=O)';
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
@tmp = sort {$a <=> $b } @tmp;
#print "@tmp","\n";
foreach my $b(@crosslinks)
{
	$clc++;
	my @tm = split(/:/,$b);
	#print "$b\n";
	foreach my $t(@tm)
	{
		#print "$t\n";
		my $t1p=0;
		foreach my $t1(@tmp)
		{
			$t1p++;
			if($t==$t1)
			{goto out}
		}
		out:
		my $tt1 = $t + ($t1p-1)*2;
		#print "tt1\t$tt1\n";
		my $subs = substr($seq,0,$tt1);
		my $hdc = () = $subs =~ m/#\d/g;
		$t = $t+$hdc*2;
		substr($seq,$t,1) = substr($seq,$t,1).'#'.$clc;
		#$l = $l+2;
		#print "$subs\t$hdc\n";
		#print "seq\t$t\t$seq\n";
		#<STDIN>;
	}
}
#print "$seq\n";	#If SMILES output is wrong then print and check here first
#<STDIN>;
#exit;
foreach(my $i=0; $i<length($seq); $i++)
{
	my $flag=0;
	my $aa=substr($seq,$i,1);
	#print "aa\t$aa\n";
	if(substr($seq,$i+1,1) eq '#' and substr($seq,$i+2,1) =~ /\d+/ and substr($seq,$i+3,1) eq '#' and substr($seq,$i+4,1) =~ /\d+/)
	{
		my $no = substr($seq,$i+2,1);
		my $no1 = substr($seq,$i+2,1);
		my $no2 = substr($seq,$i+4,1);
		my @tm = split(/\@/, $hash{$aa});
		if($aa eq 'C')
		{
			#print "@tm","\n";
			my $cc_count1 = 0;
			my $cc_count2 = 0;
			my $tmpseq = substr($seq,$i+4+1,length($seq)-($i+4));
			#print $tmpseq,"\n";
			$cc_count1 = () = $tmpseq =~ m/C#$no1/g;
			$cc_count2 = () = $tmpseq =~ m/C#$no2/g;
			if($cc_count1==1)
			{
				$tm[1] =~ s/CS/CS$no1/;
				$tm[0] =~ s/N/N$no2/;
			}elsif($cc_count2==1)
			{
				$tm[1] =~ s/CS/CS$no2/;
				$tm[0] =~ s/N/N$no1/;
			}
		}
		my $out = join("\@", @tm);
		$out =~ s/\@//g;
		print "$out";
		$i=$i+4;
	}
	elsif(substr($seq,$i+1,1) eq '#' and substr($seq,$i+2,1) =~ /\d+/)
	{
		my $no = substr($seq,$i+2,1);
		my @tm = split(/\@/, $hash{$aa});
		if($i==0)
		{
			 #print "@tm","\n";
			$tm[0] =~ s/N/N$no/;
		}else
		{
			$tm[1] =~ s/C\(\=O\)O/C$no\(=O\)/;
			$tm[1] =~ s/CS/CS$no/;
		}
		my $out = join("\@", @tm);
		$out =~ s/\@//g;
		#print "ot\t$aa\t$out\n";
		print "$out";
		$i=$i+2;
	}
	else
	{
		#if(not exists $hash{$aa})
		#{print "aa\t$aa\n"}
		my $val = $hash{$aa};
		$val =~ s/\@//g;
		if($aa eq 'G')
		{
			$val=~ s/\(\)//g;
		}
		if($i==length($seq)-1)
		{
			print "$val";
		}else
		{
			print "$val";
		}
	}
#print "\n";
#<STDIN>;
}
print "O";
print "\n";
