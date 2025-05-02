CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_AssetProvisionTypeEntity
AS
BEGIN
	--Mandatory field missing:
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetProvisionTypeEntity' TABLEID, 
		'TypeId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'TypeId is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetProvisionTypeEntity A
	WHERE 
		TypeId = '' OR TypeId IS NULL;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetProvisionTypeEntity' TABLEID, 
		'Description' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'Description is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetProvisionTypeEntity A
	WHERE 
		Description = '' OR Description IS NULL;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetProvisionTypeEntity' TABLEID, 
		'LengthOfOwnership' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'LengthOfOwnership is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetProvisionTypeEntity A
	WHERE 
		LengthOfOwnership = '' OR LengthOfOwnership IS NULL;

	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetProvisionTypeEntity' TABLEID, 
		'Months' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'Months is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetProvisionTypeEntity A
	WHERE 
		Months = '' OR Months IS NULL;

	--Duplicate occurance
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_AssetProvisionTypeEntity' TABLEID, 
		'TypeId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(TypeId) > 10 THEN 
				'TypeId has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'TypeId has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		TypeId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_AssetProvisionTypeEntity A
	WHERE CONCAT(LEFT(TypeId, 10), DATAAREAID) IN (
		SELECT CONCAT(LEFT(TypeId, 10), DATAAREAID) 
		FROM PWC_T_AssetProvisionTypeEntity
		GROUP BY LEFT(TypeId, 10), DATAAREAID 
		HAVING COUNT(*) > 1
	);


	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_AssetProvisionTypeEntity'
END