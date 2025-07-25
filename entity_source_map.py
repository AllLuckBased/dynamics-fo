import argparse

from lib.common import *

def write_source_map(field_table_map, output_path):
    rows = []
    for field_name in field_table_map:
        rows.append({
            'Entity Field': field_name,
            'Source Table': field_table_map[field_name][0],
            'Source Field': field_table_map[field_name][1],
        })
    pd.DataFrame(rows).to_excel(output_path, index=False)

def find_element_with_string(element, search_string, parent=None):
        if element.text is not None and search_string in element.text:
            return parent
        for child in element:
            possible_element = find_element_with_string(child, search_string, element)
            if possible_element is not None:
                return possible_element

def get_entity_relations(entity_name):
    model_name = identify_model(entity_name)
    if model_name is None:
        return {}
    
    required_path = f'{root_path}/{model_name}/{model_name}/AxDataEntityView'
    if model_name == 'ApplicationSuite':
        required_path = f'{root_path}/{model_name}/Foundation/AxDataEntityView'

    if(os.path.exists(f'{required_path}/{entity_name}.xml')):
        root = ET.parse(f'{required_path}/{entity_name}.xml').getroot()
    else:
        print(f'Error: Entity: {entity_name} was not found!')
        exit(-1)
    
    # For every field containing a relation, it maps to an array of 
            #[relatedEntity, relatedField, relatedEntityFilter]
    relations = {}
    for relationXML in root.find('Relations').findall('AxDataEntityViewRelation'):
        relatedEntity = getEntityInfo(relationXML.find('RelatedDataEntity').text, False)
        if relatedEntity is None: continue
        else: relatedEntity = relatedEntity['Data Entity'].astype(str).iloc[0]

        optional = True
        if relationXML.find('RelatedDataEntityCardinality') is not None\
            and relationXML.find('RelatedDataEntityCardinality').text == 'ExactlyOne':
            optional = False
        
        constraint = {}
        relatedEntityFilter = None
        for constraintXML in relationXML.find('Constraints').findall('AxDataEntityViewRelationConstraint'):
            constraintType = constraintXML.get('{http://www.w3.org/2001/XMLSchema-instance}type')\
                .replace('AxDataEntityViewRelationConstraint', '').replace('DataEntityViewRelationConstraint', '')
            if constraintType == 'Field':
                field = constraintXML.find('Field').text
                relatedField = constraintXML.find('RelatedField').text
                constraint[field] = [relatedEntity, relatedField, optional, relatedEntityFilter]
            else:
                filter = constraintXML.find('ValueStr')
                if filter is None: continue
                filter = filter.text
                relatedField = constraintXML.find(
                    'RelatedField' if constraintType == 'RelatedFixed' else 'Field').text
                relatedEntityFilter = (relatedField, f'{constraintType}::{filter}')
                for constraint_value in constraint.values():
                    constraint_value[3] = relatedEntityFilter
        relations.update(constraint)
    return relations

def get_all_data_sources(entity_name, no_blanks=False, prevRoot=None):        
    model_name = identify_model(entity_name)
    if model_name is None and prevRoot is not None:
        entity_name = find_element_with_string(prevRoot.find(
            'ViewMetadata/DataSources/AxQuerySimpleRootDataSource'), entity_name).find('Table').text
        model_name = identify_model(entity_name)
    elif model_name is None and prevRoot is None:
        return {}
    
    required_paths = [f'{root_path}/{model_name}/{model_name}/AxDataEntityView',
            f'{root_path}/{model_name}/{model_name}/AxView']
    if model_name == 'ApplicationSuite':
        required_paths = [f'{root_path}/{model_name}/Foundation/AxDataEntityView',
            f'{root_path}/{model_name}/Foundation/AxView']

    prefix = 'AxDataEntityView'
    for required_path in required_paths:
        if(os.path.exists(f'{required_path}/{entity_name}.xml')):
            root = ET.parse(f'{required_path}/{entity_name}.xml').getroot()
            break
        prefix = 'AxView'
    else:
        print(f'Error: Entity/View object {entity_name} was not found!')
        exit(-1)

    field_table_map = {}
    for index in root.find('Fields').findall(f'{prefix}Field'):
        name_text = index.find('Name').text
        
        data_source = index.find('DataSource')
        data_field = index.find('DataField')
        computed_field = index.find('ComputedFieldMethod')

        if data_source is not None and data_field is not None:
            if 'Entity' in data_source.text and data_source.text != 'LegalEntity':
                inner_map = get_all_data_sources(data_source.text, prevRoot=root)
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
            entity_info = getEntityInfo(name)
        except ValueError:
            continue
        fileName = format_for_windows_filename(entity_info['Data Entity'].astype(str).iloc[0])
        write_source_map(get_all_data_sources(entity_info['Target Entity'].astype(str).iloc[0]), 
                       f'entity_maps/{fileName}.xlsx')
