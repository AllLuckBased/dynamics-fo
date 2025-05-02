CREATE OR ALTER PROCEDURE [dbo].[PWC_SP_VALIDATE_LogisticsAddressCountryRegionEntity]
AS
BEGIN

-- Mandatory fields missing
-- COUNTRYREGION is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCountryRegionEntity' TABLEID, 
    'COUNTRYREGION' ERRORCOLUMN, 
    PWCROWID ROWID, 
    1 CATEGORY, 
    'COUNTRYREGION is blank' ERRORDESC, 
    '' ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCountryRegionEntity A
WHERE 
    COUNTRYREGION = '' OR COUNTRYREGION IS NULL;


-- Duplicate keys 
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCountryRegionEntity' TABLEID, 
    'COUNTRYREGION' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(COUNTRYREGION) > 10 THEN 
            'COUNTRYREGION has duplicate values upon truncation in ' + DATAAREAID
        ELSE 
            'COUNTRYREGION has duplicate values in ' + DATAAREAID
    END ERRORDESC, 
    COUNTRYREGION ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCountryRegionEntity A
WHERE 
    CONCAT(LEFT(COUNTRYREGION, 10), DATAAREAID) IN (
    SELECT CONCAT(LEFT(COUNTRYREGION, 10), DATAAREAID) 
    FROM PWC_T_LogisticsAddressCountryRegionEntity
    GROUP BY LEFT(COUNTRYREGION, 10), DATAAREAID 
    HAVING COUNT(*) > 1
);


-- Invalid Enum values
-- TIMEZONE enum has invalid enum values
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCountryRegionEntity' TABLEID, 
    'TIMEZONE' ERRORCOLUMN, 
    PWCROWID ROWID, 
    2 CATEGORY, 
    'TIMEZONE enum has invalid enum values' ERRORDESC, 
    TIMEZONE ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCountryRegionEntity A
WHERE 
    TIMEZONE IS NOT NULL 
    AND TIMEZONE NOT IN (
        SELECT MEMBERNAME 
        FROM RETAILENUMVALUETABLE 
        WHERE ENUMNAME LIKE 'Timezone'
    );



-- String length check
-- COUNTRYREGION exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCountryRegionEntity' TABLEID, 
    'COUNTRYREGION' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'COUNTRYREGION exceeds max length 10' ERRORDESC, 
    COUNTRYREGION ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCountryRegionEntity A
WHERE LEN(COUNTRYREGION) > 10;

-- ADDRESSFORMAT exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCountryRegionEntity' TABLEID, 
    'ADDRESSFORMAT' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'ADDRESSFORMAT exceeds max length 10' ERRORDESC, 
    ADDRESSFORMAT ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCountryRegionEntity A
WHERE LEN(ADDRESSFORMAT) > 10;

-- ISOCODE exceeds max length 2
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCountryRegionEntity' TABLEID, 
    'ISOCODE' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'ISOCODE exceeds max length 2' ERRORDESC, 
    ISOCODE ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCountryRegionEntity A
WHERE LEN(ISOCODE) > 2;

EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_LogisticsAddressCountryRegionEntity'
END