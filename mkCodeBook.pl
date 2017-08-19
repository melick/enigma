#!/usr/bin/perl

# -----
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 June 16 - LOMelick - moved to GitHub and updated for Raspberry Pi Zero W
#                   - 2015 March 23 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage(1): /usr/bin/perl /home/melick/enigma/mkCodeBook.pl -p 'Red Stallion' -s '2014-09-01' [-v] [-d]
# usage(1): /usr/bin/perl /home/melick/enigma/mkCodeBook.pl --patrol 'Red Stallion' --start '2014-09-01' [--verbose] [--debug]


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
my $Patrol = '';
my $StartDate = '';
my $verbose;
my $debug;
GetOptions ("debug"   => \$debug,     # flag
            "patrol=s" => \$Patrol,   # string
            "start=s" => \$StartDate, # string
            "verbose" => \$verbose)   # flag
or die("Error in command line arguments\n");
die("StartDate is not defined.\n") if ( ! $StartDate );
die("Patrol is not defined.\n") if ( ! $Patrol );


# ----- handle the date variable
printf "my StartDate is: %s.\n", $StartDate if $verbose;
my ($year, $month, $day_of_month) = split('-', $StartDate);
printf "y:%s, m:%s, d:%s.\n", $year, $month, $day_of_month if $debug;
my @months = ('', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
my $num_days = Days_in_Month($year,$month);
printf "numdays: [%s].\n", $num_days if $debug;


# ----- database handle
use lib '/home/melick/perl5/lib/perl5';
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
printf "dbh: [%s]\n", $dbh if $debug;


# ----------------------------------------------------------------------
# ----- set up the rotor set.  Max Rotor could be passed in (5 or 8)
# ----------------------------------------------------------------------
my $max_rotor = 8;  # Enigmas had 3, 5 or 8 available
my $num_rotors = 3; # Enigmas could have 3 (M1, M2 and M3) or 4 (M4) rotors installed for operation.


# ----- set up list if letters for number to letter conversion
my @letters = 'A' .. 'Z';
printf "letters:\n" if $debug;
foreach my $n (@letters) {
    printf " - [%s]\n", $n if $debug;
}


# ----------------------------------------------------------------------
# ----- print header
# ----------------------------------------------------------------------
$a = Text::Banner->new;
$a->set($Patrol);
$a->size(1);
$a->fill('*');
$a->rotate('h');
print $a->get;
printf "        %04d %s\n\n", $year, $months[$month];
printf "-----------+---+---------------------+-----+-----+--------------------------------+----------------\n";
printf "    Day    |UKW|     Walzenlage      |Ring |Grund| Steckerverbindungen            | Kenngruppen    \n";
printf "-----------+---+---------------------+-----+-----+--------------------------------+----------------\n";


# ----------------------------------------------------------------------
# ----- make table
# ----------------------------------------------------------------------
for (my $day=$num_days; $day >= 1; $day--) {

    # ----------------------------------------------------------------------
    # date
    # ----------------------------------------------------------------------
    my $day_len = 2;
    my $padded_day = sprintf ("%0${day_len}d", $day );
    my $date = $year . '-' . $month . '-' . $padded_day;
    printf "date: [%s]\n", $date if $debug;

    # ----------------------------------------------------------------------
    # pick random reflector - app has B, C, B (Thin) and C (thin).  I'm only doing B & C
    # ----------------------------------------------------------------------
    my $Umkehrwalze = random_string_from('BC',1);
    printf "Umkehrwalze: [%s]\n", $Umkehrwalze if $debug;


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
    printf "Walzenlage:\n" if $debug;
    foreach my $n (@Walzenlage) {
        printf " - [%s]\n", $n if $debug;
    }


    # ----------------------------------------------------------------------
    # pick ring settings
    # ----------------------------------------------------------------------
    my $Ringstellung;
    if ($num_rotors == 3) {
        $Ringstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    } else {
        $Ringstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    }
    printf "Ringstellung: [%s]\n", $Ringstellung if $debug;


    # ----------------------------------------------------------------------
    # pick starting positions
    # ----------------------------------------------------------------------
    my $Grundstellung;
    if ($num_rotors == 3) {
        $Grundstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    } else {
        $Grundstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    }
    printf "Grundstellung: [%s]\n", $Grundstellung if $debug;

    # ----------------------------------------------------------------------
    # ----- set up the plugs set.  This is number of terminations.  a -> b = 2 connections.  Normal usage uses 10 connectors, or 20 connections
    # ----------------------------------------------------------------------
    my $max_plug = 2 * int rand(10);
    printf "max_plug: [%s]\n", $max_plug if $debug;

    # pick plug combinations
    my @Plugs;
    for (my $p=0; $p < 26; $p++) {
        push @Plugs, $letters[$p];
        printf "plugs: [%s:%s]\n", $p, $letters[$p] if $debug;
    }

    # Shuffled list of indexes into @deck
    my @shuffled_plug_indexes = shuffle(0..$#Plugs);

    # Get just N of them.
    my @pick_plug_indexes = @shuffled_plug_indexes[ 0 .. $max_plug -1 ];

    # Pick cards from @deck
    my @negnudnibrevrekcetS = @Plugs[ @pick_plug_indexes ];
    foreach my $n (@negnudnibrevrekcetS) {
        printf " - [%s]\n", $n if $debug;
    };

    my $Steckerverbindungen = '';

    # I've got space in the output for 24, but might not use them all if $max_plug < 24.  Push the unneeded ones off the back end of the truck.
    for (my $s=0; $s < $max_plug; $s++) {
        if ($s %2) {
            # odd
            $Steckerverbindungen = join('', $Steckerverbindungen, $negnudnibrevrekcetS[$s]);
        } else {
            # even
            $Steckerverbindungen = join(' ', $Steckerverbindungen, $negnudnibrevrekcetS[$s]);
        }
        printf " -) [%s]\n", $Steckerverbindungen if $debug;
    }
    $Steckerverbindungen =~ s/^\s+//;
    $Steckerverbindungen =~ s/\s+$//;
    printf "Final Steckerverbindungen: [%s]\n", $Steckerverbindungen if $debug;


    # ----------------------------------------------------------------------
    # Kenngruppen
    # ----------------------------------------------------------------------
    my $Kenngruppen = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . ' ' . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . ' ' . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . ' ' . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
    printf "Kenngruppen: [%s]\n", $Kenngruppen if $debug;


    # ----------------------------------------------------------------------
    # remove old entry
    # ----------------------------------------------------------------------
    my $delete_query = "DELETE FROM `CodeBook` WHERE `date` = '" . $date . "' AND AES_DECRYPT(`Patrol`,UNHEX(SHA2('" . $Patrol . "',512))) = '" . $Patrol . "';";
    printf "delete_query: [%s]\n", $delete_query if $debug;
    my $sth_d = $dbh->prepare($delete_query);
    $sth_d->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
    $sth_d->finish();

    # ----------------------------------------------------------------------
    # store in database -- http://thinkdiff.net/mysql/encrypt-mysql-data-using-aes-techniques/
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


    # ----------------------------------------------------------------------
    # print out settings
    # ----------------------------------------------------------------------
    if ($num_rotors == 3) {
        printf "%04d-%02d-%02d | %s |   %4s %4s %4s    | %3s | %3s | %-30s | %s\n", $year, $month, $day, $Umkehrwalze, $Walzenlage[0], $Walzenlage[1], $Walzenlage[2], $Ringstellung, $Grundstellung, $Steckerverbindungen, $Kenngruppen;
    } else {
        printf "%04d-%02d-%02d | %s | %4s %4s %4s %4s  | %4s | %4s | %-30s | %s\n", $year, $month, $day, $Umkehrwalze, $Walzenlage[0], $Walzenlage[1], $Walzenlage[2], $Walzenlage[3], $Ringstellung, $Grundstellung, $Steckerverbindungen, $Kenngruppen;
    }

}

printf "-----------+---+---------------------+-----+-----+--------------------------------+----------------\n";

$dbh->disconnect;


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



# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut
