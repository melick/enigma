#!/usr/bin/perl

# ----- this /usr/bin/perl will create keys for dbLib.pm
#       Lyle Melick - LMelick@SSandG.com - SS&G Healthcare Services LLC
#       Last Update - 2014 October 21 - Created
#
# $WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$
# $WCDATE=%Y-%b-%d %I:%M:%S%p$
#
# usage: /usr/bin/perl /home/melick/enigma/decypher.pl -U <username>
# example: /usr/bin/perl /home/melick/enigma/decypher.pl -U BigFatWhiteGuy
# ----- assumes there's already an entry in the PasswordStore for the user.


use strict;
use warnings;


use Getopt::Long;
my $username = "";
my $verbose;
GetOptions ("username=s" => \$username,    # string
            "verbose"    => \$verbose)     # flag
or die("Error in command line arguments\n");


use Crypt::GCM;
use Crypt::Rijndael;


my %PasswordStore = (
    # ----- the meat goes here
);
my ($key, $aad, $iv, $tag, $ciphertext) = split(/\:/, $PasswordStore{$username});


# ----- unpack the password
my $gcm2 = Crypt::GCM->new(
    -key => pack('H*', $key),
    -cipher => 'Crypt::Rijndael',
);
$gcm2->set_iv(pack 'H*', $iv);
$gcm2->aad(pack 'H*', $aad);
$gcm2->tag(pack 'H*', $tag);
my $plaintext = $gcm2->decrypt(pack 'H*', $ciphertext);
my $password = unpack 'H*', $plaintext;

# ----- convert each two digit into char code
$password =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
printf "[%s]\n", $password;

# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut
