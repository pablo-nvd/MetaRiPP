#To Create all possible Cyclizations of Lanthipeptides
use warnings;
#open(FH,"corepep_seqs/$ARGV[0]") || die "Invalid Input $ARGV[0]\n";;
open(FH,"$ARGV[0]") || die "Invalid Input $ARGV[0]\n";
open(OT11,">$ARGV[1]/Pseq.txt");
open(OT22,">$ARGV[1]/cycpart_pos");
my $otfile = $ARGV[0]."_cyclized";
#open(OT,">$otfile") || die "cant write to $otfile\n";
my @ary = <FH>;
close(FH);
my $header = shift @ary;
$header =~ s/\n+//g;
$header =~ s/>//;
my $seq = join('',@ary);
$seq =~ s/\s+//g;
$seqh{$header} = $seq;
foreach my $k(sort keys %seqh)
{
	
	print OT11 "$k\t$seq\n";
	my $seq = $seqh{$k};
	my @ST_pos = ();
	my @C_pos = ();
	for(my $i=0; $i<length($seq); $i++)
	{
		my $substr = substr($seq,$i,1);
		if($substr =~ /S|T/)
		{
			push(@ST_pos,$i);
		}elsif($substr =~ /C/)
		{
			push(@C_pos, $i);
		}

	}
	#print scalar @ST_pos,"\t",scalar @C_pos,"\n";
	for(my $i =0; $i<scalar @ST_pos; $i++)
	{
		for(my $j =0; $j<scalar @C_pos; $j++)
		{
			
			if($ST_pos[$i]<$C_pos[$j])
			{
				my $tmp = "$ST_pos[$i]:$C_pos[$j]";
				my $cycpart = substr($seq,$ST_pos[$i],$C_pos[$j]-$ST_pos[$i]+1);
				if(length$cycpart>2)
				{
					$counter++;
					print OT22 "$counter\_$k\t$tmp\n";
					print ">$counter\_$k\n$cycpart\n";
				}
				push(@chechr,$tmp);
			}
			else
			{
				#$counter++;
				my $tmp = "$C_pos[$j]:$ST_pos[$i]";
				my $flag=0;
				foreach my $e(@chechr)
				{
					if($e eq $tmp){$flag=1}
				}
				if($flag==0)
				{
					my $cycpart = substr($seq,$C_pos[$j],$ST_pos[$i]-$C_pos[$j]+1);
					if(length$cycpart>2)
					{
						$counter++;
						my $cyclen1 =length $cycpart;
						print OT22 "$counter\_$k\t$tmp\n";
						#print "*$counter\_$k\t",length$cycpart,"\n";
						print  ">$counter\_$k\n$cycpart\n";
					}
				}
			}
		}
	}
}
close(OT11);
close(OT22);
exit;
