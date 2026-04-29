#To retrieve core peptide predicted from Core-prediction script script
use warnings;
open(FH,"$ARGV[0]/core_predict.out") || die "cant find 'core_predict.out'\n";
system(`rm -f $ARGV[0]/cyclizationInput.fasta $ARGV[0]/cyclizationInput1.fasta`);
open(OT,">$ARGV[0]/cyclizationInput.fasta");
open(OT2,">$ARGV[0]/cyclizationInput1.fasta");
open(OT1,">$ARGV[0]/core_leader_prdct.out");
#print OT1 "<table>\n";
print OT2 ">test\n";
my @output = ();
#push(@output,"<table>");
my $cleavagem = '';
while(<FH>)
{
	chomp;
	if(/^Score/i){next}
	elsif(/^Seq:\s+/)
	{
		my $seq = $_;
		$seq =~ s/^Seq:\s+//;
		my $pos = 0;
		#print OT1 "<tr>";
		#push(@output,"<tr>");
		#print OT1 "seq\t$seq\n";
		my $seq1 ='';
		#for(my $i=0; $i<length $seq; $i++)
		#{
		#	my $aa = substr($seq,$i,1);
		#	if($aa eq '-'){$pos=$i}
		#	elsif($i>=$pos and $pos!=0)
		#	{
		#		$seq1 .= "<font color=\"red\">$aa</font>";
				#print OT1 "<td width=\"1%\">$aa</td>";
		#	}
		#	else
		#	{
		#		$seq1 .=$aa;
		#	}
		#}
		$seq =~ s/-/<font color=\"red\" size=\"5\"><b>-<\/b><\/font>/;
		#print OT1 "<td>Sequence: </td><td>$seq</td>\n";
		push(@output,"<tr><td>Sequence: </td><td style=\"word-wrap:break-word;\">$seq</td></tr>");
		#print OT1 "</tr>";
		#push(@output,"</tr>");
		#print OT1 "<tr>";
		#$seq =~ s/-/<font color=\"red\" size=\"5\"><b>-<\/b><\/font>/;
		#for(my $i=0; $i<length $seq; $i++)
		#{
		#	if($i==$pos)
		#	{print OT1 "<td width=\"1%\"><font color=\"red\" size=\"4\"><b>&#8593;<\/b><\/font></td>";}
		#	else
		#	{print OT1 "<td width=\"1%\">&nbsp;</td>";}
		#}
		#print OT1 "</tr>";
		#print OT1 "</table>\n";
		#print OT1 "<table>\n";
	}
	elsif(/^Cleavage site/)
        {
                $cleavagem =$_;
                next;
        }
	else
	{
		my $l = $_;
		$l =~ s/:\s+/:<\/td><td>/;
		$l = "<tr><td>$l</td></tr>";
		#print OT1 "$l\n";
		push(@output,$l);
	}
	if(/^Core peptide:/)
        {
        	my $l1 = $_;
        	$l1 =~  s/^Core peptide:\s+//;
       		print OT "$l1\n";
        	print OT2 "$l1\n";
        	close(OT);
	}
}
$cleavagem  =~ s/:\s+/:<\/td><td>/;
$cleavagem =~ s/12-mer/12mer/;
$cleavagem  =~ s/\-/<font color=\"red\" size=\"5\"><b>-<\/b><\/font>/g;
$l = "<tr><td>$cleavagem</td></tr>";
#print OT1 "$l\n";
push(@output,"$l");
#close(OT1);
close(OT2);
close(OT);
print OT1 "\n<table width=\"70%\">\n";
print OT1 "$output[0]\n";
shift @output;
foreach my $o(@output)
{
	if($o =~ /Cleavage site/)
	{
		print OT1 "$o\n";
	}
}
foreach my $o(@output)
{
	unless($o =~ /Cleavage site/)
	{
		print OT1 "$o\n";
	}
}
#print OT1 "</table>\n";
close(OT1);
