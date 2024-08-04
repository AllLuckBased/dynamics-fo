import os
import shutil
import argparse
import pandas as pd

from entity_source_map import *
from template_from_table import *

def merge_template_with_map(filename, path_to_sample_data):
    if not os.path.exists('template&maps'):
        os.makedirs('template&maps')
    try:
        with pd.ExcelWriter(f'template&maps/{filename}.xlsx') as writer:
            if path_to_sample_data:
                df1 = pd.read_excel(f'{path_to_sample_data}/{filename}.xlsx')
                df1.to_excel(writer, sheet_name='Sample data', index=False)

            df2 = pd.read_excel(f'templates/{filename}.xlsx')
            df2.to_excel(writer, sheet_name='Template', index=False)

            df3 = pd.read_excel(f'entity_maps/{filename}.xlsx')
            df3.to_excel(writer, sheet_name='Source Map', index=False)
    except:
        print('Failed to merge for ' + filename)

def getRelations(fromTable, toTable):
    relations = []
    model_names = identify_model(fromTable, ['AxTable', 'AxTableExtension'])
    for model_name in model_names:
        main_paths, _, _= get_required_paths(model_name)

        for main_path in main_paths:
            if os.path.exists(f'{main_path}/{fromTable}.xml'):
                root = ET.parse(f'{main_path}/{fromTable}.xml').getroot()
                break
            elif os.path.exists(f'{main_path}/{fromTable}.extension.xml'):
                root = ET.parse(f'{main_path}/{fromTable}.extension.xml').getroot()
                break
        else:
            print(f'Error: Staging table {fromTable} was not found!')
            exit(-1)
        
    
        for relation in root.find('Relations').findall('AxTableRelation'):
            if relation.find('RelatedTable').text == toTable:
                for constraint in relation.find('Constraints').findall('AxTableRelationConstraint'):
                    relations.append(f'{fromTable}.{constraint.find('Field').text} = {toTable}.{constraint.find('RelatedField').text}')
                return relations
    return relations
    
def generate_script(field_table_map, indexes):
    sql = 'SELECT\n'
    tables = set()
    primary_table = None

    ledgerdimension = []
    not_primary = []
    for field_name in field_table_map:
        if not (field_table_map[field_name][0] and field_table_map[field_name][1]): continue
        if 'DAVC' in field_table_map[field_name][0] : continue

        if 'DefaultLedgerDimension' in field_name:
            sql += f'\tdavc{len(ledgerdimension)}.DisplayValue AS {field_name},\n'
            ledgerdimension.append((field_table_map[field_name][0], field_table_map[field_name][1]))
        else:            
            sql += f'\t{field_table_map[field_name][0]}.{field_table_map[field_name][1]} AS {field_name},\n'
            if len(indexes) > 0 and field_name in indexes[0]:
                if not primary_table:
                    primary_table = field_table_map[field_name][0]
                elif field_table_map[field_name][0] != primary_table and field_table_map[field_name][0] not in not_primary:
                    if input(f'Change primary table from {primary_table} to {field_table_map[field_name][0]}? (Y/n)').capitalize().startswith('Y'):
                        primary_table = field_table_map[field_name][0]
                    else: not_primary.append(field_table_map[field_name][0])
            tables.add(field_table_map[field_name][0])
    if not primary_table:
        tables_list = list(tables)
        print('Tables are: ')
        for i in range(len(tables)):
            print(f'{i+1}: {tables_list[i]}')
        primary_table = tables_list[int(input('Failed to identify the primary table, please specify: '))-1]
    tables.discard(primary_table)
    print(f'Primary identified as {primary_table}')
    sql += f'\t{primary_table}.DATAAREAID\nFROM\n\t{primary_table}'
    
    index = 0
    found_relations = [primary_table]
    while index < len(found_relations):
        primary_table = found_relations[index]
        for i in range(len(tables)):
            tables_list = list(tables)
            relations = getRelations(tables_list[i], primary_table)
            if len(relations) == 0: 
                relations = getRelations(primary_table, tables_list[i])
            if len(relations) > 0:
                if tables_list[i] not in found_relations:
                    found_relations.append(tables_list[i])
                sql+= f'\nLEFT JOIN\n\t{tables_list[i]} ON '
                for i  in range(len(relations)):
                    sql += relations[i]
                    if i < len(relations) - 1:
                        sql += ' AND '
        index += 1
    for i in range(len(ledgerdimension)):
        sql+= f'\nLEFT JOIN\n\t DimensionAttributeValueCombination davc{i} ON {ledgerdimension[i][0]}.{ledgerdimension[i][1]} = davc{i}.RecId'
    print(sql)

parser = argparse.ArgumentParser()
parser.add_argument('-e', '--excel', help='List of entity names in excel sheet')
parser.add_argument('-m', '--merge', help='Pass the path to the sample data folder.')
parser.add_argument('-f', '--force', action='store_true', help='Ignore and omit the columns which are throwing errors.')
args, names = parser.parse_known_args()

if not os.path.exists('templates'):
    os.makedirs('templates')
if not os.path.exists('entity_maps'):
    os.makedirs('entity_maps')

if args.excel:
    inputs = pd.read_excel(args.excel, header=None)
    names = inputs.iloc[:, 0].astype(str).tolist()

for name in names:
    try:
        entity_info = getEntityInfo(name)
    except ValueError:
        continue

    if not os.path.exists('templates/'):
        os.makedirs('templates/')
    if not os.path.exists('entity_maps/'):
        os.makedirs('entity_maps/')

    try:
        template_rows, indexes = generate_template(entity_info['Staging Table'].astype(str).iloc[0], args.force)
        fileName = encode_filename(entity_info['Data Entity'].astype(str).iloc[0])
        pd.DataFrame(template_rows).to_excel(f'templates/{fileName}.xlsx', index=False)
    except Exception as e:
        continue

    source_map = get_all_data_sources(entity_info['Target Entity'].astype(str).iloc[0])
    write_source_map(source_map, f'entity_maps/{fileName}.xlsx')
    generate_script(source_map, indexes)
    merge_template_with_map(fileName, args.merge)

    try:
        shutil.rmtree('templates/')
        shutil.rmtree('entity_maps/')
    except OSError as e:
        print(f"Error while trying to remove directories: {e}")