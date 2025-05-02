CREATE OR ALTER PROCEDURE PWC_SP_ChangeEmptyToNull
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dbo')
    BEGIN
        PRINT 'Schema "dbo" does not exist.';
        RETURN;
    END

    DECLARE @TableName NVARCHAR(MAX);
    DECLARE @SchemaName NVARCHAR(MAX);
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @COLUMNNAME NVARCHAR(128);

-- Check if the column cursor already exists and deallocate if necessary
    IF CURSOR_STATUS('global', 'COLUMN_CURSOR') >= -1
    BEGIN
        CLOSE COLUMN_CURSOR;
        DEALLOCATE COLUMN_CURSOR;
    END

-- Check if the table cursor already exists and deallocate if necessary
    IF CURSOR_STATUS('global', 'TableCursor ') >= -1
    BEGIN
        CLOSE TableCursor ;
        DEALLOCATE TableCursor ;
    END



    DECLARE TableCursor CURSOR FOR
    SELECT TABLE_NAME, TABLE_SCHEMA
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'
      AND TABLE_SCHEMA LIKE 'dbo'  AND TABLE_NAME LIKE 'PWC_T_%';

    OPEN TableCursor;

    FETCH NEXT FROM TableCursor INTO @TableName, @SchemaName;

    WHILE @@FETCH_STATUS = 0
    BEGIN

	---Put the cursor at the beginning of the column list of the PwC Table
	DECLARE COLUMN_CURSOR CURSOR FOR 
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @TABLENAME AND COLUMN_NAME NOT LIKE 'PWCROWID'

	OPEN COLUMN_CURSOR
	FETCH NEXT FROM COLUMN_CURSOR INTO @COLUMNNAME;
	WHILE @@FETCH_STATUS = 0
	BEGIN
 	       SET @SQL = '
		UPDATE ' + @TABLENAME + ' 
    	       SET ' + @COLUMNNAME + ' = NULL
   	       WHERE ' + @COLUMNNAME + ' LIKE ''''
		'

		--PRINT @SQL
		EXEC sp_executesql @SQL;
		
		FETCH NEXT FROM COLUMN_CURSOR INTO @COLUMNNAME
	END;
	
	CLOSE COLUMN_CURSOR;
	DEALLOCATE COLUMN_CURSOR;
	

            FETCH NEXT FROM TableCursor INTO @TableName, @SchemaName;
    END

    CLOSE TableCursor;
    DEALLOCATE TableCursor;

END;


