import argparse
import pandas as pd
import xml.etree.ElementTree as ET

from lib import *

def get_all_data_sources(entity_name, no_blanks=False):
    model_name = identify_model(entity_name)
    if model_name is None:
        return {}
    
    required_path = f'{root_path}/{model_name}/{model_name}/AxDataEntityView'
    if model_name == 'ApplicationSuite':
        required_path = f'{root_path}/{model_name}/Foundation/AxDataEntityView'
    root = ET.parse(f'{required_path}/{entity_name}.xml').getroot()

    field_table_map = {}
    for index in root.find('Fields').findall('AxDataEntityViewField'):
        name_text = index.find('Name').text
        
        data_source = index.find('DataSource')
        data_field = index.find('DataField')
        computed_field = index.find('ComputedFieldMethod')

        if data_source is not None and data_field is not None:
            if 'Entity' in data_source.text:
                inner_map = get_all_data_sources(data_source.text)
                field_table_map[name_text] = inner_map[data_field.text]
            else:
                field_table_map[name_text] = [data_source.text, data_field.text]
        elif computed_field is not None:
            field_table_map[name_text] = ['[Computed Field]', f'[{computed_field.text}]'] if no_blanks else ['', '']
        elif data_source is not None:
            field_table_map[name_text] = [data_source.text, '']
            print(f'Verify {name_text} in {entity_name} does not contain any method or field mapping...')
        else:
            field_table_map[f'{name_text}'] = ['Unmapped', 'N/A'] if no_blanks else ['', '']

    return field_table_map

def write_to_excel(field_table_map, output_path):
    rows = []
    for field_name in field_table_map:
        rows.append({
            'Entity Field': field_name,
            'Source Table': field_table_map[field_name][0],
            'Source Field': field_table_map[field_name][1],
        })
    pd.DataFrame(rows).to_excel(output_path, index=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--excel', help='List of entity names in excel sheet')
    args, names = parser.parse_known_args()

    if not os.path.exists('entity_maps/'):
        os.makedirs('entity_maps/')
    if args.excel:
        inputs = pd.read_excel(args.excel, header=None)
        names = inputs.iloc[:, 0].astype(str).tolist()

    for name in names:
        try:
            entityInfo = getEntityInfo(name)
        except ValueError:
            continue
        write_to_excel(get_all_data_sources(entityInfo['Target Entity'].astype(str).iloc[0]), 
                       f'entity_maps/{entityInfo['Data Entity'].astype(str).iloc[0]}.xlsx')
