#!/usr/bin/perl -w

use strict;
use warnings;

# get the directory you want to rename files from

my $num_args = $#ARGV + 1;

if ($num_args < 1) {
    print "\nUsage of script is 'rename-file.pl <directory>'\n";
    exit;
}

my $directory_name = $ARGV[0];
# stolen from http://perlmeme.org/faqs/file_io/directory_listing.html
opendir (DIR, $directory_name) or die $!;

print "Heres what I'm going to rename these files\n";

my @old_files = ();
my @new_files = ();


while (my $file = readdir(DIR)) {
    # perl gives you some dot files by default
    # thank you perl, its nice that you give me that option
    if ($file =~ m/^\./) {
        next;
    }

    push(@old_files, $file);
    (my $nice_file = $file ) =~ s/\ +\[Explicit\]//;
    push(@new_files, $nice_file);

    print $file . " --> " . $nice_file . "\n";
}

# make sure user is actually ok with this
# looking at you, drunk me
print "It cool if I do it now (y/n)?";

my $user_input = <STDIN>;
chomp($user_input);

if ("$user_input" ne "y" ){
    print "Alright then you do it, stupid human\n";
    print "I'm OUT!\n";
    exit 1;
}

# old files and new files should be same length
# but verify that now before you start doing crazy shit

my $num_old = scalar @old_files;
my $num_new = scalar @new_files;

if ($num_old ne $num_new) {
    print "Old file and new file names dont match\n";
    print "Some shit has seriously gone wrong, exiting\n";
    exit 1;
}

my $count = 0;

while ($count < $num_old ) {
    my $old_full_path = sprintf("%s/%s", $directory_name, $old_files[$count]);
    my $new_full_path = sprintf("%s/%s", $directory_name, $new_files[$count]);
    rename($old_full_path, $new_full_path);
    $count++;
}

closedir(DIR);
exit 0;
