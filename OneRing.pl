#!/usr/bin/perl

# ----- sets up a Enigma simulator
#       Lyle Melick - LMelick@MedicMgmt.com - Medic Management Group, LLC
#       Last Update - 2015 March 23 - LOMelick
my $Revision = '$WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$';$Revision =~ s/\A\s+//;$Revision =~ s/\s+\z//;
my $BuildDate = '$WCDATE=%Y-%b-%d %I:%M:%S%p$';$BuildDate =~ s/\A\s+//;$BuildDate =~ s/\s+\z//;
#
# http://enigma.louisedade.co.uk/enigma.html?m3;b;b245;ABUL;ABLA;AV-BS-CG-DL-FU-HZ-IN-KM-OW-RX
#
# usage: C:\Strawberry\perl\bin\perl.exe C:\Users\melick\workspace\Enigma\OneRing.pl [--Tag XX] [--verbose] [--debug]


use warnings;
use strict;
use Switch;


# ----- handle input options
use Getopt::Long;
my $debug;
my $Tag;
my $verbose;
my $verbosity;
GetOptions ("debug"           => \$debug,         # flag
            "Tag=s"           => \$Tag,           # string (day of month)
            "verbose"         => \$verbose)       # flag
or die("Error in command line arguments\n");
if ($verbose) {printf "--verbose\n"; $verbosity = '--verbose'; };
if ($debug)   {printf "--debug\n";   $verbosity = join(" ", '--debug'); use Data::Dumper; };

# ----- handle the date
use Time::Piece;
if (defined $Tag && length $Tag > 0) { } else { $Tag = localtime->strftime('%d') };
printf "Tag:%s.\n", $Tag if $debug;

# ----- pick a random Kenngruppen for the first Grundstellung
my $minimum = 1;
my $maximum = 5;
my $Kenngruppen_no = $minimum + int(rand($maximum - $minimum));
printf "rand kenngruppen slot: %s\n", $Kenngruppen_no;


