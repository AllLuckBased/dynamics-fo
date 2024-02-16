import os
import re
import pandas as pd
from bidict import bidict
from collections import defaultdict
from lib.validation_errors import *

def parseDataWithTemplate(df, template):
    # Information required to collect:
    mandatory_columns = []
    enum_names_with_values = []
    string_columns_with_size = []
    excel_to_d365_mapping = bidict()
    
    for row in template:
        found = False
        is_mandatory = row['Mandatory'] == 'Yes'
        d365_column_name = row['D365 Column Name']

        # Collects all the mandatory columns from the template itself.
        if is_mandatory:
            mandatory_columns.append(d365_column_name)
        
        for data_column in df.columns:
            match = data_column.lower() == d365_column_name.lower()
            
            # Maps the template column name to data column name (usually in all caps)
            if match:
                found = True
                excel_to_d365_mapping[data_column] = d365_column_name

                # Collects all the string columns, casts the dataframe, and stores the max size.
                if row['Data type'] == 'String':
                    df[data_column] = df[data_column].astype(str)
                    string_columns_with_size.append((data_column, 
                        int(row['Length'] if row['Length'] != 'MEMO' else -1)))
                #Collects all the enum columns and all the allowed values in that column.
                elif row['Data type'] == 'Enum':
                    enum_names_with_values.append((data_column, row['EnumValues'].split(', ')))
                break
        # Raises ValueError if mandatory column was missing from the dataframe.
        if not found and is_mandatory:
            raise ValueError(f'"{d365_column_name}"')
        
    return (excel_to_d365_mapping, mandatory_columns, string_columns_with_size, enum_names_with_values)

def validate_dependencies(input_df, company, excelToTemplateColumnMapping, relations, all_entity_source_maps, logs):
    def hot_fetch_data(sourceInfo, company=None):
        for filename in os.listdir('cache/data/'):
            if filename.startswith(sourceInfo[0] + "."):
                df = pd.read_excel(f'cache/data/{filename}')
                if company is None:
                    return df[sourceInfo[1].upper()]
                for column in input_df.columns:
                    if column.lower() == 'dataareaid':
                        return df[df[column] == company][sourceInfo[1].upper()]
                else:
                    return df[sourceInfo[1].upper()]

        raise FileNotFoundError()
    def minimum_cover(*lists):
        def most_common_element(combined_list):
            counts = {}
            for item in combined_list:
                counts[item[0]] = counts.get(item[0], 0) + 1
            max_count = max(counts.values())
            return [key for key, count in counts.items() if count == max_count]
        
        if not lists or len(lists) == 0:
            return []
        
        possibilities = []
        if len(lists) == 1:
            for x in lists[0]:
                possibilities.append((x,))    
        else:
            combined_list = []
            for index, my_list in enumerate(lists):
                for value in my_list:
                    combined_list.append((value, index))
            for most_common in most_common_element(combined_list):
                for possibility in minimum_cover(*[my_list for my_list in lists if most_common not in my_list]):
                    possibilities.append((most_common,) + tuple(possibility))
        return possibilities

    source_data = {}
    source_entities = defaultdict(int)
    choose_source_entity = {}
    for excel_column in input_df.columns.tolist():
        try:
            column = excelToTemplateColumnMapping[excel_column] 
        except:
            continue
        if column in relations:
            relation = relations[column][:2] #TODO: remove this slice and handle that fixed field relation... see below redundancy too
            
            try:
                entity_source_map = all_entity_source_maps.inv[tuple(relation)]
                source_entities_column = list(entity_source_map[0])
                if len(source_entities_column) == 1:
                    source_entities[source_entities_column[0]]+=1
                    source_data[column] = hot_fetch_data((entity_source_map[0][0], entity_source_map[1][0]), company)
                else:
                    choose_source_entity[column] = entity_source_map
            except FileNotFoundError:
                logs.append(SourceEntityMissing(column, entity_source_map[0][0], entity_source_map[1][0]))
            except:
                logs.append(SourceEntityNotFound(column, relation[0], relation[1]))

    if len(choose_source_entity.values()) > 0:
        possibility = minimum_cover([
            [x for x in choose_source_entity.values()[i][0]] 
            for i in range(0, len(choose_source_entity.values()))
        ])

        for key, _ in sorted(source_entities.items(), key=lambda item: item[1], reverse=True):
            possibilitiesNew = [possibility for possibility in possibility if key in possibility]
            if len(possibilitiesNew) != 0:
                possibility = possibilitiesNew
            if len(possibilitiesNew) == 1:
                break
        possibility = possibility[0]

        for column in choose_source_entity.keys():
            chosen_entity = (set(entity_source_map[0]) & set(possibility))[0]
            entity_field = entity_source_map[1][entity_source_map[0].index(chosen_entity)]
            source_data[column] = hot_fetch_data((chosen_entity, entity_field), company)

    if len(source_data.values()) > 0:
        for excel_column in input_df.columns.tolist():
            try:
                column = excelToTemplateColumnMapping[excel_column] 
            except:
                continue
            error_df = input_df[~input_df[column.upper()].isin(source_data[column])]
            if error_df.shape[0] > 0:
                logs.append(KeyViolation(column, error_df[column].unique().tolist(), ', '.join(map(str, error_df.index))))


