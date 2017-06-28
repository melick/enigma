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
        'melick' => 'ed0b0ed0bccd088ccd30b2c47e5fc855d7b1296128a10419c17de4709cafc462:8a2ed4d001e2d7bb45bba2090104af7e5ed14553:b8ca02dcde49550a74043da0:61e1b49fa8d1b7ecc1871c804a9e16d1:fc122a329462d6cbccdc53882a6a7e0394a79539da60f98e1e23a5',
    'LyleMelick' => '0c74a8888f27d2c2c1fc8edfa9f14f512946b2bcdee3de9ba9fe9b27fae3eaba:52616fde04d1e389d8e3c52cfb6836b5b90b046b:20681834b922da4760f3d67a:7bca6c8d2c6492efff3f0bb3dfbdaa9c:f0ceabe6',
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