# ----- Enigma Settings from codebook
my %ShortNorth = (
#
#GEHEIM!               RED STALLION (FUNKSCHLUSSEL M) ROT HENGST        JANUARY 2017
#
#-----------------------------------------------------------------------------------------------
#| Tag |UKW|   Walzenlage      | Rng   |      Steckerverbindungen            |   Kenngruppen   |
#-----------------------------------------------------------------------------------------------
 '31'=>' B :   IV  VII   VI    : P W L : DE RT LG BS AO MY JU NQ IH PK CZ WF : KXC YWT BAT JOT ',
 '30'=>' B : VIII   IV    V    : G P V : XF .. .. .. .. .. .. .. .. .. .. .. : BMG VSG TYL UEK ',
 '29'=>' C :   VI    I   IV    : U K R : NH IL BO WQ KY FA VU .. .. .. .. .. : SWI LDM MQX QEQ ',
 '28'=>' C :  VII    V VIII    : R A W : LZ KR ET .. .. .. .. .. .. .. .. .. : OEY WDR JEI QOK ',
 '27'=>' B :   II    V    I    : O B B : CF XD HE YU .. .. .. .. .. .. .. .. : ZGD CHN BOC ZVB ',
 '26'=>' C :    I VIII   VI    : E X L : SV MC IJ RE HL OP QW DX UB YZ .. .. : HLO GJK ZUG XYX ',
 '25'=>' B : VIII    V    I    : E L W : QM RP LK EO CF WI ZT .. .. .. .. .. : RFZ CZH SUB ETO ',
 '24'=>' B :  VII   IV    V    : U S K : ON EQ ZI .. .. .. .. .. .. .. .. .. : DYM JBB XIB ZHA ',
 '23'=>' B :    I  VII    V    : H T Z : CH DN QU JS AG LK .. .. .. .. .. .. : FLT QCI VNS OPI ',
 '22'=>' B :   VI    I VIII    : P T V : UZ GR SC AM .. .. .. .. .. .. .. .. : ZCY YMG FLW XDF ',
 '21'=>' B :   II  VII  III    : L L X : YW UR TN ED CV LS BF GI MK PH .. .. : SNR FYS HOK GCZ ',
 '20'=>' C : VIII    I    V    : H L C : UB RZ JA XD PG LO ES .. .. .. .. .. : SFE UQO TAI EAK ',
 '19'=>' B :   IV  VII  III    : E G Z : CV PB NK YA RS GI QX JH UF ZT DO .. : CIC TPM XME DNU ',
 '18'=>' B :  VII  III VIII    : F I Q : AX WO IC NQ LB KV FS .. .. .. .. .. : ZQE QWF SKN KBF ',
 '17'=>' C :    I   II    V    : Z H B : OW NG UB TR MS DK EL HI JX .. .. .. : FUJ POW OHZ MNX ',
 '16'=>' B :    I   IV    V    : U C Z : WD BM XT .. .. .. .. .. .. .. .. .. : HVW WFZ JHQ ISC ',
 '15'=>' C :  VII   VI    V    : M A T : TJ HR KW DF QX YA GV CE .. .. .. .. : PSF MYO TXE SJS ',
 '14'=>' B :    V  III    I    : P G G : YL BS ER UJ FG .. .. .. .. .. .. .. : HLM RVR AKS HIH ',
 '13'=>' C :   VI  III  VII    : A M P : IK UX TR BA .. .. .. .. .. .. .. .. : VAT PUS YFH XIW ',
 '12'=>' C :   IV    I  VII    : H S H : CU QA JS .. .. .. .. .. .. .. .. .. : GTV ZJC GTP REK ',
 '11'=>' C :  VII   VI VIII    : N W H : FB JM YT VZ WI PC NK .. .. .. .. .. : LGE JLK KES XXA ',
 '10'=>' B :    V   IV  III    : W Y G : UZ TS BN PI FG LC JA VY WE .. .. .. : KRT BJS APC DRO ',
 '09'=>' B :   VI    I  III    : B H R : UT ON RB AD HF JV XS .. .. .. .. .. : TRW SNY XUR UTN ',
 '08'=>' B :   IV   VI    I    : R N V : RZ XE MQ WT YN KL .. .. .. .. .. .. : OMA JMJ LIH MYS ',
 '07'=>' C :    I VIII   IV    : X L P : GH EC UP KN AF IO QM DY SV WR XT .. : PBF ERU OPT NZR ',
 '06'=>' B :    V   VI  VII    : Y C K : JK TL FP CW GY AQ IZ HD .. .. .. .. : JQP KNY RRZ CAY ',
 '05'=>' C : VIII  VII    I    : U G O : MB SN JO KY .. .. .. .. .. .. .. .. : YBM MRS YVP KXX ',
 '04'=>' B : VIII    V   II    : J Y Z : XK PI UV DO ZA SN YR MB JL QG WE FH : MNC GFN TDL YUV ',
 '03'=>' B :  VII   IV VIII    : M I A : XD CZ GU WS EO BI JL HK PF MN AY RV : GZZ IPN OVL TAK ',
 '02'=>' B : VIII  VII  III    : L P K : BC OJ GP UQ FY DI AT XL VR NE .. .. : YPN VCS WWO ECB ',
 '01'=>' B :   VI   IV    V    : N J C : EK FG HC IZ .. .. .. .. .. .. .. .. : QMX ZSY JJN XZG ',
#-----------------------------------------------------------------------------------------------
 'XX'=>' B :   II   IV    V    : B U L : AV BS CG DL FU HZ IN KM OW RX .. .. : BLA             ',
);



# ----- the day (Tag) is passed on the command line, as well as the pre-arranged reflector (Umkehrwalze) for the month.
#       look up the rest of the settings from the codebook
my ($Umkehrwalze,$Walzenlage,$Ringstellung,$Steckerverbindungen,$Kenngruppen) = split(/\:/, $ShortNorth{$Tag});
$Umkehrwalze         =~ s/^\s+//;         $Umkehrwalze =~ s/\s+$//; $Umkehrwalze         =~ s/ +/ /g; $Umkehrwalze = lc($Umkehrwalze);
$Walzenlage          =~ s/^\s+//;          $Walzenlage =~ s/\s+$//; $Walzenlage          =~ s/ +/ /g;
$Ringstellung        =~ s/^\s+//;        $Ringstellung =~ s/\s+$//; $Ringstellung        =~ s/ +/ /g;
$Steckerverbindungen =~ s/^\s+//; $Steckerverbindungen =~ s/\s+$//; $Steckerverbindungen =~ s/ +/ /g;
$Kenngruppen         =~ s/^\s+//;         $Kenngruppen =~ s/\s+$//; $Kenngruppen         =~ s/ +/ /g;


