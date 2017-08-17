#!/usr/bin/perl

# ----- pulls data from a database stored procedure, table or view based on name passed in and formats it for delivery.
#       Lyle Melick - Red Stallion Patrol
#       Last Update - 2017 July 21 - LOMelick - Created
#
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# usage: /usr/bin/perl /home/melick/enigma/sendMessage.pl -p RS -m 'Hello World' -v -d
# usage: /usr/bin/perl /home/melick/enigma/sendMessage.pl --patrol 'RS' --message 'Hello World' --verbose --debug
# usage: /usr/bin/perl /home/melick/enigma/sendMessage.pl --patrol 'RS' --message 'Hello World. 0000 000 00 1 2 3 4 5 6 7 8 9, 1.2 (well?) "`´‘’“”' --verbose --debug
# usage: /usr/bin/perl /home/melick/enigma/runReport.pl --patrol 'RS' --message 'ZOIG CPKO XBOT PVOL LLDI WSCJ FMAB AMXK LWZM UNOZ HIKG XQZT WLTJ LUMV JEJQ EAMV JZUF XLGP HWEZ UOMP QNTN IDAT YQYA IEHQ YY' --verbose --debug


my $which_db = 'Enigma';

use warnings;
use strict;


# ----- input parameters
use Getopt::Long;
my $Message = '';
my $Patrol = '';
my $verbose;
my $debug;
GetOptions ("debug"     => \$debug,     # flag
            "message=s" => \$Message,   # string
            "patrol=s"  => \$Patrol,    # string
            "verbose"   => \$verbose)   # flag
or die("Error in command line arguments\n");
die("Message is not defined.\n") if ( ! $Message );
die("Patrol is not defined.\n") if ( ! $Patrol );


# ----- Misc Variable Setups
my $ScriptName = "$0";


# ----- Misc Variable Setups
use File::Basename;  #qw(dirname, fileparse);
my($filename, $DIR, $suffix) = fileparse($0, qr/\.[^.]*/);
printf "DIR [%s], filename [%s], suffix [%s]\n", $DIR, $filename, $suffix if $debug;


# ----- echo the input variables
printf "Patrol:%s.\n", $Patrol if $debug;


# ----- massage the message per http://users.telenet.be/d.rijmenants/en/enigmaproc.htm
$Message = uc $Message;

$Message =~ s/0000/MYRIA/g;
$Message =~ s/000/MILLE/g;
$Message =~ s/00/CENTA/g;

$Message =~ s/0/NULL/g;
$Message =~ s/1/EINZ/g;
$Message =~ s/2/ZWO/g;
$Message =~ s/3/DREI/g;
$Message =~ s/4/VIER/g;
$Message =~ s/5/FUNF/g;
$Message =~ s/6/SEQS/g;
$Message =~ s/7/SEIBEN/g;
$Message =~ s/8/ACHT/g;
$Message =~ s/9/NEUN/g;

