package Melick::dbLib;

# Copyright (c) 2014 Lyle Melick.  All rights reserved.  This
# program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ----- this module provides tools to connect to databases
#       Lyle Melick - lyle@melick.net
#       Last Update - 2014 October 21 - Created
#
# v76
# 2017-Jun-08 02:03:57PM


require 5.14.0;
require Exporter;


BEGIN {
        use Exporter   ();

        @ISA        = qw(Exporter);
        @EXPORT     = qw(connection $dbh $SQL_Instance $SQL_Engine $SQL_Server $SQL_User $SQL_Database $SQL_Schema
                         mkObject
                         ckObject );
}


sub connection {

    my ($which_db) = @_;
    #printf "w:[%s]\n", $which_db;

    # -----------------------------------------------------------------
    # ----- (pointer in /etc/odbc.ini on BBDEB001)
    if ($which_db eq 'Enigma') {

        our $SQL_Instance = 'Enigma';   # ----- not really used for MySQL
        our $SQL_Engine   = 'mysql';
        our $SQL_Server   = 'Aurora';   # ----- machine name of server
        our $SQL_User     = 'melick';
        our $SQL_Database = 'enigma';
        our $SQL_Schema   = 'dbo';      # ----- probably not really used for MySQL


    }


    # -----------------------------------------------------------------
    # ----- pull the password from Davey Jone's Locker
    use Crypt::GCM;
    use Crypt::Rijndael;


    my %PasswordStore = (
        'melick' => 'ed0b0ed0bccd088ccd30b2c47e5fc855d7b1296128a10419c17de4709cafc462:8a2ed4d001e2d7bb45bba2090104af7e5ed14553:b8ca02dcde49550a74043da0:61e1b49fa8d1b7ecc1871c804a9e16d1:fc122a329462d6cbccdc53882a6a7e0394a79539da60f98e1e23a5',
    'LyleMelick' => '0c74a8888f27d2c2c1fc8edfa9f14f512946b2bcdee3de9ba9fe9b27fae3eaba:52616fde04d1e389d8e3c52cfb6836b5b90b046b:20681834b922da4760f3d67a:7bca6c8d2c6492efff3f0bb3dfbdaa9c:f0ceabe6',
    );
    #printf "u:[%s]\n", $SQL_User;
    my ($key, $aad, $iv, $tag, $ciphertext) = split(/\:/, $PasswordStore{$SQL_User});
    #printf "%s:%s:%s:%s:%s.\n",
    $key, $aad, $iv, $tag, $ciphertext;


    # ----- unpack the password
    my $gcm2 = Crypt::GCM->new(
        -key => pack('H*', $key),
        -cipher => 'Crypt::Rijndael',
    );
    $gcm2->set_iv(pack 'H*', $iv);
    $gcm2->aad(pack 'H*', $aad);
    $gcm2->tag(pack 'H*', $tag);
    my $plaintext = $gcm2->decrypt(pack 'H*', $ciphertext);
    our $SQL_Password = unpack 'H*', $plaintext;

    # ----- convert each two digit into char code
    $SQL_Password =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;



    # -----------------------------------------------------------------
    # ----- Connect to the database already!
    use DBI();
    #printf "%s:%s [%s] [%s] [%s] [%s] [%s] [%s]\n", $which_db, $SQL_Engine, $SQL_Instance, $SQL_Server, $SQL_Database, $SQL_Schema, $SQL_User , $SQL_Password;
    if ($SQL_Engine eq 'ODBC') {
        our $dbh = DBI->connect("DBI:$SQL_Engine:$SQL_Server", "$SQL_User", "$SQL_Password", {PrintError => 0, RaiseError => 1, odbc_exec_direct => 1}) or die "Can't connect to database: $DBI::errstr\n"; #$dbh->trace(1);
        $dbh->do("SET ANSI_NULLS ON");
        $dbh->do("SET ANSI_WARNINGS ON");
    } elsif ($SQL_Engine eq 'mysql') {
        our $dbh = DBI->connect("DBI:$SQL_Engine:database=$SQL_Database;host=$SQL_Server", "$SQL_User", "$SQL_Password", {PrintError => 0, RaiseError => 1}) or die "Can't connect to database: $DBI::errstr\n"; #$dbh->trace(1);
    }


    my $use_stmt = join('', "USE ", $SQL_Database, ';');
    $dbh->do($use_stmt);
    $dbh;

}


# ----- put your toys away little Johnny


# ----- HC SVNT DRACONES -----
=begin GHOSTCODE

my $which_db = 'db_handle';

# ----- database handle
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
#printf "dbh: [%s]\n", $dbh;
=end GHOSTCODE
=cut

