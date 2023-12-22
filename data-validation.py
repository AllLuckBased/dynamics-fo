import argparse
import pandas as pd
from bidict import bidict

from template_from_table import generate_template

GLOBAL_LOG_LEVEL = 2
def log(message, logLevel):
    if logLevel > GLOBAL_LOG_LEVEL:
        print(message)

def validateIndexIntegrity(df, indexes, excel_to_d365_mapping):
    duplicates_found = False
    for index in indexes:
        data_columns_indices = list(excel_to_d365_mapping.inverse[x] for x in index)
        error_df = df[df.duplicated(subset=data_columns_indices)]
        if error_df.shape[0] > 0:
            log(f"\nERROR - {data_columns_indices} has duplicate values:", 3)
            log(f"{error_df[data_columns_indices]}\n", 3)
            duplicates_found = True
    return duplicates_found

def validateOtherFields(df, other_fields):
    for other_column_name in other_fields:
        df = df[(df[other_column_name] != "")]
        error_df = df[~(df[other_column_name] != "")]
        if error_df.shape[0] > 0:
            log(f"\nERROR - {other_column_name} is a non string field which was empty", 3)
            log(f"{error_df[other_column_name]}\n", 3)
    return df

def validateStringFields(df, string_columns_with_size):
    for string_column_name, size in string_columns_with_size:
        df = df[(df[string_column_name].str.len() <= int(size))]
        error_df = df[~(df[string_column_name].str.len() <= int(size))]
        if error_df.shape[0] > 0:
            log(f"\nERROR - {string_column_name} has rows whose string length exceeds the max: {size}", 3)
            log(f"{error_df[string_column_name]}\n", 3)
    return df

def validateEnumFields(df, enum_names_with_values):
    for enum_column_name, values in enum_names_with_values:
        df = df[df[enum_column_name].isin(values)]
        error_df = df[~df[enum_column_name].isin(values)]
        if error_df.shape[0] > 0:
            log(f"\nERROR - {enum_column_name} has values which are not in the enum:\n{values}", 3)
            log(f"{error_df[enum_column_name]}\n", 3)
    return df

def validate_data(df, staging_table_name):
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
                log(f"INFO - '{d365_column_name}' was found in the data", 1)
                break

        if not found and is_mandatory:
            log(f"ERROR - Mandatory column '{d365_column_name}' was missing from the data!", 3)
        elif not found:
            log(f"WARN - '{d365_column_name}' was missing from the data but is not mandatory", 2)

    unmapped_data_fields = []
    for data_column in df.columns:
        if not data_column in excel_to_d365_mapping:
            unmapped_data_fields.append(data_column)
    if not len(unmapped_data_fields) == 0:
        log(f"\nINFO - Fields from the data which are not mapped are:", 1)
        for field in unmapped_data_fields:
            log("\t" + field, 1)
    else:
        log("INFO - All data fields were successfully mapped to a d365 entity field.", 1)

    log("\nINFO - Checking for index integrity...", 1)
    validateIndexIntegrity(df, indexes, excel_to_d365_mapping)

    log("\nINFO - Checking whether dataset follows string size constraints...", 1)
    validateStringFields(df.copy(), string_columns_with_size)

    log("\nINFO - Checking whether dataset enum values columns contain permissible values...", 1)
    validateEnumFields(df.copy(), enum_names_with_values)

    validateOtherFields(df.copy(), other_fields)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--data_file', help='Name of the excel file where the data to validate is present')
    parser.add_argument('-s', '--staging', help='Name of the staging table for the D365 entity')
    parser.add_argument('-l', '--log_level', help='''
        Should be a number less than 3 for any logging to be printed to console
            0 - Info, Warnings, Errors
            1 - Warnings, Errors
            2 - Errors    
    ''')

    args, strings = parser.parse_known_args()
    GLOBAL_LOG_LEVEL = int(args.log_level)
    df = pd.read_excel(f"data/{args.data_file}", keep_default_na=False)

    for column in df.columns:
        if column.lower() == 'dataareaid':
            grouped = df.groupby(column)
            for category, group_df in grouped:
                print(f"Company: {category}")
                validate_data(group_df, args.staging)
                print("\n")
            break
    else:
        validate_data(df, args.staging)