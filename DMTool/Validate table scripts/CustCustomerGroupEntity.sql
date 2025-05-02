CREATE OR ALTER PROCEDURE PWC_SP_Validate_CustCustomerGroupEntity
AS
BEGIN

-- Mandatory fields missing
    -- CustomerGroupId is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustCustomerGroupEntity' TABLEID, 
        'CustomerGroupId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'CustomerGroupId is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustCustomerGroupEntity A
    WHERE CustomerGroupId = '' OR CustomerGroupId IS NULL;


-- Functionally reqd fields missing
    -- Description is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustCustomerGroupEntity' TABLEID, 
        'Description' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'Description is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustCustomerGroupEntity A
    WHERE Description = '' OR Description IS NULL;




-- Duplicate occurrence:
	-- CustomerGroupId has duplicate values
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_CustCustomerGroupEntity' TABLEID, 
		'CustomerGroupId' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(CustomerGroupId) > 10 THEN 
				'CustomerGroupId has duplicate values upon truncation'
			ELSE 
				'CustomerGroupId has duplicate values'
		END ERRORDESC, 
		CustomerGroupId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_CustCustomerGroupEntity A
	WHERE 
		CONCAT(LEFT(CustomerGroupId, 10), DATAAREAID) IN (
		SELECT CONCAT(LEFT(CustomerGroupId, 10), DATAAREAID) 
		FROM PWC_T_CustCustomerGroupEntity
		GROUP BY LEFT(CustomerGroupId, 10), DATAAREAID 
		HAVING COUNT(*) > 1
	);



-- Invalid submaster reference
	-- TaxGroupId validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_CustCustomerGroupEntity' TABLEID, 
		CASE 
			WHEN COUNT(B.TAXGROUPCODE) = 0 THEN 'TaxGroupId'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'TaxGroupId,[PWC_T_TaxGroupEntity]'
		END ERRORCOLUMN, 
		A.PWCROWID ROWID, 
		CASE 
			WHEN COUNT(B.TAXGROUPCODE) = 0 THEN 4
			WHEN COUNT(E.CATEGORY) <> 0 THEN 5
		END CATEGORY, 
		CASE 
			WHEN COUNT(B.TAXGROUPCODE) = 0 THEN 'TaxGroupId is not present in TAXGROUPCODE of PWC_T_TaxGroupEntity'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_TaxGroupEntity has error(s) in corresponding TAXGROUPCODE'
		END ERRORDESC,
		A.TaxGroupId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_CustCustomerGroupEntity A
	LEFT JOIN PWC_T_TaxGroupEntity B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.TaxGroupId = B.TAXGROUPCODE
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_TaxGroupEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
			AND B.PWCROWID = E.ROWID
	WHERE 
		A.TaxGroupId IS NOT NULL AND A.TaxGroupId != ''
	GROUP BY A.PWCROWID, A.TaxGroupId, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;

	-- PaymentTermId validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (SELECT 
		'PWC_T_CustCustomerGroupEntity' TABLEID, 
		CASE 
			WHEN COUNT(B.NAME) = 0 THEN 'PaymentTermId'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PaymentTermId,[PWC_T_PaymentTermEntity]'
		END ERRORCOLUMN, 
		A.PWCROWID ROWID, 
		CASE 
			WHEN COUNT(B.NAME) = 0 THEN 4
			WHEN COUNT(E.CATEGORY) <> 0 THEN 5
		END CATEGORY, 
		CASE 
			WHEN COUNT(B.NAME) = 0 THEN 'PaymentTermId is not present in NAME of PWC_T_PaymentTermEntity'
			WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_PaymentTermEntity has error(s) in corresponding NAME'
		END ERRORDESC,
		A.PaymentTermId ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_CustCustomerGroupEntity A
	LEFT JOIN PWC_T_PaymentTermEntity B
		ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL' OR UPPER(A.DATAAREAID) = 'GLOBAL') AND A.PaymentTermId = B.NAME
	LEFT JOIN PWCERRORTABLE E
		ON E.TABLEID = 'PWC_T_PaymentTermEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
			AND B.PWCROWID = E.ROWID
	WHERE 
		A.PaymentTermId IS NOT NULL AND A.PaymentTermId != ''
	GROUP BY A.PWCROWID, A.PaymentTermId, A.DATAAREAID) a
	WHERE CATEGORY IS NOT NULL;




-- String length exceeded
    -- TaxGroupId exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustCustomerGroupEntity' TABLEID, 
        'TaxGroupId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'TaxGroupId exceeds max length 10' ERRORDESC, 
        TaxGroupId ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustCustomerGroupEntity A
    WHERE LEN(TaxGroupId) > 10;

    -- CustomerGroupId exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustCustomerGroupEntity' TABLEID, 
        'CustomerGroupId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'CustomerGroupId exceeds max length 10' ERRORDESC, 
        CustomerGroupId ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustCustomerGroupEntity A
    WHERE LEN(CustomerGroupId) > 10;

    -- Description exceeds max length 60
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustCustomerGroupEntity' TABLEID, 
        'Description' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'Description exceeds max length 60' ERRORDESC, 
        Description ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustCustomerGroupEntity A
    WHERE LEN(Description) > 60;

    -- PaymentTermId exceeds max length 100
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustCustomerGroupEntity' TABLEID, 
        'PaymentTermId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'PaymentTermId exceeds max length 100' ERRORDESC, 
        PaymentTermId ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustCustomerGroupEntity A
    WHERE LEN(PaymentTermId) > 100;

    -- Calculate successful count
    EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_CustCustomerGroupEntity';
END;