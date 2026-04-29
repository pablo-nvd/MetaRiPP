#use warnings;
my %aa = (
"A", => "Ala",
"R", => "Arg",
"N", => "Asn",
"D", => "Asp",
"C", => "Cys",
"E", => "Glu",
"Q", => "Gln",
"G", => "Gly",
"H", => "His",
"I", => "Ile",
"L", => "Leu",
"K", => "Lys",
"M", => "Met",
"F", => "Phe",
"P", => "Pro",
"S", => "Ser",
"T", => "Thr",
"W", => "Trp",
"Y", => "Tyr",
"V", => "Val",
);

open (FILE2, "$ARGV[0]")||die "cannot open file";
chomp (my @file2 = <FILE2>);
chomp (my $leader_checker = "$ARGV[1]");
chomp (my $user_dir= "$ARGV[2]");
#$file_joined = join ("\n", @file);
chdir $user_dir;
$file2_joined = join ("\n", @file2);
@seq = split (/\n>/, $file2_joined);
my $length = @seq;
`rm -f predictions_top_rs2 predictions_top_rs3 predictions_top_10_rs* aac_dpc_feature predictions_hetero`;
foreach my $seq (@seq)
        {if ($leader_checker==1)
		{ if ($seq =~ /(.*)\n([A-Z]+)/)
                        {$name = $1;
                        $fas = $2;
			$core_length = length ($fas);
			$substr = substr($fas,0,1);
			$last_substr = substr($fas,-1,1);
			print "$name\t1-$core_length\t$fas\t1,$core_length,peptide_bond($aa{$substr}-$aa{$last_substr})\n";
			}
		}
	else{
	#undef @frag;
        #undef @rs2_frag;
        #undef @rs3_frag;
	`rm -f test_frag_rs* test_feature_rs* svm_model predictions_rs* test_col_rs* aac_dpc_feature predictions_hetero`;
        undef @rs2_frag1;
        undef @rs3_frag1;
	my $fasta = &frag($seq);
	open (TEST, ">test_frag_rs2")||die "cannot open file for writing";
	print  TEST map {$_, "\n"} @rs2_frag1;
	#print   map {$_, "\n"} @rs2_frag1;
	close TEST;
	open (TEST1, ">test_frag_rs3")||die "cannot open file for writing";
	print  TEST1 map {$_, "\n"} @rs3_frag1;
	close TEST1;
	`perl ../scripts/get_encoding_at_each_pos test_frag_rs2 > test_feature_rs2`;
	`perl ../scripts/get_encoding_at_each_pos test_frag_rs3 > test_feature_rs3`;
	`../scripts/svm_classify aac_dpc_feature ../scripts/cyanobactin_aac_dpc_rbf_g1_c50_model predictions_hetero`; #############HETERO CLASSIFICATION#########
	`../scripts/svm_classify test_feature_rs2 ../scripts/cyanobactin_rs2_5mer_model_g1_c50 predictions_rs2`;
	`../scripts/svm_classify test_feature_rs3 ../scripts/cyanobactin_rs3_4mer_model_g1_c50 predictions_rs3`;
	#print ">$test_name\n";
	`paste predictions_rs2 test_frag_rs2| sort -r -n > predictions_top_rs2`;
	`paste predictions_rs3 test_frag_rs3| sort -r -n > predictions_top_rs3`;
	`paste predictions_rs2 test_frag_rs2| sort -r -n | head -5 > predictions_top_5_rs2`;
	`paste predictions_rs3 test_frag_rs3| sort -r -n | head -5 > predictions_top_5_rs3`;
	open (HET, "predictions_hetero")||die "cannot open input file"; #### hetero prediction file;
	chomp (my @het= <HET>); my $het_status;
	if ($het[0] >=0)
		{$het_status = 1;
		}
	else {$het_status = 0;}
	open (FILE, "predictions_top_5_rs3")||die "cannot open input file"; #### rs3 file
	chomp (my @file= <FILE>);
	open (FILE1, "predictions_top_5_rs2")||die "cannot open input file1";#### rs2 file
	chomp (my @file1= <FILE1>);
	foreach my $file (@file)
		{my $p = 0;
		my ($score,$fragment,$actual,$name) = split(/\s+/, $file);
		$name =~ s/;(\d+)//;
		my $rs3_position = $1;
		$rs3_position1 = $rs3_position -1; 
		$name =~ s/#//;
		$name =~ s/>//;
		my @grep = grep (/$name/, @file1);
		foreach $grep (@grep)
			{#print "$file\t\t$grep\n";
			my ($rs2_score,$rs2_fragment,$rs2_actual,$rs2_name) = split(/\s+/, $grep);
			$rs2_name =~ s/;(\d+)//;
			my $rs2_position = $1;
			$rs2_position +=5;
			my $core_length = $rs3_position - $rs2_position;
			my $rs2_position1 = $rs2_position +1; 
			my $substr = substr ($fasta, $rs3_position1, 1);#last amino acid of core peptide
			my $core_pep = substr ($fasta, $rs2_position, $core_length);
			my $fir_substr = substr ($core_pep, 0, 1);#first amino acid of core peptide
			if ($substr =~ /C|P/ && $core_length < 20 && $core_length > 2)
				{print "$name\t$rs2_position1-$rs3_position\t$core_pep\t1,$core_length,peptide_bond($aa{$fir_substr}-$aa{$substr})\t";
				if ($het_status == 1) 
					{my @het_array;
					for ($y =0; $y < $core_length;)
						{my $c_substr = substr($core_pep, $y, 1);
						$y++;
						if ($c_substr eq "C")
							{print "$y,thiazol(in)e(Cys);";}
						elsif ($c_substr eq "S")
							{print "$y,oxazol(in)e(Ser);";}
						if ($c_substr eq "T")
							{print "$y,methyloxazol(in)e(Thr);";}
						#my $s_position = index($core_pep, "S", $y);
						#my $t_position = index($core_pep, "T", $y);
						}
					print "\n";
					}
				#$index++ until $file1[$index] eq "$grep";
				#splice(@file1, $index, 1);
				last;
				}
			}
		}
	}
	#$name =~ s/(;\d+)//;
	#my $top_5_rs3= `paste predictions_rs3 test_frag_rs2| sort -r -n `;
	}


