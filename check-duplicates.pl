#!/usr/bin/perl -w
# Usage of script
# check-duplicates.pl <directory> [<log_file>]

# Check for file duplicates using MD5 checksum

use strict;
use warnings;
use Digest::MD5  qw(md5_hex);
use File::Spec;

# Check arguments
# Get full path of dir name given
my $num_args = $#ARGV + 1;
if ($num_args < 1) {
    print "Usage of script is 'check-duplicates.pl <directory>'\n";
    exit;
}
my $dir_name = $ARGV[0];
$dir_name = File::Spec->rel2abs($dir_name);
my @item_list = directory_files($dir_name);

# Set correct log file
my $log_file = "file-log.txt";
if ($num_args == 2){
    $log_file = $ARGV[1];
}
unlink $log_file;

# Get directory file list
# One argument : directory_name
sub directory_files {
    my($directory_name) = @_;
    opendir(DIR, $directory_name);
    my @files = sort(grep { !/^\.|\.\.}$/ } readdir(DIR));
    closedir(DIR);
    return @files;
}

# Iterate through each file in directory
# Use recursion for additional subdirs
# Write all checksums and file names to dir
# Takes one argument: dir_name
sub check_directory {
    my($dir_name) = @_;
    my @item_list = directory_files($dir_name);
    # Get current item list ( item meaning file or dir )
    # .. and go through each one
    foreach my $item_name (@item_list){
        # Use full file path
        my $full_path = "${dir_name}/${item_name}";
        # Check if path is a directory
        if ( -d $full_path ){
            check_directory($full_path);
        }
        else {
            # Get MD5 hash for file
            open(my $FILE, $full_path);
            binmode($FILE);
            my $hash = Digest::MD5->new->addfile($FILE)->hexdigest;
            close($FILE);
            # Write checksum and full path into a file
            open(my $fh, '>>', $log_file);
            print $fh "$hash\t$full_path\n";
            close $fh;
        }
    }
}

check_directory($dir_name);
print "Files located and hashed\n";

# Create hash table of arrays from file
# .. {"<checksum>" : ["file name", "file name 2"]}
my %checksum_hash;
open(my $FILE, $log_file);
while(my $line = <$FILE>){
    my @line_split = split("\t", $line);
    if ( !$checksum_hash{$line_split[0]} ){
        $checksum_hash{$line_split[0]} = [];
    }
    chomp $line_split[1];
    push(@{$checksum_hash{$line_split[0]}}, $line_split[1]);
}
close($FILE);

# Now go through hash table and print out entries with
# .. array lists greater than 1 item
foreach my $key (keys %checksum_hash){
    my $row_reference = $checksum_hash{$key};
    my @row_array = @$row_reference;
    my $row_length = $#row_array + 1;
    if ( $row_length > 1 ){
        print "++++++++++++++++++++++++++++++\n";
        print "Found duplicates\n";
        foreach my $column (@row_array){
            print "$column\n";
        }
        print "++++++++++++++++++++++++++++++\n";
    }
}
exit 0;
