use warnings;
open(FH1,"$ARGV[0]/positivepredictin") || die "Cant find Input File positivepredictin\n";
open(FH3,"$ARGV[0]/cyclized.out") || die "Cant find Input File cyclized.out\n";
open(FH4, "$ARGV[0]/cycpart_pos") || die "Cant find Input File cycpart_pos\n";
open(FH5, "$ARGV[0]/Pseq.txt") || die "Cant find Input File cycpart_pos\n";
while(<FH1>)
{
	chomp;
	my @tm = split(/:/);
	$posh{$tm[0]} = $tm[1];
}
if((scalar keys %posh)==0)
{
	print "<br><br><b>No Cyclization Predictied!!!</b>\n";
	exit;
}
close(FH1);

my $inputseq = '';
while(<FH5>)
{
	chomp;
	my @tm = split(/\s+/);
	$inputseq = $tm[1];
	$inputseq =~ s/\s+//g;
}
close(FH5);

while(<FH4>)
{
        chomp;
        my @tm = split(/\s+/);
	my @cord1 = split(":",$tm[1]);
	#print "@cord1","\n";
	foreach my $c(@cord1){$c = $c+1}
	my $cord2 = join(":",@cord1);
        #print "$cord2\n";
	$cycposh{$tm[0]} = $cord2;
}
close(FH4);
my @pos = reverse sort { $posh{$a} <=> $posh{$b} }keys %posh;

foreach my $p(@pos)
{
	my $fh = 'FH2';
	my $c1 = 0;
	open($fh,"$ARGV[0]/aa_12") || die "Cant find Input File aa_12\n";
	while(<$fh>)
	{
		chomp;
		$c1++;
		if($p == $c1)
		{
			#print "$c1\n";
			#<STDIN>;
			my @tm = split(/\t/);
			$tm[-1] =~ s/^#//g;
			#$scoreh{$tm[-1]} = $posh{$p};
			push(@cycnames,$tm[-1]);
		}
	}
	close($fh);

}
my $dat = '';
while(<FH3>)
{$dat .= $_}
close(FH3);
my @data = split(/>/,$dat);
#print 'cycname ', "@cycnames","\n";
foreach my $cn(@cycnames)
{
	#print "#$cn#\n";
	for(my $i=0; $i<scalar @data; $i++)
	{
		if($data[$i] =~ /^$cn/)
		{
			my @inf = split(/\n/,$data[$i]);
			shift @inf;
			my $prediction = join('',@inf);
			print "<br>\n";
			#print "<b>Prediction&nbspScore:&nbsp&nbsp&nbsp&nbsp<font color=\"blue\">$scoreh{$cn}</font><br>";
			#my $imginput = "$inputseq:$cycposh{$cn}";
			#print "<br>$inputseq<br>";
			print "<table width=\"%50\">";
			print "<tr>";
			my @cord = split(":", $cycposh{$cn});
			foreach (my $i=0; $i<length $inputseq; $i++)
			{
				my $t = substr($inputseq,$i,1);
				if($i>=($cord[0]-1) and $i<=($cord[1]-1))
				{print "<td><font color=\"red\">$t</font></td>";}
				else{print "<td>$t</td>";}
			}
			print "</tr>\n";
			#print  "</table>";
			#system("rm -f sequence.png");
			#system("rm -f crosslinks.png");
			#system("/data2/priyesh/software/phpmy/bin/php /home/priyesh/public_html/lantipepDB/sequence2image1.php  $inputseq");
			#system("/data2/priyesh/software/phpmy/bin/php /home/priyesh/public_html/lantipepDB/put_cross_links.php $imginput");
			#<STDIN>;
			#print "<table>";
			print "<tr>";
			foreach(my $i=0; $i<length $inputseq; $i++)
			{
				if($i==$cord[0]-1)
				{
					print "<td>|</td>";
				}elsif($i==$cord[1]-1)
				{
					print "<td>|</td>";
				}elsif($i> ($cord[0]-1) and $i<($cord[1]-1))
				{
					print "<td><b>_</b></td>";
				}elsif(($cord[0]-1)>$i)
				{print '<td>&nbsp&nbsp</td>'}
				elsif(($cord[1]-1)<$i)
				{print '<td>&nbsp&nbsp</td>'}				
			}
			print "</tr>\n";
			print  "</table>";
			#print "<br>\n";
		}
	}
}
exit;
