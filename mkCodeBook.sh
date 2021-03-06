#! /bin/bash

# =====================================================================
# Author:      Lyle Melick - Red Stallion Patrol
# Create date: 2015 March 23
# Description: creates the codebook - run from crontab
#
# $Id$
# =====================================================================

# ----- pull the date for file name fun
today=`date '+%Y-%m'`;
echo ${today}

# ----- this will create the 'Red Stallion' patrol codebook.
/usr/bin/perl /home/melick/enigma/mkCodeBook.pl --patrol 'Red Stallion' --start ${today}-01 > /home/melick/enigma/CodeBook-RS-${today}.txt
cat /home/melick/enigma/CodeBook-RS-${today}.txt | /usr/bin/unix2dos | /usr/bin/a2ps --chars-per-line=104 --columns=1 --landscape --no-header --output=- | /usr/bin/ps2pdf - /home/melick/enigma/CodeBook-RS-${today}.pdf

# ----- this will create the 'Viking' patrol codebook.
/usr/bin/perl /home/melick/enigma/mkCodeBook.pl --patrol 'Viking' --start ${today}-01  > /home/melick/enigma/CodeBook-V-${today}.txt
cat /home/melick/enigma/CodeBook-V-${today}.txt | /usr/bin/unix2dos | /usr/bin/a2ps --chars-per-line=104 --columns=1 --landscape --no-header --output=- | /usr/bin/ps2pdf - /home/melick/enigma/CodeBook-V-${today}.pdf

# ----- this will create the 'Pioneer' patrol codebook.
/usr/bin/perl /home/melick/enigma/mkCodeBook.pl --patrol 'Pioneer' --start ${today}-01  > /home/melick/enigma/CodeBook-P-${today}.txt
cat /home/melick/enigma/CodeBook-P-${today}.txt | /usr/bin/unix2dos | /usr/bin/a2ps --chars-per-line=104 --columns=1 --landscape --no-header --output=- | /usr/bin/ps2pdf - /home/melick/enigma/CodeBook-P-${today}.pdf
