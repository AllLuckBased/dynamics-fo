def not_null_sql(entity_name, column):
    name_without_spaces = entity_name.replace(' ', '')
    return f'''
UPDATE PWC_E_{name_without_spaces}
SET
    ERRORDESC = CONCAT(ERRORDESC, '{column} is blank', '; '),
    ERRORSTATUS = CONCAT(ERRORSTATUS, 'Error', '; ')
WHERE
    {column} = '' OR {column} IS NULL;
    '''

def string_size_sql(entity_name, column, size):
    if size == -1: return ''
    name_without_spaces = entity_name.replace(' ', '')
    return f'''
UPDATE PWC_E_{name_without_spaces}
SET
    ERRORDESC = CONCAT(ERRORDESC, '{column} exceeds max length {size}', '; '),
    ERRORSTATUS = CONCAT(ERRORSTATUS, 'Constraint', '; ')
WHERE
    LEN({column}) > {size};
    '''

def enum_values_sql(entity_name, column):
    name_without_spaces = entity_name.replace(' ', '')
    return f'''
UPDATE PWC_E_{name_without_spaces}
SET
    ERRORDESC = CONCAT(ERRORDESC, '{column} has invalid enum values', '; '),
    ERRORSTATUS = CONCAT(ERRORSTATUS, 'Error', '; ')
WHERE
    {column} IS NOT NULL
    AND {column} NOT IN (
        SELECT MEMBERNAME
        FROM RETAILENUMVALUETABLE
        WHERE ENUMNAME LIKE '{column}'
    );
    '''

def duplicate_sql(entity_name, index_columns):
    name_without_spaces = entity_name.replace(' ', '')
    columns_str = ', '.join(index_columns)
    where_conditions = '\n\tAND '.join([f'{column} IS NOT NULL' for column in index_columns])
    join_conditions = '\n\tAND '.join([f't1.{column} = t2.{column}' for column in index_columns])

    return f'''
UPDATE PWC_E_{name_without_spaces}
SET
    ERRORDESC = CONCAT(ERRORDESC, '{columns_str} has duplicate values', '; '),
    ERRORSTATUS = CONCAT(ERRORSTATUS, 'Constraint', '; ')
FROM
    PWC_E_{name_without_spaces} AS t1
JOIN (
    SELECT
        {columns_str}
    FROM
        PWC_E_{name_without_spaces}
    WHERE
        {where_conditions}
    GROUP BY
        {columns_str}
    HAVING
        COUNT(*) > 1
) AS t2
ON
    {join_conditions}
WHERE
    {where_conditions}
    '''

def dependency_sql(entity_name, entity_dependencies):
    sql = ''
    name_without_spaces = entity_name.replace(' ', '')
    for column, dependency in entity_dependencies.items():
        relatedEntity = dependency[0][0].replace(' ', '')
        sql += f'''
UPDATE PWC_E_{name_without_spaces}
SET
    ERRORDESC = CONCAT(ERRORDESC, '{column} is not in {dependency[1][0]} of {relatedEntity}', '; '),
    ERRORSTATUS = CONCAT(ERRORSTATUS, 'Error', '; ')
FROM
    PWC_E_{name_without_spaces}
WHERE
    {column} IS NOT NULL AND {column} NOT IN (SELECT {dependency[1][0]} FROM PWC_E_{relatedEntity});
        '''
    return sql

