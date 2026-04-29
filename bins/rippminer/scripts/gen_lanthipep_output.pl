use warnings;
#To generate final formatted output for Lanthipeptide.
open(FH1,"$ARGV[0]/predicted_class") || die "Can't open $ARGV[0]/predicted_class\n";
chomp(my $predictedclass = <FH1>);
close(FH1);
chomp(my $leaderchecker = $ARGV[1]);
my $core = '';
my %hash =(
'S' => 'Ser',
'T' => 'Thr',
'C' => 'Cys',
);
if($leaderchecker==0)
{
	my $sequence = '';
	my $leader = '';
	my $cleavage_site = '';
	open(FH2,"$ARGV[0]/core_predict.out") || die "Can't open $ARGV[0]/predicted_class\n";
	while(<FH2>)
	{
		chomp;
		my @tm = split(/:\s+/);
		if(/^Seq/i)
		{
			$sequence = $tm[1];
		}elsif(/^Leader peptide/i)
		{
			$leader = $tm[1];
		}elsif(/^Core peptide/i)
		{
			$core = $tm[1];
		}elsif(/^Cleavage site/i)
		{
			 $cleavage_site = $tm[1];
		}
	}
	close(FH2);
	print "Sequence:\t$sequence\n";
	print "Cleavage site (12 mer):\t$cleavage_site\n";
	print "Leader peptide:\t$leader\n";
	print "Core peptide:\t$core\n";
}else
{
	open(FH5,"$ARGV[0]/cyclizationInput.fasta") || die "Can't open $ARGV[0]/cyclizationInput.fasta\n";
	chomp($core = <FH5>);
	print "Core peptide:\t$core\n";
}
#<STDIN>;
##Crosslink Visualisation
if(-e "$ARGV[0]/bposf")
{
	my @crosslinks = ();
	open(FH3,"$ARGV[0]/bposf") || die "can't find $ARGV[0]/bposf\n";
	while(<FH3>)
	{
		chomp;
		my @tm = split(/\t/);
		push(@crosslinks,$tm[1]);
	}
	close(FH3);
	print "\nPredicted Crosslinks\n";
	my $core_new = put_crosslink($core,\@crosslinks);
	$core_new =~ s/#//g;
	$core_new =~ s/(\d)/\($1\)/g;
	print "$core_new\n\n";
	@crosslinks = sort_crosslinks_array(\@crosslinks);
	foreach my $cl(@crosslinks)
	{
		my @clt = split(/:/,$cl);
		my $aa1 = substr($core,$clt[0],1);
		my $aa2 = substr($core,$clt[1],1);
		$clt[0] = $clt[0]+1;
		$clt[1] = $clt[1]+1;
		$aa1 = $hash{$aa1};
		$aa2 = $hash{$aa2};
		print "Crosslinks:\t$clt[0] - $clt[1]\t$aa1 - $aa2\n";
	}
	print "SMILES\n";
	`perl scripts/pep2smi_maker_lanthipeptide.pl TMP bposf >TMP/test.smiles`;
	open(SMI,"TMP/test.smiles") || die "Can't find TMP/test.smiles\n";
	chomp( my $smi=<SMI>);
	close(SMI);
	print "$smi\n";
}elsif(-e "$ARGV[0]/bposf_s" and -e "$ARGV[0]/bposf_l")
{
	my @crosslinks_s = ();
	my @crosslinks_l = ();
	open(FH3,"$ARGV[0]/bposf_s") || die "can't find $ARGV[0]/bposf_s\n";
	while(<FH3>)
	{
		chomp;
		my @tm = split(/\t/);
		push(@crosslinks_s,$tm[1]);
	}
	close(FH3);
	open(FH4,"$ARGV[0]/bposf_l") || die "can't find $ARGV[0]/bposf_l\n";
        while(<FH4>)
        {
                chomp;
                my @tm = split(/\t/);
                push(@crosslinks_l,$tm[1]);
        }
        close(FH4);
	print "\nPredicted Crosslinks\n";
	print "Model\t1\n";
	my $core_new1 = put_crosslink($core,\@crosslinks_l);
	$core_new1 =~ s/#//g;
	$core_new1 =~ s/(\d)/\($1\)/g;
	print "$core_new1\n\n";
	@crosslinks_l = sort_crosslinks_array(\@crosslinks_l);
	foreach my $cl(@crosslinks_l)
	{
                my @clt = split(/:/,$cl);
                my $aa1 = substr($core,$clt[0],1);
                my $aa2 = substr($core,$clt[1],1);
                $clt[0] = $clt[0]+1;
                $clt[1] = $clt[1]+1;
                $aa1 = $hash{$aa1};
                $aa2 = $hash{$aa2};
                print "Crosslinks:\t$clt[0] - $clt[1]\t$aa1 - $aa2\n";
        }
	print "SMILES\n";
	`perl scripts/pep2smi_maker_lanthipeptide.pl TMP bposf_l >TMP/test1.smiles`;
	open(SMI1,"TMP/test1.smiles") || die "Can't find TMP/test1.smiles\n";
	chomp( my $smi1=<SMI1>);
	print "$smi1\n";
	print "\n";
	print "Model\t2 (Labionin Linkage)\n";
	my $core_new = put_crosslink($core,\@crosslinks_s);
	$core_new =~ s/#//g;
	$core_new =~ s/(\d)/\($1\)/g;
	print "$core_new\n\n";
	@crosslinks_s = sort_crosslinks_array(\@crosslinks_s);
	foreach my $cl(@crosslinks_s)
        {
                my @clt = split(/:/,$cl);
                my $aa1 = substr($core,$clt[0],1);
                my $aa2 = substr($core,$clt[1],1);
                $clt[0] = $clt[0]+1;
                $clt[1] = $clt[1]+1;
                $aa1 = $hash{$aa1};
                $aa2 = $hash{$aa2};
                print "Crosslinks:\t$clt[0] - $clt[1]\t$aa1 - $aa2\n";
        }
	print "SMILES\n";
	`perl scripts/pep2smi_maker_lanthipeptide.pl TMP bposf_s >TMP/test2.smiles`;
	open(SMI2,"TMP/test2.smiles") || die "Can't find TMP/test2.smiles\n";
	chomp( my $smi2=<SMI2>);
	print "$smi2\n";	
}

