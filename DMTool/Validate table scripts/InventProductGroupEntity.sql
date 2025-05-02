CREATE OR ALTER PROCEDURE PWC_SP_Validate_InventProductGroupEntity
AS
BEGIN

-- Mandatory field missing:
-- GROUPID is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_InventProductGroupEntity' TABLEID, 
'GROUPID' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'GROUPID is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_InventProductGroupEntity A
WHERE 
GROUPID = '' OR GROUPID IS NULL;

-- Business required fields missing:
-- GROUPNAME is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_InventProductGroupEntity' TABLEID, 
'GROUPNAME' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'GROUPNAME is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_InventProductGroupEntity A
WHERE 
GROUPNAME = '' OR GROUPNAME IS NULL;



-- Duplicate occurrence:
-- GROUPID has duplicate values
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_InventProductGroupEntity' TABLEID, 
    'GROUPID' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(GROUPID) > 10 THEN 
            'GROUPID has duplicate values upon truncation'
        ELSE 
            'GROUPID has duplicate values'
    END ERRORDESC, 
    GROUPID ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_InventProductGroupEntity A
WHERE 
    CONCAT(LEFT(GROUPID, 10), DATAAREAID) IN (
    SELECT CONCAT(LEFT(GROUPID, 10), DATAAREAID) 
    FROM PWC_T_InventProductGroupEntity
    GROUP BY LEFT(GROUPID, 10), DATAAREAID 
    HAVING COUNT(*) > 1
);




-- String length exceeded maximum
-- GROUPID exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_InventProductGroupEntity' TABLEID, 
'GROUPID' ERRORCOLUMN, 
PWCROWID ROWID, 
7 CATEGORY, 
'GROUPID exceeds max length 10' ERRORDESC, 
GROUPID ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_InventProductGroupEntity A
WHERE LEN(GROUPID) > 10;

-- GROUPNAME exceeds max length 60
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_InventProductGroupEntity' TABLEID, 
'GROUPNAME' ERRORCOLUMN, 
PWCROWID ROWID, 
7 CATEGORY, 
'GROUPNAME exceeds max length 60' ERRORDESC, 
GROUPNAME ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_InventProductGroupEntity A
WHERE LEN(GROUPNAME) > 60;

EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_InventProductGroupEntity'
END
