#! /bin/bash

# =====================================================================
# Author:      Lyle Melick - Red Stallion Patrol
# Create date: 2015 March 23
# Description: creates the codebook - run from crontab
#
# $WCMIXED?[$WCRANGE$]:v$WCREV$$ $WCMODS?with local mods:$
# $WCDATE=%Y-%b-%d %I:%M:%S%p$
# =====================================================================

# ----- pull the date for file name fun
today=`date '+%Y-%m'`;
echo $today

# ----- this will create the codebook.  The only output is the pdf file and a text file for use in OneRing.pl
/usr/bin/perl /users/melick/enigma/mkCodeBook.pl > /users/melick/enigma/CodeBook-$today.txt
cat /users/melick/enigma/CodeBook-$today.txt | /usr/bin/todos | /usr/bin/a2ps --chars-per-line=104 --columns=1 --landscape --no-header --output=- | /usr/bin/ps2pdf - /users/melick/enigma/CodeBook-$today.pdf

