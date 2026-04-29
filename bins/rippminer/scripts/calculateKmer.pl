use warnings;
system(`rm -f kmerlist`);
#file xlinksgenereated.
open(OT, ">$ARGV[2]/kmerlist") || die "can not write to kmerlist\n";
open(OT1, ">$ARGV[2]/freqfile") || die "can not write to freqfile\n";
open(FH11,"$ARGV[2]/Pseq.txt") || die "can not read Pseq.txt\n";
unless(scalar(@ARGV) >=2 and $ARGV[1] =~ /\d/)
{die "Correct syntax : 'perl calculateKmer.pl Fasta_file kmerlength' \n"}
my $kmer = $ARGV[1];
#my $nuclist = 'A,C,G,T';
my $nuclist  = 'A,C,D,E,F,G,H,I,K,L,M,N,P,Q,R,S,T,V,W,Y';
my $temp = "{$nuclist}";
my @ary = ();
while(<FH11>)
{
	chomp;
	my @tt = split(/\t/);
	my @t1 = split(/\s+/,$tt[0]);
	#$Pseqhash{$t1[0]} = $tt[1];
}
close(FH11);
for(my $i=1; $i<=$kmer; $i++)
{
	push(@ary, $temp);
}
my $kmergen = join('',@ary);
undef @ary;
my @many = glob "$kmergen";
foreach my $aa(@many)
{print OT "$aa\n"}
close(OT);
my $normf = scalar @many;
#print STDERR "#Kmers written to file 'kmerlist'; calculating frequencies(Length Normalized; rouneded off to 5th digit)\n";
undef $kmergen;
open(FH, "$ARGV[2]/$ARGV[0]") || die "no fasta-sequence(s) file was provided\n";
my $data = '';
while(<FH>){$data .=$_}
my @seqs = split(/>/, $data);
undef $data;
shift @seqs;
foreach my $data(@seqs)
{
	my @seq = split(/\n/, $data);
	my $header = shift @seq;
	my @tmp = split(/\s+/, $header);
	my $colname = $tmp[0];
	my $seq = join('',@seq);
	$seq =~ s/\s+//g;
	undef $header;
	undef  @tmp;
	undef  @seq;
	$seqh{$colname} = $seq;
	#print "$colname\t",length $seq,"\n";
}
undef @seqs;
foreach my $kmerseq(@many) #foreach kmer
{
	foreach my $k(keys %seqh)	#foreach sequence
	{
		my $count =0;
		my $seq = $seqh{$k};
		for(my $i=0; $i<length($seq)-$kmer+1; $i++)
		{
                	my $substr = substr($seq, $i, $kmer);
                	if($kmerseq eq $substr)
                	{$count++}
                }
		push(@{$counth{$kmerseq}},"$k#$count");
	}
}

undef @many;
my $c=0;
my %hashnw = ();
foreach my $k(sort keys %counth)	#foreach K-mer
{
	#print "$k\t";
	#<STDIN>;
	my @ary = sort @{$counth{$k}};
	#print "@ary","\n";
	#<STDIN>;
	foreach my $e(@ary)
	{
		my @tmp = split('#', $e);
		#push(@{$totch{$tmp[0]}},$tmp[1]);
		my $kk = $tmp[0];
		$kk =~ s/\*//g;
		my @tmkk = split(/_/, $kk);
		#print "aa\t$tmp[0]\t$Pseqhash{$tmkk[1]}\n";
		$kk = '';
		shift @tmkk;
		$kk = join("_",@tmkk);
		#print "$tmp[0]\t$seqh{$tmp[0]}\n";
		#<STDIN>;
		my $lnorscore = $tmp[1]/(length($seqh{$tmp[0]}) - (length($k)-1));
		#my $lnorscore = $tmp[1]/length($seqh{$tmp[0]});
		#my $lnorscore = $tmp[1];
		undef $kk;
		undef @tmkk;
		#$lnorscore = $tmp[1];
		$lnorscore = sprintf ("%.5f", "$lnorscore");
		#push(@{$hashnw{$tmp[0]}}, "$lnorscore#$k");
		push(@{$hashnw{$tmp[0]}}, "$lnorscore#$k");
		push(@{$hashnw1{$tmp[0]}}, "$tmp[1]#$k");
	}
	#print "\n";
}
undef %counth;
$c=0;
foreach my $k(sort keys %hashnw)
{
	$c++;
	if($c==1)
	{
        	print "#SEQUENCE\t";
		print OT1 "#SEQUENCE\t";
        	foreach my $a(@{$hashnw{$k}})
        	{
       	        	my @tt = split(/#/, $a);
        	        print "$tt[1]\t";
        	}
		foreach my $a(@{$hashnw1{$k}})
                {
                        my @tt = split(/#/, $a);
                        print OT1 "$tt[1]\t";
                }
        	print "\n";
		print OT1 "\n";
	}else{goto outhere}
}
outhere:
foreach my $k(sort keys %hashnw)
{
	print "$k\t";
	print OT1 "$k\t";
	foreach my $a(@{$hashnw{$k}})
	{
		my @tt = split(/#/, $a);
		print "$tt[0]\t";
	}
	foreach my $a(@{$hashnw1{$k}})
        {
                my @tt = split(/#/, $a);
                print OT1 "$a\t";
        }
	print OT1 "\n";
	print "\n";
}
close(OT1);
exit;
