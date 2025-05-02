CREATE OR ALTER PROCEDURE PWC_SP_Validate_TaxServiceTaxRegistrationNumberVendorEntity
AS
BEGIN

-- Invalid data format
-- VALIDTO HAS WRONG DATE FORMAT
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'VALIDTO' ERRORCOLUMN, 
PWCROWID ROWID, 
2 CATEGORY, 
'VALIDTO has wrong date format' ERRORDESC, 
VALIDTO ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
VALIDTO IS NOT NULL AND ISDATE(VALIDTO) = 0;

-- VALIDFROM HAS WRONG DATE FORMAT
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'VALIDFROM' ERRORCOLUMN, 
PWCROWID ROWID, 
2 CATEGORY, 
'VALIDFROM has wrong date format' ERRORDESC, 
VALIDFROM ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
VALIDFROM IS NOT NULL AND ISDATE(VALIDFROM) = 0;

-- VALIDFROM IS NOT LESS THAN OR EQUAL TO VALIDTO
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'(VALIDFROM, VALIDTO)' ERRORCOLUMN, 
PWCROWID ROWID, 
6 CATEGORY, 
'VALIDFROM is not less than or equal to VALIDTO' ERRORDESC, 
CONCAT('(', VALIDFROM, ', ', VALIDTO, ')') ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
TRY_CAST(VALIDFROM AS DATE) IS NOT NULL AND
TRY_CAST(VALIDTO AS DATE) IS NOT NULL AND
TRY_CAST(VALIDFROM AS DATE) > TRY_CAST(VALIDTO AS DATE);

-- Mandatory field missing:
-- TaxRegstrationType is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'TaxRegstrationType' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'TaxRegstrationType is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
TaxRegstrationType = '' OR TaxRegstrationType IS NULL;

-- RegistrationNumber is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'RegistrationNumber' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'RegistrationNumber is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
RegistrationNumber = '' OR RegistrationNumber IS NULL;

-- VendAccount is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'VendAccount' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'VendAccount is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
VendAccount = '' OR VendAccount IS NULL;

-- VendName is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'VendName' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'VendName is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
VendName = '' OR VendName IS NULL;

-- LEGALENTITY is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'LEGALENTITY' ERRORCOLUMN, 
PWCROWID ROWID, 
1 CATEGORY, 
'LEGALENTITY is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
LEGALENTITY = '' OR LEGALENTITY IS NULL;




-- Business required fields missing:
-- ValidFrom is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'ValidFrom' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'ValidFrom is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
ValidFrom = '' OR ValidFrom IS NULL;

-- ValidTo is blank
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'ValidTo' ERRORCOLUMN, 
PWCROWID ROWID, 
8 CATEGORY, 
'ValidTo is blank' ERRORDESC, 
'' ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
ValidTo = '' OR ValidTo IS NULL;



-- Invalid submaster reference
-- VendAccount validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (SELECT 
    'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
    CASE 
        WHEN COUNT(B.VENDORACCOUNTNUMBER) = 0 THEN 'VendAccount'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'VendAccount,[PWC_T_VendVendorV2Entity]'
    END ERRORCOLUMN,
    A.PWCROWID ROWID, 
    CASE 
        WHEN COUNT(B.VENDORACCOUNTNUMBER) = 0 THEN 4
        WHEN COUNT(E.CATEGORY) <> 0 THEN 5
    END CATEGORY, 
    CASE 
        WHEN COUNT(B.VENDORACCOUNTNUMBER) = 0 THEN 'VendAccount is not present in VENDORACCOUNTNUMBER of PWC_T_VendVendorV2Entity'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_VendVendorV2Entity has error(s) in corresponding VENDORACCOUNTNUMBER'
    END ERRORDESC,
    A.VendAccount ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
LEFT JOIN PWC_T_VendVendorV2Entity B
    ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.VendAccount = B.VENDORACCOUNTNUMBER
LEFT JOIN PWCERRORTABLE E
    ON E.TABLEID = 'PWC_T_VendVendorV2Entity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
        AND B.PWCROWID = E.ROWID
WHERE 
    A.VendAccount IS NOT NULL AND A.VendAccount != ''
GROUP BY TABLEID, A.PWCROWID, A.VendAccount, A.DATAAREAID) a
WHERE CATEGORY IS NOT NULL;

-- CountryRegionId validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (SELECT 
    'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
    CASE 
        WHEN COUNT(B.COUNTRYREGION) = 0 THEN 'CountryRegionId'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'CountryRegionId,[PWC_T_LogisticsAddressCountryRegionEntity]'
    END ERRORCOLUMN,
    A.PWCROWID ROWID, 
    CASE 
        WHEN COUNT(B.COUNTRYREGION) = 0 THEN 4
        WHEN COUNT(E.CATEGORY) <> 0 THEN 5
    END CATEGORY, 
    CASE 
        WHEN COUNT(B.COUNTRYREGION) = 0 THEN 'CountryRegionId is not present in COUNTRYREGION of PWC_T_LogisticsAddressCountryRegionEntity'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_LogisticsAddressCountryRegionEntity has error(s) in corresponding COUNTRYREGION'
    END ERRORDESC,
    A.CountryRegionId ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
LEFT JOIN PWC_T_LogisticsAddressCountryRegionEntity B
    ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.CountryRegionId = B.COUNTRYREGION
LEFT JOIN PWCERRORTABLE E
    ON E.TABLEID = 'PWC_T_LogisticsAddressCountryRegionEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
        AND B.PWCROWID = E.ROWID
WHERE 
    A.CountryRegionId IS NOT NULL AND A.CountryRegionId != ''
GROUP BY TABLEID, A.PWCROWID, A.CountryRegionId, A.DATAAREAID) a
WHERE CATEGORY IS NOT NULL;

-- LEGALENTITY validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (SELECT 
    'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
    CASE 
        WHEN COUNT(B.LEGALENTITYID) = 0 THEN 'LEGALENTITY'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'LEGALENTITY,[PWC_T_OMLegalEntity]'
    END ERRORCOLUMN,
    A.PWCROWID ROWID, 
    CASE 
        WHEN COUNT(B.LEGALENTITYID) = 0 THEN 4
        WHEN COUNT(E.CATEGORY) <> 0 THEN 5
    END CATEGORY, 
    CASE 
        WHEN COUNT(B.LEGALENTITYID) = 0 THEN 'LEGALENTITY is not present in LEGALENTITYID of PWC_T_OMLegalEntity'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_OMLegalEntity has error(s) in corresponding LEGALENTITYID'
    END ERRORDESC,
    A.LEGALENTITY ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
LEFT JOIN PWC_T_OMLegalEntity B
    ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.LEGALENTITY = B.LEGALENTITYID
LEFT JOIN PWCERRORTABLE E
    ON E.TABLEID = 'PWC_T_OMLegalEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
        AND B.PWCROWID = E.ROWID
WHERE 
    A.LEGALENTITY IS NOT NULL AND A.LEGALENTITY != ''
GROUP BY TABLEID, A.PWCROWID, A.LEGALENTITY, A.DATAAREAID) a
WHERE CATEGORY IS NOT NULL;

