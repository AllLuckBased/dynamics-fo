import re
import json
import pandas as pd

def parseDataWithTemplate(df, template):
    def find_duplicates(arr):
        seen, duplicates = set(), set()
        for x in arr:
            if x in seen: duplicates.add(x)
            else: seen.add(x)
        return list(duplicates)
    
    # Information required to collect:
    mandatory_columns = []
    enum_names_with_values = []
    string_columns_with_size = []
    
    data_columns = df.columns.tolist()
    data_columns.remove('PwCErrorReason')
    data_columns.remove('PwCWarnReason')
    if len(find_duplicates(data_columns)) > 0:
        print(f'Duplicate columns found in the headers:\n{find_duplicates(data_columns)}')
        raise Exception('ParseError')
    if 'DATAAREAID' in data_columns:
        data_columns.remove('DATAAREAID')

    for row in template:
        datatype = row['Data type']
        is_mandatory = row['Mandatory'] == 'Yes'
        d365_column_name = row['D365 Column Name']
        
        data_column = d365_column_name.upper()
        if data_column not in df.columns and is_mandatory: 
            print(f'Mandatory column {d365_column_name} was missing!\n')
            raise Exception('ParseError')
        
        if data_column in df.columns: data_columns.remove(data_column)
        else: continue

        if is_mandatory: 
            mandatory_columns.append(data_column)

        if datatype != 'Enum':
            df[data_column] = df[data_column].astype(str)
            custom_regexp, standard_regexps = None, None
            with open(f'lib/regexps.json', 'r') as file: standard_regexps = json.load(file)
            if not pd.isna(row['AllowedValues']):
                if standard_regexps is not None and row['AllowedValues'] in standard_regexps:
                    custom_regexp = standard_regexps[row['AllowedValues']]
                else: custom_regexp = re.compile(row['AllowedValues'])

            if datatype == 'String':
                if custom_regexp:
                    df.loc[df[(~df[data_column].str.contains(custom_regexp)) & (df[data_column]!='')].index, 
                        'PwCWarnReason' if custom_regexp is None else 'PwCErrorReason'
                    ] += f'{data_column} contains suspicious value;'
                string_columns_with_size.append((data_column, 
                    int(row['Length'] if row['Length'] != 'MEMO' else -1)))
            elif row['Data type'] == 'Int':
                df.loc[df[df[data_column].str.contains(
                    r'[^0-9\-]' if custom_regexp is None else custom_regexp
                    )].index, 'PwCErrorReason'] += f'{data_column} contains invalid int value;'
            elif row['Data type'] == 'Real':
                df.loc[df[df[data_column].str.contains(
                    r'[^0-9.\-]' if custom_regexp is None else custom_regexp
                    )].index, 'PwCErrorReason'] += f'{data_column} contains invalid real value;'
        else:
            df[data_column] = df[data_column].astype('category')
            enum_names_with_values.append((data_column, row['AllowedValues'].split(', ')))

    if len(data_columns) > 0:
        for data_column in data_columns:
            df['PwCWarnReason'] += f'{data_column} was unmapped;'
    return df[df['PwCErrorReason'] == ''], mandatory_columns, \
            string_columns_with_size, enum_names_with_values

def validateMandatoryFields(df, result_df, mandatory_columns):
    for mandatory_column_name in mandatory_columns:
        result_df = result_df[(result_df[mandatory_column_name] != '')]
        error_df = df[(df[mandatory_column_name] == '')]
        df.loc[error_df.index, 'PwCErrorReason'] += f'Mandatory column {mandatory_column_name} empty;'
    return result_df

