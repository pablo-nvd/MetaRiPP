use warnings;
open (POS_DAT, "$ARGV[0]")||die "cannot open 1st file";
chomp (my $user_dir = "$ARGV[1]");
chdir $user_dir;
my @pos = <POS_DAT>;
my $pos_data = join ("", @pos);
my @pos_array = split (/\n>/, $pos_data);
my $p = 0;
open (OUT, ">ripp_out")||die "cannot open 1st file";
my @all_name;
foreach my $pos_array (@pos_array)
	{
	my %aa_list = ();
	my @seq = split (/\n/,$pos_array);chomp @seq;
	my $name = shift (@seq);
	my $class = $name;
	$name =~ s/ .*//;
	my $sequence = join ("", @seq);
	if (length($sequence) >150)
		{#print "$name\tNONE\n";next();##For Genome Mining
		print "NORiPP";next();
		}
	else
		{my $p = 1;
		push @all_name, $name;
		&perc_aa ($p, $name, $sequence);
		}
		#}
	#else {#print "$p\ ";
	#	&perc_aa ($p, $seq[0]);
	#	}
	}
###################
#RiPP Identification
###################

`../scripts/svm_classify ripp_out ../scripts/ripp_identification_model_c0.01_t2_g0.5_j20 ripp_identification_out`;
open (OUT_IDE, "ripp_identification_out")||die "cannot open identification file";
chomp (my @iden= <OUT_IDE>);
close OUT_IDE;

open (IN, "ripp_out")||die "cannot open input file";
chomp (my @inp= <IN>);
close IN;

if (scalar @all_name ne scalar @iden) {die "Number of input and output do not match"};
my @ripp_pos;
for ($n=0;$n<(scalar @iden);$n++)
	{
	my $iden_pred = $iden[$n];
	my $in = $inp[$n];
	if ($iden[$n] > -0.3727) ####CUT-OFF for RiPP Identification. Change new model used.
		{push (@ripp_pos, $inp[$n]);
		}
	else {my $cla = $inp[$n];
		$cla =~ s/.*#//;
		#print "$cla\tNONE\n";##For Genome Mining
		print "NORiPP";
		}
	}
open (IDEN_OUT, ">ripp_out1")||die "cannot open input file";
print IDEN_OUT map {$_, "\n"} @ripp_pos;
close IDEN_OUT;

####################
#RiPP Classification
####################

`../scripts/svm_multiclass_classify  ripp_out1 ../scripts/ripp_classification_aac_dpc_t_2_c_15_g_150_model ripp_prediction`;
open (OUT_DAT, "ripp_prediction")||die "cannot open 1st file";
my @out = <OUT_DAT>;

open (IN, "ripp_out1")||die "cannot open input file";
chomp (my @inp1= <IN>);
close IN;

#if (scalar @all_name ne scalar @out) {die "Number of input and output do not match"};
for ($x=0;$x<(scalar @out);$x++)
	{my @pred = split(/\s+/, $out[$x]);
	my $predicted_class = $pred[0];
	my $lanthipeptideB_score = $pred[1];
	my $lanthipeptideA_score = $pred[2];
	my $lanthipeptideC_score = $pred[3];
	my $linardin_score = $pred[4];
	my $cyanobactin_score = $pred[5];
	my $sactipeptide_score = $pred[6];
	my $microcin_score = $pred[7];
	my $lassopeptide_score = $pred[8];
	my $head_to_tail_score = $pred[9];
	my $auto_inducing_score = $pred[10];
	my $comX_score = $pred[11];
	my $thio_score = $pred[12];
	my $class_name;
	if ($predicted_class eq 1 and $lanthipeptideB_score >= 0.000109)    #cutoff to remove lanthipeptideB FP
		{$class_name = "lanthipeptideB";
		} 
	elsif ($predicted_class eq 2 and $lanthipeptideA_score >= 0.000002)
		{$class_name = "lanthipeptideA";
		} 
	elsif ($predicted_class eq 3 and $lanthipeptideC_score >= 0.000009)
		{$class_name = "lanthipeptideC";
		} 
	elsif ($predicted_class eq 4 and $linardin_score >= 0.000182)	
		{$class_name = "Linaridin";
		} 
	elsif ($predicted_class eq 5 and $cyanobactin_score >= 0.000936)
		{$class_name = "Cyanobactin";
		} 
	elsif ($predicted_class eq 6 and $sactipeptide_score >= 0.000013)
		{$class_name = "Sactipeptide";
		} 
	elsif ($predicted_class eq 7 and $microcin_score >= 0.000199)
		{$class_name = "Microcin";
		} 
	elsif ($predicted_class eq 8 and $lassopeptide_score >= 0.000004)
		{$class_name = "Lassopeptide";
		} 
	elsif ($predicted_class eq 9 and $head_to_tail_score >= 0.001367)
		{$class_name = "Bacterial_head_to_tail_cyclized";
		} 
	elsif ($predicted_class eq 10 and $auto_inducing_score >= 0.00009)
		{$class_name = "Auto_inducing_peptide";
		} 
	elsif ($predicted_class eq 11 and $comX_score >= 0.010228)
		{$class_name = "ComX";
		}
	elsif ($predicted_class eq 12 and $thio_score >= 0.00003)
		{$class_name = "Thiopeptide";
		}
	else
		{
		$class_name = 'NONE';
		}
	$all_name[$x] =~ s/^>//;
	$inp1[$x] =~ s/.*#//;
	#print "$inp1[$x]\t$class_name\n"; #For genome mining
	print "$class_name";
	}





sub perc_aa
	{
	my ($p, $name, $sequence) = @_;
	my @aa = split (//,$sequence);
        chomp @aa;
	print OUT "$p\ ";
	my $length = @aa;
	%di = ();   #####CHANGE
	$total = ($length -1);   #####CHANGE
        for ($n=0;$n<($length-1);$n++)  #####CHANGE
                {if ($aa[$n] =~ /[A-Z]/)
			{$x = "$aa[$n]$aa[$n+1]";   #####CHANGE
                #print "$x\n";
	                $a = ord"$aa[$n]";
        	        $b = ord"$aa[$n+1]";
        	        $y = "$a$b";         #####CHANGE
			$di{$y} ++ ;
                        $y = $a*100;
                        $di{$y} ++;
                        #print "$y\n";
                        }
                }
        $y = (ord"$aa[-1]")*100;
        $di{$y} ++;
#       print "$y:$di{$y}\n";

        foreach $dip (sort keys (%di))
                {
                if ($dip =~ /00$/)
                        {$perc = $di{$dip}/$length;
                        }
                else
                        {$perc = $di{$dip}/$total;
                        }
                printf OUT ("$dip:%.5f\ ", $perc);
                }
        print OUT " #$name\n";
        }

