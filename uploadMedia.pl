#!/usr/bin/perl

# -----
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 July 13 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage(1): /usr/bin/perl /home/melick/enigma/uploadMedia.pl -f '' [-v] [-d]
# usage(1): /usr/bin/perl /home/melick/enigma/uploadMedia.pl --file '' [--verbose] [--debug]


my $which_db = 'Enigma';

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


# ----- database handle
use lib '/home/melick/perl5/lib/perl5';
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
printf "dbh: [%s]\n", $dbh if $debug;


# ----- http://perltricks.com/article/29/2013/9/17/How-to-Load-YAML-Config-Files/
use YAML::XS 'LoadFile';
our $config = LoadFile('config.yaml');
our $username         = $config->{username};
our $password         = $config->{password};
our $proxy            = $config->{proxy};
our $server_time_zone = $config->{server_time_zone};

# ----- check the vars
unless ($username && $password && $proxy && $server_time_zone) {
  die 'Required Wordpress API Env vars are not all defined';
}


# ----------------------------------------------------------------------
# connect to the blog
# ----------------------------------------------------------------------

my $api = WP::API->new(
    username         => $username,
    password         => $password,
    proxy            => $proxy,
    server_time_zone => $server_time_zone,
);


=begin GHOSTCODE
# ----------------------------------------------------------------------
# remove old entry
# ----------------------------------------------------------------------
my $delete_query = "DELETE FROM `Media` WHERE `date` = '" . $date . "' AND AES_DECRYPT(`CodeBook`,UNHEX(SHA2('" . $Patrol . "',512))) = '" . $Patrol . "';";
printf "delete_query: [%s]\n", $delete_query if $debug;
my $sth_d = $dbh->prepare($delete_query);
$sth_d->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
$sth_d->finish();

# ----------------------------------------------------------------------
# store in database -- http://thinkdiff.net/mysql/encrypt-mysql-data-using-aes-techniques/
# ----------------------------------------------------------------------
my $return_value = 0;
my $query = "INSERT INTO `CodeBook` (`CodeBook`, `date`, `Umkehrwalze`, `Walzenlage1`, `Walzenlage2`, `Walzenlage3`, `Walzenlage4`, `Ringstellung`, `Grundstellung`, `Steckerverbindungen`, `Kenngruppen`, `Revision`, `LastUpdate`) VALUES (
        AES_ENCRYPT('" . $Patrol . "', UNHEX(SHA2('" . $Patrol . "',512))),
        '" . $date . "',
        AES_ENCRYPT('" . $Umkehrwalze . "', UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Walzenlage[0] . "', UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Walzenlage[1] . "', UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Walzenlage[2] . "', UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Walzenlage[3] . "', UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Ringstellung . "', UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Grundstellung . "',UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Steckerverbindungen . "',UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Kenngruppen . "',UNHEX(SHA2('" . $Patrol . "',512))),
        AES_ENCRYPT('" . $Revision . "',UNHEX(SHA2('" . $Patrol . "',512))),
        NOW());";
printf "query: [%s]\n", $query if $debug;
my $sth = $dbh->prepare($query);
$sth->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
$sth->finish();
warn "ERROR: record insert terminated early by error: $DBI::errstr\n" if $DBI::err;
$dbh->disconnect;
=end GHOSTCODE
=cut



# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut


=begin GHOSTCODE
# ----------------------------------------------------------------------
# upload to wordpress blog
# ----------------------------------------------------------------------
use File::Slurp qw( read_file );
 
my $content = read_file('path/to/file.jpg');
 
my $media = $api->media()->create(
    name      => 'foo.jpg',
    type      => 'image/jpeg',
    bits      => $content,
    overwrite => 1,
);
 
print $media->date_created_gmt()->date();
=end GHOSTCODE
=cut