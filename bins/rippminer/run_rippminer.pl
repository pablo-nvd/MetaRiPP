use warnings;
use FindBin qw($Bin);
chdir($Bin);
use Getopt::Long qw(GetOptions);
my $rippclass='PRED';
my $inpfile = '';
my $leaderchecker =0;
my $classifier = 'RF';
my $predictclass = 0;
my $outfile = 'prediction.out';
my $help ='';

###Exception Handling
GetOptions('class=s' => \$rippclass, 'i=s' => \$inpfile, 'o=s' => \$outfile, 'coreonly=s' => \$leaderchecker, 'classifier=s' => \$classifier, 'predictclass=s' => \$predictclass, 'h=s' => \$help) or die "Usage: perl $0 -i protein_fasta_input_file\nRun 'perl $0 -h help' for more!\n";
if($inpfile eq '' and $help eq '')
{
	die "Input ('-i') not provided\nRun 'perl $0 -h help' for more!\n";
}elsif($inpfile eq '' and $help ne '')
{
	print "Usage: perl $0 -i protein_fasta_input_file\n\n";
	print "Following arguments can be passed to the program\n";
	print "-i\t\tinput peptide sequence file(Fasta)\n-class\t\tprovide RiPP class(LanthipeptideA, LanthipeptideB, LanthipeptideC,\n\t\tLanthipeptideD, Cyanobactin, Lassopeptide, Thiopeptide) of the input Sequence.\n\t\t(By deafault the program will predict the class)\n";
	print "-coreonly\t1 if the input sequence contain only core sequence(0 is Default)\n";
	print "-classifier\tChose SVM for Support Vector machine or RF for Random Forest for Lanthipeptide Crosslink prediction.(RF is default)\n";
	print "-predictclass\t1 if only Class Prediction is required (default is 0)\n";
	print "-h help\t\tDisplays short information about various options that can be used with this script.\n";
	die "\n";
}
###Parameter checking
if($rippclass !~ /PRED|LanthipeptideA|LanthipeptideB|LanthipeptideC|LanthipeptideD|Lassopeptide|Cyanobactin|Thiopeptide|Lanthipeptide/i)
{
	die "Wrong parameter is provided in '-class' argument\nRun 'perl $0 -h help' for detail information about parameters usage!\n";
}elsif(!( -e $inpfile))
{
	die "Input file '$inpfile' does not exists\nCheck the file name and try again!\n";
}elsif($leaderchecker !~ /1|0/)
{
	die "Wrong parameter is provided in '-coreonly' argument\nRun 'perl $0 -h help' for detail information about parameters usage!\n";
}elsif($predictclass !~ /1|0/)
{
	die "Wrong parameter is provided in '-predictclass' argument\nRun 'perl $0 -h help' for detail information about parameters usage!\n";
}
`rm -rf TMP`;
`chmod +x scripts/*`;
###
my $multiseq = '';
my @multiseqary = ();
open(MULTICHECK,"$inpfile") || die "Can't open/find $inpfile\n";
while(<MULTICHECK>)
{
	$multiseq .= $_;
}
close(MULTICHECK);
@multiseqary = split(/>/, $multiseq);
shift @multiseqary;
`rm -rf >>$outfile`;
`rm -rf TMP`;
`rm -f input_rippminer_tmp*.txt`;
for(my $i=0; $i<scalar@multiseqary; $i++)
{
my @arytmp = split(/\n+/,$multiseqary[$i]);
my $header = shift @arytmp;
my $counttmp = $i+1;
#print "#INPUT\t$counttmp\n";
my $seqfile = 'input_rippminer_tmp'.$counttmp.'.txt';
my $oth = 'OTSEQ';
open($oth,">$seqfile") || die "Can't write to $seqfile\n";
print $oth ">$multiseqary[$i]";
close($oth);
my $classflag=0;
my $classpred='';
`rm -rf TMP`;
`rm -rf >>$outfile`;
`mkdir TMP`;
`cp $seqfile TMP/cyclizationInput.fasta`;
`perl scripts/chech_fasta_input.pl TMP`;

####Class Prediction###
my $inpseq ='';
open(INPSEQ,"TMP/cyclizationInput.fasta") || die "Can't open TMP/cyclizationInput.fasta\n";
while(<INPSEQ>)
{
	chomp;
	$inpseq .= $_;
}
close(INPSEQ);
$inpseq =~ s/\s+//g;
$inpseq =~ s/\n+//g;
if($rippclass eq 'PRED')
{
	$classflag=1;
	`perl scripts/RiPP_classification_new.pl TMP/cyclizationInput1.fasta TMP >TMP/predicted_class`;
	my $fh1 = 'OPEN1';
	open($fh1,"TMP/predicted_class") || die "Can't open the file TMP/predicted_class\n";
	chomp($classpred = <$fh1>);
	close($fh1);
	#`echo 'Predicted Class:\t$classpred\n' >>$outfile`;
	if($classpred =~ /NONE/)
	{
		`echo '\n#INPUT\t$counttmp\t$header\n' >>$outfile`;
		`echo 'The Input Peptide sequence is predicted as RiPP!\n' >>$outfile`;
		`echo 'Predicted RiPP Class:\t$classpred\n' >>$outfile`;
		goto skip;
	}elsif($classpred =~ /NORiPP/)
	{
		`echo '\n#INPUT\t$counttmp\t$header\n' >>$outfile`;
		`echo 'The Input Peptide sequence is not predicted as RiPP!' >>$outfile`;
		goto skip;
	}
}else
{
	`echo $rippclass >TMP/predicted_class`;
	#`echo 'RiPP Class:\t$rippclass\n' >>$outfile`;
}
#print "leaderchecker\t$leaderchecker\n";
if($predictclass==1)
{
	#print "Input Sequence\t$inpseq\n";
	`echo '\n#INPUT\t$counttmp\t$header\n' >>$outfile`;
	`echo 'Predicted RiPP Class:\t$classpred\n' >>$outfile`;
	goto skip;
}
###LASSOPEPTIDE Prediction
if($classpred eq 'Lassopeptide' or $rippclass =~ /Lassopeptide/i)
{
        #print "SEQUENCE\t$inpseq\n";
        `perl scripts/lassopeptide_cleavage_cyclization.pl TMP/cyclizationInput1.fasta $leaderchecker TMP >TMP/lasso_output`;
        `perl scripts/format_lasso_result.pl TMP`;
	`cat TMP/lasso*.txt >prediction.output`;
	#open('LASSOP',"prediction.output") || die "Can't find prediction.output\n";
	#while(<LASSOP>){print}
	#close(LASSOP);
}

###CYANOBACTIN Prediction
if($classpred eq 'Cyanobactin' or $rippclass =~ /Cyanobactin/i)
{
	`perl scripts/cyanobactin_core_peptide.pl TMP/cyclizationInput1.fasta $leaderchecker TMP >TMP/cyanopred.out`;
	`perl scripts/format_cyanopred_result.pl TMP`;
	`cat TMP/cyanob*.txt >prediction.output`;
	#open('CYANOB',"prediction.output") || die "Can't find prediction.output\n";
	#while(<CYANOB>){print}
	#close(CYANOB);
}

###THIOPEPTIDE Prediction
if($classpred eq 'Thiopeptide' or $rippclass =~ /Thiopeptide/i)
{
	`perl scripts/thiopeptide_predictions_web.pl TMP/cyclizationInput.fasta  >TMP/thiopred.out`;
	`perl scripts/format_thiopeptide_predictions.pl TMP/thiopred.out >TMP/thiopred_formatted.out`;
	`perl  scripts/pep2smi_maker_thiop.pl TMP/thiopred.out >>TMP/thiopred_formatted.out`;
	`cp TMP/thiopred_formatted.out prediction.output`;
	#open('THIOP',"prediction.output") || die "Can't find prediction.output\n";
	#while(<THIOP>){print}
	#close(THIOP);
}

###LANTHIPEPTIDE Prediction
if($classpred =~ /lanthipeptide/i or $rippclass =~ /lanthipeptide/i)
{
	#Leader-Core Prediction for Lanthipeptide.
	if($leaderchecker!=1)
	{
		`perl scripts/get_core_leader.pl TMP/cyclizationInput.fasta TMP >TMP/core_predict.out`;
		`perl scripts/extract_core.pl TMP`;
	}	
	`perl scripts/create_cyclizations_newprediction.pl TMP/cyclizationInput1.fasta TMP >TMP/cyclized.out`;
	`perl scripts/calculateKmer.pl cyclized.out 1  TMP >TMP/1mer`;
	`perl scripts/calculateKmer.pl cyclized.out 2  TMP >TMP/2mer`;
	`perl scripts/merge_kmersfile.pl TMP/1mer TMP/2mer >TMP/aa_12`;
	if($classifier eq 'RF')
	{
		`perl scripts/merge_kmersfile_rf.pl TMP/1mer TMP/2mer >TMP/aa_12.arff`;
		`java -classpath scripts/weka-3-6-14/weka.jar weka.classifiers.trees.RandomForest -l scripts/MODELRFF -T TMP/aa_12.arff -p first >TMP/rfout`;
		`perl scripts/format_rfout.pl  TMP >TMP/svmout`;
		`perl scripts/gen_positivepredictin.pl MODELRFF TMP >TMP/positivepredictin`;	
	}else
	{
		`./scripts/svm_classify TMP/aa_12  scripts/MODELSVMF TMP/svmout`;
		`perl scripts/gen_positivepredictin.pl MODELSVMF TMP >TMP/positivepredictin`;
	}
	`perl scripts/retrieve_finalresult.pl TMP >TMP/cycPred.out`;
	`perl scripts/remove_overlapping.pl TMP >TMP/bposf`;
	`perl scripts/gen_complete_cyclization_new.pl TMP`;
	`perl scripts/gen_lanthipep_output.pl TMP $leaderchecker >TMP/prediction.output`;
	`cp TMP/prediction.output prediction.output`;
	#open('LANTHIP',"prediction.output") || die "Can't find prediction.output\n";
	#while(<LANTHIP>){print}
	#close(LANTHIP);
}
`echo '\n#INPUT\t$counttmp\t$header\n' >>$outfile`;
if($classflag==1)
{
	`echo 'Predicted RiPP Class:\t$classpred\n' >>$outfile`;
}else
{
	`echo 'RiPP Class:\t$rippclass\n' >>$outfile`;
}
`cat prediction.output >>$outfile`;
skip:
`rm -rf $seqfile`;
`rm -rf TMP`;
`rm -rf prediction.output`;
}
print "Execution Complete!\nResults have been saved to file '>>$outfile'.\n";