def validateMandatoryFields(df, result_df, mandatory_columns, excel_to_d365_mapping, logs):
    for d365_column_name in mandatory_columns:
        mandatory_column_name = excel_to_d365_mapping.inverse[d365_column_name]
        result_df = result_df[(result_df[mandatory_column_name].notna())]
        error_df = df[(df[mandatory_column_name].isna())]
        if error_df.shape[0] > 0:
            logs.append(MissingDataError(d365_column_name, ', '.join(map(str, error_df.index))))
    return result_df

def validateStringFields(df, result_df, string_columns_with_size, excel_to_d365_mapping, logs):
    # Creating another copy of the df to compare there is no loss of data on truncation
    truncated_df = df.copy()
    for string_column_name, size in string_columns_with_size:
        try:
            # Strips whitespaces on the left and right for all the data frames...
            df[string_column_name] = df[string_column_name].str.lstrip().str.rstrip()
            result_df.loc[:, string_column_name] = result_df[string_column_name].str.lstrip().str.rstrip()
            # ... but truncates this df to max allowed size before striping whitespace on right.
            truncated_df[string_column_name] = df[string_column_name].str.lstrip().str[:size].str.rstrip()
        except KeyError:
            continue

        # Checking how many unique values were lost during truncation.
        unique_values_result_df = set(df[string_column_name].unique())
        unique_values_truncated_df = set(truncated_df[string_column_name].unique())
        
        # There was loss of data after truncation.
        if len(unique_values_result_df) > len(unique_values_truncated_df):
            lost_unique_values = {
                value for value in unique_values_result_df - unique_values_truncated_df 
                    if value[:size] in unique_values_result_df
            }
            # Grouping the lost values to their corresponding new value.
            grouped_lost_values = []
            seen_truncated_values = []
            for lost_value in lost_unique_values:
                truncated_value = lost_value[:size]
                try:
                    bucket_index = seen_truncated_values.index(truncated_value)
                    grouped_lost_values[bucket_index].append(lost_value)
                except ValueError:
                    seen_truncated_values.append(truncated_value)
                    grouped_lost_values.append([lost_value])
            
            for index, seen_truncated_value in enumerate(seen_truncated_values):
                logs.append(DataLossError(excel_to_d365_mapping[string_column_name], size, grouped_lost_values[index], seen_truncated_value, 
                    ', '.join(map(str, df[df[string_column_name].isin(grouped_lost_values[index])].index.tolist()))))
            
            # Only filtering the values which are not losing data after truncation
            result_df = result_df[~result_df[string_column_name].isin(lost_unique_values)]
        
        result_df.loc[:, string_column_name] = result_df[string_column_name].str[:size].str.rstrip()
        
        error_df = df[(df[string_column_name].str.len() > int(size))]
        if error_df.shape[0] > 0:
            logs.append(StringSizeError(excel_to_d365_mapping[string_column_name], size, 
                error_df[string_column_name].unique().tolist(), ', '.join(map(str, error_df.index))))

    return result_df

def validateIndexIntegrity(df, result_df, indexes, excel_to_d365_mapping, logs):
    for index in indexes:
        #Need to inverse it as the indexes are in d365 name while we need the df names.
        df_index_names = []
        for index_column in index:
            try:
                df_index_names.append(excel_to_d365_mapping.inverse[index_column])
            except KeyError:
                 print(f"No template column found for column {index_column} in data. Skipping...")
        if(len(df_index_names) == 0):
            continue

        #Once the column names of the indexes in the df are identified, filter every duplicate but just the first
        result_df = result_df[~result_df.duplicated(subset=df_index_names, keep='first')]

        #Check whether the duplicated index rows are exact same or conflicting.
        error_df = df[df.duplicated(subset=df_index_names, keep=False)]
        if error_df.shape[0] > 0:
            grouped_duplicates = error_df.groupby(df_index_names)
            for category, group_df in grouped_duplicates:
                all_duplicated = group_df[~group_df.duplicated(keep=False)]
                if all_duplicated.shape[0] == 0:
                    logs.append(DuplicateRowsError(', '.join(index), category, ', '.join(map(str, group_df.index))))
                else:
                    logs.append(DataConflictError(', '.join(index), category, ', '.join(map(str, group_df.index))))
    return result_df

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
