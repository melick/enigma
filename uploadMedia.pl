#!/usr/bin/perl

# -----
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 July 13 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage(1): /usr/bin/perl /home/melick/enigma/uploadMedia.pl -f '/home/melick/enigma/CodeBook-RS-2017-07.pdf' [-v] [-d]
# usage(1): /usr/bin/perl /home/melick/enigma/uploadMedia.pl --file '/home/melick/enigma/CodeBook-RS-2017-07.pdf' [--verbose] [--debug]

use warnings;
use strict;


# ----- input parameters
use Getopt::Long;
my $File = '';
my $verbose;
my $debug;
GetOptions ("debug"   => \$debug,     # flag
            "file=s"  => \$File,      # string
            "verbose" => \$verbose)   # flag
or die("Error in command line arguments\n");
die("File is not defined.\n") if ( ! $File );


# ----- http://perltricks.com/article/29/2013/9/17/How-to-Load-YAML-Config-Files/
use YAML::XS 'LoadFile';
our $config = LoadFile('config.yaml');
our $username         = $config->{username};
our $password         = $config->{password};
our $proxy            = $config->{proxy};
our $server_time_zone = $config->{server_time_zone};
printf "u:%s, p:%s, pr:%s,stz:%s.\n", $username, $password, $proxy, $server_time_zone if $debug;

# ----- check the vars
unless ($username && $password && $proxy && $server_time_zone) {
  die 'Required Wordpress API Env vars are not all defined';
}


# ----------------------------------------------------------------------
# connect to the blog
# ----------------------------------------------------------------------
use WP::API;
my $api = WP::API->new(
    username         => $username,
    password         => $password,
    proxy            => $proxy,
    server_time_zone => $server_time_zone,
);


=begin GHOSTCODE
# ----------------------------------------------------------------------
# upload to wordpress blog
# ----------------------------------------------------------------------
use File::Slurp qw( read_file );
 
my $content = read_file($File);
 
my $media = $api->media()->create(
    name      => 'test.pdf',
    type      => 'application/pdf',
    bits      => $content,
    overwrite => 1,
);
 
print $media->date_created_gmt()->date();
=end GHOSTCODE
=cut



# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut


