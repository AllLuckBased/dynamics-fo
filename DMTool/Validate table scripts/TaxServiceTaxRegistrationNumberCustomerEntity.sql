CREATE OR ALTER PROCEDURE PWC_SP_Validate_TaxServiceTaxRegistrationNumberCustomerEntity
AS
BEGIN

-- Invalid data format
    -- VALIDTO has wrong date format
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'VALIDTO' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'VALIDTO has wrong date format' ERRORDESC, 
        VALIDTO ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE VALIDTO IS NOT NULL AND ISDATE(VALIDTO) = 0;

    -- VALIDFROM has wrong date format
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'VALIDFROM' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'VALIDFROM has wrong date format' ERRORDESC, 
        VALIDFROM ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE VALIDFROM IS NOT NULL AND ISDATE(VALIDFROM) = 0;



-- Other system checks
    -- VALIDFROM is not less than or equal to VALIDTO
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        '(VALIDFROM,VALIDTO)' ERRORCOLUMN, 
        PWCROWID ROWID, 
        6 CATEGORY, 
        'VALIDFROM is not less than or equal to VALIDTO' ERRORDESC, 
        CONCAT('(', VALIDFROM, ', ', VALIDTO, ')') ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE ISDATE(VALIDFROM) IS NOT NULL AND ISDATE(VALIDTO) IS NOT NULL
          AND CAST(VALIDFROM AS DATE) > CAST(VALIDTO AS DATE);



-- Mandatory field missing
    -- RegistrationNumber is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'RegistrationNumber' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'RegistrationNumber is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE RegistrationNumber = '' OR RegistrationNumber IS NULL;

    -- CountryRegionId is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'CountryRegionId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'CountryRegionId is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE CountryRegionId = '' OR CountryRegionId IS NULL;

    -- TaxRegstrationType is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'TaxRegstrationType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'TaxRegstrationType is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE TaxRegstrationType = '' OR TaxRegstrationType IS NULL;

    -- CustAccountNum is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'CustAccountNum' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'CustAccountNum is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE CustAccountNum = '' OR CustAccountNum IS NULL;

    -- LegalEntity is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'LegalEntity' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'LegalEntity is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LegalEntity = '' OR LegalEntity IS NULL;



-- Functionally reqd fields missing
    -- Description is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'Description' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'Description is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE Description = '' OR Description IS NULL;

    -- ValidTo is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'ValidTo' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'ValidTo is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE ValidTo = '' OR ValidTo IS NULL;

    -- CustAccountName is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'CustAccountName' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'CustAccountName is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE CustAccountName = '' OR CustAccountName IS NULL;



-- Duplicate occurrence:
	-- RegistrationNumber, ValidTo, CountryRegionId, TaxRegstrationType, CustAccountNum, LegalEntity has duplicates
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
		'(RegistrationNumber, ValidTo, CountryRegionId, TaxRegstrationType, CustAccountNum, LegalEntity)' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(RegistrationNumber) > 60 OR LEN(CountryRegionId) > 10 OR LEN(TaxRegstrationType) > 30 OR LEN(CustAccountNum) > 20 THEN 
				'RegistrationNumber, ValidTo, CountryRegionId, TaxRegstrationType, CustAccountNum, LegalEntity has duplicate values upon truncation'
			ELSE 
				'RegistrationNumber, ValidTo, CountryRegionId, TaxRegstrationType, CustAccountNum, LegalEntity has duplicate values'
		END ERRORDESC, 
		CONCAT('(', RegistrationNumber, ', ', ValidTo, ', ', CountryRegionId, ', ', TaxRegstrationType, ', ', CustAccountNum, ', ', LegalEntity, ')') ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
	WHERE 
		CONCAT(LEFT(RegistrationNumber, 60), ValidTo, LEFT(CountryRegionId, 10), LEFT(TaxRegstrationType, 30), LEFT(CustAccountNum, 20), LegalEntity, DATAAREAID) IN (
		SELECT CONCAT(LEFT(RegistrationNumber, 60), ValidTo, LEFT(CountryRegionId, 10), LEFT(TaxRegstrationType, 30), LEFT(CustAccountNum, 20), LegalEntity, DATAAREAID) 
		FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity
		GROUP BY LEFT(RegistrationNumber, 60), ValidTo, LEFT(CountryRegionId, 10), LEFT(TaxRegstrationType, 30), LEFT(CustAccountNum, 20), LegalEntity, DATAAREAID 
		HAVING COUNT(*) > 1
	);



