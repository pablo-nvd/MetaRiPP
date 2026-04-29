use warnings;
#To convert weka-Random forrest output format into svmlight output format
open(FH,"$ARGV[0]/rfout") || die "cant find 'rfout' file\n";
while(<FH>)
{
	chomp;
	if($_ eq '' or $_ =~ /\=\=\=/ or $_ =~ /inst#/)
	{next}
	$_ =~ s/^\s+//;
	$_ =~ s/\+//;
	my @tm = split(/\s+/);
	shift @tm;
	pop @tm;
	my @t1 = split(/:/,$tm[1]);
	#print "@tm","\n";
	if($t1[1]==0)
	{
		print "-$tm[2]","\n";
	}else
	{
		print "$tm[2]","\n";
	}
}
close(FH);
exit;
