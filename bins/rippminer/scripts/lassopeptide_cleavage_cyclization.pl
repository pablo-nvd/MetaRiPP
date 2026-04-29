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
open (FILE1, "$ARGV[0]")||die "cannot open file";
chomp (my @file1 = <FILE1>);
chomp (my $leader_checker = "$ARGV[1]");
chomp (my $user_dir = "$ARGV[2]");
chdir ("$user_dir")||die "cannot change directory";
$file1_joined = join ("\n", @file1);
@seq = split (/\n>/, $file1_joined);
my $length = @seq;
foreach my $seq (@seq)
        {undef @frag;
	`rm -f test_frag test_feature predictions`;
	my $name;my $fas;
	if ($seq =~ /(.*)\n([A-Z]+)/)
		{$name = $1;
		$fas = $2;
		my $top_5;
		my $seq_len = length $fas;
		if ($leader_checker == 0)
			{for ($n=0; $n <$seq_len-12; $n++)
                       		{my $l = $n+1+12;
				my $infrag;
				my $substr = substr ($fas, $n, 13);
				$infrag = "$substr\t1\t$l";
				push @frag, $infrag;
	        	        }
			open (TEST, ">test_frag")||die "cannot open file for writing";
			print  TEST map {$_, "\n"} @frag;
			close TEST;
			`perl ../scripts/get_encoding_at_each_pos_lasso test_frag >test_feature`;
			`../scripts/svm_classify test_feature ../scripts/all_lasso_13_mer_svm_model predictions`;
			$name =~ s/>//;
			print ">$name\n";
			$top_5= `paste predictions test_frag| sort -r -n `;
			}
		elsif ($leader_checker == 1) 
			{$top_5 = "NA\tNA\tNA\t1";   #### Using 1 as starting position for core peptide when user submits only core
			}
		 
		#print "$top_5\n";
		#####################
		#Cyclization
		#####################
		my @top = split(/\n/, $top_5);chomp @top;
		my $x=1;
		foreach my $top (@top)
			{if ($x <= 3)
				{my ($score,$fragment,$void,$pos) = split (/\s+/,$top);
				my $pos1 = ($seq_len - $pos +1 ) *-1;
				my $cleavage = ($pos -1) ;
				my $prepep_seq = substr ($fas, $pos1);
				my $prepep_length = length ($prepep_seq);
				my $first = substr ($prepep_seq, 0, 1);
				my $seven = substr ($prepep_seq, 6, 1);
				my $eight = substr ($prepep_seq, 7, 1);
				my $nine = substr ($prepep_seq, 8, 1);
				my $cycle1; my $cycle2; my $cycle3;
				if ($seven =~ "D|E")
					{$cycle1 = "1,7,($aa{$first}-$aa{$seven})";
					if ($eight =~ "D|E")
                				{$cycle2 = "1,8,($aa{$first}-$aa{$eight})";}
					if ($nine =~ "D|E")
						{$cycle3 = "1,9,($aa{$first}-$aa{$nine})";}
					}
				elsif ($eight =~ "D|E")
					{$cycle1 = "1,8,($aa{$first}-$aa{$eight})";
					if ($nine =~ "D|E")
						{$cycle2 = "1,9,($aa{$first}-$aa{$nine})";}
					}
				elsif ($nine =~ "D|E")
					{$cycle1 = "1,9,($aa{$first}-$aa{$nine})";}
				else {next;}
				my $fircys = index ($prepep_seq, "C");
				my $fir = $fircys+1;
				my $seccys;my $sec;my $thrcys;my $thr;my $forcys;my $for;my $cyscycle1 ;my $cyscycle2 ;
				if ($fircys != -1)
					{$seccys = index ($prepep_seq, "C",$fir);
					my $sec = $seccys+1;
					if ($seccys != -1)
						{$thrcys = index ($prepep_seq, "C",$sec);
						my $thr = $thrcys+1;
						if ($thrcys != -1)
							{$forcys = index ($prepep_seq, "C",$thr);
							$for = $forcys +1;
							$cyscycle1 = "$fir,$thr,(Cys-Cys);";
							$cyscycle2 = "$sec,$for,(Cys-Cys);";
							}	
						else {$cyscycle1 = "$fir,$sec,(Cys-Cys);";}
						}
					}
				print "$x. $cleavage\t$score\t$cycle1;$cyscycle1$cyscycle2\n";	
				$x++;
				if ($cycle2 ne "" && $x <= 3)
					{print "$x. $cleavage\t$score\t$cycle2;$cyscycle1$cyscycle2\n";
					$x++;}
				if ($cycle3 ne "" && $x <= 3)
					{print "$x. $cleavage\t$score\t$cycle3;$cyscycle1$cyscycle2\n";
					$x++;}
				}
			else {next;
				print "--\n";
				}
			}
		}
	}
	
#	`rm -f train_frag test_frag test_feature predictions`;
