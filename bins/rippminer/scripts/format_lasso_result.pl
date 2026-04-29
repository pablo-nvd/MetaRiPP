use warnings;
#To format output from lassopeptide prediction
open(FH,"$ARGV[0]/lasso_output") || die "cant find 'lasso_output'\n";
open(FH1,"$ARGV[0]/cyclizationInput.fasta") || die "cant find 'cyclizationInput.fasta'\n";
my $seq = '';
while(<FH1>)
{
	chomp;
	if(/^>/){next}
	$seq .= $_;
}
close(FH1);
$seq =~ s/\s//g;
my $count=0;
while(<FH>)
{
	my $str = $seq;
	chomp;
	if(/^>/)
	{next}
	$count++;
	my $ot = 'OT';
	my $file = 'lasso'.$count.'.txt';
	my $smiles = 'lasso'.$count.'.smiles';
	open($ot, ">$ARGV[0]/$file") || die "cant open $file\n";
	my @tm = split(/\s+/);
	shift @tm;
	my $leader = substr($seq,0,$tm[0]);
	my $core = $seq;
	substr($core,0,$tm[0])='';
	my $xlinp = $tm[2];
	my $imgname = 'lasso'.$count.'.jpg';
	system(`perl scripts/pep2smi_maker_lasso.pl $core "$xlinp" >$ARGV[0]/$smiles`);
	my $smifh = 'SMIFH';
	open($smifh,"$ARGV[0]/$smiles") || die "Cant find $ARGV[0]/$smiles\n";
	chomp(my $inpsmi = <$smifh>);
	print $ot "MODEL\t$count\n";
	print $ot "Cleavage Site:\t$tm[0]\n";
	print $ot "Leader Peptide:\t$leader\n";
	print $ot "Core Peptide:\t$core\n";
	my $vsmi = $ARGV[0].'_lasso'.$count.'.smiles';
	print $ot "Predicted Crosslinks:\t$tm[2]\n";
	print $ot "SMILES\t$inpsmi\n";
	print $ot "\n";
	close($ot);
}
close(FH);
