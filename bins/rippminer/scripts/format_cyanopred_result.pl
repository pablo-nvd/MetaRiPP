use warnings;
#test    57-62   HCATIC  1,6,peptide_bond(His-Cys)       2,thiazol(in)e(Cys);4,methyloxazol(in)e(Thr)6,thiazol(in)e(Cys);
#test    43-48   HCATIC  1,6,peptide_bond(His-Cys)       2,thiazol(in)e(Cys);4,methyloxazol(in)e(Thr)6,thiazol(in)e(Cys);
open(FH,"$ARGV[0]/cyanopred.out") || die "Cant open $ARGV[0]/cyanopred.out\n";
open(FH1,"$ARGV[0]/cyclizationInput.fasta") || die "Cant open $ARGV[0]/cyclizationInput.fasta\n";
chomp(my $seq = <FH1>);
close(FH1);
my $count =0;
while(<FH>)
{
	chomp;
	$_ =~ s/;$//;
	@tm = split(/\t+/);
	shift @tm;
	$count++;
	my @cord = split(/-/,$tm[0]);
	#print "CORE POSITION\t$tm[0]<br>\n";
	if(not exists $tm[3])
	{
		$tm[3] = 'NA';
	}
	my @modp = split(/;/,$tm[3]);
	my $ot = 'OT1';
	my $file = 'cyanob'.$count.'.txt';
	my $smiles = 'cyanob'.$count.'.smiles';
	open($ot,">$ARGV[0]/$file") || die "can not open $file\n";
	#print "<tr>$seq1</tr><br>\n";
	#print "<tr>CORE\t$tm[1]</tr>\n";
	my @modres = split(/;/,$tm[3]);
	my @core = ();
	my $core = '';
	for(my $i=0; $i<length($tm[1]); $i++)
	{
		my $aa1 = substr($tm[1],$i,1);
		push(@core,$aa1);
	}
	$core = join("",@core);
	$modres1 = join("\t",@modres);
	print $ot "CORE $count\n";
	my $userdir = $ARGV[0];
	print $ot "Sequence:\t$seq\n";
	print $ot "Core Peptide\t$core\n";
	print $ot "Core Position:\t$tm[0]\n";
	print $ot "Modified Residues\t$modres1\n";
	print $ot "Predicted Crosslinks:\t$tm[2]\n";
	system("perl scripts/pep2smi_maker_cyano.pl $tm[1] $ARGV[0]/$smiles");
	open(SMILES,"$ARGV[0]/$smiles") || die "Can't Open '$ARGV[0]/$smiles'\n";
	print $ot "SMILES:\n";
	while(<SMILES>)
	{
		print $ot "$_";
	}
	close(SMILES);
	close($ot);
}
exit;
