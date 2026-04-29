use warnings;
use Getopt::Long qw(GetOptions);
my $Path_to_Blast_bin = '';	# Put path to your Blast bin directory in the file 'path' For Ex: '~user/software/ncbi-blast-2.2.30+/bin'.
`rm -rf sequence_similarity.out`;
`rm -rf all_alignment`;
open(PATH,"path") || die "File 'path' not found\n";
while(<PATH>)
{
	chomp;
	if(/^Blast/i)
	{
		s/^Blast=//i;
		s/'//g;
		$Path_to_Blast_bin =$_;
	}
}
close(PATH);
open(OT1,">sequence_similarity.out") || die "Can't write to sequence_similarity.out\n";
if($Path_to_Blast_bin eq '')
{
	die "Path to Blast 'bin' directory not provided\nCheck the Documentation\n";
}
$Path_to_Blast_bin =~ s/\/$//;
my $input = '';
GetOptions('i=s' => \$input) or die "Usage: perl $0 -i protein_fasta_input_file\n";
if($input eq '')
{
	die "Inp(-i) is not provided!\n";
}
`rm -rf all_alignment`;
my %hash = ();
my $blast_out = `$Path_to_Blast_bin/blastp -query $input -db DB/seq_database -outfmt 6 -num_alignments 50`;
my $blast_out_a = `$Path_to_Blast_bin/blastp -query $input -db DB/seq_database -outfmt 0 -num_alignments 50 `;
my @blast_out = split (/\n/, $blast_out);
open(OT,">all_alignment") || die "Can't Open 'all_alignment'\n";
$blast_out_a =~ s/\@/ /g;
print OT $blast_out_a,"\n";
close(OT);
my @ali_out = split (/(?=^Query=)/m, $blast_out_a); ## (?=pattern) is a positive look ahead assertion
#print "Subject\tIdentity\tAlignment Length\tAli start\tAli end\tE-value\n\n";
foreach my $a(@blast_out)
{
	my @tm = split(/\t/,$a);
	my $ky = shift@tm;
	my $val = join("\t",@tm);
	$val =~ s/\@/ /g;
	push(@{$hash{$ky}},$val); 
}

foreach my $k(sort keys %hash)
{
	print OT1 "Sequences similar to $k:\n";
	print OT1 "Subject\tIdentity\tAlignment Length\tAli start\tAli end\te-value\n\n";
	foreach my $e(@{$hash{$k}})
	{
		my @tm = split(/\t/,$e);
		print OT1 "$tm[0]\t$tm[1]\t\t$tm[2]\t$tm[5]\t$tm[6]\t$tm[9]\n";
	}
	print OT1 "\n";
}
print "Sequence Similarity Result has been saved to 'sequence_similarity.out'\n";
print "Complete alignments have been saved into 'all_alignment' file\n";
exit;
