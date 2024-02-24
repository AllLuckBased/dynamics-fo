import os
import pandas as pd
from lib.validation_errors import *
from collections import defaultdict

# Quickly returns any column from any excel entity data by converting it to a Dataframe.
# Data structures:
#       fetchWhat --> tuple(entityFileName, entityFieldName)
def hot_fetch_data(fetchWhat, optional, company=None):
    data = None
    for filename in os.listdir('cache/data/'):
        if filename.startswith(fetchWhat[0] + "."):
            if filename.endswith(".csv"):
                df = pd.read_csv(f'cache/data/{filename}', encoding_errors='replace', keep_default_na=False, on_bad_lines='skip')
            else: df = pd.read_excel(f'cache/data/{filename}', encoding_errors='replace', keep_default_na=False, on_bad_lines='skip')
            if fetchWhat[1].upper() in df.columns:
                df_column = fetchWhat[1].upper()
            else: 
                for df_column in df.columns:
                    if df_column.upper() == fetchWhat[1].upper():
                        break
            if company is None:
                data = df[df_column]
            for column in df.columns:
                if column.lower() == 'dataareaid':
                    data = df[df[column] == company][df_column]
            else:
                data = df[df_column]

            if optional:
                data = pd.concat([data, pd.Series([''])])
            return data
    raise FileNotFoundError()

# Given a list of lists:
#   this will return a list of all the smallest tuples which 
#   will contain at least one element from every list

def minimum_cover(*lists):
    def most_common_element(combined_list):
        counts = {}
        for item in combined_list:
            counts[item] = counts.get(item, 0) + 1
        max_count = max(counts.values())
        return [key for key, count in counts.items() if count == max_count]
    
    if not lists or len(lists) == 0:
        return []
    
    minimum_covers = []
    if len(lists) == 1:
        for x in lists[0]:
            minimum_covers.append((x,))    
    else:
        combined_list = []
        for list_ in lists:
            combined_list.extend(list_)
        for most_common in most_common_element(combined_list):
            for minimum_cover in minimum_cover(*[my_list for my_list in lists if most_common not in my_list]):
                minimum_covers.append((most_common,) + tuple(minimum_cover))
    return minimum_covers

# Validates the data where there are dependencies on other data.
# Data structures:
#       excelToTemplateColumnMapping --> bidict{excelColumnName: temlpateColumnName?}
#       relations(staging/entity) --> dict{templateColumnName: list[relatedTable, tableField, optional?, relatedFixedConstraint]}
#       all_entity_source_maps --> bidict{
#           tuple(relatedTable, tableField): 
#               tuple(tuple(...source_entities), tuple(...correspondingEntityFields)
#           )
#       }
#       return --> set(source_entities)
def validate_dependencies(input_df, company, excelToTemplateColumnMapping, stagingRelations, entityRelations, all_entity_source_maps, logs):
    source_data = {}
    choose_source_entity = {}
    combined_standardized_relations = {}
    source_entity_counts = defaultdict(int)
    for excel_column in input_df.columns.tolist():
        try: column = excelToTemplateColumnMapping[excel_column] 
        except: continue

        if column in stagingRelations:
            relation = stagingRelations[column][:2] #TODO: remove this slice and handle that fixed field relation.
            optional = stagingRelations[column][2]
            fixed = stagingRelations[column][3]
            
            try: source_entities = all_entity_source_maps.inv[tuple(relation)]
            except: 
                logs.append(SourceEntityNotFound(column, relation[0], relation[1]))
                continue
        elif column in entityRelations:
            source_entities = ((entityRelations[column][0],), (entityRelations[column][1],))
            optional = entityRelations[column][2]
            fixed = entityRelations[column][3]
        else: continue
        try:
            source_entities += (optional, fixed)
            source_entity_names = source_entities[0]
            if len(source_entity_names) == 1:
                combined_standardized_relations[excel_column] = source_entities + (optional, fixed)
                source_entity_counts[source_entity_names[0]]+=1
                source_data[column] = hot_fetch_data(
                    (source_entities[0][0], source_entities[1][0]), optional, company)
            else:
                choose_source_entity[column] = source_entities
        except FileNotFoundError:
            logs.append(SourceEntityMissing(column, source_entities[0][0], source_entities[1][0]))

    if len(choose_source_entity.values()) > 0:
        covers = minimum_cover([
            [x for x in choose_source_entity.values()[i][0]] 
            for i in range(0, len(choose_source_entity.values()))
        ])

        for key, _ in sorted(source_entity_counts.items(), key=lambda item: item[1], reverse=True):
            newCovers = [cover for cover in covers if key in cover]
            if len(newCovers) != 0: covers = newCovers
            if len(covers) == 1: break
        cover = covers[0]

        for column, choices in choose_source_entity.items():
            chosen_entity = (set(choices[0]) & set(cover))[0]
            entity_field = source_entities[1][source_entities[0].index(chosen_entity)]
            
            source_entity_counts[chosen_entity]+=1
            combined_standardized_relations[excelToTemplateColumnMapping.inv[column]]\
                = (chosen_entity, entity_field, optional, fixed)
            source_data[column] = hot_fetch_data((chosen_entity, entity_field), company)

    if len(source_data.values()) > 0:
        for column, data in source_data.items():
            error_df = input_df[~input_df[excelToTemplateColumnMapping.inv[column]].isin(data)]
            if error_df.shape[0] > 0:
                input_df.loc[error_df.index, 'PwCErrorReason'] += f'Source reference missing for {column};'
                logs.append(KeyViolation(column, 
                    error_df[excelToTemplateColumnMapping.inv[column]].unique().tolist(), 
                    ', '.join(map(str, error_df.index)))
                )
    return combined_standardized_relations
