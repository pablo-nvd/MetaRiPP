use warnings;
use Getopt::Long qw(GetOptions);
my $Path_to_openbabel_bin = '';	#Put the Path to Openbabel's bin directory in the file path .('~user/openbabel/bin').
`rm -rf structure_search.out`;
`rm -rf all_smiles.out`;
open(PATH,"path") || die "File 'path' not found\n";
while(<PATH>)
{
        chomp;
        if(/^Openbabel/i)
        {
                s/^Openbabel=//i;
                s/'//g;
                $Path_to_openbabel_bin =$_;
        }
}
close(PATH);
open(OT1,">structure_search.out") || die "Can't write to structure_search.out\n";
if($Path_to_openbabel_bin eq '')
{
	die "Path to Openbabel bin directory not provided\nRead the Documentation!\n";
}
$Path_to_openbabel_bin =~ s/\/$//;
my $input = '';
my $cut = 10;
my $tani=0;
my $help ='';
#Exception Handling

GetOptions('i=s' => \$input, 'top=s' => \$cut, 'tanimoto=s' => \$tani, 'h=s' => \$help) or die "Usage: perl $0 -i smiles_input_file\nRun 'perl $0 -h help' for more!\n";
my $hits = '';
if($input eq '' and $help eq '')
{
	print "Input ('-i') not provided\n";
	die "Run 'perl $0 -h help' for more!\n";
}elsif($help eq 'help')
{
	print "Usage: perl $0 -i smiles_input_file\n\n";
	print "Following arguments can be passed to the program\n";
	print "-i\t\tProvide Input file in smiles format.\n";
	print "-top NUM\tOutput NUM Most similar Molecules. (NUM is an Integer)\n";
	print "-tanimoto NUM\tOutput Molecules with Tanimoto score greater than NUM (0<NUM<=1).\n";
	die "-h help\t\tShows this help.!\n\n";
}
#Parameters Checking
if($cut !~ /^\d+$/)
{
	die "Argument 'outputnumber' must be an integer value!\n";
}elsif($tani > 1)
{
	die "Argument 'tanimotocutoff' must be <=1!\n";
}
##Main Program
open(SMILES,"DB/smiles_data") || die "Can't Find 'DB/smiles_data'\n";
open(OUT2,">all_smiles.out") || die "Can't write to 'all_smiles.out'\n";
my %smilesh = ();
while(<SMILES>)
{
	chomp;
	my @tm = split(/,/);
	$smilesh{$tm[1]} = "$tm[0]:$tm[2]";
}
close(SMILES);
if($cut!=0)
{
    $hits =`$Path_to_openbabel_bin/obabel $input DB/allmol_pri.sdf -ofpt -xfFP4 | sort -r -t "=" --key=2 | head -$cut`;
}elsif ($tani!=0)
{ 
    $hits =`$Path_to_openbabel_bin/obabel $input DB/allmol_pri.sdf -ofpt -xfFP4 | sort -r -t "=" --key=2 | awk -F'=' '{if (\$2 > $tani) print}'`;
}
my @hits_spl = split (/\n/, $hits);
chomp @hits_spl;
#$smi_name= ucfirst($smi_name);
my @all_hits;
my $count =0;
my @output = ();
foreach my $hits_spl (@hits_spl)
{
	if ($hits_spl =~ /Tanimoto from/)
	{
		$count++;
		my @spl_spl = split (/\s+Tanimoto from .* =\s+/, $hits_spl);
		$spl_spl[0] =~ s/.smiles.*$//;
		$spl_spl[0] =~ s/^>//;
		my $link = $spl_spl[0];
		my $link1 = $link;
		$link1 =~ s/@/ /g;
		$link1 = ucfirst($link1);
		my @row = ("$count","\t","$link1","\t", "$spl_spl[1]");
		my $row = join("",@row);
		#print "$row","\n";
		push(@output, $row);
	}
}
if($count==0)
{
	die "No match was found!\n";
}else
{
	print OT1 "S.No.\tRiPP\tTanimoto score\n";
	foreach my $ot(@output)
	{
		my @tm = split(/\t/,$ot);
		if(exists $smilesh{$tm[1]})
		{
			my @val = split(/:/, $smilesh{$tm[1]});
			print OUT2 "$tm[1]\t$val[0]\n$val[1]\n";
		}
		print OT1 "$ot\n";
	}
}
close(OT1);
close(OUT2);
print "List of Top matches have been saved to 'structure_search.out'\n";
print "SMILES Information of Top matches has been saved to 'all_smiles.out'\n";

exit;
