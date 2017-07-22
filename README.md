# enigma
enigma code book generator and message creator

ChangeLog.txt, LICENSE, and this README.md are self explanatory.

mkCodeBook.pl will create a codebook.  mkCodeBook.sh is a bash script
that drives the perl to create three monthly codebooks.  The codebook
settings are stored in a mySql database in a table called CodeBook
(table_CodeBook.svn).  These files produce a txt file and a pdf for
each of the patrols (Red Stallion, Pioneer and Viking).

uploadMedia.pl will eventually upload the codebook PDFs to
https://melick.wordpress.com

OneRing.pl currently creates some links for encypting the messages.
Eventually it will create the message from a prepopulated database
table called Messages (table_Messages.svn [TBD]).

TwitterBot.pl will post a message to a twitter account.

Details are stored in a config.yaml file (not in GitHub for obvious
reasons).

I use a private build.bat and WinSCP script to help automate the
version control process.


BACKGROUND
from http://users.telenet.be/d.rijmenants/en/enigmatech.htm

Default rotors, used by the Wehrmacht and Kriegsmarine
------------------------------------------------------------------------
Entry = ABCDEFGHIJKLMNOPQRSTUVWXYZ (rotor right side)   
        ||||||||||||||||||||||||||
I     = EKMFLGDQVZNTOWYHXUSPAIBRCJ
II    = AJDKSIRUXBLHWTMCQGZNPYFVOE
III   = BDFHJLCPRTXVZNYEIWGAKMUSQO
IV    = ESOVPZJAYQUIRHXLNFTGKDCMWB
V     = VZBRGITYUPSDNHLXAWMJQOFECK


Additional rotors used by Kriegsmarine M3 and M4 only:
------------------------------------------------------------------------
Entry = ABCDEFGHIJKLMNOPQRSTUVWXYZ (rotor right side)   
        ||||||||||||||||||||||||||
VI    = JPGVOUMFYQBENHZRDKASXLICTW
VII   = NZJHGRCXMYSWBOUFAIVLPEKQDT
VIII  = FKQHTLXOCBJSPDZRAMEWNIUYGV


The special fourth rotors, also called Zusatzwalzen or Greek rotors.
Used on the Kriegsmarine M4 with thin reflectors only:
------------------------------------------------------------------------
Entry = ABCDEFGHIJKLMNOPQRSTUVWXYZ (rotor right side)   
        ||||||||||||||||||||||||||
Beta  = LEYJVCNIXWPBQMDRTAKZGFUHOS
Gamma = FSOKANUERHMBTIYCWLQPZXVGJD



The reflector (Umkehrwalze or UKW in German) is a unique feature of the
Enigma machine. On the normal rotors, each letter can be wired with any
other letter. An 'A' could be wired to 'F', while the 'F' is wired to 'K'.
In the reflector, the connections are made in loop pairs. In the case
of the wide B reflector, the 'A' is wired to the 'Y' which means that
the 'Y' is also wired to the 'A', resulting in a reciprocal encryption.
The advantage of this design is that encryption and decryption are
possible with the same machine setting and wiring. Unfortunately, a
letter can never be encrypted into itself, a property that opened the
door to cryptanalysis, making the job easier to the codebreakers.


Default wide reflectors Wehrmacht and Luftwaffe:
------------------------------------------------------------------------
Contacts    = ABCDEFGHIJKLMNOPQRSTUVWXYZ                
              ||||||||||||||||||||||||||
Reflector B = YRUHQSLDPXNGOKMIEBFZCWVJAT
Reflector C = FVPJIAOYEDRZXWGCTKUQSBNMHL


Thin reflectors, Kriegsmarine M4 only:
------------------------------------------------------------------------
Contacts         = ABCDEFGHIJKLMNOPQRSTUVWXYZ           
                   ||||||||||||||||||||||||||
Reflector B Thin = ENKQAUYWJICOPBLMDXZVFTHRGS
Reflector C Thin = RDOBJNTKVEHMLFCWZAXGYIPSUQ

The wirings as described here, are for the rotors for Wehrmacht (Heer and
Luftwaffe) and Kriegsmarine Enigma's only. The rotors for other versions
of the Enigma machine had other internal wirings.