# ----------------------------------------------------------------------
# ----- Wheel order
# ----------------------------------------------------------------------
printf "Walzenlage:%s.\n", $Walzenlage if $debug;
my ($Walzenlage1,$Walzenlage2,$Walzenlage3,$Walzenlage4) = split(/ /, $Walzenlage);
my @Walzenlage;
use Roman;    # convert from roman numerals
$Walzenlage1 = arabic($Walzenlage1) if isroman($Walzenlage1);
$Walzenlage2 = arabic($Walzenlage2) if isroman($Walzenlage2);
$Walzenlage3 = arabic($Walzenlage3) if isroman($Walzenlage3);
if (defined $Walzenlage4 && length $Walzenlage4 > 0) {
    $Walzenlage4 = arabic($Walzenlage4) if isroman($Walzenlage4);
} else {
    $Walzenlage4 = '';
};


# ----------------------------------------------------------------------
# ----- Ring settings. the position of the alphabet ring relative to the rotor wiring
# ----------------------------------------------------------------------
printf "Ringstellung:%s.\n", $Ringstellung if $debug;
my ($Ringstellung1, $Ringstellung2, $Ringstellung3, $Ringstellung4) = split(/ /, $Ringstellung);
#$Ringstellung1 = chr(64 + $Ringstellung1);
#$Ringstellung2 = chr(64 + $Ringstellung2);
#$Ringstellung3 = chr(64 + $Ringstellung3);
#if (defined $Ringstellung4 && length $Ringstellung4 > 0) { $Ringstellung4 = chr(64 + $Ringstellung4) } else { $Ringstellung4 = '' };


# ----------------------------------------------------------------------
# ----- random message key
# ----------------------------------------------------------------------
my $minRMK = 1;
my $maxRMK = 27;
my $RMK;
if (defined $Ringstellung4 && length $Ringstellung4 > 0) {
    $RMK = join(
     chr(64 + $minRMK + int(rand($maxRMK - $minRMK)))
    ,chr(64 + $minRMK + int(rand($maxRMK - $minRMK)))
    ,chr(64 + $minRMK + int(rand($maxRMK - $minRMK)))
    ,chr(64 + $minRMK + int(rand($maxRMK - $minRMK))));
} else {
    $RMK = join(
     chr(64 + $minRMK + int(rand($maxRMK - $minRMK)))
    ,chr(64 + $minRMK + int(rand($maxRMK - $minRMK)))
    ,chr(64 + $minRMK + int(rand($maxRMK - $minRMK))));
}
printf "Random Message Key:%s.\n\n", $RMK;


# ----------------------------------------------------------------------
# ----- plugboard connections
# ----------------------------------------------------------------------
printf "Steckerverbindungen:%s.\n", $Steckerverbindungen if $debug;
my ($Steckerverbindungen1, $Steckerverbindungen2, $Steckerverbindungen3, $Steckerverbindungen4, $Steckerverbindungen5, $Steckerverbindungen6, $Steckerverbindungen7, $Steckerverbindungen8, $Steckerverbindungen9, $Steckerverbindungen10) = split(/ /, $Steckerverbindungen);


# ----------------------------------------------------------------------
# ----- sometimes used for the initial position of the rotors.  Operator was given a set (Kenngruppen) to choose from, then randomly selected his/her own & encoded with the rotors set to one of the Kenngruppen.
# ----------------------------------------------------------------------
printf "Kenngruppen:%s.\n", $Kenngruppen if $debug;
my $Grundstellung;
my ($Kenngruppen1, $Kenngruppen2, $Kenngruppen3, $Kenngruppen4) = split(/ /, $Kenngruppen);
if (defined $Kenngruppen1 && length $Kenngruppen1 > 0 && $Kenngruppen_no == 1 ) { $Grundstellung = $Kenngruppen1 } else { $Kenngruppen1 = '' };
if (defined $Kenngruppen2 && length $Kenngruppen2 > 0 && $Kenngruppen_no == 2 ) { $Grundstellung = $Kenngruppen2 } else { $Kenngruppen2 = '' };
if (defined $Kenngruppen3 && length $Kenngruppen3 > 0 && $Kenngruppen_no == 3 ) { $Grundstellung = $Kenngruppen3 } else { $Kenngruppen3 = '' };
if (defined $Kenngruppen4 && length $Kenngruppen4 > 0 && $Kenngruppen_no == 4 ) { $Grundstellung = $Kenngruppen4 } else { $Kenngruppen4 = '' };


# ----------------------------------------------------------------------
# ----- Grundstellung and chosen kenngruppen may have to be slpit apart.
# ----------------------------------------------------------------------
printf "Grundstellung:%s.\n", $Grundstellung if $debug;

# ----------------------------------------------------------------------
# Make it hap'n Cap'n!
# ----------------------------------------------------------------------
printf "[%s], [%s] [%s] [%s] [%s], [%s] [%s] [%s] [%s],  [%s] [%s] [%s] [%s] [%s] [%s] [%s] [%s] [%s] [%s],  [%s] [%s] [%s] [%s]\n", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Walzenlage4, $Ringstellung1, $Ringstellung2, $Ringstellung3, $Ringstellung4, $Steckerverbindungen1, $Steckerverbindungen2, $Steckerverbindungen3, $Steckerverbindungen4, $Steckerverbindungen5, $Steckerverbindungen6, $Steckerverbindungen7, $Steckerverbindungen8, $Steckerverbindungen9, $Steckerverbindungen10, $Kenngruppen1, $Kenngruppen2, $Kenngruppen3, $Kenngruppen4 if $debug;
if (defined $Walzenlage4 && length $Walzenlage4 > 0) {
    printf "http://enigma.louisedade.co.uk/enigma.html?m4;%s;b%s%s%s;A%s%s%s;A%s;%s-%s-%s-%s-%s-%s-%s-%s-%s-%s\n", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung1, $Ringstellung2, $Ringstellung3, $Grundstellung, $Steckerverbindungen1, $Steckerverbindungen2, $Steckerverbindungen3, $Steckerverbindungen4, $Steckerverbindungen5, $Steckerverbindungen6, $Steckerverbindungen7, $Steckerverbindungen8, $Steckerverbindungen9, $Steckerverbindungen10;
    printf "encrypt %s with %s as Grundstellung, set new Grundstellung to %s and encrypt the message.\n\n", $RMK, $Grundstellung, $RMK;
    printf "http://enigma.louisedade.co.uk/enigma.html?m4;%s;b%s%s%s;A%s%s%s;A%s;%s-%s-%s-%s-%s-%s-%s-%s-%s-%s\n", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung1, $Ringstellung2, $Ringstellung3, $RMK, $Steckerverbindungen1, $Steckerverbindungen2, $Steckerverbindungen3, $Steckerverbindungen4, $Steckerverbindungen5, $Steckerverbindungen6, $Steckerverbindungen7, $Steckerverbindungen8, $Steckerverbindungen9, $Steckerverbindungen10;
} else {
    printf "http://enigma.louisedade.co.uk/enigma.html?m3;%s;b%s%s%s;A%s%s%s;A%s;%s-%s-%s-%s-%s-%s-%s-%s-%s-%s\n", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung1, $Ringstellung2, $Ringstellung3, $Grundstellung, $Steckerverbindungen1, $Steckerverbindungen2, $Steckerverbindungen3, $Steckerverbindungen4, $Steckerverbindungen5, $Steckerverbindungen6, $Steckerverbindungen7, $Steckerverbindungen8, $Steckerverbindungen9, $Steckerverbindungen10;
    printf "encrypt %s with %s as Grundstellung, set new Grundstellung to %s and encrypt the message.\n\n", $RMK, $Grundstellung, $RMK;
    printf "http://enigma.louisedade.co.uk/enigma.html?m3;%s;b%s%s%s;A%s%s%s;A%s;%s-%s-%s-%s-%s-%s-%s-%s-%s-%s\n", $Umkehrwalze, $Walzenlage1, $Walzenlage2, $Walzenlage3, $Ringstellung1, $Ringstellung2, $Ringstellung3, $RMK, $Steckerverbindungen1, $Steckerverbindungen2, $Steckerverbindungen3, $Steckerverbindungen4, $Steckerverbindungen5, $Steckerverbindungen6, $Steckerverbindungen7, $Steckerverbindungen8, $Steckerverbindungen9, $Steckerverbindungen10;
};

my $min_pad = 1;
my $max_pad = 26;
my $pad_char = chr(64 + $min_pad + int(rand($max_pad - $min_pad)));

my $min_loc = 0;
my $max_loc = 100;
my $char_loc = $min_loc + int(rand($max_loc - $min_loc));

# 140 - 21 (banner) - 2 (CRLF) - 25 (header) - 2 (CRLF) = 90
# 90/5 = 18 character blocks (4 characters + space or carriage return)
# 17 * 4 = 72
# 71 - 1 (trailing equal sign) - 4 MESSAGE LINE FEEDS = 67 characters in message
printf "break message into 67 character chunks.\n\n";

printf "enigma msg of the day\n";
if ($char_loc > 50) {
    printf "19|1tle|1tle|#chars|%s|___=\n%s%s \n=", $Grundstellung, $pad_char, $Grundstellung;
} else {
    printf "19|1tle|1tle|#chars|%s|___=\n%s%s \n=", $Grundstellung, $Grundstellung, $pad_char;
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
