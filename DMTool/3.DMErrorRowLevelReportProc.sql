CREATE OR ALTER PROCEDURE PWC_SP_DMERRORROWLEVELREPORT
    @TableName NVARCHAR(100) -- Accept table name as parameter
AS
BEGIN
    DECLARE @SQLQuery NVARCHAR(MAX);
    DECLARE @ColumnList NVARCHAR(MAX) = '';
	DECLARE @COLUMNNAME NVARCHAR(128);

	-- Check if the column cursor already exists and deallocate if necessary
    IF CURSOR_STATUS('global', 'COLUMN_CURSOR') >= -1
    BEGIN
        CLOSE COLUMN_CURSOR;
        DEALLOCATE COLUMN_CURSOR;
    END

    -- Retrieve the column names dynamically
	DECLARE COLUMN_CURSOR CURSOR FOR
	SELECT COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
 

	OPEN COLUMN_CURSOR
	FETCH NEXT FROM COLUMN_CURSOR INTO @COLUMNNAME;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ColumnList = @ColumnList + 'T1.' + @COLUMNNAME + ', ' + CHAR(10) + CHAR(9) + CHAR(9);
		FETCH NEXT FROM COLUMN_CURSOR INTO @COLUMNNAME
	END

	CLOSE COLUMN_CURSOR;
	DEALLOCATE COLUMN_CURSOR;

	
	-- Remove the trailing comma and space
	SET @COLUMNLIST = LEFT(@COLUMNLIST, LEN(@COLUMNLIST) - 5)

    -- Construct the dynamic SQL query
    SET @SQLQuery = '
    WITH PWCERRORTABLE_CONCATERRORS AS 
    (
     	SELECT E.TABLEID, E.ROWID, E.CATEGORY, CONCAT(''{'',C.DESCRIPTION,'' :: '',E.ERRORDESC,'' -> '',E.ERRORCOLUMN,'' = '',E.ERRORVALUE,''}'') AS ERRORDESCRIPTION
	FROM PWCERRORTABLE E
	LEFT JOIN PWCCATEGORY C ON E.CATEGORY = C.ID
    )
    SELECT 
        T2.[STATUS] STATUS,
		T3.[CATEGORY] CATEGORY, 
		T2.ERRORDESCRIPTION ERRORDESCRIPTION,
        ' + @ColumnList + '
	FROM ' + QUOTENAME(@TableName) + ' T1
    LEFT JOIN (
        SELECT 
            TEMP.TABLEID, TEMP.ROWID, TEMP.ERRORDESCRIPTION, S.DESCRIPTION STATUS
        FROM (
            SELECT 
                ''' + @TableName + ''' AS TABLEID, E.ROWID, 
                STRING_AGG(CAST(E.ERRORDESCRIPTION AS NVARCHAR(MAX)), '','') AS ERRORDESCRIPTION,
                MAX(S.ID) AS STATUS
            FROM PWCERRORTABLE_CONCATERRORS E
            JOIN PWCCATEGORY C
            ON E.CATEGORY = C.ID
            JOIN PWCSTATUS S
            ON S.ID = C.STATUS
            GROUP BY E.ROWID, E.TABLEID
			HAVING E.TABLEID = ''' + @TableName + '''
        ) TEMP 	
        JOIN PWCSTATUS S
        ON S.ID = TEMP.STATUS
    ) T2 
    ON T1.PWCROWID = T2.ROWID
    LEFT JOIN (
        SELECT 
            in1.ROWID, STRING_AGG(in2.DESCRIPTION, '','') AS CATEGORY 
        FROM (
            SELECT ROWID, CATEGORY 
            FROM PWCERRORTABLE
            WHERE TABLEID = ''' + @TableName + '''
            GROUP BY ROWID, CATEGORY
        ) in1 
        LEFT JOIN PWCCATEGORY in2 
        ON in1.CATEGORY = in2.ID
        GROUP BY in1.ROWID
    ) T3 
    ON T3.ROWID = T1.PWCROWID
    '
	--PRINT @SQLQuery
	EXEC sp_executesql @SQLQuery
	-- EXEC PWC_SP_DMERRORROWLEVELREPORT @TableName='PWC_T_BANKACCOUNTENTITY'
END