sub put_crosslink
{
	my ($seq,$cl) = @_;
	my @crosslinks = @{$cl};
	my @tmp =();
	my %xlhash=();
	my $clc =0;
	my $l = 0;
	foreach my $b(@crosslinks)
	{
	        my @tm = split(/:/,$b);
	        foreach my $t(@tm)
	        {
	                push(@tmp,$t);
	        }
	}
	@tmp = sort {$a <=> $b } @tmp;
	#print "@tmp","\n";
	foreach my $b(@crosslinks)
	{
        	my @tm = split(/:/,$b);
        	if($tm[0]>=$tm[1])
        	{
        	        $xlhash{$tm[1]}=$b;
        	}else
        	{
        	        $xlhash{$tm[0]}=$b;
        	}
	}
	@crosslinks = ();
	foreach my $k(sort {$a <=> $b } keys %xlhash)
	{
	        #print "$k\t$xlhash{$k}\n";
	        push(@crosslinks,$xlhash{$k});
	}
	undef %xlhash;
	my $countxl =0;
	foreach my $b(@crosslinks)
	{
        	$clc++;
        	my @tm = split(/:/,$b);
        	#print "$b\n";
        	foreach my $t(@tm)
        	{
        	        #print "$t\n";
        	        my $t1p=0;
        	        foreach my $t1(@tmp)
        	        {
        	                $t1p++;
        	                if($t==$t1)
        	                {goto out}
                	}
                	out:
                	my $tt1 = $t + ($t1p-1)*2;
                	#print "tt1\t$tt1\n";
                	my $subs = substr($seq,0,$tt1);
                	my $hdc = () = $subs =~ m/#\d/g;
                	$t = $t+$hdc*2;
                	substr($seq,$t,1) = substr($seq,$t,1).'#'.$clc;
                	#$l = $l+2;
                	#print "$subs\t$hdc\n";
                	#print "seq\t$t\t$seq\n";
                	#<STDIN>;
        	}
	}
	return $seq;	
}

sub sort_crosslinks_array
{
	my ($inp) = @_;
	my %hash = ();
	my @crosslinks = @{$inp};
	foreach my $cl(@crosslinks)
	{
		my @tm = split(/:/,$cl);
		if($tm[0]>$tm[1])
		{
			$hash{$cl} = $tm[0];
		}else
		{
			$hash{$cl} = $tm[1];
		}
	}
	my @out = sort {$hash{$a} <=> $hash{$b}} keys %hash;
	#print "@out","\n";
	return(@out);
}
