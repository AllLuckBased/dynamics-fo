CREATE OR ALTER PROCEDURE PWC_SP_Validate_CustomerPaymentMethodEntity
AS
BEGIN


-- Mandatory fields missing
    -- Name is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'Name' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'Name is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE Name = '' OR Name IS NULL;




-- Functionally reqd fields missing
    -- AccountType is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'AccountType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'AccountType is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE AccountType = '' OR AccountType IS NULL;

    -- BankTransactionType is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'BankTransactionType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'BankTransactionType is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE BankTransactionType = '' OR BankTransactionType IS NULL;

    -- ExportBillOfExchangeDuringInvoicePosting is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'ExportBillOfExchangeDuringInvoicePosting' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'ExportBillOfExchangeDuringInvoicePosting is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE ExportBillOfExchangeDuringInvoicePosting = '' OR ExportBillOfExchangeDuringInvoicePosting IS NULL;

    -- PaymentStatus is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'PaymentStatus' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'PaymentStatus is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE PaymentStatus = '' OR PaymentStatus IS NULL;

    -- SumByPeriod is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'SumByPeriod' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'SumByPeriod is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE SumByPeriod = '' OR SumByPeriod IS NULL;

    -- EnablePostdatedCheckClearingPosting is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'EnablePostdatedCheckClearingPosting' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'EnablePostdatedCheckClearingPosting is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE EnablePostdatedCheckClearingPosting = '' OR EnablePostdatedCheckClearingPosting IS NULL;

    -- BillOfExchangeDraftType is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'BillOfExchangeDraftType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'BillOfExchangeDraftType is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE BillOfExchangeDraftType = '' OR BillOfExchangeDraftType IS NULL;



--- Duplicate occurence
    -- Name, DATAAREAID has duplicate values
	INSERT INTO PWCERRORTABLE
	SELECT 
		'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
		'Name' ERRORCOLUMN, 
		PWCROWID ROWID, 
		3 CATEGORY, 
		CASE 
			WHEN LEN(Name) > 10 THEN 
				'Name has duplicate values upon truncation'
			ELSE 
				'Name has duplicate values'
		END ERRORDESC, 
		Name ERRORVALUE,
		A.DATAAREAID DATAAREAID
	FROM PWC_T_CustomerPaymentMethodEntity A
	WHERE 
		CONCAT(LEFT(Name, 10), DATAAREAID) IN (
		SELECT CONCAT(LEFT(Name, 10), DATAAREAID) 
		FROM PWC_T_CustomerPaymentMethodEntity
		GROUP BY LEFT(Name, 10), DATAAREAID 
		HAVING COUNT(*) > 1
	);



-- Invalid Enum values
    -- AccountType has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'AccountType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'AccountType has invalid enum values' ERRORDESC, 
        AccountType ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE AccountType IS NOT NULL AND AccountType NOT IN
          (SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'LedgerJournalACType');

    -- PaymentType has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'PaymentType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'PaymentType has invalid enum values' ERRORDESC, 
        PaymentType ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE PaymentType IS NOT NULL AND PaymentType NOT IN
          (SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'CustPaymentType');

    -- PaymentStatus has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'PaymentStatus' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'PaymentStatus has invalid enum values' ERRORDESC, 
        PaymentStatus ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE PaymentStatus IS NOT NULL AND PaymentStatus NOT IN
          (SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'CustVendPaymStatus');

    -- SumByPeriod has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'SumByPeriod' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'SumByPeriod has invalid enum values' ERRORDESC, 
        SumByPeriod ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE SumByPeriod IS NOT NULL AND SumByPeriod NOT IN
          (SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'PaymSumBy');

    -- BillOfExchangeDraftType has invalid enum values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'BillOfExchangeDraftType' ERRORCOLUMN, 
        PWCROWID ROWID, 
        2 CATEGORY, 
        'BillOfExchangeDraftType has invalid enum values' ERRORDESC, 
        BillOfExchangeDraftType ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE BillOfExchangeDraftType IS NOT NULL AND BillOfExchangeDraftType NOT IN
          (SELECT MEMBERNAME FROM RETAILENUMVALUETABLE WHERE ENUMNAME LIKE 'TypeOfDraft');



-- String length exceeded
    -- PaymentAccountDisplayValue exceeds max length 500
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'PaymentAccountDisplayValue' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'PaymentAccountDisplayValue exceeds max length 500' ERRORDESC, 
        PaymentAccountDisplayValue ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE LEN(PaymentAccountDisplayValue) > 500;

    -- Description exceeds max length 60
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'Description' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'Description exceeds max length 60' ERRORDESC, 
        Description ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE LEN(Description) > 60;

    -- Name exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'Name' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'Name exceeds max length 10' ERRORDESC, 
        Name ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE LEN(Name) > 10;

    -- PaymentJournalName exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_CustomerPaymentMethodEntity' TABLEID, 
        'PaymentJournalName' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'PaymentJournalName exceeds max length 10' ERRORDESC, 
        PaymentJournalName ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_CustomerPaymentMethodEntity A
    WHERE LEN(PaymentJournalName) > 10;

    -- Calculate successful count
    EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_CustomerPaymentMethodEntity';
END;