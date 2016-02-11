#!/usr/bin/perl -w

use strict;
use warnings;
use Digest::MD5  qw(md5_hex);

my $num_args = $#ARGV + 1;

if ($num_args < 1) {
    print "Usage of script is 'check-duplicates.pl <directory>'\n";
    exit;
}

my $directory_name = $ARGV[0];

sub directory_files {
    my($directory_name) = @_;
    opendir(DIR, $directory_name);
    my @files = sort(grep { !/^\.|\.\.}$/ } readdir(DIR));
    closedir(DIR);
    return @files;
}

my @files = directory_files($directory_name);

if ($directory_name eq "."){
    $directory_name = ""
}

my @file_names = ();
my @file_hashes = ();

my $count;

sub check_directory {
    my($dir_files_ref, $dir_prefix) = @_;
    my @dir_files = @$dir_files_ref;
    my @names = ();
    my @hashes = ();
    foreach my $file_name (@dir_files) {
        my $better_name = "${dir_prefix}${file_name}";
        # check for directory
        if ( -d $better_name){
            my @dir_files = directory_files($better_name);
            my($sub_name, $sub_hash) = check_directory(\@dir_files, "${better_name}/");
            push(@names, @$sub_name);
            push(@hashes, @$sub_hash);
            next;
        }
        open(my $FILE, $better_name);
        binmode($FILE);
        my $hash = Digest::MD5->new->addfile($FILE)->hexdigest;
        close($FILE);

        # check if hash already exists somewhere
        $count = scalar @hashes - 1;
        while ($count > 0){
            if ($hash eq $hashes[$count]){
                print "Found redudant files --> $names[$count] and $better_name\n";
            }
            $count--;
        }
        push(@names, $better_name);
        push(@hashes, $hash);
    }
    return (\@names, \@hashes);
}

my ($name_ref, $hash_ref) = check_directory(\@files, $directory_name);

exit 0;
