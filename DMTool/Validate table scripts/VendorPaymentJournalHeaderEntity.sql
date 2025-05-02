CREATE OR ALTER PROCEDURE PWC_SP_Validate_VendorPaymentJournalHeaderEntity
AS
BEGIN

-- Mandatory field missing:
-- JOURNALBATCHNUMBER is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'JOURNALBATCHNUMBER' ERRORCOLUMN, 
    PWCROWID ROWID, 
    1 CATEGORY, 
    'JOURNALBATCHNUMBER is blank' ERRORDESC, 
    '' ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE 
    JOURNALBATCHNUMBER = '' OR JOURNALBATCHNUMBER IS NULL;



-- Business reqd fields missing
-- JOURNALNAME is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'JOURNALNAME' ERRORCOLUMN, 
    PWCROWID ROWID, 
    8 CATEGORY, 
    'JOURNALNAME is blank' ERRORDESC, 
    '' ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE 
    JOURNALNAME = '' OR JOURNALNAME IS NULL;

-- DESCRIPTION is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'DESCRIPTION' ERRORCOLUMN, 
    PWCROWID ROWID, 
    8 CATEGORY, 
    'DESCRIPTION is blank' ERRORDESC, 
    '' ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE 
    DESCRIPTION = '' OR DESCRIPTION IS NULL;




-- Duplicate occurrence:
-- JOURNALBATCHNUMBER, DATAAREAID has duplicates
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'JOURNALBATCHNUMBER' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(JOURNALBATCHNUMBER) > 20 THEN 
            'JOURNALBATCHNUMBER has duplicate values upon truncation in ' + DATAAREAID
        ELSE 
            'JOURNALBATCHNUMBER has duplicate values in ' + DATAAREAID
    END ERRORDESC, 
    JOURNALBATCHNUMBER ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE 
    CONCAT(LEFT(JOURNALBATCHNUMBER, 20), DATAAREAID) IN (
    SELECT CONCAT(LEFT(JOURNALBATCHNUMBER, 20), DATAAREAID) 
    FROM PWC_T_VendorPaymentJournalHeaderEntity
    GROUP BY LEFT(JOURNALBATCHNUMBER, 20), DATAAREAID 
    HAVING COUNT(*) > 1
);




-- Duplicate occurrence:
-- JOURNALBATCHNUMBER, DATAAREAID has duplicates
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'JOURNALBATCHNUMBER' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(JOURNALBATCHNUMBER) > 20 THEN 
            'JOURNALBATCHNUMBER has duplicate values upon truncation in ' + DATAAREAID
        ELSE 
            'JOURNALBATCHNUMBER has duplicate values in ' + DATAAREAID
    END ERRORDESC, 
    JOURNALBATCHNUMBER ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE 
    CONCAT(LEFT(JOURNALBATCHNUMBER, 20), DATAAREAID) IN (
    SELECT CONCAT(LEFT(JOURNALBATCHNUMBER, 20), DATAAREAID) 
    FROM PWC_T_VendorPaymentJournalHeaderEntity
    GROUP BY LEFT(JOURNALBATCHNUMBER, 20), DATAAREAID 
    HAVING COUNT(*) > 1
);



-- Invalid submaster reference
-- JOURNALNAME validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (
    SELECT 
        'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
        CASE 
            WHEN COUNT(B.Name) = 0 THEN 'JOURNALNAME'
            WHEN COUNT(E.CATEGORY) <> 0 THEN 'JOURNALNAME,[PWC_T_LedgerJournalNameEntity]'
        END ERRORCOLUMN, 
        A.PWCROWID ROWID, 
        CASE 
            WHEN COUNT(B.Name) = 0 THEN 4
            WHEN COUNT(E.CATEGORY) <> 0 THEN 5
        END CATEGORY, 
        CASE 
            WHEN COUNT(B.Name) = 0 THEN 'JOURNALNAME is not present in Name of PWC_T_LedgerJournalNameEntity where TYPE is like Payment'
            WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_LedgerJournalNameEntity has error(s) in corresponding Name'
        END ERRORDESC,
        A.JOURNALNAME ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_VendorPaymentJournalHeaderEntity A
    LEFT JOIN PWC_T_LedgerJournalNameEntity B
        ON (B.DATAAREAID = A.DATAAREAID OR UPPER(A.DATAAREAID) = 'GLOBAL' OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.JOURNALNAME = B.Name AND B.TYPE LIKE 'Payment'
    LEFT JOIN PWCERRORTABLE E
        ON E.TABLEID = 'PWC_T_LedgerJournalNameEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
            AND B.PWCROWID = E.ROWID
    WHERE 
        A.JOURNALNAME IS NOT NULL AND A.JOURNALNAME != ''
    GROUP BY A.PWCROWID, A.JOURNALNAME, A.DATAAREAID
) a
WHERE CATEGORY IS NOT NULL;






-- String length exceeded maximum:
-- JOURNALBATCHNUMBER exceeds max length 20
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'JOURNALBATCHNUMBER' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'JOURNALBATCHNUMBER exceeds max length 20' ERRORDESC, 
    JOURNALBATCHNUMBER ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE LEN(JOURNALBATCHNUMBER) > 20;

-- DESCRIPTION exceeds max length 60
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentJournalHeaderEntity' TABLEID, 
    'DESCRIPTION' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'DESCRIPTION exceeds max length 60' ERRORDESC, 
    DESCRIPTION ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentJournalHeaderEntity A
WHERE LEN(DESCRIPTION) > 60;

EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_VendorPaymentJournalHeaderEntity'
END
