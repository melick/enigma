# enigma
enigma code book generator and message creator

ChangeLog.txt, LICENSE, and this README.md are self explanatory.

mkCodeBook.pl will create a codebook.  mkCodeBook.sh is a bash script
that drives the perl to create three monthly codebooks.  The codebook
settings are stored in a mySql database in a table called CodeBook
(table_CodeBook.sql).  These files produce a txt file and a pdf for
each of the patrols (Red Stallion, Pioneer and Viking).

uploadMedia.pl will eventually upload the codebook PDFs to
https://melick.wordpress.com.  table_Media.sql will hold a record
of what has been uploaded.

table_Messages.sql will eventually hold a record of messages sent.

Details are stored in a config.yaml file (not in GitHub for obvious
reasons).

EnigmaWeather.py was recently added to pull current weather for
my location with the thought that that could be automated as a
6:00am message everyday.

Note that I'm using the enigma simulator from:
    http://www.crufty.net/sjg/blog/EnigmaEmulator.htm
to actually encode the messages.  It sits in a subdirectory
in the enigma directory on my raspberry pi machines

------------------------------------------------------------------------

    Sample message and decoding process

    PIO DE CTU 1236 = 13 = IYW NPZ = BRIGP BCKE KVAH EPS
    --- -- --- ----   --   --- ---   ----- -------------
     |   |  |    |     |    |   |      |          |
     |   |  |    |     |    |   |      |          +----- encrypted message
     |   |  |    |     |    |   |      |                 
     |   |  |    |     |    |   |      +---------------- One of the Kenngruppen 
     |   |  |    |     |    |   |                        padded with two random
     |   |  |    |     |    |   |                        characters.  (not decoded
     |   |  |    |     |    |   |                        as part of the message)
     |   |  |    |     |    |   +----------------------- encrypted message key
     |   |  |    |     |    |                            
     |   |  |    |     |    +--------------------------- daily key, from CodeBook Gnd column
     |   |  |    |     |                                 
     |   |  |    |     +-------------------------------- number of characters in the encrypted message
     |   |  |    |                                       
     |   |  |    +-------------------------------------- time of message (24 hour clock?)
     |   |  |                                            
     |   |  +------------------------------------------- destination organization if DE, sending organization if EN
     |   |                                               
     |   +---------------------------------------------- EN/DE, to or from
     |                                                   
     +-------------------------------------------------- sending organization if DE, destination organization if EN

    This message was sent from CTU to the Pioneer patrol at 12:36PM.
    It was 13 characters long.  Daily key was IYW, encrypted message
    key was NPZ.  This message was sent on September 22, 2017.

    Set up enigma according to CodeBook, xxcrypt NPZ to get message
    key of ZGH.  Set Grundstellung to ZGH and decrypt the message.
    You should get "HELL OXWO RLD"

    As a check, you'll find one of the Kenngruppen words in the
    first group of 5 characters after the last "=" sign.  In this
    case IGP.

------------------------------------------------------------------------

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

------------------------------------------------------------------------


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
