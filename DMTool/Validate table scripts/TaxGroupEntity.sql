CREATE OR ALTER PROCEDURE PWC_SP_Validate_TaxGroupEntity
AS
BEGIN

-- Mandatory field missing:
    -- TAXGROUPCODE is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'TAXGROUPCODE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'TAXGROUPCODE is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        TAXGROUPCODE = '' OR TAXGROUPCODE IS NULL;


-- Business reqd fields missing
    -- DESCRIPTION is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'DESCRIPTION' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'DESCRIPTION is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        DESCRIPTION = '' OR DESCRIPTION IS NULL;

    -- INVOICEPRINTDETAILS is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'INVOICEPRINTDETAILS' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'INVOICEPRINTDETAILS is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        INVOICEPRINTDETAILS = '' OR INVOICEPRINTDETAILS IS NULL;

    -- ROUNDINGBY is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'ROUNDINGBY' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'ROUNDINGBY is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        ROUNDINGBY = '' OR ROUNDINGBY IS NULL;



-- Invalid Enum Values:
    -- INVOICEPRINTDETAILS has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'INVOICEPRINTDETAILS' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'INVOICEPRINTDETAILS has invalid enum values' ERRORDESC, 
        INVOICEPRINTDETAILS ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        INVOICEPRINTDETAILS IS NOT NULL 
        AND INVOICEPRINTDETAILS NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'TaxPrintDetail'
        );

    -- ROUNDINGBY has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'ROUNDINGBY' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'ROUNDINGBY has invalid enum values' ERRORDESC, 
        ROUNDINGBY ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        ROUNDINGBY IS NOT NULL 
        AND ROUNDINGBY NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'TaxGroupRounding'
        );



-- Duplicate occurrence:
    -- TAXGROUPCODE,DATAAREAID has duplicate values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        '(TAXGROUPCODE,DATAAREAID)' ERRORCOLUMN, 
        PWCROWID ROWID, 
        3 CATEGORY, 
        CASE 
            WHEN LEN(TAXGROUPCODE) > 10 THEN 
                'TAXGROUPCODE has duplicate values upon truncation in ' + DATAAREAID
            ELSE 
                'TAXGROUPCODE has duplicate values in ' + DATAAREAID
        END ERRORDESC, 
        TAXGROUPCODE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE 
        CONCAT(LEFT(TAXGROUPCODE, 10), DATAAREAID) IN (
        SELECT CONCAT(LEFT(TAXGROUPCODE, 10), DATAAREAID) 
        FROM PWC_T_TaxGroupEntity
        GROUP BY LEFT(TAXGROUPCODE, 10), DATAAREAID 
        HAVING COUNT(*) > 1
    );



-- String length exceeded maximum:
    -- TAXGROUPCODE exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'TAXGROUPCODE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TAXGROUPCODE exceeds max length 10' ERRORDESC, 
        TAXGROUPCODE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE LEN(TAXGROUPCODE) > 10;

    -- DESCRIPTION exceeds max length 60
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxGroupEntity' TABLEID, 
        'DESCRIPTION' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'DESCRIPTION exceeds max length 60' ERRORDESC, 
        DESCRIPTION ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxGroupEntity A
    WHERE LEN(DESCRIPTION) > 60;

    EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_TaxGroupEntity'
END