-- VendAccount, CountryRegionId validation
INSERT INTO PWCERRORTABLE
SELECT * FROM (SELECT 
    'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
    CASE 
        WHEN COUNT(B.VENDORACCOUNTNUMBER) = 0 THEN '(VendAccount, CountryRegionId)'
        WHEN COUNT(E.CATEGORY) <> 0 THEN '(VendAccount, CountryRegionId),[PWC_T_VendVendorV2Entity]'
    END ERRORCOLUMN,
    A.PWCROWID ROWID, 
    CASE 
        WHEN COUNT(B.VENDORACCOUNTNUMBER) = 0 THEN 4
        WHEN COUNT(E.CATEGORY) <> 0 THEN 5
    END CATEGORY, 
    CASE 
        WHEN COUNT(B.VENDORACCOUNTNUMBER) = 0 THEN 'VendAccount, CountryRegionId is not present in VENDORACCOUNTNUMBER, ADDRESSCOUNTRYREGIONID of PWC_T_VendVendorV2Entity'
        WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_VendVendorV2Entity has error(s) in corresponding VENDORACCOUNTNUMBER, ADDRESSCOUNTRYREGIONID'
    END ERRORDESC,
    CONCAT('(', A.VendAccount, ',', A.CountryRegionId, ')') ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
LEFT JOIN PWC_T_VendVendorV2Entity B
    ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR (A.DATAAREAID) = 'GLOBAL') AND A.VendAccount = B.VENDORACCOUNTNUMBER AND A.CountryRegionId = B.ADDRESSCOUNTRYREGIONID
LEFT JOIN PWCERRORTABLE E
    ON E.TABLEID = 'PWC_T_VendVendorV2Entity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
        AND B.PWCROWID = E.ROWID
WHERE 
    A.VendAccount IS NOT NULL AND A.VendAccount != '' AND 
    A.CountryRegionId IS NOT NULL AND A.CountryRegionId != ''
GROUP BY TABLEID, A.PWCROWID, A.VendAccount, A.CountryRegionId, A.DATAAREAID) a
WHERE CATEGORY IS NOT NULL;







-- Duplicate occurrence:
-- RegistrationNumber, ValidFrom, ValidTo, VendAccount has duplicate values
INSERT INTO PWCERRORTABLE
SELECT 
    'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
    '(RegistrationNumber, ValidFrom, ValidTo, VendAccount)' ERRORCOLUMN, 
    PWCROWID ROWID, 
    3 CATEGORY, 
    CASE 
        WHEN LEN(RegistrationNumber) > 60 OR LEN(VendAccount) > 20 THEN 
            'RegistrationNumber, ValidFrom, ValidTo, VendAccount has duplicate values upon truncation'
        ELSE 
            'RegistrationNumber, ValidFrom, ValidTo, VendAccount has duplicate values'
    END ERRORDESC, 
    CONCAT('(', RegistrationNumber, ', ', ValidFrom, ', ', ValidTo, ', ', VendAccount, ')') ERRORVALUE,
    A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE 
    CONCAT(LEFT(RegistrationNumber, 60), ValidFrom, ValidTo, LEFT(VendAccount, 20), DATAAREAID) IN (
    SELECT CONCAT(LEFT(RegistrationNumber, 60), ValidFrom, ValidTo, LEFT(VendAccount, 20), DATAAREAID) 
    FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity
    GROUP BY LEFT(RegistrationNumber, 60), ValidFrom, ValidTo, LEFT(VendAccount, 20), DATAAREAID 
    HAVING COUNT(*) > 1
);







-- String length exceeded maximum
-- RegistrationNumber exceeds max length 60
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'RegistrationNumber' ERRORCOLUMN, 
PWCROWID ROWID, 
7 CATEGORY, 
'RegistrationNumber exceeds max length 60' ERRORDESC, 
RegistrationNumber ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE LEN(RegistrationNumber) > 60;

-- TaxRegstrationType exceeds max length 30
INSERT INTO PWCERRORTABLE
SELECT 
'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity' TABLEID, 
'TaxRegstrationType' ERRORCOLUMN, 
PWCROWID ROWID, 
7 CATEGORY, 
'TaxRegstrationType exceeds max length 30' ERRORDESC, 
TaxRegstrationType ERRORVALUE,
A.DATAAREAID DATAAREAID
FROM PWC_T_TaxServiceTaxRegistrationNumberVendorEntity A
WHERE LEN(TaxRegstrationType) > 30;

EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_TaxServiceTaxRegistrationNumberVendorEntity'
END
