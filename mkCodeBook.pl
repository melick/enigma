#!/usr/bin/perl

# -----
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 June 16 - LOMelick - moved to GitHub and updated for Raspberry Pi Zero W
#                   - 2015 March 23 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage(1): /usr/bin/perl /home/melick/enigma/mkCodeBook.pl -s '2014-09-01' [-d] [-v]

my $which_db = 'Enigma';

use warnings;
use strict;

use Bytes::Random::Secure qw(random_string_from);
use Roman;
use List::Util qw/shuffle/;
use Date::Calc qw(:all);
use Text::Banner;


# ----- input parameters
use Getopt::Long;
my $StartDate = '';
my $verbose;
my $debug;
GetOptions ("debug"   => \$debug,     # flag
            "start=s" => \$StartDate, # string
            "verbose" => \$verbose)   # flag
or die("Error in command line arguments\n");
if !(defined($StartDate)) { die("Missing required StartDate [-s or --start]") };


# ----- handle the date variable
printf "my StartDate is: %s.\n", $StartDate;
my ($year, $month, $day_of_month) = split('-', $StartDate);
printf "y:%s, m:%s, d:%s.\n", $year, $month, $day_of_month if $debug;
my @months = ('', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
my $num_days = Days_in_Month($year,$month);
printf "numdays:%s.\n", $num_days if $debug;


# ----- database handle
use lib '/home/melick/perl5/lib/perl5';
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
#printf "dbh: [%s]\n", $dbh;


# ----- basic info
my $network = 'Red Stallion';


# ----------------------------------------------------------------------
# ----- set up the rotor set.  Max Rotor could be passed in (5 or 8)
# ----------------------------------------------------------------------
my $max_rotor = 8;  # Enigmas had 3, 5 or 8 available
my $num_rotors = 3; # Enigmas could have 3 (M1, M2 and M3) or 4 (M4) rotors installed for operation.


# ----- set up list if letters for number to letter conversion
my @letters = 'A' .. 'Z';
printf "letters:%s.\n", @letters;


# ----------------------------------------------------------------------
# ----- print header
# ----------------------------------------------------------------------
#$network = ' ' . $network;
$a = Text::Banner->new;
$a->set($network);
$a->size(1);
$a->fill('*');
$a->rotate('h');
print $a->get;
printf "        %04d %s\n\n", $year, $months[$month];
printf "-----------+---+---------------------+-----+-----+-------------------------------------+----------------\n";
printf "    Day    |UKW|     Walzenlage      |Ring |Grund| Steckerverbindungen                 | Kenngruppen    \n";
printf "-----------+---+---------------------+-----+-----+-------------------------------------+----------------\n";


# ----------------------------------------------------------------------
# ----- make table
# ----------------------------------------------------------------------
for (my $day=$num_days; $day >= 1; $day--) {

    # ----------------------------------------------------------------------
    # date
    # ----------------------------------------------------------------------
    my $date = $year . '-' . $month . '-' . $day;
    printf "date:%s\n", $date if $debug;

    # ----------------------------------------------------------------------
    # pick random reflector - app has B, C, B (Thin) and C (thin).  I'm only doing B & C
    # ----------------------------------------------------------------------
    my $Umkehrwalze = random_string_from('BC',1);
    printf "Umkehrwalze:%s\n", $Umkehrwalze if $debug;


    # ----------------------------------------------------------------------
    # rotors
    # ----------------------------------------------------------------------
    my @Rotors;
    for (my $r=1; $r <= $max_rotor; $r++) {
        push @Rotors, Roman($r);
    }

    # Shuffled list of indexes into @deck
    my @shuffled_indexes = shuffle(0..$#Rotors);

    # Get just N of them.
    my @pick_indexes = @shuffled_indexes[ 0 .. $num_rotors ];

    # Pick cards from @deck
    my @Walzenlage = @Rotors[ @pick_indexes ];
    printf 'Walzenlage ' . @Walzenlage if $debug;


    # ----------------------------------------------------------------------
    # pick ring settings
    # ----------------------------------------------------------------------
    my $Ringstellung;
    if ($num_rotors == 3) {
        $Ringstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    } else {
        $Ringstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    }
    printf "Ringstellung:%s\n", $Ringstellung if $debug;


    # ----------------------------------------------------------------------
    # pick starting positions
    # ----------------------------------------------------------------------
    my $Grundstellung;
    if ($num_rotors == 3) {
        $Grundstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    } else {
        $Grundstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    }
    printf "Grundstellung:%s\n", $Grundstellung if $debug;

    # ----------------------------------------------------------------------
    # ----- set up the plugs set.  This is number of terminations.  a -> b = 2 connections.  Normal usage uses 10 connectors, or 20 connections
    # ----------------------------------------------------------------------
    my $max_plug = 2 * int rand(12);

    # pick plug combinations
    my @Plugs;
    for (my $p=0; $p < 26; $p++) {
        push @Plugs, $letters[$p];
    }

    # Shuffled list of indexes into @deck
    my @shuffled_plug_indexes = shuffle(0..$#Plugs);

    # Get just N of them.
    my @pick_plug_indexes = @shuffled_plug_indexes[ 0 .. $max_plug + 1 ];

    # Pick cards from @deck
    my @negnudnibrevrekcetS = @Plugs[ @pick_plug_indexes ];
    for (my $s=$max_plug; $s < 24; $s++) {
        push @negnudnibrevrekcetS, '.';
    }
    my @Steckerverbindungen = reverse @negnudnibrevrekcetS;
    printf 'Steckerverbindungen: ' . @Steckerverbindungen if $debug;


    # ----------------------------------------------------------------------
    # Kenngruppen
    # ----------------------------------------------------------------------
    my $Kenngruppen = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . ' ' . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . ' ' . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . ' ' . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    printf "Kenngruppen:%s\n", $Kenngruppen if $debug;


    # ----------------------------------------------------------------------
    # store in database -- http://thinkdiff.net/mysql/encrypt-mysql-data-using-aes-techniques/
    # ----------------------------------------------------------------------
    my $return_value = 0;
    #SET key = UNHEX(SHA2('" . $network . "',512));
    my $query = "INSERT INTO `CodeBook` (`CodeBook`, `date`, `Umkehrwalze`, `Walzenlage1`, `Walzenlage2`, `Walzenlage3`, `Walzenlage4`, `Ringstellung`, `Grundstellung`, `Steckerverbindungen`, `Kenngruppen`, `Revision`, `LastUpdate`) VALUES (
        AES_ENCRYPT(" . $network . ",key),
        NOW()
    )";
    printf "query: [%s]\n", $query if $debug;
    my $sth = $dbh->prepare($query);
=begin GHOSTCODE
    $sth->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
    while (my $ref = $sth->fetchrow_hashref()) {
        $return_value = $ref->{'numObjects'};
    }
=end GHOSTCODE
=cut
    $sth->finish();
    warn "dbLib ERROR: view check in dbLib terminated early by error: $DBI::errstr\n" if $DBI::err;

=begin GHOSTCODE
    # ----------------------------------------------------------------------
    # print out settings
    # ----------------------------------------------------------------------
    if ($num_rotors == 3) {
        printf "%04d-%02d-%02d | %s |   %4s %4s %4s    | %3s | %3s | %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
    } else {
        printf "%04d-%02d-%02d | %s | %4s %4s %4s %4s  | %4s | %4s | %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
    }
=end GHOSTCODE
=cut

}

=begin GHOSTCODE
#printf "-----------+---+---------------------+-----+-----+----------------------------------------+-------------\n";
=end GHOSTCODE
=cut

$dbh->close;


# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
    my $query = "INSERT INTO `CodeBook` (`CodeBook`, `date`, `Umkehrwalze`, `Walzenlage1`, `Walzenlage2`, `Walzenlage3`, `Walzenlage4`, `Ringstellung`, `Grundstellung`, `Steckerverbindungen`, `Kenngruppen`, `Revision`, `LastUpdate`) VALUES (
        AES_ENCRYPT(" . $network . ",key),
        '" . $date . "',
        AES_ENCRYPT(" . $Umkehrwalze . ",key),
        AES_ENCRYPT(" . $Walzenlage[0] . ",key),
        AES_ENCRYPT(" . $Walzenlage[1] . ",key),
        AES_ENCRYPT(" . $Walzenlage[2] . ",key),
        AES_ENCRYPT(" . $Walzenlage[3] . ",key),
        AES_ENCRYPT(" . $Ringstellung . ",key),
        AES_ENCRYPT(" . $Grundstellung . ",key),
        AES_ENCRYPT(" . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . " " . pop @Steckerverbindungen . ",key),
        AES_ENCRYPT(" . $Kenngruppen . ",key),
        AES_ENCRYPT(" . $Revision . ",key),
        NOW()
    )";
=end GHOSTCODE
=cut
