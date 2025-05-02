CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_AssetAcquisitionMethodEntity
AS
BEGIN
	--Mandatory field missing:
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetAcquisitionMethodEntity' TABLEID, 
		'AcquisitionMethod' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'AcquisitionMethod is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetAcquisitionMethodEntity A
	WHERE 
		AcquisitionMethod = '' OR AcquisitionMethod IS NULL;

	--Duplicate occurance
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetAcquisitionMethodEntity' TABLEID, 
		'AcquisitionMethod' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(AcquisitionMethod) > 20 THEN 
				'AcquisitionMethod has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'AcquisitionMethod has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		AcquisitionMethod ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetAcquisitionMethodEntity A
	WHERE CONCAT(LEFT(AcquisitionMethod, 20), DATAAREAID) IN (
		SELECT CONCAT(LEFT(AcquisitionMethod, 20), DATAAREAID) 
		FROM PwC_T_AssetAcquisitionMethodEntity
		GROUP BY LEFT(AcquisitionMethod, 20), DATAAREAID 
		HAVING COUNT(*) > 1
	);

	--String length mismatch
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetAcquisitionMethodEntity' AS TABLEID, 
		'AcquisitionMethod' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'AcquisitionMethod exceeds max length 20' AS ERRORDESC, 
		AcquisitionMethod AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PwC_T_AssetAcquisitionMethodEntity A
	WHERE 
		LEN(AcquisitionMethod) > 20;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetAcquisitionMethodEntity' AS TABLEID, 
		'DESCRIPTION' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'DESCRIPTION exceeds max length 60' AS ERRORDESC, 
		DESCRIPTION AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PwC_T_AssetAcquisitionMethodEntity A
	WHERE 
		LEN(DESCRIPTION) > 60;

	-- Business required field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PwC_T_AssetAcquisitionMethodEntity' TABLEID, 
		'DESCRIPTION' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'DESCRIPTION is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PwC_T_AssetAcquisitionMethodEntity A
	WHERE 
		DESCRIPTION = '' OR DESCRIPTION IS NULL;

	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_AssetAcquisitionMethodEntity'
END