$Message =~ s/,/ZZ/g;
$Message =~ s/\. /X/g;
$Message =~ s/\./YY/g;
$Message =~ s/\(/KLAM/g;
$Message =~ s/\)/KLAM/g;
$Message =~ s/\?/FRAGEZ/g;
$Message =~ s/\'/X/g; # ----- this can't be passed in but I'm including it just in case...
$Message =~ s/\"/X/g;
$Message =~ s/\`/X/g;
$Message =~ s/\´/X/g;
$Message =~ s/\‘/X/g;
$Message =~ s/\’/X/g;
$Message =~ s/\“/X/g;
$Message =~ s/\”/X/g;

$Message =~ s/CH/Q/g;
if ($debug) {
     $Message =~ s/ /x/g;
} else {
    $Message =~ s/ //g;
}

# -----Foreign names, places, etc. are delimited twice by "X", as in XPARISXPARISX or XFEUERSTEINX.  This needs to be handled manually.

printf "Message [%s]\n\tis %s characters long.\n", $Message, length $Message if $verbose;


# ----- database handle
use lib '/home/melick/perl5/lib/perl5';
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
printf "dbh: [%s]\n", $dbh if $debug;


# ----- Date & Time setups
use Melick::MySQLDate;
my $TodaysDate = MySQLDate();
(my $year,my $month,my $day) = split(/-/,$TodaysDate);

use Melick::newJulian;
my $julian_day = &jday($month,$day,$year);
($month,$day,$year,my $weekday) = &jdate($julian_day);

use Melick::Time;
my $Time = Time();
$Time =~ s/\://g;
$Time = substr($Time, 0, 4);

# ----- translate the patrol abbreviations
my %ShortNorth = (
  'RS' => 'RDS:Red Stallion:0',
  'P'  => 'PIO:Pioneer:0',
  'V'  => 'VIK:Viking:0',
);
my ($patrol_name,$CodeBook,$other_info) = split(/\:/, $ShortNorth{$Patrol});
printf "\t%s is working on patrol %s from CodeBook %s : %s at %s %s\n", $ScriptName, $patrol_name, $CodeBook, $other_info, $TodaysDate, $Time;


# ----- set the key
my $key_query = "SET \@key = UNHEX(SHA2('$CodeBook',512))";
printf "\tkq:%s:\n", $key_query if $debug;
my $sth = $dbh->prepare($key_query);
$sth->execute() || die DBI::err.": ".$DBI::errstr;

# ----- Proceed.
my $bskg_order = '';
my $Buchstabenkenngruppe = '';
my $Buchstabenkenngruppe_a = '';
my $Buchstabenkenngruppe_b = '';
my $encrypted_message = '';
my $encrypted_Spruchschlussel = '';
my $full_message = '';
my $Grundstellung = '';
my $Kenngruppen = '';
my $message_header = '';
my $num_rotors = 3;   # ----- default for now... LOMelick - 2017-08-16
my $python_command = '';
my $python_command_a = '';
my $python_command_b = '';
my $random_Grundstellung = '';
my $Ringstellung = '';
my $Spruchschlussel = '';
my $Steckerverbindungen = '';
my $Umkehrwalze = '';
my $unencrypted_message = '';
my $Walzenlage1 = '';
my $Walzenlage2 = '';
my $Walzenlage3 = '';
my $Walzenlage4 = '';
my @KG;


my $query = "\
SELECT AES_DECRYPT(`Umkehrwalze`,\@key) \
     , AES_DECRYPT(`Walzenlage1`,\@key) \
     , AES_DECRYPT(`Walzenlage2`,\@key) \
     , AES_DECRYPT(`Walzenlage3`,\@key) \
     , AES_DECRYPT(`Walzenlage4`,\@key) \
     , AES_DECRYPT(`Ringstellung`,\@key) \
     , AES_DECRYPT(`Grundstellung`,\@key) \
     , AES_DECRYPT(`Steckerverbindungen`,\@key) \
     , AES_DECRYPT(`Kenngruppen`,\@key) \
  FROM `CodeBook` \
 WHERE AES_DECRYPT(`Patrol`,\@key) in ('$CodeBook') \
   AND `date` = '$TodaysDate';";

printf "\tq:%s:\n", $query if $debug;
$sth = $dbh->prepare($query);
$sth->execute() || die DBI::err.": ".$DBI::errstr;


# ----- let's git bizzy
do {

    # ----- handle the data from each row
    while (my @row = $sth->fetchrow_array())  {

        foreach my $field_num (0..$#row) {
            # ----------------------------------------------------------------------
            # ----- assign variables here...
            # ----------------------------------------------------------------------
            if ($field_num == 0) { $Umkehrwalze = $row[$field_num]; printf "Umkehrwalze:%s.\n", $Umkehrwalze if $debug; };
            if ($field_num == 1) { $Walzenlage1 = $row[$field_num]; printf "Walzenlage1:%s.\n", $Walzenlage1 if $debug; };
            if ($field_num == 2) { $Walzenlage2 = $row[$field_num]; printf "Walzenlage2:%s.\n", $Walzenlage2 if $debug; };
            if ($field_num == 3) { $Walzenlage3 = $row[$field_num]; printf "Walzenlage3:%s.\n", $Walzenlage3 if $debug; };
            if ($field_num == 4) { $Walzenlage4 = $row[$field_num]; printf "Walzenlage4:%s.\n", $Walzenlage4 if $debug; };
            if ($field_num == 5) { $Ringstellung = $row[$field_num];
                                   printf "Ringstellung:%s.\n", $Ringstellung if $debug;
                                   if (length $Ringstellung == 3) {
                                       $Ringstellung = join(',', substr($Ringstellung,0,1), substr($Ringstellung,1,1), substr($Ringstellung,2,1));
                                   } elsif  (length $Ringstellung == 4) {
                                       $Ringstellung = join(',', substr($Ringstellung,0,1), substr($Ringstellung,1,1), substr($Ringstellung,2,1), substr($Ringstellung,3,1));
                                   } else {
                                       printf "ERROR: invalid Ringstellung length %s [%s]\n", length $Ringstellung, $Ringstellung;
                                   }
            }
            if ($field_num == 6) { $Grundstellung = $row[$field_num];
                                       printf "Grundstellung:%s.\n", $Grundstellung if $debug;
                                   if (length $Grundstellung == 3) {
                                   } elsif  (length $Grundstellung == 4) {
                                   } else {
                                       printf "ERROR: invalid Grundstellung length %s [%s]\n", length $Grundstellung, $Grundstellung;
                                   }
            }
            if ($field_num == 7) { $Steckerverbindungen = $row[$field_num];
                                   printf "Steckerverbindungen:%s.\n", $Steckerverbindungen if $debug;
                                   $Steckerverbindungen =~ tr/ /,/s;
            }
            if ($field_num == 8) { $Kenngruppen = $row[$field_num]; printf "Kenngruppen:%s.\n", $Kenngruppen if $debug; };

        }


        # ----------------------------------------------------------------------
        # ----- pick one of the Kenngruppen to use in the Buchstabenkengruppe
        # ----------------------------------------------------------------------
        use Math::Random::Secure qw(rand);
        @KG = split / /, $Kenngruppen;
        $Kenngruppen = $KG[ rand @KG ];
        printf "Kengruppen [%s]\n\n", $Kenngruppen if $debug;


        # ----------------------------------------------------------------------
        # ----- start assembling the Buchstabenkenngruppe
        # ----------------------------------------------------------------------
        use Bytes::Random::Secure qw(random_string_from);
        $Buchstabenkenngruppe_a = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
        $Buchstabenkenngruppe_b = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);

        $bskg_order = random_string_from('123',1);
        if ($bskg_order eq '1') {
            $Buchstabenkenngruppe = join('', $Buchstabenkenngruppe_a, $Buchstabenkenngruppe_b, $Kenngruppen);
        } elsif ($bskg_order eq '2') {
            $Buchstabenkenngruppe = join('', $Buchstabenkenngruppe_a, $Kenngruppen, $Buchstabenkenngruppe_b);
        } elsif ($bskg_order eq '3') {
            $Buchstabenkenngruppe = join('', $Kenngruppen, $Buchstabenkenngruppe_a, $Buchstabenkenngruppe_b);
        } else {
            printf "ERROR: invalid bskg order [%s]\n", $bskg_order;
        }
        printf "Buchstabenkenngruppe [%s]\n", $Buchstabenkenngruppe if $debug;


        # ----------------------------------------------------------------------
        # ----- Procedure for post-1940 Grundstellung Wehrmacht (and Heer?) procedure per http://users.telenet.be/d.rijmenants/en/enigmaproc.htm
        #       pick new/random starting positions
        # ----------------------------------------------------------------------
        if ($num_rotors == 3) {
            $random_Grundstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
        } else {
            $random_Grundstellung = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
        }
        printf "random Grundstellung: [%s]\n", $random_Grundstellung if $debug;

        if ($num_rotors == 3) {
            $Spruchschlussel = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
        } else {
            $Spruchschlussel = random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1) . random_string_from('ABCDEFGHIJKLMNOPQRSTUVWXYZ',1);
        }
        printf "Spruchschlussel: [%s]\n", $Spruchschlussel if $debug;

        $python_command_a .= sprintf "/home/melick/enigma/python/enigma.py -r %s -R %s,%s,%s -O %s -P %s -K %s '%s'", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung, $Steckerverbindungen, $random_Grundstellung, $Spruchschlussel;
        $encrypted_Spruchschlussel = `$python_command_a`;
        $encrypted_Spruchschlussel =~ s/\n/ /g;
        $encrypted_Spruchschlussel =~ s/\r//g;
        $encrypted_Spruchschlussel =~ s/^\s+//;
        $encrypted_Spruchschlussel =~ s/\s+$//;
        printf "encrypted_Spruchschlussel [%s]\n", $encrypted_Spruchschlussel if $debug;


        # ----------------------------------------------------------------------
        # ----- https://stackoverflow.com/questions/2461472/how-can-i-run-an-external-command-and-capture-its-output-in-perl
        # python example printf "/home/melick/enigma/python/enigma.py -r B -R I,V,II -O 1,2,3 -P AE,IO,UW -K FOO 'HELLOXWORLD'\n" if $debug;
        # ----------------------------------------------------------------------
      # fix this some day.  I'm generating 4 walzenlages, but the emulator only has three and the codebooks I'm generating only have 3.
        if ($num_rotors == 4) {
            $python_command .= sprintf "/home/melick/enigma/python/enigma.py -r %s -R %s,%s,%s    -O %s -P %s -K %s '%s'", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3,               $Ringstellung, $Steckerverbindungen, $Spruchschlussel, $Message;
        } else {
            printf "should see this.\n" if $debug;
            $python_command .= sprintf "/home/melick/enigma/python/enigma.py -r %s -R %s,%s,%s -O %s -P %s -K %s '%s'", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung, $Steckerverbindungen, $Spruchschlussel, $Message;
        }
        printf "python_command [%s]\n", $python_command if $debug;

        # ----- set up header just to see how long it might be.  We'll make the real header later
        $message_header = join('', $patrol_name, ' DE CTU ',  $Time, ' = NNN = ', $random_Grundstellung, ' ', $encrypted_Spruchschlussel, ' = ', $Buchstabenkenngruppe, ' ', '=' );

        $encrypted_message = `$python_command`;
        $encrypted_message =~ s/\n/ /g;
        $encrypted_message =~ s/\r//g;
        $encrypted_message =~ s/^\s+//;
        $encrypted_message =~ s/\s+$//;
        $encrypted_message = substr($encrypted_message, 0, 140 - length $message_header);
        printf "encrypted_message %s characters [%s]\n", length $encrypted_message, $encrypted_message if $debug;

        $python_command_b .= sprintf "/home/melick/enigma/python/enigma.py -r %s -R %s,%s,%s -O %s -P %s -K %s '%s'", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung, $Steckerverbindungen, $Spruchschlussel, $encrypted_message;
        $unencrypted_message = `$python_command_b`;
        $unencrypted_message =~ s/\n/ /g;
        $unencrypted_message =~ s/\r//g;
        $unencrypted_message =~ s/^\s+//;
        $unencrypted_message =~ s/\s+$//;
        printf "You'll be sending %s characters as the message: [%s]\n", length $unencrypted_message, $unencrypted_message;


        # ----- build the real message.
        $full_message = join('', $patrol_name, ' DE CTU ',  $Time, ' = ', length $encrypted_message, ' = ', $random_Grundstellung, ' ', $encrypted_Spruchschlussel, ' = ', $Buchstabenkenngruppe, ' ', $encrypted_message, '=' );
        printf "full_message %s [%s]\n", length $full_message, $full_message;


    } # end or row1 processing

} until (!$sth->more_results);
$sth->finish();
$dbh->disconnect();


# ----- http://perltricks.com/article/154/2015/2/23/Build-a-Twitter-bot-with-Perl/
use Net::Twitter::Lite::WithAPIv1_1;
use Try::Tiny;

my $url = "https://melick.wordpress.com/"; # ----- twitter treats this as 29 bytes
my $hashtag = "#enigma";                   # ----- 7 bytes, and only included if there is room left in the tweet.
tweet($full_message, $url, $hashtag);


# ----- https://perlmaven.com/sending-tweets-from-a-perl-script
# could also pull down previous tweets, decode and post



# ----- put your toys away little Johnny
sub tweet {

    my ($text, $url, $hashtag) = @_;

    unless ($text && $url && $hashtag) {
        die 'tweet requires text, url and hashtag arguments';
    }


    # ----- http://perltricks.com/article/29/2013/9/17/How-to-Load-YAML-Config-Files/
    use YAML::XS 'LoadFile';
    our $config = LoadFile('config.yaml');
    our $access_token_secret = $config->{access_token_secret};
    our $consumer_secret     = $config->{consumer_secret};
    our $access_token        = $config->{access_token};
    our $consumer_key        = $config->{consumer_key};
    our $user_agent          = $config->{user_agent};
    our $ssl                 = $config->{ssl};

    # ----- check the vars
    unless ($consumer_key && $consumer_secret && $access_token && $access_token_secret) {
      die 'Required Twitter Env vars are not all defined';
    }


    # -- build tweet, max 140 chars
    my $tweet;
    if (length("$text $hashtag") < 110) {
        $tweet = "$text $hashtag $url";
    } elsif (length($text) < 110) { # try dropping the hashtag
        $tweet = "$text $url";
    } else { # shorten text, drop the url & hashtag {
        $tweet = substr($text, 0, 140);
    }


    # -- tweet it
    try {
        my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
            access_token_secret => $access_token_secret,
            consumer_secret     => $consumer_secret,
            access_token        => $access_token,
            consumer_key        => $consumer_key,
            user_agent          => $user_agent,
            ssl                 => $ssl,
        );
        $twitter->update($tweet);
    }
    catch {
        die join(' ', "Error tweeting $text $url $hashtag", $_->code, $_->message, $_->error);
    };

}


# ----- HC SVNT DRACONES (no user servicable parts beyond here)
=begin GHOSTCODE

    During World War II, codebooks were only used each day to set up the rotors, their ring settings and the plugboard.  For each message,
    the operator selected a random start position, let's say WZA (possibly from the Kenngruppen), and a random/arbitrary message key,
    perhaps SXT.  He moved the rotors to the WZA start position and encoded the message key SXT.  Assume the result was UHL.  He then set
    up the message key, SXT, as the start position and encrypted the message.  Next, he transmitted the start position, WZA, the encoded
    message key, UHL, and then the ciphertext.

    The receiver set up the start position according to the first trigram, WZA, and decoded the second trigram, UHL, to obtain the SXT
    message setting.  Next, he used this SXT message setting as the start position to decrypt the message.  This way, each ground
    setting was different and the new procedure avoided the security flaw of double encoded message settings.

    This procedure was used by Wehrmacht and Luftwaffe only.  The Kriegsmarine procedures on sending messages with the Enigma were far
    more complex and elaborate.  Prior to encryption the message was encoded using the Kurzsignalheft code book.  The Kurzsignalheft
    contained tables to convert sentences into four-letter groups.  A great many choices were included, for example, logistic matters
    such as refuelling and rendezvous with supply ships, positions and grid lists, harbour names, countries, weapons, weather conditions,
    enemy positions and ships, date and time tables.  Another codebook contained the Kenngruppen and Spruchschlussel: the key identification
    and message key.

=end GHOSTCODE
=cut
