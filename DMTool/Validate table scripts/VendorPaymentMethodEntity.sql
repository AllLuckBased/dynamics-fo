CREATE OR ALTER PROCEDURE PWC_SP_Validate_VendorPaymentMethodEntity
AS
BEGIN

-- Mandatory field missing:
-- Name is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'Name' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'Name is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE 
Name = '' OR Name IS NULL;



-- Business required fields missing:
-- AccountType is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'AccountType' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'AccountType is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE 
AccountType = '' OR AccountType IS NULL;

-- BankTransactionType is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'BankTransactionType' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'BankTransactionType is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE 
BankTransactionType = '' OR BankTransactionType IS NULL;

-- PaymentAccountDisplayValue is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'PaymentAccountDisplayValue' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'PaymentAccountDisplayValue is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE 
PaymentAccountDisplayValue = '' OR PaymentAccountDisplayValue IS NULL;

-- PaymentType is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'PaymentType' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'PaymentType is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE 
PaymentType = '' OR PaymentType IS NULL;



-- Invalid Enum Values
	-- PaymentType enum has invalid enum values
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_VendorPaymentMethodEntity' TABLEID, 
		'PaymentType' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'PaymentType enum has invalid enum values' ERRORDESC, 
		PaymentType ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_VendorPaymentMethodEntity A
	WHERE 
		PaymentType IS NOT NULL 
		AND PaymentType NOT IN (
			SELECT MEMBERNAME 
			FROM RETAILENUMVALUETABLE 
			WHERE ENUMNAME LIKE 'PaymentType'
		);




-- Duplicate occurrence:
-- Name has duplicate values
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_VendorPaymentMethodEntity' TABLEID, 
    'Name' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(Name) > 10 THEN 
            'Name has duplicate values upon truncation'
        ELSE 
            'Name has duplicate values'
    END ERRORDESC, 
    Name ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE 
    CONCAT(LEFT(Name, 10), DATAAREAID) IN (
    SELECT CONCAT(LEFT(Name, 10), DATAAREAID) 
    FROM PWC_T_VendorPaymentMethodEntity
    GROUP BY LEFT(Name, 10), DATAAREAID 
    HAVING COUNT(*) > 1
);



-- Invalid submaster reference
-- PaymentAccountDisplayValue validation for Bank Account
INSERT INTO PWCERRORTABLE
SELECT * FROM (SELECT 
    'PWC_T_VendorPaymentMethodEntity' TABLEID, 
    CASE 
        WHEN COUNT(B.BankAccountId) = 0 THEN 'PaymentAccountDisplayValue'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PaymentAccountDisplayValue,[PWC_T_BankAccountEntity]'
    END ERRORCOLUMN,
    A.PWCROWID ROWID, 
    CASE 
        WHEN COUNT(B.BankAccountId) = 0 THEN 4
        WHEN COUNT(E.CATEGORY) <> 0 THEN 5
    END CATEGORY, 
    CASE 
        WHEN COUNT(B.BankAccountId) = 0 THEN 'PaymentAccountDisplayValue is not present in BankAccountId of PWC_T_BankAccountEntity if ACCOUNTTYPE is Bank'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_BankAccountEntity has error(s) in corresponding BankAccountId'
    END ERRORDESC,
    A.PaymentAccountDisplayValue ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
LEFT JOIN PWC_T_BankAccountEntity B
    ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.PaymentAccountDisplayValue = B.BankAccountId
LEFT JOIN PWCERRORTABLE E
    ON E.TABLEID = 'PWC_T_BankAccountEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
        AND B.PWCROWID = E.ROWID
WHERE 
    A.PaymentAccountDisplayValue IS NOT NULL AND A.PaymentAccountDisplayValue != '' AND
    A.AccountType LIKE 'BANK'
GROUP BY TABLEID, A.PWCROWID, A.PaymentAccountDisplayValue, A.DATAAREAID) a
WHERE CATEGORY IS NOT NULL;

-- PaymentAccountDisplayValue validation for Main Account
INSERT INTO PWCERRORTABLE
SELECT * FROM (SELECT 
    'PWC_T_TAXSERVICETAXREGISTRATIONNUMBERVENDORS' TABLEID, 
    CASE 
        WHEN COUNT(B.MAINACCOUNTID) = 0 THEN 'PaymentAccountDisplayValue'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PaymentAccountDisplayValue,[PWC_T_MainAccountEntity]'
    END ERRORCOLUMN,
    A.PWCROWID ROWID, 
    CASE 
        WHEN COUNT(B.MAINACCOUNTID) = 0 THEN 4
        WHEN COUNT(E.CATEGORY) <> 0 THEN 5
    END CATEGORY, 
    CASE 
        WHEN COUNT(B.MAINACCOUNTID) = 0 THEN 'PaymentAccountDisplayValue is not present in MAINACCOUNTID of PWC_T_MainAccountEntity if ACCOUNTTYPE is Ledger'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_MainAccountEntity has error(s) in corresponding MAINACCOUNTID'
    END ERRORDESC,
    A.PaymentAccountDisplayValue ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
LEFT JOIN PWC_T_MainAccountEntity B
    ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.PaymentAccountDisplayValue = B.MAINACCOUNTID
LEFT JOIN PWCERRORTABLE E
    ON E.TABLEID = 'PWC_T_MainAccountEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
        AND B.PWCROWID = E.ROWID
WHERE 
    A.PaymentAccountDisplayValue IS NOT NULL AND A.PaymentAccountDisplayValue != '' AND
    A.AccountType LIKE 'LEDGER'
GROUP BY TABLEID, A.PWCROWID, A.PaymentAccountDisplayValue, A.DATAAREAID) a
WHERE CATEGORY IS NOT NULL;





-- String length exceeded maximum
-- Description exceeds max length 60
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'Description' ERRORCOLUMN, 
PWCROWID ROWID, 
7 CATEGORY, 
'Description exceeds max length 60' ERRORDESC, 
Description ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE LEN(Description) > 60;

-- Name exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_VendorPaymentMethodEntity' TABLEID, 
'Name' ERRORCOLUMN, 
PWCROWID ROWID, 
7 CATEGORY, 
'Name exceeds max length 10' ERRORDESC, 
Name ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_VendorPaymentMethodEntity A
WHERE LEN(Name) > 10;

EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_VendorPaymentMethodEntity'
END
