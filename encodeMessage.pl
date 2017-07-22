#!/usr/bin/perl

# -----
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 July 20 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage(1): /usr/bin/perl /home/melick/enigma/encodeMessage.pl -p 'Red Stallion' -m 'Hello World' [-v] [-d]
# usage(1): /usr/bin/perl /home/melick/enigma/encodeMessage.pl --patrol 'Red Stallion' --message 'Hellow World' [--verbose] [--debug]


my $which_db = 'Enigma';

use warnings;
use strict;

use Date::Calc qw(:all);


# ----- input parameters
use Getopt::Long;
my $Patrol = '';
my $Message = '';
my $verbose;
my $debug;
GetOptions ("debug"   => \$debug,     # flag
            "patrol=s" => \$Patrol,   # string
            "start=s" => \$Message,   # string
            "verbose" => \$verbose)   # flag
or die("Error in command line arguments\n");
die("StartDate is not defined.\n") if ( ! $Message );
die("Patrol is not defined.\n") if ( ! $Patrol );


# ----- database handle
use lib '/home/melick/perl5/lib/perl5';
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
printf "dbh: [%s]\n", $dbh if $debug;


# ----------------------------------------------------------------------
# get setting for the day
# ----------------------------------------------------------------------
my $query = "SELECT AES_DECRYPT(`Umkehrwalze`,@key)
     , AES_DECRYPT(`Walzenlage1`,@key)
     , AES_DECRYPT(`Walzenlage2`,@key)
     , AES_DECRYPT(`Walzenlage3`,@key)
     , AES_DECRYPT(`Walzenlage4`,@key)
     , AES_DECRYPT(`Ringstellung`,@key)
     , AES_DECRYPT(`Grundstellung`,@key)
     , AES_DECRYPT(`Steckerverbindungen`,@key)
     , AES_DECRYPT(`Kenngruppen`,@key)
  FROM `CodeBook`
 WHERE AES_DECRYPT(`Patrol`,@key) = '" . $Patrol . "'
  AND `date` = '" . $date . "';";

printf "query: [%s]\n", $query if $debug;
my $sth = $dbh->prepare($query);
$sth->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
$sth->finish();



# ----------------------------------------------------------------------
# store message in database -- http://thinkdiff.net/mysql/encrypt-mysql-data-using-aes-techniques/
# ----------------------------------------------------------------------
my $return_value = 0;
my $query = "INSERT INTO `CodeBook` (`Patrol`, `date`, `Umkehrwalze`, `Walzenlage1`, `Walzenlage2`, `Walzenlage3`, `Walzenlage4`, `Ringstellung`, `Grundstellung`, `Steckerverbindungen`, `Kenngruppen`, `Revision`, `LastUpdate`) VALUES (
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



}

$dbh->disconnect;



# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut
