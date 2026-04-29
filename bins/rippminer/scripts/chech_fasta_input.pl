use warnings;
open(FH,"$ARGV[0]/cyclizationInput.fasta") || die "cant open cyclizationInput1.fasta\n";
my @seq = ();
my $flag=0;
while(<FH>)
{
	chomp;
	if(/^>/){next}
	push(@seq,$_);
}
close(FH);
system(`rm -f $ARGV[0]/cyclizationInput.fasta`);
open(OT,">$ARGV[0]/cyclizationInput.fasta") || die "cant open cyclizationInput.fasta\n";
my $seq = join('',@seq);
$seq =~ s/\n+//g;
$seq =~ s/\s+//g;
$seq = uc $seq;
print OT "$seq";
close(OT);
open(OT1,">$ARGV[0]/cyclizationInput1.fasta") || die "cant open cyclizationInput.fasta\n";
#my $seq1 = join('',@seq);
print OT1 ">test\n";
print OT1 "$seq";
close(OT1);
exit;
