import os
import argparse
import pandas as pd
from bidict import bidict

from template_from_table import generate_template

GLOBAL_LOG_LEVEL = 2
log_file_path = 'log.txt'
failed_with_errors = False
def resetLogPath(_log_file_path, _GLOBAL_LOG_LEVEL = 0):
    global log_file_path, failed_with_errors, GLOBAL_LOG_LEVEL
    log_file_path = _log_file_path
    failed_with_errors = False
    if(_GLOBAL_LOG_LEVEL):
        GLOBAL_LOG_LEVEL = _GLOBAL_LOG_LEVEL

def log(message, logLevel):
    global GLOBAL_LOG_LEVEL, log_file_path, failed_with_errors
    if logLevel > GLOBAL_LOG_LEVEL:
        with open(log_file_path, 'a') as log_file:
            log_file.write(message + '\n')
    if logLevel > 2:
        failed_with_errors = True

def validateIndexIntegrity(df, result_df, indexes, excel_to_d365_mapping):
    for index in indexes:
        data_columns_indices = list(excel_to_d365_mapping.inverse[x] for x in index)
        if(len(data_columns_indices) == 0):
            continue
        result_df = result_df[~result_df.duplicated(subset=data_columns_indices, keep=False)]
        error_df = df[df.duplicated(subset=data_columns_indices, keep=False)]
        if error_df.shape[0] > 0:
            log(f'\nERROR - {data_columns_indices} has duplicate values:', 4)
            log(f'{error_df[data_columns_indices]}\n', 3)
    return result_df

def validateStringFields(df, result_df, string_columns_with_size):
    for string_column_name, size in string_columns_with_size:
        result_df = result_df[(result_df[string_column_name].str.len() <= int(size))]
        error_df = df[(df[string_column_name].str.len() > int(size))]
        if error_df.shape[0] > 0:
            log(f'\nERROR - {string_column_name} has rows whose string length exceeds the max: {size}', 4)
            log(f'{error_df[string_column_name]}\n', 3)
    return result_df

def validateEnumFields(df, result_df, enum_names_with_values):
    for enum_column_name, values in enum_names_with_values:
        result_df = result_df[result_df[enum_column_name].isin(values)]
        error_df = df[~df[enum_column_name].isin(values)]
        if error_df.shape[0] > 0:
            log(f'\nERROR - {enum_column_name} has values which are not in the enum:\n{values}', 4)
            log(f'{error_df[enum_column_name]}\n', 3)
    return result_df

def validateOtherFields(df, result_df, other_fields):
    for other_column_name in other_fields:
        error_df = df[~(df[other_column_name] != '')]
        if error_df.shape[0] > 0:
            log(f'WARN - {other_column_name} is a non string field which was empty', 3)
            log(f'{error_df[other_column_name]}\n', 2)
    return result_df

i = 0
def validate_data(df, staging_table_name, skipIndexCheck = False):
    global i
    i+=1
    template, indexes = generate_template(staging_table_name, True)
    excel_to_d365_mapping = bidict({})
    string_columns_with_size = []
    enum_names_with_values = []
    other_fields = []

    for row in template:
        found = False
        is_mandatory = row['Mandatory'] == 'Yes'
        d365_column_name = row['D365 Column Name']
        
        for data_column in df.columns:
            match = data_column.lower() == d365_column_name.lower()
            if match:
                found = True
                excel_to_d365_mapping[data_column] = d365_column_name

                if row['Data type'] == 'String':
                    df[data_column] = df[data_column].astype(str)
                    string_columns_with_size.append((data_column, int(row['Length'])))
                elif row['Data type'] == 'Enum':
                    df[data_column] = df[data_column].astype(str)
                    enum_names_with_values.append((data_column, row['EnumValues'].split(', ')))
                else:
                    other_fields.append(data_column)
                log(f'INFO - "{d365_column_name}" was found in the data', 1)
                break

        if not found and is_mandatory:
            log(f'ERROR - Mandatory column "{d365_column_name}" was missing from the data!', 3)
        elif not found:
            log(f'WARN - "{d365_column_name}" was missing from the data but is not mandatory', 2)

    unmapped_data_fields = []
    for data_column in df.columns:
        if not data_column in excel_to_d365_mapping:
            unmapped_data_fields.append(data_column)
    if not len(unmapped_data_fields) == 0:
        log(f'\nINFO - Fields from the data which are not mapped are:', 1)
        for field in unmapped_data_fields:
            log('\t' + field, 1)
    else:
        log('INFO - All data fields were successfully mapped to a d365 entity field.', 1)

    result_df = df.copy()
    if not skipIndexCheck:
        log('\nINFO - Checking for index integrity...', 1)
        result_df = validateIndexIntegrity(df, result_df, indexes, excel_to_d365_mapping)

    log('\nINFO - Checking whether dataset follows string size constraints...', 1)
    result_df = validateStringFields(df, result_df, string_columns_with_size)

    log('\nINFO - Checking whether dataset enum values columns contain permissible values...', 1)
    result_df = validateEnumFields(df, result_df, enum_names_with_values)

    log('\nINFO - Checking whether there are any empty non string values...', 1)
    result_df = validateOtherFields(df, result_df, other_fields)

    return result_df

