CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_AssetPropertyGroupEntity
AS
BEGIN
	--Mandatory field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetPropertyGroupEntity' TABLEID, 
		'AssetPropertyGroupId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'AssetPropertyGroupId is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetPropertyGroupEntity A
	WHERE 
		AssetPropertyGroupId = '' OR AssetPropertyGroupId IS NULL;

	--Duplicate occurrance
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetPropertyGroupEntity' TABLEID, 
		'AssetPropertyGroupId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(AssetPropertyGroupId) > 10 THEN 
				'AssetPropertyGroupId has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'AssetPropertyGroupId has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		AssetPropertyGroupId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetPropertyGroupEntity A
	WHERE CONCAT(LEFT(AssetPropertyGroupId, 10), DATAAREAID) IN (
		SELECT CONCAT(LEFT(AssetPropertyGroupId, 10), DATAAREAID) 
		FROM PwC_T_AssetPropertyGroupEntity
		GROUP BY LEFT(AssetPropertyGroupId, 10), DATAAREAID 
		HAVING COUNT(*) > 1
	);

	--String length mismatch
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetPropertyGroupEntity' AS TABLEID, 
		'AssetPropertyGroupId' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'AssetPropertyGroupId exceeds max length 10' AS ERRORDESC, 
		AssetPropertyGroupId AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PwC_T_AssetPropertyGroupEntity A
	WHERE 
		LEN(AssetPropertyGroupId) > 10;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetPropertyGroupEntity' AS TABLEID, 
		'DESCRIPTION' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'DESCRIPTION exceeds max length 60' AS ERRORDESC, 
		DESCRIPTION AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PwC_T_AssetPropertyGroupEntity A
	WHERE 
		LEN(DESCRIPTION) > 60;

	--Business required field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetPropertyGroupEntity' TABLEID, 
		'DESCRIPTION' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'DESCRIPTION is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetPropertyGroupEntity A
	WHERE 
		DESCRIPTION = '' OR DESCRIPTION IS NULL;

	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PwC_T_AssetPropertyGroupEntity'
END