CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_AssetDepreciationProfileEntity
AS
BEGIN
	--Mandatory field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetDepreciationProfileEntity' TABLEID, 
		'DepreciationProfileId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'DepreciationProfileId is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetDepreciationProfileEntity A
	WHERE 
		DepreciationProfileId = '' OR DepreciationProfileId IS NULL;
	
	--Invalid data type
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetDepreciationProfileEntity' TABLEID, 
		'Method' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'Method has invalid enum values' ERRORDESC, 
		Method ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetDepreciationProfileEntity A
	WHERE 
		Method IS NOT NULL 
		AND Method NOT IN 
		(SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'AssetDepreciationMethod');

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetDepreciationProfileEntity' TABLEID, 
		'DepreciationYear' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'DepreciationYear has invalid enum values' ERRORDESC, 
		DepreciationYear ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetDepreciationProfileEntity A
	WHERE 
		DepreciationYear IS NOT NULL 
		AND DepreciationYear NOT IN 
		(SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'AssetDepreciationYear');

	--Duplicate occurance
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetDepreciationProfileEntity' TABLEID, 
		'DepreciationProfileId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(DepreciationProfileId) > 10 THEN 
				'DepreciationProfileId has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'DepreciationProfileId has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		DepreciationProfileId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetDepreciationProfileEntity A
	WHERE CONCAT(LEFT(DepreciationProfileId, 10), DATAAREAID) IN (
		SELECT CONCAT(LEFT(DepreciationProfileId, 10), DATAAREAID) 
		FROM PwC_T_AssetDepreciationProfileEntity
		GROUP BY LEFT(DepreciationProfileId, 10), DATAAREAID 
		HAVING COUNT(*) > 1
	);

	--String length mismatch
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetDepreciationProfileEntity' AS TABLEID, 
		'DepreciationProfileId' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'DepreciationProfileId exceeds max length 10' AS ERRORDESC, 
		DepreciationProfileId AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PWC_T_AssetDepreciationProfileEntity A
	WHERE 
		LEN(DepreciationProfileId) > 10;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetDepreciationProfileEntity' AS TABLEID, 
		'Name' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'Name exceeds max length 30' AS ERRORDESC, 
		Name AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PWC_T_AssetDepreciationProfileEntity A
	WHERE 
		LEN(Name) > 30;

	--Business required field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetDepreciationProfileEntity' TABLEID, 
		'DepreciationYear' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'DepreciationYear is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetDepreciationProfileEntity A
	WHERE 
		DepreciationYear = '' OR DepreciationYear IS NULL;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetDepreciationProfileEntity' TABLEID, 
		'Name' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'Name is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetDepreciationProfileEntity A
	WHERE 
		Name = '' OR Name IS NULL;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetDepreciationProfileEntity' TABLEID, 
		'Method' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'Method is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetDepreciationProfileEntity A
	WHERE 
		Method = '' OR Method IS NULL;

	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_AssetDepreciationProfileEntity'
END