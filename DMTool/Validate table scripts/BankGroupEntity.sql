CREATE OR ALTER PROCEDURE PWC_SP_VALIDATE_BankGroupEntity
AS
BEGIN
	--Mandatory field missing:
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'BankGroupId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		1 CATEGORY, 
		'BankGroupId is blank' ERRORDESC, 
		'' ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE 
		(BankGroupId = '' OR BankGroupId IS NULL);

	-- RoutingNumberType enum has invalid enum values
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'RoutingNumberType' ERRORCOLUMN, 
		PWCROWID ROWID, 
		2 CATEGORY, 
		'RoutingNumberType enum has invalid enum values' ERRORDESC, 
		RoutingNumberType ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE 
		RoutingNumberType IS NOT NULL 
		AND RoutingNumberType NOT IN 
		(SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'BankCodeType');

	-- BankGroupId has duplicate values
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'BankGroupId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(BankGroupId) > 10 THEN 
				'BankGroupId has duplicate values upon truncation in ' + DATAAREAID
			ELSE 'BankGroupId has duplicate values in ' + DATAAREAID
		END ERRORDESC, 
		BankGroupId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE CONCAT(LEFT(BankGroupId, 10), DATAAREAID) IN (
			SELECT CONCAT(LEFT(BankGroupId, 10), DATAAREAID) 
			FROM PWC_T_BankGroupEntity
			GROUP BY LEFT(BankGroupId, 10), DATAAREAID 
			HAVING COUNT(*) > 1
		);

	-- Invalid submaster reference for Currency
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		CASE 
			WHEN COUNT(B.CurrencyCode) = 0 THEN 'Currency'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'Currency,[PWC_T_CURRENCYENTITY]'
		END ERRORCOLUMN,
		A.PWCROWID ROWID, 
		CASE 
			WHEN COUNT(B.CurrencyCode) = 0 THEN 4
			WHEN COUNT(E.CATEGORY) <> 0 THEN 5
		END CATEGORY, 
		CASE 
			WHEN COUNT(B.CurrencyCode) = 0 THEN 'Currency is not present in CurrencyCode of PWC_T_CURRENCYENTITY'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_CURRENCYENTITY has error(s) in corresponding CurrencyCode'
		END ERRORDESC,
		A.Currency ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	LEFT JOIN PWC_T_CURRENCYENTITY B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') AND A.Currency = B.CurrencyCode
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_CURRENCYENTITY' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
		AND B.PWCROWID = E.ROWID
	WHERE 
		A.Currency IS NOT NULL AND A.Currency != ''
	GROUP BY TABLEID, A.PWCROWID, A.CURRENCY, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;

	-- BankGroupId exceeds max length 10
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'BankGroupId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		7 CATEGORY, 
		'BankGroupId exceeds max length 10' ERRORDESC, 
		BankGroupId ERRORVALUE, 
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE 
		LEN(BankGroupId) > 10;

	-- ContactName exceeds max length 60
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'ContactName' ERRORCOLUMN, 
		PWCROWID ROWID, 
		7 CATEGORY, 
		'ContactName exceeds max length 60' ERRORDESC, 
		ContactName ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE 
		LEN(ContactName) > 60;

	-- ContactEmail exceeds max length 80
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'ContactEmail' ERRORCOLUMN, 
		PWCROWID ROWID, 
		7 CATEGORY, 
		'ContactEmail exceeds max length 80' ERRORDESC, 
		ContactEmail ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE 
		LEN(ContactEmail) > 80;

	-- Name exceeds max length 60
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_BankGroupEntity' TABLEID, 
		'Name' ERRORCOLUMN, 
		PWCROWID ROWID, 
		7 CATEGORY, 
		'Name exceeds max length 60' ERRORDESC, 
		Name ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_BankGroupEntity A
	WHERE 
		LEN(Name) > 60;

	EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_BankGroupEntity'
END