`rm -f test_frag_rs* test_feature_rs* predictions_rs* test_col_rs* aac_dpc_feature predictions_hetero`;


#my $length = @seq;
	#print "$grep1[0]\n";
	#undef @seq_grep;
        #my $name = $spl_name[0];
		#print "$substr\t$core_length\t$rs3_position\t$rs2_position1\t$cycle\n";
	#print map {$fragment, "\t", $_, "\n"} @grep;

sub frag
	{my ($fasta) =@_;
	my $test_name;my $fas;
		if ($fasta =~ /(.*)\n([A-Z]+)/)
			{$name = $1;
			$fas = $2;
			$name =~ s/^\s+//;
			$name =~ s/\s+.*//;
			#print "$name\t$fas\n";
			#undef @seq_grep;
			my $seq_len = length $fas;
			##################### HETEROCYCLIZATION PREDICTION ################
			open (OUT, ">aac_dpc_feature")||die "cannot open file for writing";
			print OUT "1 ";
			my %aa_list = ();
			my @aa = split (//,$fas);chomp @aa;
			%di = (); 
			my $total = ($seq_len -1); 
			for ($n=0;$n<($seq_len-1);$n++)  #####CHANGE
                		{
                        	$x = "$aa[$n]$aa[$n+1]";   #####CHANGE
                        	$a = ord"$aa[$n]";
                        	$b = ord"$aa[$n+1]";
                        	$y = "$a$b";         #####CHANGE
                        	$di{$y} ++ ;
                        	$y = $a*100;
                        	$di{$y} ++;
                        	}
			$y = (ord"$aa[-1]")*100;
			$di{$y} ++;
			foreach $dip (sort keys (%di))
		                {if ($dip =~ /00$/)
					{$perc = $di{$dip}/$length;
                        		}
				else
					{$perc = $di{$dip}/$total;}
                		printf OUT ("$dip:%.5f\ ", $perc);
                		}
			print OUT " #$name\n";
			close OUT;
			for ($n=0; $n <$seq_len-3; $n++)
                        	{
				my $substr = substr ($fas, $n, 4);
				my $substr_rs2 = substr ($fas, $n, 5);
		                my $fragment_rs2;
		                my $fragment_rs3;
				################FRAGMENTS FOR CLEAVAGE PREDICTION- NOT UNIQUE###################
	                        if ($n < $seq_len-4)
                		         {$fragment_rs2 = "$substr_rs2\t1\t#$name;$n";
                        		push @rs2_frag1, $fragment_rs2;
                                	}
				$fragment_rs3 = "$substr\t1\t#$name;$n";
                        	push @rs3_frag1, $fragment_rs3;
				}
			}
	return $fas;
	}
