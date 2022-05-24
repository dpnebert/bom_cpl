#!/usr/local/bin/perl -w
#
# Reformat data coming from EAGLE going to JLCPCB
#
use warnings;
use strict;

if (scalar(@ARGV) != 2) {
 print "usage: bom.pl project_name full_path\n";
 
 print "example: bom.pl v1r19 \"C:\\Users\\dpneb\\Documents\\EAGLE\\projects\\LED Planet\\LED Planet\\v1r19\\CAMOutputs\\Assembly\"\n";
 exit;
}
my $project = $ARGV[0];
my $full_path = $ARGV[1];

print "\nProject: \"$full_path\"\n";
print "\nProject Location: \"$full_path\"\n";


my $filename;
opendir ( DIR, $full_path ) || die "Error in opening dir $full_path\n";
while($filename = readdir(DIR)) {
   next if -d $filename;
   if($filename eq ("PnP_$project"."_front.csv")) {
		print("Current File: $filename\n");
		print("Current Path: $full_path\\$filename\n");		
	
		my @designators = ();
		my @minXs = ();
		my @minYs = ();
		my @rotations = ();
		
		open(FH, '<', $full_path . '\\' . $filename) or die $!;
		my @lines = <FH>;
		close(FH);
		
		foreach my $line (@lines) {
			chomp($line);
			my @columns = split(',', $line);
			
			push(@designators, $columns[0]);
			push(@minXs, $columns[1]);
			push(@minYs, $columns[2]);
			push(@rotations, $columns[3]);
		}
		
		
		my $output_path = $full_path . '\\' . "JLCPCB_".$filename;
		print "Writing to output file:" . $output_path . "\n";
		open(FH, '>', $output_path) or die $!;
		print FH "Designator,Mid X,Mid Y,Layer,Rotation\n";
		for(my $i = 0; $i < scalar(@designators); $i++) {
			print FH $designators[$i].",".$minXs[$i].",".$minYs[$i].",Top,".$rotations[$i]."\n";
		}
		close(FH);
		
		
		
   } elsif($filename eq "$project.csv") {
		print("Current File: $filename\n");
		print("Current Path: $full_path\\$filename\n");		
	
		open(FH, '<', $full_path . '\\' . $filename) or die $!;
		my @lines = <FH>;
		shift(@lines);
		close(FH);		
		
		my @output = ();
		foreach my $line (@lines) {
			chomp($line);
			my @columns = split(',', $line);
			my $out = "";
			if($columns[1] eq '') {
				$out = "0,";
			} else {
				$out = $columns[1].",";
			}
			for(my $i = 0; $i < $columns[0]; $i++) {
				my $str = $columns[4+$i];
				$str =~ s/^\s+|\s+$//g;
				$out .= $str;
				if($i < ($columns[0] - 1)) { $out .= "|"; }
			}
			$out .= ",".$columns[3];
			
			push(@output, $out);
		}
		my $output_path = $full_path . '\\' . "JLCPCB_BOM_".$filename;
		print "Writing to output file:" . $output_path . "\n";
		open(FH, '>', $output_path) or die $!;
		print FH "Comment,Designator,Footprint\n";
		foreach my $out (@output) {
			print FH $out."\n";
		}
		close(FH);
		
		
		
		
	   
   }
}
closedir(DIR);

