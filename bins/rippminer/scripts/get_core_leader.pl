#!/usr/bin/perl
($file,$user)=@ARGV; #test_file
open (FL,"$file")||die("cant open");
@input=<FL>;
foreach $input(@input)
{
 chomp $input;
 open (PL,">$user/protein_test");
 @seq1=();@seq1=split(//,$input);
 for $k(0..(@seq1-1))
 {
  @random=();
  for $l($k..($k+11))
  { push @random,$seq1[$l] if $seq1[$l];}
  $ran=@random;
  if ($ran == 12)
  {
   print PL  @random;
   print PL "\n";
  }
 }
close PL;
}
close FL;
$aa="ACDEFGHIKLMNPQRSTVWY";
@freq=();
@freq=split(//,$aa);$k=@freq;
open (EL,"$user/protein_test");
open (OL,">$user/protein_test.encoded");
@input1=<EL>;
foreach $input1(@input1)
{
 chomp $input1;
 print OL "0 ";
 @freq1=();
 @freq1=split(//,$input1);$s=@freq1;
 $k=1;
 for $c(0..($s-1))
 {
  chomp $freq1[$c];#print "$freq1[$c]:\n";
  foreach $freq(@freq)
  {
   #print "$freq";
   if ($freq1[$c] =~/$freq/)
   {
    print OL "$k:1 ";
   }
   else {print OL "$k:0 ";}
   $k++;
  }
 }
 print OL "\n";
}
close EL;
close OL;
`./scripts/svm_classify $user/protein_test.encoded scripts/svm_model_svml_loo_final $user/protein_test.predictions`;

open (WL,"$user/protein_test.predictions")||die ("protein_test.predictions not there");
@score=<WL>;;
open (TL,"$user/protein_test")||die ("protein_test not there");
@label=<TL>;
open (QL,"> $user/protein_test.predictions.peptide");
$k=0;
foreach $label(@label)
{
 chomp $label;
 chomp $score[$k];
 print QL "$label,$score[$k]\n";
 $k++;
}
close WL;close TL; close QL;
$high_rank=`sort -t"," -n -k 2 -r $user/protein_test.predictions.peptide |head -1`;chomp $high_rank;
#print $high_rank;
@high=();@high=split(/,/,$high_rank);
$rounded = sprintf("%.2f", $high[1]);
@cleavage=();@cleavage=split(//,$high[0]);
print "Cleavage site (12-mer): ";
for $cleav(0..5){print "$cleavage[$cleav]";}
print "-";
for $cleav(6..11){print "$cleavage[$cleav]";}
print "\n";
print "score: $rounded\n";
@inp=();@inp=split(//,$input[0]);
$k=0;
for $i(0..(@inp-1))
{
 if ("$inp[$i]$inp[$i+1]$inp[$i+2]$inp[$i+3]$inp[$i+4]$inp[$i+5]$inp[$i+6]$inp[$i+7]$inp[$i+8]$inp[$i+9]$inp[$i+10]$inp[$i+11]"=~/^$high[0]$/)
 {
  $k=$i+5 ;
 }
}
@comp_seq1=();@comp_seq2=();
for $i(0..$k)
{
  push @comp_seq1,$inp[$i];
}
for $i(($k+1)..(@inp-1))
{
  push @comp_seq2,$inp[$i];
  
}
$comp1=join ('',@comp_seq1);
$comp2=join('',@comp_seq2);
print "Seq: $comp1-$comp2\n";
print "Leader peptide: $comp1\n";
print "Core peptide: $comp2\n";
