use warnings;
open(FH1,"$ARGV[1]/svmout");
my $model = $ARGV[0];
my $c =0;
while(<FH1>)
{
	chomp;
	$c++;
	
	if($model eq 'MODELSVMF')
	{
		if($_ >=-1.055)
		{
			print "$c:$_\n";
		}
	}
	elsif($model eq 'MODELRFF')
	{
		if($_ >=-0.88)
		{
			print "$c:$_\n";
		}
	}
}
close(FH1);
exit;
