use warnings;
#use strict;
#For 'predicted part'
# To put the links '|' and '_' in the same order.
open(FH,"$ARGV[0]/cycPred.out") || die "cant open the input: $ARGV[0]\n";
open(FH1,"$ARGV[0]/Pseq.txt") || die "cant open the input: tmpinput.seq\n";
#open(FH2,'true_xlinks.txt') || die "cant open the input: true_xlinks.txt\n";
#open(OT,">$ARGV[0]/gennewtmp.html") || die "cant open the output: gennewtmp.html\n";
my $inpseq = '';
while(<FH1>)
{
	chomp;
	my @tm = split(/\t/);
	$inputseq = $tm[1];
}
close(FH1);
$inputseq =~ s/\s+//g;
#print $ot  "$inputseq\n";
my $seq = '';
while(<FH>)
{
	chomp;
	if(/^<tr><td>/)
	{
		push(@dat,$_);
	}elsif(/<table width=/)
	{$seq = $_;}
}
close(FH);
my @dat1 = @dat;
my @bposf = ();
for(my $i=0; $i<scalar @dat; $i++)
{
        my @ar = split(/<\/td><td>/, $dat[$i]);
        #print $ot  "@ar","\n";
        #<STDIN>;
        my @bpos = ();
        for(my $j=0; $j<scalar @ar; $j++)
        {
                if($ar[$j] =~ /\|/)
                {push(@bpos, $j)}
        }
	my $bpl = join(":",@bpos);
        push(@bposf, $bpl);
}
#print $ot  "@bposf","<br>\n";
###Removing overlap Here######
@bposf=();
open(POSF,"$ARGV[0]/bposf") || die "Can't opn bposf";
while(<POSF>)
{
	chomp;
	my @tm = split(/\t/);
	push(@bposf,$tm[1]);
}
close(POSF);
#print $ot  "@bposf","<br>\n";
#system(`rm -f bposf`);
###############################
#open(OFF,">$ARGV[0]/gentmp.html") || die "cant open the output: \n";
my @bposff1= @bposf;
my %sorth = ();
my %sorth1 = ();
my %scount1 = ();
foreach my $b(@bposff1)
{
	my @tb = split(":", $b);
	$sorth{$b} = $tb[0];
	push(@{$sorth1{$tb[1]}},$b);
}
my @bposff = (sort {$sorth{$a} <=> $sorth{$b}} keys %sorth);
undef %sorth;
my $gntmpcount = 0;
my @labionin_s = ();
my @labionin_l = ();
my @ser_ser_lab = ();
foreach my $k(keys %sorth1)
{
#	print OFF "XX\t$k\t","@{$sorth1{$k}}","\n";
	my @tm =@{$sorth1{$k}};
	if(scalar(@tm)>=2)
	{
		my %th = ();
		foreach my $t(@tm)
		{
			my @t1 = split(/:/,$t);
			my $diff = $t1[1] - $t1[0];
			$th{$t} = $diff;
		}
		my @tmsorted = (sort {$th{$a} <=> $th{$b}} keys %th);
		#print OFF "@tmsorted","<br>\n";
		my @ser_xl1 = split(/:/,$tmsorted[0]);
		my @ser_xl2 = split(/:/,$tmsorted[1]);
		push(@ser_ser_lab,"$ser_xl2[0]:$ser_xl1[0]");
		push(@labionin_s,$tmsorted[0]);
		push(@labionin_l,$tmsorted[1]);
	}else
	{
		push(@labionin_s,$tm[0]);
		push(@labionin_l,$tm[0]);
	}
}
my %sorth_s = ();
my %sorth_l = ();
foreach my $b(@labionin_s)
{
	my @tb = split(":", $b);
	$sorth_s{$b} = $tb[0];
}
foreach my $b(@labionin_l)
{
	my @tb = split(":", $b);
	$sorth_l{$b} = $tb[0];
}
my @bposff_s = (sort {$sorth_s{$a} <=> $sorth_s{$b}} keys %sorth_s);
my @bposff_l = (sort {$sorth_l{$a} <=> $sorth_l{$b}} keys %sorth_l);
#@bposf = @bposff;
#print OFF "s ","@bposff_s","<br>\n";
#print OFF "l ","@bposff_l","\n";
#close(OFF);
my $bposff_l = join("#",@bposff_l);
my $bposff_s = join("#",@bposff_s);
my $fh_count = 0;
if($bposff_s eq $bposff_l)
{
	$fh_count++;
	my $file ="gennewtmp.html";
}else
{
	`rm -f $ARGV[0]/bposf`;
	$fh_count++;
	my $file ="gennewtmp_l.html";
	$fh_count++;
	$file ="gennewtmp_s.html";
	foreach my $a(@ser_ser_lab)
        {
                push(@bposff_s,$a);
        }
	my %sorth_s_tm = ();
	foreach my $b(@bposff_s)
	{
        	my @tb = split(":", $b);
        	$sorth_s_tm{$b} = $tb[0];
	}
	@bposff_s = (sort {$sorth_s_tm{$a} <=> $sorth_s_tm{$b}} keys %sorth_s_tm);
	undef %sorth_s_tm;
	#print OFF "<br>ss ","@bposff_s","<br>\n";
	open(BPOSFL,">$ARGV[0]/bposf_l");
	foreach my $a(@bposff_l)
	{
		print BPOSFL "test\t$a","\n";
	}
	close(BPOSFL);
	open(BPOSFS,">$ARGV[0]/bposf_s");
	foreach my $a(@bposff_s)
	{
		print BPOSFS "test\t$a","\n";
	}
	close(BPOSFS);
}
undef $bposff_l;
undef $bposff_s;
exit;

