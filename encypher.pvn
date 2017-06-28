#!/usr/bin/perl

# ----- this /usr/bin/perl will create keys for dbLib.pm
#       Lyle Melick - LMelick@SSandG.com - SS&G Healthcare Services LLC
#       Last Update - 2014 October 21 - Created
#
# $WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$ 
# $WCDATE=%Y-%b-%d %I:%M:%S%p$
#
# usage: /usr/bin/perl /home/lmelick/CryptKeeper/encypher.pl -u <username> -p <password>
# example: /usr/bin/perl /home/lmelick/CryptKeeper/encypher.pl -v -p "0penS3zMe$@!" -u BigFatWhiteGuy


use strict;
use warnings;


use Getopt::Long;
my $password = "";
my $username = "";
my $verbose;
GetOptions ("username=s" => \$username,    # string
            "password=s" => \$password,    # string
            "verbose"    => \$verbose)     # flag
or die("Error in command line arguments\n");


use Crypt::GCM;
use Crypt::Rijndael;


use Bytes::Random::Secure qw( random_bytes_hex );
my $random_bytes_hex = Bytes::Random::Secure->new(
    Bits        => 64,
    NonBlocking => 1,
); # Seed with 64 bits, and use /dev/urandom (or other non-blocking).


# ----- muddle the "message" a bit.
my $message = $password;
$message =~ s/(.)/sprintf("%x",ord($1))/eg;


# ----- encryption parameters
printf "thinking...\n";
my $key = random_bytes_hex(32); # 256 bit;
my $aad = random_bytes_hex(20); # 160 bit; 
my $iv = random_bytes_hex(12);  # 96 bit - for compatibility & efficiency;  
printf "done.\n";
# ----- output of encryption pass.
my $tag = '';
my $ciphertext = '';


# ----- use this to generate tag & ciphertext
my $gcm = Crypt::GCM->new(
    -key => pack('H*', $key),
    -cipher => 'Crypt::Rijndael',
);
$gcm->set_iv(pack 'H*', $iv);
$gcm->aad(pack 'H*', $aad);
$ciphertext = unpack 'H*', $gcm->encrypt(pack 'H*', $message);
$tag = unpack 'H*', $gcm->tag();


# ----- print out all this lovely stuff
my $sec_blob = join(':', $key, $aad, $iv, $tag, $ciphertext); 
#print "my %PasswordStore = (\n";
printf "    '%s' => '%s',\n", $username, $sec_blob;
#print ");\n";
#print "my (\$key, \$aad, \$iv, \$tag, \$ciphertext) = split(/\\:/, \$PasswordStore{\$username});\n";


# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut