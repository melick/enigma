#!/usr/bin/perl

# -----
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 June 16 - LOMelick - moved to GitHub and updated for Raspberry Pi Zero W
#                   - 2015 March 23 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage(1): /usr/bin/perl /home/melick/enigma/mkCodeBook.pl -s '2014-09-01' -e '2014-09-30'

use warnings;
use strict;

#use lib '/home/melick/perl5/lib/perl5';
use Math::Random::Secure qw(rand);
use Roman;
use List::Util qw/shuffle/;
use Date::Calc qw(:all);
use Text::Banner;


# ----- input parameters
use Getopt::Long;
my $StartDate = '';
my $EndDate = '';
my $verbose;
GetOptions ("start=s" => \$StartDate, # string
            "end=s"   => \$EndDate,   # string
            "verbose" => \$verbose)   # flag
or die("Error in command line arguments\n");


# ----- input variables
my $ScriptName = "$0";


# ----- Date & Time setups
use DateTime;
my $TodaysDate = DateTime->now;
my $Now = join(' ', $TodaysDate->ymd, $TodaysDate->hms);
printf "[%s] [%s : %s]\n", $Now, $TodaysDate->ymd, $TodaysDate->hms if $verbose;

my $julian_day = $TodaysDate->day_of_year();
my $month = $TodaysDate->month(); my $day = $TodaysDate->day(); my $year = $TodaysDate->year(); my $weekday = $TodaysDate->day_name();
printf "j:%s, m:%s, d:%s, y:%s, w:%s\n", $julian_day, $month,$day,$year,$weekday if $verbose;

# ----- if StartDate and EndDate were not passed, set them to the default of Sunday/Saturday of current week.
if ($StartDate eq '') {
    $StartDate = DateTime->today()
        ->truncate( to => 'week' )
        ->subtract( days => 1 )->ymd;
}
if ($EndDate eq '') {
    $EndDate = DateTime->today()
        ->truncate( to => 'week' )
        ->add( days => 5 )->ymd;
}
printf "[%s] my StartDate is: %s, my EndDate is: %s.\n", DateTime->today()->truncate( to => 'week' )->ymd, $StartDate, $EndDate;


# ----- database handle
my $which_db = 'enigma';

use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
printf "dbh: [%s]\n", $dbh if $verbose;


# ----- file handles
use File::Basename;  #qw(dirname, fileparse);
my($filename, $DIR, $suffix) = fileparse($0);
printf "filename [%s], DIR [%s] suffix [%s]\n", $filename, $DIR, $suffix if $verbose;

my $filehandle = join('', $DIR, 'CodeBook-', $StartDate, '.dat');
open(OUTPUT, ">$filehandle") || die "Can't open output file [$filehandle] : $!\n";


# ----- basic info
my $network = 'Red Stallion';


# ----------------------------------------------------------------------
# ----- set up the rotor set.  Max Rotor could be passed in (5 or 8)
# ----------------------------------------------------------------------
my $max_rotor = 8;  # Enigmas had 3, 5 or 8 available
my $num_rotors = 3; # Enigmas could have 3 (M1, M2 and M3) or 4 (M4) rotors installed for operation.


# ----------------------------------------------------------------------
# ----------------------------------------------------------------------


# ----- set up list if letters for number to letter conversion
my @letters = 'A' .. 'Z';


# ----- get todays date and the number of days in this month
my @months = ('', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
my ($year,$month,$day, $hour,$min,$sec, $doy,$dow,$dst) = Localtime();
my $num_days = Days_in_Month($year,$month);


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


open(OUTPUT,">CodeBook-$year-$months[$month].txt");
open(PERL,">CodeBook-$year-$months[$month].pm");

# ----------------------------------------------------------------------
# ----- make table
# ----------------------------------------------------------------------
for (my $day=$num_days; $day >= 1; $day--) {

    # ----------------------------------------------------------------------
    # date
    # ----------------------------------------------------------------------
    my $date = $year . '-' . $month . '-' . $day;


    # ----------------------------------------------------------------------
    # pick random reflector
    # ----------------------------------------------------------------------
    my $Umkehrwalze = $letters[1 + int rand(2)];


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


    # ----------------------------------------------------------------------
    # pick ring settings
    # ----------------------------------------------------------------------
    my $Ringstellung;
    if ($num_rotors == 3) {
        $Ringstellung = $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)];
    } else {
        $Ringstellung = $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)];
    }


    # ----------------------------------------------------------------------
    # pick starting positions
    # ----------------------------------------------------------------------
    my $Grundstellung;
    if ($num_rotors == 3) {
        $Grundstellung = $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)];
    } else {
        $Grundstellung = $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)];
    }


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


    # ----------------------------------------------------------------------
    # Kenngruppen
    # ----------------------------------------------------------------------
    my $Kenngruppen = $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)] . ' ' . $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)] . ' ' . $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)] . ' ' . $letters[int rand(26)] . $letters[int rand(26)] . $letters[int rand(26)];


    # ----------------------------------------------------------------------
    # print out settings
    # ----------------------------------------------------------------------
    if ($num_rotors == 3) {
        printf        "%04d-%02d-%02d | %s |   %4s %4s %4s    | %3s | %3s | %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
      # printf OUTPUT "%04d-%02d-%02d | %s |   %4s %4s %4s    | %3s | %3s | %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
      # printf PERL   "'%02d'=>' %s :   %4s %4s %4s    : %3s : %3s : %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s : %s',\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
    } else {
        printf "%04d-%02d-%02d | %s | %4s %4s %4s %4s | %4s| %4s| %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
      # printf OUTPUT "%04d-%02d-%02d | %s | %4s %4s %4s %4s | %4s| %4s| %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
      # printf PERL "%04d-%02d-%02d | %s | %4s %4s %4s %4s | %4s| %4s| %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s | %s\n", $year, $month, $day, $Umkehrwalze, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, $Grundstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;
    }
    # printf " '%02d'=>'   %4s %4s %4s    :  %3s  : %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s : %s ',\n", $day, pop @Walzenlage, pop @Walzenlage, pop @Walzenlage, $Ringstellung, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, pop @Steckerverbindungen, $Kenngruppen;;

}

printf "-----------+---+---------------------+-----+-----+----------------------------------------+-------------\n";

close(OUTPUT);
close(PERL);


# ----- HC SVNT DRACONES -----