-- Invalid submaster reference
	-- CountryRegionId validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
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
	FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
	LEFT JOIN PWC_T_LogisticsAddressCountryRegionEntity B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.CountryRegionId = B.COUNTRYREGION
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_LogisticsAddressCountryRegionEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
			AND B.PWCROWID = E.ROWID
	WHERE 
		A.CountryRegionId IS NOT NULL AND A.CountryRegionId != ''
	GROUP BY A.PWCROWID, A.CountryRegionId, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;

	-- CustAccountNum validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
		CASE 
			WHEN COUNT(B.CUSTOMERACCOUNT) = 0 THEN 'CustAccountNum'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'CustAccountNum,[PWC_T_CustCustomerV3Entity]'
		END ERRORCOLUMN, 
		A.PWCROWID ROWID, 
		CASE 
			WHEN COUNT(B.CUSTOMERACCOUNT) = 0 THEN 4
			WHEN COUNT(E.CATEGORY) <> 0 THEN 5
		END CATEGORY, 
		CASE 
			WHEN COUNT(B.CUSTOMERACCOUNT) = 0 THEN 'CustAccountNum is not present in CUSTOMERACCOUNT of PWC_T_CustCustomerV3Entity'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_CustCustomerV3Entity has error(s) in corresponding CUSTOMERACCOUNT'
		END ERRORDESC,
		A.CustAccountNum ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
	LEFT JOIN PWC_T_CustCustomerV3Entity B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.CustAccountNum = B.CUSTOMERACCOUNT
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_CustCustomerV3Entity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
			AND B.PWCROWID = E.ROWID
	WHERE 
		A.CustAccountNum IS NOT NULL AND A.CustAccountNum != ''
	GROUP BY A.PWCROWID, A.CustAccountNum, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;

	-- LegalEntity validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
		CASE 
			WHEN COUNT(B.LEGALENTITYID) = 0 THEN 'LegalEntity'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'LegalEntity,[PWC_T_OMLegalEntity]'
		END ERRORCOLUMN, 
		A.PWCROWID ROWID, 
		CASE 
			WHEN COUNT(B.LEGALENTITYID) = 0 THEN 4
			WHEN COUNT(E.CATEGORY) <> 0 THEN 5
		END CATEGORY, 
		CASE 
			WHEN COUNT(B.LEGALENTITYID) = 0 THEN 'LegalEntity is not present in LEGALENTITYID of PWC_T_OMLegalEntity'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_OMLegalEntity has error(s) in corresponding LEGALENTITYID'
		END ERRORDESC,
		A.LegalEntity ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
	LEFT JOIN PWC_T_OMLegalEntity B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.LegalEntity = B.LEGALENTITYID
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_OMLegalEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
			AND B.PWCROWID = E.ROWID
	WHERE 
		A.LegalEntity IS NOT NULL AND A.LegalEntity != ''
	GROUP BY A.PWCROWID, A.LegalEntity, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;

	-- CustAccountNum, CountryRegionId validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
		CASE 
			WHEN COUNT(B.CUSTOMERACCOUNT) = 0 THEN '(CustAccountNum, CountryRegionId)'
			WHEN COUNT(E.CATEGORY) <> 0 THEN '(CustAccountNum, CountryRegionId),[PWC_T_CustCustomerV3Entity]'
		END ERRORCOLUMN, 
		A.PWCROWID ROWID, 
		CASE 
			WHEN COUNT(B.CUSTOMERACCOUNT) = 0 THEN 4
			WHEN COUNT(E.CATEGORY) <> 0 THEN 5
		END CATEGORY, 
		CASE 
			WHEN COUNT(B.CUSTOMERACCOUNT) = 0 THEN 'CustAccountNum, CountryRegionId is not present in CUSTOMERACCOUNT, ADDRESSCOUNTRYREGIONID of PWC_T_CustCustomerV3Entity'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_CustCustomerV3Entity has error(s) in corresponding CUSTOMERACCOUNT, ADDRESSCOUNTRYREGIONID'
		END ERRORDESC,
		CONCAT('(', A.CustAccountNum, ',', A.CountryRegionId, ')') ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
	LEFT JOIN PWC_T_CustCustomerV3Entity B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR (A.DATAAREAID) = 'GLOBAL') AND A.CustAccountNum = B.CUSTOMERACCOUNT AND A.CountryRegionId = B.ADDRESSCOUNTRYREGIONID
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_CustCustomerV3Entity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
			AND B.PWCROWID = E.ROWID
	WHERE 
		A.CustAccountNum IS NOT NULL AND A.CustAccountNum != '' AND 
		A.CountryRegionId IS NOT NULL AND A.CountryRegionId != ''
	GROUP BY A.PWCROWID, A.CustAccountNum, A.CountryRegionId, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;




-- String length exceeded
    -- Description exceeds max length 60
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'Description' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'Description exceeds max length 60' ERRORDESC, 
        Description ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(Description) > 60;

    -- RegistrationNumber exceeds max length 60
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'RegistrationNumber' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'RegistrationNumber exceeds max length 60' ERRORDESC, 
        RegistrationNumber ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(RegistrationNumber) > 60;

    -- CountryRegionId exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'CountryRegionId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'CountryRegionId exceeds max length 10' ERRORDESC, 
        CountryRegionId ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(CountryRegionId) > 10;

    -- TaxRegstrationType exceeds max length 30
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'TaxRegstrationType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TaxRegstrationType exceeds max length 30' ERRORDESC, 
        TaxRegstrationType ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(TaxRegstrationType) > 30;

    -- CustAccountNum exceeds max length 20
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'CustAccountNum' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'CustAccountNum exceeds max length 20' ERRORDESC, 
        CustAccountNum ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(CustAccountNum) > 20;

    -- CustAccountName exceeds max length 160
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'CustAccountName' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'CustAccountName exceeds max length 160' ERRORDESC, 
        CustAccountName ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(CustAccountName) > 160;

    -- LegalEntity exceeds max length 4
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity' TABLEID, 
        'LegalEntity' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'LegalEntity exceeds max length 4' ERRORDESC, 
        LegalEntity ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity A
    WHERE LEN(LegalEntity) > 4;

    -- Calculate successful count
    EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_TaxServiceTaxRegistrationNumberCustomerEntity';
END;