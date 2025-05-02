CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_AssetActivityCodeEntity
AS
BEGIN
	--Mandatory field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetActivityCodeEntity' TABLEID, 
		'ActivityCode' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'ActivityCode is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetActivityCodeEntity A
	WHERE 
		ActivityCode = '' OR ActivityCode IS NULL;
	
	-- Duplicate occurance
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetActivityCodeEntity' TABLEID, 
		'ActivityCode' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(ActivityCode) > 10 THEN 
				'ActivityCode has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'ActivityCode has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		ActivityCode ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetActivityCodeEntity A
	WHERE CONCAT(LEFT(ActivityCode, 10), DATAAREAID) IN (
		SELECT CONCAT(LEFT(ActivityCode, 10), DATAAREAID) 
		FROM PWC_T_AssetActivityCodeEntity
		GROUP BY LEFT(ActivityCode, 10), DATAAREAID 
		HAVING COUNT(*) > 1
	);

	-- String length mismatch
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetActivityCodeEntity' AS TABLEID, 
		'ActivityCode' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'ActivityCode exceeds max length 10' AS ERRORDESC, 
		ActivityCode AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PWC_T_AssetActivityCodeEntity A
	WHERE 
		LEN(ActivityCode) > 10;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetActivityCodeEntity' AS TABLEID, 
		'DESCRIPTION' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'DESCRIPTION exceeds max length 60' AS ERRORDESC, 
		DESCRIPTION AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PWC_T_AssetActivityCodeEntity A
	WHERE 
		LEN(DESCRIPTION) > 60;


	-- Business required field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetActivityCodeEntity' TABLEID, 
		'DESCRIPTION' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'DESCRIPTION is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetActivityCodeEntity A
	WHERE 
		DESCRIPTION = '' OR DESCRIPTION IS NULL;

	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_AssetActivityCodeEntity'
END