def validateStringFields(df, result_df, string_columns_with_size, truncate=True):
    # Creating another copy of the df to compare there is no loss of data on truncation
    truncated_df = df.copy()
    for string_column_name, size in string_columns_with_size:
        if size == -1: continue #MEMO string
        try:
            # Strips whitespaces on the left and right for all the data frames...
            df[string_column_name] = df[string_column_name].str.lstrip().str.rstrip()
            result_df.loc[:, string_column_name] = result_df[string_column_name].str.lstrip().str.rstrip()
            # ... but truncates this df to max allowed size before striping whitespace on right.
            truncated_df[string_column_name] = truncated_df[string_column_name].str.lstrip().str[:size].str.rstrip()
        except KeyError:
            #Non mandatory string column was absent from data
            continue

        # Checking how many unique values were lost during truncation.
        unique_values_og_df = set(df[string_column_name].unique())
        unique_values_truncated_df = set(truncated_df[string_column_name].unique())
        
        # Checking if there was loss of data after truncation.
        if len(unique_values_og_df) > len(unique_values_truncated_df):
            lost_unique_values = set()
            value_to_truncated = {}
            for value in unique_values_og_df - unique_values_truncated_df:
                stripped_value = value[:size].strip()
                if stripped_value in unique_values_og_df:
                    lost_unique_values.add(value)
                elif stripped_value in value_to_truncated:
                    lost_unique_values.update([value_to_truncated[stripped_value], value])
                else: value_to_truncated[stripped_value] = value

            result_df = result_df[~result_df[string_column_name].isin(lost_unique_values)]
            error_df = df[(df[string_column_name].isin(lost_unique_values))]
            df.loc[error_df.index, 'PwCErrorReason'] += \
                f'Data loss after truncating {string_column_name} to {size};'
    
        if truncate:
            result_df.loc[:, string_column_name] = result_df[string_column_name].str[:size].str.rstrip()
        else:
            result_df = result_df[(result_df[string_column_name].str.len() <= int(size))]
            error_df = df[(df[string_column_name].str.len() > int(size))]
            df.loc[error_df.index, 'PwCErrorReason'] += f'{string_column_name} exceeds {size} characters;'
    
    del truncated_df
    return result_df

def validateIndexIntegrity(df, result_df, indexes, keep='first'):
    for index in indexes:
        df_index_names = []
        for index_column in index:
            df_index_name = index_column.upper()
            if df_index_name in df.columns:
                df_index_names.append(df_index_name)
                if df[df_index_name].dtype == 'O':
                    df[df_index_name] = df[df_index_name].str.lstrip()
                    result_df[df_index_name] = result_df[df_index_name].str.lstrip()
        if(len(df_index_names) == 0): continue

        temp_df_index_names = []
        for index_name in df_index_names:
            result_df[f'{index_name}_upper'] = result_df[index_name].apply(lambda x: x.upper() if isinstance(x, str) else x)
            temp_df_index_names.append(f'{index_name}_upper')

        error_df = result_df[result_df.duplicated(subset=temp_df_index_names, keep=False)]
        result_df = result_df[~result_df.duplicated(subset=temp_df_index_names, keep='first')]

        conflict_df = error_df[error_df.duplicated(keep=False)]
        df.loc[error_df.index, 'PwCErrorReason'] += f'Duplicated row;'
        df.loc[conflict_df.index, 'PwCErrorReason'] += f'Conflicted row;'
        result_df = result_df.drop(temp_df_index_names, axis=1)
    return result_df

#TODO: Add Error reason for this as well, check label values too.
#Method currently not in use...
def validateEnumFields(df, result_df, enum_names_with_values, excel_to_d365_mapping, logs):
    for enum_column_name, values in enum_names_with_values:
        #Check whether its and integer or string. If its a string, then cast it to str first before validating.
        if df[enum_column_name].dtype in (int, 'int64', 'int32', 'int16', 'int8'):
            result_df = result_df[(result_df[enum_column_name] < len(values)) | result_df[enum_column_name].isna()]
            error_df = df[~(df[enum_column_name] < len(values)) & ~result_df[enum_column_name].isna()]
            if error_df.shape[0] > 0:
                logs.append(InvalidEnumPositionError(excel_to_d365_mapping[enum_column_name],
                    error_df[enum_column_name].unique().tolist(), ', '.join(map(str, error_df.index))))
        else:
            values.append('')
            df[enum_column_name] = df[enum_column_name].astype(str)
            result_df.loc[:, enum_column_name] = result_df[enum_column_name].astype(str)
            result_df = result_df[result_df[enum_column_name].isin(values)]
            error_df = df[~df[enum_column_name].isin(values)]
            if error_df.shape[0] > 0:
                logs.append(EnumValueError(excel_to_d365_mapping[enum_column_name], 
                    error_df[enum_column_name].unique().tolist(), ', '.join(map(str, error_df.index))))
    return result_df
