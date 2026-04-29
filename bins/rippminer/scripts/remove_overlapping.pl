#use warnings;
#To remove Overlappings
open(FH1,"$ARGV[0]/positivepredictin");
open(FH2,"$ARGV[0]/aa_12");
open(FH3,"$ARGV[0]/Pseq.txt") || die "cant open Pseq.txt";
while(<FH1>)
{
	chomp;
	my @tm = split(":");
	$hash1{$tm[0]} = $tm[1];
}
close(FH1);
my @aa_12 = <FH2>;
close(FH2);
while(<FH3>)
{
	chomp;
	#print "$_\n";
	my @tm = split(/\t/,$_);
	my @k1 = split(/\s+/, $tm[0]);
	my $kk ='';
	if((scalar @k1)==0)
	{
		$kk = $tm[0];
	}
	else
	{
		$kk = $k1[0];
	}
	#print scalar @k1,"\t$kk\n";
	#<STDIN>;
	$pseqh{$kk} = $tm[1];
}
close(FH3);
#foreach my $k(keys %pseqh)
#{print "$k\t$pseqh{$k}\n"}
#exit;
for(my $i=0; $i<scalar @aa_12; $i++)
{
	my $k = $i+1;
	if(exists $hash1{$k})
	{
		$aa_12[$i] =~ s/\n+$//;
		my @tm = split(/\t+/,$aa_12[$i]);
		$tm[-1] =~ s/^#\*//;
		#my @aa1 = split(/:/,$tm[-1]);
		#my @aa = split(/_/, $aa1[0]);
		$hash2{$tm[-1]} = $hash1{$k};
	}
}
undef %hash1;
open(OTCYC,">$ARGV[0]/cycnames") || die "cant write to $ARGV[0]/cycnames\n";
foreach my $k(keys %hash2)
{
	$k =~ s/\*/#/;
	print OTCYC "$k\t$hash2{$k}\n";
}
close(OTCYC);
system(`cp $ARGV[0]/cycpart_pos $ARGV[0]/abc`);
system(`rm -f $ARGV[0]/cycpart_*`);
system(`cp $ARGV[0]/abc $ARGV[0]/cycpart_pos`);
system(`cp $ARGV[0]/abc $ARGV[0]/cycpart_pos1`);
open(FHCPT,"$ARGV[0]/cycpart_pos1") || die "cant open cycpart_pos1\n";
open(OTCPT,">$ARGV[0]/cycpart_pos") || die "cant write to cycpart_pos\n";
while(<FHCPT>)
{
	chomp;
	my @tm = split(/\t/);
	my @t = split(/\s+/, $tm[0]);
	print OTCPT "$t[0]\t$tm[1]\n";
}
close(FHCPT);
close(OTCPT);
open(FH33,"$ARGV[0]/cycpart_pos") || die "cant open cycpart_pos\n";
while(<FH33>)
{
	chomp;
	my @tt = split(/\t/,$_);
	my $fh = 'CYP';
	my $file = $tt[0];
	$file =~ s/^#\d+_//;
	$file =~ s/^\d+_//;
	$file = "cycpart_"."$file";
	open($fh, ">>$ARGV[0]/$file") || die "cant open $tm[1]\n";
	print $fh "$_\n";
	close($fh);
}
close(FH33);
open(FH44,"$ARGV[0]/cycnames") || die "cant open cycnames\n";
system(`rm -f $ARGV[0]/cycnames_*`);
while(<FH44>)
{
        chomp;
	my @tt = split(/\t/,$_);
        my $fh = 'CYN';
	my $file = $tt[0];
	$file =~ s/^#\d+_//;
	$file =~ s/^\d+_//;
	#push(@cycaryn, $file);
	$file = "cycnames_"."$file";
	#system(`echo "$tt[0]\t$tt[1]" >>$file`);
        open($fh, ">>$ARGV[0]/$file") || die "cant open $tm[1]\n";
        print $fh "$_\n";
	close($fh);
}
close(FH44);
#exit;
opendir(DH,"$ARGV[0]") || die "cant open dir $ARGV[0]\n";
my @dh =readdir(DH);
close(DH);
foreach my $k(keys %pseqh)
{
	#unless($k =~ /carnolysins/){next}
	#print "NEW\t$k\n";
	my @subalone=();
	@truexl = ();
	my $cycnfile = '';
	my $cycpfile = '';
	foreach my $d(@dh)
	{
		if($d =~ /$k/ and $d =~ /cycnames_/)
		{
			$cycnfile = $d;
		}elsif($d =~ /$k/ and $d =~ /cycpart_/)
		{
			$cycpfile = $d;
		}
	}
	if($cycnfile eq '' or $cycpfile eq '')
	{next}
	#print "$k\t$cycnfile\t$cycpfile\n";
	my $fh1 = 'FH3A';
	my $fh2 = 'FH4A';
	open($fh1,"$ARGV[0]/$cycpfile") || die "cant open $ARGV[0]/$cycpfile\n";
	open($fh2,"$ARGV[0]/$cycnfile") || die "cant open $ARGV[0]/$cycnfile\n";
	%scoreh = ();
	while(<$fh2>)
	{
        	chomp;
		s/^#//g;
        	my @tm =split(/\t/);
        	#push(@cycname,$tm[0]);
        	$scoreh{$tm[0]} = $tm[1];
	}
	my @cycname = (reverse sort {$scoreh{$a}  <=> $scoreh{$b}} keys %scoreh);
	close($fh2);
	#print "@cycname","\n";
	%hcpos=();
	while(<$fh1>)
	{
	        chomp;
		s/^#//;
        	my @tm =split(/\t/);
        	$hcpos{$tm[0]} = $tm[1];
	}
	#foreach my $k(keys %hcpos)
	#{print "$k\t$hcpos{$k}\n"}
	#<STDIN>;
	#foreach my $k(keys %scoreh)
        #{print "$k\t$scoreh{$k}\n"}
        #<STDIN>;
	close($fh1);
	%hcpos1=();
	foreach my $cn(@cycname)
	{
	        $hcpos1{$cn} = $hcpos{$cn};
	}
	%hcpos2=();
	foreach my $k(keys %hcpos1)
	{
	        my @tt = split(":", $hcpos1{$k});
	        $hcpos2{$hcpos1{$k}} = $tt[0];
	}
	#undef %hcpos1;
	my @truexl2 = (sort {$hcpos2{$a}  <=> $hcpos2{$b}} keys %hcpos2);
	@truexl = (sort {$hcpos2{$a}  <=> $hcpos2{$b}} keys %hcpos2);        #array @truexl is changed.
	#@cycname1 = @cycname;
	my $subcount=1;
	@array = ();
	#@subalone=();
	#print "B4 ",scalar @cycname,"\t",scalar keys %hcpos,"\t",scalar keys %scoreh,"\n";
	my $BIGFLAG=0;
	open(PREDCLS,"$ARGV[0]/predicted_class") || die "$ARGV[0]/predicted_class file not found 183 @ remove_overlapping.pl\n";
	chomp(my $predictedclass=<PREDCLS>);
	close(PREDCLS);
	if($predictedclass eq 'lanthipeptideC')
	{$BIGFLAG=1}
	#print 'cycname ',"@cycname","\n";
	#print "flag\t$BIGFLAG\n";
	my @classclanncomm = ();
	##### Class-C Lanthipeptide Motifs #####
	if($BIGFLAG==1)
	{
		my $FSEQ = $pseqh{$k};
		#print "$FSEQ\n";
		while($FSEQ =~ /(S\w{2}[S,T]\w{3,5}C)/g)
		{
        	my $motif = $1;
        	#print "$motif\n";
        	my $mpos = pos($FSEQ)-length($motif);
        	my $tm = split(//, $motif);
        	my $cpos = $mpos+$tm-1;
        	my $cycp ="$mpos:$cpos";
        	$mpos = $mpos+3;
        	my $cycp1 ="$mpos:$cpos";
        	push(@classclanpos, $cycp);
        	push(@classclanpos, $cycp1);
		}
		my @classclann = ();
		my @classclanpoints = ();
		foreach my $clp(@classclanpos)
		{
        	my @tm = split(/:/,$clp);
        	#push(@classclanpoints, $tm[0]);
        	#push(@classclanpoints, $tm[1]);
        	foreach my $k(keys %hcpos)
        	{
        	        if($clp eq $hcpos{$k})
        	        {
        	                push(@classclann, $k);
        	                goto outclan;
        	        }
        	}
        	outclan:
		}
		#print "ca\t","@classclann","\n";
		my @classclanpoints1 = uniq(@classclanpoints);
		#print "points\t","@classclanpoints1","\n";
		foreach my $a1(@classclann)
		{
        	foreach my $a2(@cycname)
        	{
        	        if($a1 eq $a2)
        	        {push(@classclanncomm,$a1)}
        	}
		}
		#print "comm\t","@classclanncomm","\n";
		undef @classclann;
		undef @classclanpos;
		my @classclanncomm_points = ();
		foreach my $comm(@classclanncomm)
		{
        	my @tm = split(/:/, $hcpos{$comm});
        	push(@classclanncomm_points,$tm[0]);
        	push(@classclanncomm_points,$tm[1]);
		}
		@classclanncomm_points = uniq(@classclanncomm_points);
		#print 'cpoints ',"@classclanncomm_points","\n";
		my @cycname_new = ();
		foreach my $cn(@cycname)
		{
        		my @tm = split(/:/,$hcpos{$cn});
        		my $flag=0;
        		foreach my $pnt(@classclanncomm_points)
        		{
        		        if($pnt==$tm[0] or $pnt==$tm[1])
        		        {
                	        $flag=1;
                	        goto bahar;
                		}
        		}
        		bahar:
        		if($flag==0)
        		{
        		        push(@cycname_new,$cn);
       			}	
		}
		#print "new\t","@cycname_new","\n";
		@cycname = ();
		foreach my $cnn(@cycname_new)
		{push(@cycname,$cnn)}
		undef @cycname_new;
	}##BIGFLAG
	#####FINISH#####
	#print @cycname,"\n";
	@alone = find_overlapping(\@cycname);
	#print "alone ","@alone","\n";
	#print "comm\t","@classclanncomm","\n";
	if($BIGFLAG==1)
	{
	        foreach my $a(@classclanncomm)
	        {
	                push(@alone,$a);
	        }
	        undef @classclanncomm;
	}
	#print "alone1 ","@alone","\n";
	foreach my $k(@alone)
	{
		push(@array,$hcpos{$k});
	}
	#print "ARRAY\t","@array","\n";
	#exit;
	
	my @truexl = uniq(@array);
	#print "$k\n";
	#print "$k\t","@truexl\n";
	foreach my $tl(@truexl)
	{
		print "$k\t$tl\n";
	}
	undef @truexl;
	undef %hcpos2;
	undef %hcpos;
	undef %hcpos1;
}
system(`rm -f $ARGV[0]/cycnames_*`);
system(`cp $ARGV[0]/cycpart_pos $ARGV[0]/cycpartpos_new`);
system(`rm -f $ARGV[0]/cycpart_*`);
system(`cp $ARGV[0]/abc $ARGV[0]/cycpart_pos1`);
exit;
###Subroutine###
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}
#my $subcount=1;
#my @subalone=();
sub find_overlapping
{
        $subcount++;
        my(@inp1) = @_;
        my $aref = $inp1[0];
	#my $href = $inp1[1];
	#my $href2 = $inp1[2];
	 #%scoreh = %{$href2};
	 #%hcpos = %{$href};
	#foreach my $kk(keys %hcpos)
	#{print "$kk\t$hcpos{$kk}\n"}
        my @cycname = @{$aref};
        my @subalone=();
        my @cycname1 = @cycname;
        my %strch = ();
        foreach my $k(keys %hcpos)
        {
		#print "kk\t$k\t$hcpos{$k}\n";
                #print "$k\t$hcpos{$k}\t$scoreh{$k}\n";
        }
	#<STDIN>;
        #my @alone = ();
	#print "here\t","@cycname1","\n";
	#<STDIN>;
        foreach my $k(@cycname1)
        {
        my $fgg=0;
        my @tm = split(":", $hcpos{$k});
        foreach my $tt1(@tm)
        {
                foreach my $k1(@cycname1)
                {
                        if($k1 eq $k){next}
                        my @tm1 = split(":", $hcpos{$k1});
                        if($tt1 == $tm1[0] or $tt1 == $tm1[1])
                        {
                                $fgg=1;
                                push(@{$strch{$tt1}},$k1);
                        }
                }
        }
        if($fgg==0)
        {push(@subalone,$k)}
        }
        #my @nonol = ();
 	foreach my $k(keys %strch)
        {
                #print "$k\n";
                my @tm = @{$strch{$k}};
                my %th=();
                foreach my $t(@tm)
                {
                        $th{$t}=$scoreh{$t};
                }
                my @tt = (reverse sort {$th{$a}  <=> $th{$b}} keys %th);
                push(@subalone,$tt[0]);
        }
        #print "@nonol","\n";
	@subalone = uniq(@subalone);
	#print "insub\t$subcount\t","@subalone","\n";
	if($subcount <=10)
        {
                find_overlapping(\@subalone);
        }else
        {
		$subcount=0;
		return @subalone;
	}

        #print "nsubalone","@alone","\n";
}

