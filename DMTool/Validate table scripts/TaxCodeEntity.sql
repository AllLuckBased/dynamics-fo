CREATE OR ALTER PROCEDURE PWC_SP_Validate_TaxCodeEntity
AS
BEGIN

-- Mandatory field missing:
    -- TAXCODE is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXCODE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'TAXCODE is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXCODE = '' OR TAXCODE IS NULL;

-- Business required fields missing:
    -- TAXPERIODID is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXPERIODID' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXPERIODID is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXPERIODID = '' OR TAXPERIODID IS NULL;

    -- TAXPOSTINGGROUPID is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXPOSTINGGROUPID' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXPOSTINGGROUPID is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXPOSTINGGROUPID = '' OR TAXPOSTINGGROUPID IS NULL;

    -- TAXBASE is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXBASE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXBASE is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXBASE = '' OR TAXBASE IS NULL;

    -- TAXCALCULATIONMETHOD is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXCALCULATIONMETHOD' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXCALCULATIONMETHOD is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXCALCULATIONMETHOD = '' OR TAXCALCULATIONMETHOD IS NULL;

    -- TAXCURRENCYCODEID is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXCURRENCYCODEID' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXCURRENCYCODEID is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXCURRENCYCODEID = '' OR TAXCURRENCYCODEID IS NULL;

    -- TAXNAME is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXNAME' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXNAME is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXNAME = '' OR TAXNAME IS NULL;

    -- TAXROUNDOFFTYPE is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXROUNDOFFTYPE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'TAXROUNDOFFTYPE is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXROUNDOFFTYPE = '' OR TAXROUNDOFFTYPE IS NULL;



-- Duplicate occurrence:
    -- TAXCODE,DATAAREAID has duplicate values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        '(TAXCODE,DATAAREAID)' ERRORCOLUMN, 
        PWCROWID ROWID, 
        3 CATEGORY, 
		CASE 
            WHEN LEN(TAXCODE) > 10 THEN 
                'TAXGROUPCODE has duplicate values upon truncation in ' + DATAAREAID
            ELSE 
                'TAXGROUPCODE has duplicate values in ' + DATAAREAID
        END ERRORDESC, 
        TAXCODE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        CONCAT(LEFT(TAXCODE, 10), DATAAREAID) IN (
        SELECT CONCAT(LEFT(TAXCODE, 10), DATAAREAID) 
        FROM PWC_T_TaxCodeEntity
        GROUP BY LEFT(TAXCODE, 10), DATAAREAID 
        HAVING COUNT(*) > 1
    );



-- Invalid Enum Values:
    -- TAXBASE has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXBASE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'TAXBASE has invalid enum values' ERRORDESC, 
        TAXBASE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXBASE IS NOT NULL 
        AND TAXBASE NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'TaxBaseType'
        );

    -- TAXCALCULATIONMETHOD has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXCALCULATIONMETHOD' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'TAXCALCULATIONMETHOD has invalid enum values' ERRORDESC, 
        TAXCALCULATIONMETHOD ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXCALCULATIONMETHOD IS NOT NULL 
        AND TAXCALCULATIONMETHOD NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'TaxCalcMode'
        );

    -- TAXLIMITBASE has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXLIMITBASE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'TAXLIMITBASE has invalid enum values' ERRORDESC, 
        TAXLIMITBASE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXLIMITBASE IS NOT NULL 
        AND TAXLIMITBASE NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'TaxLimitBase'
        );

    -- TAXROUNDOFFTYPE has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXROUNDOFFTYPE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'TAXROUNDOFFTYPE has invalid enum values' ERRORDESC, 
        TAXROUNDOFFTYPE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        TAXROUNDOFFTYPE IS NOT NULL 
        AND TAXROUNDOFFTYPE NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'RoundOffType'
        );

    -- PRINTCODETYPE has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'PRINTCODETYPE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'PRINTCODETYPE has invalid enum values' ERRORDESC, 
        PRINTCODETYPE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE 
        PRINTCODETYPE IS NOT NULL 
        AND PRINTCODETYPE NOT IN (
            SELECT MEMBERNAME 
            FROM RETAILENUMVALUETABLE 
            WHERE ENUMNAME LIKE 'TaxWriteSelection'
        );





-- Invalid submaster reference
	-- TAXCURRENCYCODEID validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (
		SELECT 
			'PWC_T_TaxCodeEntity' TABLEID, 
			CASE 
				WHEN COUNT(B.CURRENCYCODE) = 0 THEN 'TAXCURRENCYCODEID'
				WHEN COUNT(E.CATEGORY) <> 0 THEN 'TAXCURRENCYCODEID,[PWC_T_CurrencyEntity]'
			END ERRORCOLUMN,
			A.PWCROWID ROWID, 
			CASE 
				WHEN COUNT(B.CURRENCYCODE) = 0 THEN 4
				WHEN COUNT(E.CATEGORY) <> 0 THEN 5
			END CATEGORY, 
			CASE 
				WHEN COUNT(B.CURRENCYCODE) = 0 THEN 'TAXCURRENCYCODEID is not present in CURRENCYCODE of PWC_T_CurrencyEntity'
				WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_CurrencyEntity has error(s) in corresponding CURRENCYCODE'
			END ERRORDESC, 
			A.TAXCURRENCYCODEID ERRORVALUE,
			A.DATAAREAID DATAAREAID
		FROM PWC_T_TaxCodeEntity A
		LEFT JOIN PWC_T_CurrencyEntity B
			ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.TAXCURRENCYCODEID = B.CURRENCYCODE
		LEFT JOIN PWCERRORTABLE E
			ON E.TABLEID = 'PWC_T_CurrencyEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
				AND B.PWCROWID = E.ROWID
		WHERE A.TAXCURRENCYCODEID IS NOT NULL AND A.TAXCURRENCYCODEID != ''
		GROUP BY TABLEID, A.PWCROWID, A.TAXCURRENCYCODEID, A.DATAAREAID
	) a
	WHERE CATEGORY IS NOT NULL;



-- String length exceeded:
    -- TAXCODE exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXCODE' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TAXCODE exceeds max length 10' ERRORDESC, 
        TAXCODE ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE LEN(TAXCODE) > 10;

    -- TAXPOSTINGGROUPID exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXPOSTINGGROUPID' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TAXPOSTINGGROUPID exceeds max length 10' ERRORDESC, 
        TAXPOSTINGGROUPID ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE LEN(TAXPOSTINGGROUPID) > 10;

    -- TAXCURRENCYCODEID exceeds max length 3
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXCURRENCYCODEID' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TAXCURRENCYCODEID exceeds max length 3' ERRORDESC, 
        TAXCURRENCYCODEID ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE LEN(TAXCURRENCYCODEID) > 3;

    -- TAXNAME exceeds max length 30
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxCodeEntity' TABLEID, 
        'TAXNAME' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TAXNAME exceeds max length 30' ERRORDESC, 
        TAXNAME ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxCodeEntity A
    WHERE LEN(TAXNAME) > 30;




    EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_TaxCodeEntity'
END