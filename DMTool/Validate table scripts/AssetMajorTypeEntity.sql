CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_AssetMajorTypeEntity
AS
BEGIN
	--Mandatory field is blank
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetMajorTypeEntity' TABLEID, 
		'MajorTypeId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'MajorTypeId is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetMajorTypeEntity A
	WHERE 
		MajorTypeId = '' OR MajorTypeId IS NULL;
	
	-- Duplicate occurrence
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetMajorTypeEntity' TABLEID, 
		'MajorTypeId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(MajorTypeId) > 20 THEN 
				'MajorTypeId has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'MajorTypeId has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		MajorTypeId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetMajorTypeEntity A
	WHERE CONCAT(LEFT(MajorTypeId, 20), DATAAREAID) IN (
		SELECT CONCAT(LEFT(MajorTypeId, 20), DATAAREAID) 
		FROM PWC_T_AssetMajorTypeEntity
		GROUP BY LEFT(MajorTypeId, 20), DATAAREAID 
		HAVING COUNT(*) > 1
	);

	--String length mismatch
	-- Script for MajorTypeId exceeding max length 20
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetPostingProfileEntity' AS TABLEID, 
		'MajorTypeId' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'MajorTypeId exceeds max length 20' AS ERRORDESC, 
		MajorTypeId AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PWC_T_AssetMajorTypeEntity A
	WHERE 
		LEN(MajorTypeId) > 20;

	-- Script for DESCRIPTION exceeding max length 60
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetPostingProfileEntity' AS TABLEID, 
		'DESCRIPTION' AS ERRORCOLUMN, 
		PWCROWID AS ROWID, 
		7 AS CATEGORY, 
		'DESCRIPTION exceeds max length 60' AS ERRORDESC, 
		DESCRIPTION AS ERRORVALUE, 
		A.DATAAREAID AS DATAAREAID
	FROM PWC_T_AssetMajorTypeEntity A
	WHERE 
		LEN(DESCRIPTION) > 60;


	-- Business required field missing
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetMajorTypeEntity' TABLEID, 
		'DESCRIPTION' ERRORCOLUMN, 
		PWCROWID ROWID, 
		8 CATEGORY, 
		'DESCRIPTION is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetMajorTypeEntity A
	WHERE 
		DESCRIPTION = '' OR DESCRIPTION IS NULL;

	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_AssetMajorTypeEntity'
END