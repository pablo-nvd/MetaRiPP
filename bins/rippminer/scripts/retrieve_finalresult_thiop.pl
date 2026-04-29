use warnings;
#To show CrossLinks in Symbolic Format (using '|' and '-')
open(FH,"$ARGV[0]") || die "cant write to $ARGV[0]\n";
chomp (my $inp = <FH>);
my @tm = split(/\t/, $inp);
my @cordstr = ("$tm[1],$tm[2],Ser-Ser");
my $inputseq = $tm[0];
print   "<table width=\"%50\">";
print   "<tr>\n";
foreach (my $i=0; $i<length $inputseq; $i++)
{
	my $t = substr($inputseq,$i,1);
	print  "<td>$t</td>";
}
print  "</tr>\n";
my @row=();
foreach (my $i=0; $i<length $inputseq; $i++)
{
	push(@row,"<td>&nbsp;&nbsp;</td>");
}
my $cnt=0;
foreach my $cd(@cordstr)
{
	$cnt++;
	#print  "<tr>\n";
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
				#print  "$cnt\t$i\n";
				for(my $j=$cnt-1; $j>=1; $j--)
				{
					#print  "$j\n";
					#print  "@{'aray'.$j}","\n";
					#print  "here\t${'aray'.$j}[$i]\n";
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
	#print  "@{'aray'.$cnt}\n";
	#print  "</tr>\n";
}
for(my $i=1; $i<=$cnt; $i++)
{
print  "<tr>";
print  "@{'aray'.$i}";
print  "</tr>\n";

}
print   "</table>\n";
#print  "<br>\n";
exit;

###Subroutine###
sub put_bar_below
{
	#my @inp = @_;
	#my $cnt = $inp[0];
	#my $pos = $inp[1];
	#my $cnt = $ref;
	#$cnt =~ s/^\$aray//;
	#print  "@_","\n";
	if($_[0]>1)
	{
		for(my $i=$_[0]; $i>=1; $i--)
		{
			#$nm = 'aray'.$i;
			#print  ${'aray'.$_[0]}[$_[1]],"\n";
			${'aray'.$_[0]}[$_[1]]="<td>|</td>";
		}	
	}
	#<STDIN>;
}
