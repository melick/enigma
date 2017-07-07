# enigma
enigma code book generator and message creator

ChangeLog.txt, LICENSE, and this README.md are self explanatory.

TwitterBot.pl will post a message to a twitter account.
Details are stored in a config.yaml file (not in GitHub for obvious reasons).

mkCodeBook.pl will create a codebook.  mkCodeBook.sh is a bash script that drives the perl.
The settings are stored in a mySql database in a table called CodeBook (table_CodeBook.svn).

OneRing.pl currently creates some links for encypting the messages.
Eventually it will create the message from a prepopulated database
table called Messages (table_Messages.svn [TBD]).