def handleCSVFile(input_data_file, staging_table_name, companies_to_consider, log_level):
    input_df = pd.read_csv(f'data/{input_data_file}', keep_default_na=False)
    entity_name = input_data_file[:-len('.csv')]
    if not os.path.exists(f'output/{entity_name}/'):
        os.makedirs(f'output/{entity_name}/')
    try:
        with pd.ExcelWriter(f'output/{entity_name}/{entity_name}.xlsx') as raw_writer:
            with pd.ExcelWriter(f'output/{entity_name}/{entity_name}_validated.xlsx') as valid_writer:
                input_df.to_excel(raw_writer, sheet_name=entity_name, index=False)
                for column in input_df.columns:
                    if column.lower() == 'dataareaid':
                        valid_legal_entities = []
                        invalid_legal_entities = []
                        if not os.path.exists(f'output/{entity_name}/logs'):
                            os.makedirs(f'output/{entity_name}/logs')

                        grouped = input_df.groupby(column)
                        for category, group_df in grouped:
                            if companies_to_consider and category.lower() not in companies_to_consider:
                                continue
                            group_df.to_excel(raw_writer, sheet_name=category, index=False)
                            resetLogPath(f'output/{entity_name}/logs/{category}.txt', log_level)
                            validate_data(group_df, staging_table_name).to_excel(valid_writer, sheet_name=category, index=False)
                            if not failed_with_errors:
                                valid_legal_entities.append(category)
                            else:
                                invalid_legal_entities.append(category)

                        resetLogPath(f'output/{entity_name}/overall_report.txt', 3)
                        log(f'Following legal entity data was found valid:\n{valid_legal_entities}', 4)
                        log(f'Following legal entity data was found invalid:\n{invalid_legal_entities}', 4)
                        
                        validate_data(input_df, staging_table_name, True)
                        break
                else:
                    resetLogPath(f'output/{entity_name}/log.txt', log_level)
                    result_df = validate_data(input_df, staging_table_name)
                    result_df.to_excel(valid_writer, sheet_name=entity_name, index=False)
    except Exception as e:
        print(f'Failed to parse data from {input_data_file}\n{e}')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--staging', help='Name of the staging table for the D365 entity')
    parser.add_argument('-d', '--data_file', help='Name of the excel file where the data to validate is present')
    parser.add_argument('-e', '--excel', help='Pass "" to generate excel template required in this program.')
    parser.add_argument('-c', '--companies', nargs='+', help="Provide list of dataareaids to validate. Leave empty to validate all.")
    parser.add_argument('-l', '--log_level', help='''
        Should be a number less than 3 for any logging to be printed to console
            0 - Info, Warnings, Errors
            1 - Warnings, Errors
            2 - Errors    
    ''')

    args, strings = parser.parse_known_args()
    args.log_level = 2
    args.staging = "LedgerJournalNameStaging"
    args.data_file = "Journal names.csv"
    if args.excel:
        inputs = pd.read_excel(args.excel)
        for _, row in inputs.iterrows():
            handleCSVFile(row['Data Entity']+'.csv', row['Staging Table'], args.companies, args.log_level)
    elif args.excel == "":
        pd.DataFrame(columns=['Data Entity', 'Staging Table']).to_excel('entity_input.xlsx', index=False)
    else:
        handleCSVFile(args.data_file, args.staging, args.companies, args.log_level)