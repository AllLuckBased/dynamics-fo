CREATE OR ALTER PROCEDURE PWC_SP_DMERRORROWLEVELREPORT
    @TableName NVARCHAR(50) -- Accept table name as parameter
AS
BEGIN
    DECLARE @SQLQuery NVARCHAR(MAX)
    DECLARE @ColumnList NVARCHAR(MAX)
 
    -- Retrieve the column names dynamically
    SELECT @ColumnList = STRING_AGG('T1.' + COLUMN_NAME, ', ' + CHAR(10) + CHAR(9) + CHAR(9))
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName
    
    -- Construct the dynamic SQL query
    SET @SQLQuery = '
    SELECT 
        ISNULL(T2.[STATUS], ''Success'') STATUS,
		ISNULL(T3.[CATEGORY], ''None'') CATEGORY, 
		ISNULL(T2.[ERRORCOLUMN], ''N/A'') ERRORCOLUMN,
		ISNULL(T2.[ERRORDESCRIPTION], ''N/A'') ERRORDESCRIPTION,
        ' + @ColumnList + '
	FROM ' + QUOTENAME(@TableName) + ' T1
    LEFT JOIN (
        SELECT 
            TEMP.TABLEID, TEMP.ERRORCOLUMN, TEMP.ROWID, TEMP.ERRORDESCRIPTION, S.DESCRIPTION STATUS
        FROM (
            SELECT 
                ''' + @TableName + ''' AS TABLEID, E.ROWID, STRING_AGG(E.ERRORCOLUMN, '','') AS ERRORCOLUMN, 
                STRING_AGG(E.ERRORDESC, '','') AS ERRORDESCRIPTION,
                MAX(S.ID) AS STATUS
            FROM PWCERRORTABLE E
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
	-- EXEC SP_DMERRORROWLEVELREPORT @TableName='PWC_T_BANKACCOUNTENTITY'
END
