open(FH,"$ARGV[0]") || die "cant open $ARGV[0]\n";
chomp (my $input=<FH>);
close(FH);
my @tm = split(/\t/, $input);
if($tm[1] == $tm[2])
{
	print "No crosslink was Predicted!\n";
	exit;
}elsif($tm[1] >= $tm[2] and $tm[2]==0)
{
	print "No crosslink was Predicted!\n";
	exit;

}else
{
	print "Input Sequence:\t$tm[0]\n";
	print "Predicted Crosslink:\t$tm[1] -- $tm[2]\n";
	my $seq = $tm[0];
	my @modres = ();
	for(my $i=0; $i<length($seq); $i++)
	{
		my $aa = substr($seq,$i,1);
		if($aa eq 'C')
		{
			my $pos = $i+1;
			push(@modres, "$pos, Thiazole(Cys);");
		}
	}
	my $modres = join(" ",@modres);
	print "Predicted Modified Residues:\t$modres\n";
	print "SMILES:\n";
}
#print "<br>\n";
exit;
