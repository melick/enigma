#!/usr/bin/perl

# ----- this will post a tweet
#       Lyle Melick - lyle@melick.net - Melick's Hardware
#       Last Update - 2017 June 28 - Created
#
# $WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$
# $WCDATE=%Y-%b-%d %I:%M:%S%p$
#
# usage: /usr/bin/perl /home/melick/enigma/TwitterBot.pl -v -t "Hello World!"

use strict;
use warnings;

my $which_db = 'Enigma';

# ----- database handle
use lib '/home/melick/perl5/lib/perl5';
use Melick::dbLib qw(connection ckObject );
my $dbh = &connection($which_db);
#printf "dbh: [%s]\n", $dbh;

# ----- handle the options passed
use Getopt::Long;
my $tweet = "";
my $url = "";
my $hashtag = "";
my $verbose;
GetOptions ("tweet=s" => \$tweet,    # string
            "verbose" => \$verbose)  # flag
or die("Error in command line arguments\n");

# ----- http://perltricks.com/article/154/2015/2/23/Build-a-Twitter-bot-with-Perl/
use Net::Twitter::Lite::WithAPIv1_1;
use Try::Tiny;


tweet($tweet, $url, $hashtag);


# ----- https://perlmaven.com/sending-tweets-from-a-perl-script
# could also pull down previous tweets, decode and post



# ----- HC SVNT DRACONES

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