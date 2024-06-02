def parseDataWithTemplate(template):
    sql = ''
    for row in template:
        datatype = row['Data type']
        is_mandatory = row['Mandatory'] == 'Yes'
        prefer_mandatory = row['IsNullable'] == 'No'
        d365_column_name = row['D365 Column Name']

        data_column = d365_column_name.upper()
        if is_mandatory:
            sql += f'''
                UPDATE your_table
                SET PwCErrorReasons = CONCAT({data_column}, '{data_column} was blank;')
                WHERE {data_column} is null or {data_column} = '';
            '''
        elif prefer_mandatory:
            sql += f'''
                UPDATE your_table
                SET PwCErrorReasons = CONCAT({data_column}, '{data_column} was blank;')
                WHERE {data_column} is null or {data_column} = '';
            '''

        