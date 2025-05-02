CREATE   OR ALTER PROCEDURE [dbo].PWC_SP_VALIDATE_LogisticsAddressCityEntity
AS
BEGIN

-- CITYKEY is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'CITYKEY' ERRORCOLUMN, 
    PWCROWID ROWID, 
    1 CATEGORY, 
    'CITYKEY is blank' ERRORDESC, 
    '' ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE 
    CITYKEY = '' OR CITYKEY IS NULL;

-- COUNTRYREGIONID is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'COUNTRYREGIONID' ERRORCOLUMN, 
    PWCROWID ROWID, 
    1 CATEGORY, 
    'COUNTRYREGIONID is blank' ERRORDESC, 
    '' ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE 
    COUNTRYREGIONID = '' OR COUNTRYREGIONID IS NULL;

-- NAME is blank
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'NAME' ERRORCOLUMN, 
    PWCROWID ROWID, 
    1 CATEGORY, 
    'NAME is blank' ERRORDESC, 
    '' ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE 
    NAME = '' OR NAME IS NULL;

-- Duplicate Check
-- CITYKEY has duplicate values
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'CITYKEY' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(CITYKEY) > 100 THEN 
            'CITYKEY has duplicate values upon truncation in ' + DATAAREAID
        ELSE 
            'CITYKEY has duplicate values in ' + DATAAREAID
    END ERRORDESC, 
    CITYKEY ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE 
    CONCAT(LEFT(CITYKEY, 100), DATAAREAID) IN (
    SELECT CONCAT(LEFT(CITYKEY, 100), DATAAREAID) 
    FROM PWC_T_LogisticsAddressCityEntity
    GROUP BY LEFT(CITYKEY, 100), DATAAREAID 
    HAVING COUNT(*) > 1
);


-- Invalid submaster reference:
-- COUNTRYREGIONID validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (
    SELECT 
        'PWC_T_LogisticsAddressCityEntity' TABLEID, 
        CASE 
            WHEN COUNT(B.COUNTRYREGION) = 0 THEN 'COUNTRYREGIONID'
            WHEN COUNT(E.CATEGORY) <> 0 THEN 'COUNTRYREGIONID,[PWC_T_LogisticsAddressCountryRegionEntity]'
        END ERRORCOLUMN, 
        A.PWCROWID ROWID, 
        CASE 
            WHEN COUNT(B.COUNTRYREGION) = 0 THEN 4
            WHEN COUNT(E.CATEGORY) <> 0 THEN 5
        END CATEGORY, 
        CASE 
            WHEN COUNT(B.COUNTRYREGION) = 0 THEN 'COUNTRYREGIONID is not present in COUNTRYREGION of PWC_T_LogisticsAddressCountryRegionEntity'
            WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_LogisticsAddressCountryRegionEntity has error(s) in corresponding COUNTRYREGION'
        END ERRORDESC,
        A.COUNTRYREGIONID ERRORVALUE,
		A.DATAAREAID DATAAREAID
    FROM PWC_T_LogisticsAddressCityEntity A
    LEFT JOIN PWC_T_LogisticsAddressCountryRegionEntity B
        ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.COUNTRYREGIONID = B.COUNTRYREGION
    LEFT JOIN PWCERRORTABLE E
        ON E.TABLEID = 'PWC_T_LogisticsAddressCountryRegionEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
            AND B.PWCROWID = E.ROWID
    WHERE 
        A.COUNTRYREGIONID IS NOT NULL AND A.COUNTRYREGIONID != ''
    GROUP BY A.PWCROWID, A.COUNTRYREGIONID, A.DATAAREAID
) a
WHERE CATEGORY IS NOT NULL;

-- STATEID validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (
    SELECT 
        'PWC_T_LogisticsAddressCityEntity' TABLEID, 
        CASE 
            WHEN COUNT(B.STATE) = 0 THEN 'STATEID'
            WHEN COUNT(E.CATEGORY) <> 0 THEN 'STATEID,[PWC_T_LogisticsAddressStateEntity]'
        END ERRORCOLUMN, 
        A.PWCROWID ROWID, 
        CASE 
            WHEN COUNT(B.STATE) = 0 THEN 4
            WHEN COUNT(E.CATEGORY) <> 0 THEN 5
        END CATEGORY, 
        CASE 
            WHEN COUNT(B.STATE) = 0 THEN 'STATEID is not present in STATE of PWC_T_LogisticsAddressStateEntity'
            WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_LogisticsAddressStateEntity has error(s) in corresponding STATE'
        END ERRORDESC,
        A.STATEID ERRORVALUE,
		A.DATAAREAID DATAAREAID
    FROM PWC_T_LogisticsAddressCityEntity A
    LEFT JOIN PWC_T_LogisticsAddressStateEntity B
        ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.STATEID = B.STATE
    LEFT JOIN PWCERRORTABLE E
        ON E.TABLEID = 'PWC_T_LogisticsAddressStateEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
            AND B.PWCROWID = E.ROWID
    WHERE 
        A.STATEID IS NOT NULL AND A.STATEID != ''
    GROUP BY A.PWCROWID, A.STATEID, A.DATAAREAID
) a
WHERE CATEGORY IS NOT NULL;


-- String length exceeded maximum
-- CITYKEY exceeds max length 100
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'CITYKEY' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'CITYKEY exceeds max length 100' ERRORDESC, 
    CITYKEY ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE LEN(CITYKEY) > 100;

-- COUNTRYREGIONID exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'COUNTRYREGIONID' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'COUNTRYREGIONID exceeds max length 10' ERRORDESC, 
    COUNTRYREGIONID ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE LEN(COUNTRYREGIONID) > 10;

-- COUNTYID exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'COUNTYID' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'COUNTYID exceeds max length 10' ERRORDESC, 
    COUNTYID ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE LEN(COUNTYID) > 10;

-- DESCRIPTION exceeds max length 60
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'DESCRIPTION' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'DESCRIPTION exceeds max length 60' ERRORDESC, 
    DESCRIPTION ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE LEN(DESCRIPTION) > 60;

-- NAME exceeds max length 60
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'NAME' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'NAME exceeds max length 60' ERRORDESC, 
    NAME ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE LEN(NAME) > 60;

-- STATEID exceeds max length 10
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_LogisticsAddressCityEntity' TABLEID, 
    'STATEID' ERRORCOLUMN, 
    PWCROWID ROWID, 
    7 CATEGORY, 
    'STATEID exceeds max length 10' ERRORDESC, 
    STATEID ERRORVALUE,
	A.DATAAREAID DATAAREAID
FROM PWC_T_LogisticsAddressCityEntity A
WHERE LEN(STATEID) > 10;


EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_LogisticsAddressCityEntity'
END
