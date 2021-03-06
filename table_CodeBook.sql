USE enigma;

DROP TABLE `CodeBook`;

-- field length = 16 * (trunc(string_length / 16) + 1)  per MySQL
CREATE TABLE `CodeBook` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Patrol` VARBINARY(64) NOT NULL,
    `date` DATE NOT NULL,
    `Umkehrwalze` VARBINARY(64) NOT NULL,
    `Walzenlage1` VARBINARY(16) NOT NULL,
    `Walzenlage2` VARBINARY(16) NOT NULL,
    `Walzenlage3` VARBINARY(16) NOT NULL,
    `Walzenlage4` VARBINARY(16) NOT NULL,
    `Ringstellung` VARBINARY(16) NOT NULL,
    `Grundstellung` VARBINARY(16) NOT NULL,
    `Steckerverbindungen` VARBINARY(256) NOT NULL,
    `Kenngruppen` VARBINARY(16) NOT NULL,
    `Revision` VARBINARY(256) NOT NULL,
    `LastUpdate` DATETIME NOT NULL
)
ENGINE = InnoDB
COMMENT = "all codebook entries"
;

/*
-- SAMPLE CODE --
DECLARE @key VARCHAR(255);

DECLARE @Patrol VARCHAR(50);
DECLARE @Umkehrwalze VARCHAR(50);
DECLARE @Walzenlage1 VARCHAR(4);
DECLARE @Walzenlage2 VARCHAR(4);
DECLARE @Walzenlage3 VARCHAR(4);
DECLARE @Walzenlage4 VARCHAR(4);
DECLARE @Ringstellung VARCHAR(3);
DECLARE @Grundstellung VARCHAR(3);
DECLARE @Steckerverbindungen VARCHAR(255);
DECLARE @Kenngruppen VARCHAR(15);
DECLARE @Revision VARCHAR(255);

-- SET @key = 'Red Stallion';
SET @key = UNHEX(SHA2('Red Stallion',512));


SET @Patrol = '12345678901234567890123456789012345678901234567890';
SET @Umkehrwalze = '12345678901234567890123456789012345678901234567890';
SET @Walzenlage1 = '1234';
SET @Walzenlage2 = '1234';
SET @Walzenlage3 = '1234';
SET @Walzenlage4 = '1234';
SET @Ringstellung = '123';
SET @Grundstellung = '123';
SET @Steckerverbindungen = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890ABCDE';
SET @Kenngruppen = '123456789012345';
SET @Revision = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890ABCDE';

-- http://thinkdiff.net/mysql/encrypt-mysql-data-using-aes-techniques/
INSERT INTO `CodeBook` (`Patrol`, `date`, `Umkehrwalze`, `Walzenlage1`, `Walzenlage2`, `Walzenlage3`, `Walzenlage4`, `Ringstellung`, `Grundstellung`, `Steckerverbindungen`, `Kenngruppen`, `Revision`, `LastUpdate`) VALUES (
AES_ENCRYPT(@Patrol,@key),
'2016-06-16',
AES_ENCRYPT(@Umkehrwalze,@key),
AES_ENCRYPT(@Walzenlage1,@key),
AES_ENCRYPT(@Walzenlage2,@key),
AES_ENCRYPT(@Walzenlage3,@key),
AES_ENCRYPT(@Walzenlage4,@key),
AES_ENCRYPT(@Ringstellung,@key),
AES_ENCRYPT(@Grundstellung,@key),
AES_ENCRYPT(@Steckerverbindungen,@key),
AES_ENCRYPT(@Kenngruppen,@key),
AES_ENCRYPT(@Revision,@key),
NOW());


SET @key = UNHEX(SHA2('Red Stallion',512));

SELECT AES_DECRYPT(`Patrol`,@key)
     , `date`
     , AES_DECRYPT(`Umkehrwalze`,@key)
     , AES_DECRYPT(`Walzenlage1`,@key)
     , AES_DECRYPT(`Walzenlage2`,@key)
     , AES_DECRYPT(`Walzenlage3`,@key)
     , AES_DECRYPT(`Walzenlage4`,@key)
     , AES_DECRYPT(`Ringstellung`,@key)
     , AES_DECRYPT(`Grundstellung`,@key)
     , AES_DECRYPT(`Steckerverbindungen`,@key)
     , AES_DECRYPT(`Kenngruppen`,@key)
     , AES_DECRYPT(`Revision`,@key)
     , `LastUpdate`
  FROM `CodeBook`;
*/


/* field size conversions
=16*(TRUNC(A2/16) + 1)
varchar varbinary
50      64
4       16
3       16
255     256
15      16
100     112
*/
