use warnings;
#For crosslinks predictions in Thiopeptides.
open(FH,"$ARGV[0]") || die "no input provided!!\n";	#provide into file with protein sequence into raw format.
chomp(my $input =<FH>);
close(FH);
$input = uc $input;
#Crosslinking between SC to CSC
my $startpos = -1;
my $endpos = -1;
my $endpos1 = -1;
my $sc_count = 0;
my $csc_count = 0;
my $sss_count = 0;
my @endpos = ();
for(my $i=0; $i<length($input)-2; $i++)
{
	my $aa1 = substr($input,$i,1);
	my $aa2 = substr($input,$i+1,1);
	my $aa3 = substr($input,$i+2,1);
	my $aa4 = substr($input,$i+3,1);
#Condition 1: Xlink b/w SC & CSC
	if($aa1 eq 'S' and $aa2 eq 'C')
	{
		$sc_count++;
		if($sc_count==1)
		{$startpos = $i;}		
	}elsif($aa1 eq 'C' and $aa2 eq 'S' and $aa3 eq 'C')
	{
		$csc_count++;
		push(@endpos, $i+1);
	}
#Condition 2: Xlink b/w SC & CSSS/SSSS
	if($aa1 eq 'C' and $aa2 eq 'S' and $aa3 eq 'S' and $aa4 eq 'S')
	{
		if($i>$startpos and $startpos!=-1)
		{$sss_count++;}
		if($sss_count==1)
		{$endpos1=$i+4;}
	}elsif($aa1 eq 'S' and $aa2 eq 'S' and $aa3 eq 'S' and $aa4 eq 'S')
	{
		if($i>$startpos and $startpos!=-1)
		{$sss_count++;}
		if($sss_count==1)
		{$endpos1=$i+4;}
	}
}
out:
#In case where both CSC and (C/S)SSS are found; CSC is given priority.
if($csc_count>0)
{
	if($csc_count>=2)
	{
		$endpos = $endpos[1];
	}elsif($csc_count==1)
	{
		$endpos = $endpos[0];
	}
}elsif($endpos1>0)
{
	$endpos=$endpos1;
}
$startpos= $startpos+1;
$endpos = $endpos+1;
print "$input\t$startpos\t$endpos\n";
exit;
###

