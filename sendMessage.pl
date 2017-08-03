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
my $Umkehrwalze = '';
my $Walzenlage1 = '';
my $Walzenlage2 = '';
my $Walzenlage3 = '';
my $Walzenlage4 = '';
my $Ringstellung = '';
my $Grundstellung = '';
my $Steckerverbindungen = '';
my $Kenngruppen = '';
my $encrypted_message = '';

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
do {

    # ----- handle the data from each row
    while (my @row = $sth->fetchrow_array())  {

        foreach my $field_num (0..$#row) {
            # ----- assign variables here...
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


        # ----- add the header which includes a moniker for the patrol and one of the Kenngruppen for the day.
        $Message =~ join('', $patrol_name, " | ", $Kenngruppen, "\n", $Message);


        # ----- https://stackoverflow.com/questions/2461472/how-can-i-run-an-external-command-and-capture-its-output-in-perl
        # python example printf "/home/melick/enigma/python/enigma.py -r B -R I,V,II -O 1,2,3 -P AE,IO,UW -K FOO 'HELLOXWORLD'\n" if $debug;
        my $python_command = '';
      # fix this some day.  I'm generating 4 walzenlages, but the emulator only has three and the codebooks I'm generating only have 3.
      # if ($Walzenlage4 ne '') {
      #     $python_command .= sprintf "/home/melick/enigma/python/enigma.py -r %s -R %s,%s,%s,%s -O %s -P %s -K %s '%s'", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Walzenlage4, $Ringstellung, $Steckerverbindungen, $Grundstellung, $Message;
      # } else {
            $python_command .= sprintf "/home/melick/enigma/python/enigma.py -r %s -R %s,%s,%s -O %s -P %s -K %s '%s'", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung, $Steckerverbindungen, $Grundstellung, $Message;
      # }
        printf "python_command [%s]\n", $python_command if $debug;

        $encrypted_message = `$python_command`;
        $encrypted_message =~ join('', $patrol_name, " | ", $Kenngruppen, " \ ", $encrypted_message);
        printf "(1)encrypted message [%s]\n\tlength [%s]\n", $encrypted_message, length $encrypted_message;
        $encrypted_message =~ s/\n/ /g;
        $encrypted_message =~ s/\r//g;
        $encrypted_message =~ s/^\s+//;
        $encrypted_message =~ s/\s+$//;
        printf "(2)encrypted message [%s]\n\tlength [%s]\n", $encrypted_message, length $encrypted_message;

    } # end or row1 processing

} until (!$sth->more_results);
$sth->finish();
$dbh->disconnect();


# ----- http://perltricks.com/article/154/2015/2/23/Build-a-Twitter-bot-with-Perl/
use Net::Twitter::Lite::WithAPIv1_1;
use Try::Tiny;

my $url = "https://melick.wordpress.com/"; # ----- twitter treats this as 12 bytes
my $hashtag = "#enigma";                   # ----- 7 bytes, and only included if there is room left in the tweet.

if (length $encrypted_message <= 107) {
    tweet($encrypted_message, $url, $hashtag);
} else {
    printf "ERROR: message too long to include URL and hashtag [%s]\n", length $encrypted_message;
}

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

    if (length("$text $hashtag") < 118) {
        $tweet = "$text $url $hashtag";
    } elsif (length($text) < 118) {
      $tweet = "$text $url";
    } else { # shorten text, drop the hashtag {
      $tweet = substr($text, 0, 113) . "... " . $url;
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
    enemy positions and ships, date and time tables.  Another codebook contained the Kenngruppen and Spruchschlüssel: the key identification
    and message key.

=end GHOSTCODE
=cut
