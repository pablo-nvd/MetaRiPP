use warnings;
open(OUT,">>$ARGV[3]/$ARGV[2]") || die "cant write to $ARGV[2]\n";
my $str = $ARGV[0];
my @cordstr = split(/;/,$str);
my $inputseq = $ARGV[1];
print OUT  "<table width=\"%50\">";
print OUT  "<tr>\n";
foreach (my $i=0; $i<length $inputseq; $i++)
{
	my $t = substr($inputseq,$i,1);
	print OUT  "<td>$t</td>";
}
print OUT  "</tr>\n";
my @row=();
foreach (my $i=0; $i<length $inputseq; $i++)
{
	push(@row,"<td>&nbsp;&nbsp;</td>");
}
my $cnt=0;
foreach my $cd(@cordstr)
{
	$cnt++;
	#print OUT  "<tr>\n";
	my @cord = split(/,/,$cd);
	my $fontcolor1 = '';
	my $fontcolor2 = '';
	my $colorflag =0; 
	if($cord[2] =~ /Cys\-Cys/i)
	{
		$colorflag=1;
		$fontcolor1 = "<font color=\"#000000\">";	#for Cys-Cys bond coloring change here.
		$fontcolor2 = "</font>";
	}
	#my  = '$aray'.$cnt;
	@{'aray'.$cnt} = @row;
	foreach(my $i=0; $i<length $inputseq; $i++)
	{
		if($i==$cord[0]-1)
		{
			#${'aray'.$cnt}[$i]= "<td>|</td>";
			if($colorflag==1){${'aray'.$cnt}[$i] = "<td>$fontcolor1|$fontcolor2</td>";}
			else{${'aray'.$cnt}[$i]= "<td>|</td>";}
			if($cnt>1)
			{
				#print OUT  "$cnt\t$i\n";
				for(my $j=$cnt-1; $j>=1; $j--)
				{
					#print OUT  "$j\n";
					#print OUT  "@{'aray'.$j}","\n";
					#print OUT  "here\t${'aray'.$j}[$i]\n";
					#${'aray'.$j}[$i]="<td>|</td>";
					if($colorflag==1)
					{${'aray'.$j}[$i]="<td>$fontcolor1|$fontcolor2</td>";}
					else
					{${'aray'.$j}[$i]="<td>|</td>";}
				}
			}
			#put_bar_below($cnt,$i);
		}elsif($i==$cord[1]-1)
		{
			${'aray'.$cnt}[$i] = "<td>|</td>";
			if($cnt>1)
			{
				for(my $j=$cnt; $j>=1; $j--)
				{
					#${'aray'.$j}[$i]="<td>|</td>";
					if($colorflag==1){${'aray'.$j}[$i]="<td>$fontcolor1|$fontcolor2</td>";}
					else{${'aray'.$j}[$i]="<td>|</td>";}
				}	
			}
			#put_bar_below($cnt,$i);
		}elsif($i> ($cord[0]-1) and $i<($cord[1]-1) and ${'aray'.$cnt}[$i] ne '<td>|</td>')
		{
			#${'aray'.$cnt}[$i]= "<td><b>_</b></td>";
			if($colorflag==1){${'aray'.$cnt}[$i]="<td>$fontcolor1<b>\_</b>$fontcolor2</td>";}
			else{${'aray'.$cnt}[$i]="<td><b>_</b></td>";}
		}
	}
	#print OUT  "@{'aray'.$cnt}\n";
	#print OUT  "</tr>\n";
}
for(my $i=1; $i<=$cnt; $i++)
{
print OUT  "<tr>";
print OUT  "@{'aray'.$i}";
print OUT  "</tr>\n";

}
print OUT   "</table>\n";
#print OUT  "<br>\n";
exit;

###Subroutine###
sub put_bar_below
{
	#my @inp = @_;
	#my $cnt = $inp[0];
	#my $pos = $inp[1];
	#my $cnt = $ref;
	#$cnt =~ s/^\$aray//;
	#print OUT  "@_","\n";
	if($_[0]>1)
	{
		for(my $i=$_[0]; $i>=1; $i--)
		{
			#$nm = 'aray'.$i;
			#print OUT  ${'aray'.$_[0]}[$_[1]],"\n";
			${'aray'.$_[0]}[$_[1]]="<td>|</td>";
		}	
	}
	#<STDIN>;
}
