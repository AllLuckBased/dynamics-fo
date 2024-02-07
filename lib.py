import re
import os
import pandas as pd
import xml.etree.ElementTree as ET

root_path = 'K:/AosService/PackagesLocalDirectory'

def format_for_windows_filename(input_string):
    forbidden_characters = r'<>:"/\|?*'
    cleaned_string = re.sub(f'[{re.escape(forbidden_characters)}]', '_', input_string)
    cleaned_string = cleaned_string.strip()
    return cleaned_string

def getEntityInfo(name):
    excel_file = 'label_conversion.csv'
    try:
        df = pd.read_csv(excel_file, header=None, names=['Data Entity', 'Staging Table', 'Target Entity'])
        for col in df.columns:
            row = df.loc[df[col] == name]
            if not row.empty:
                return row

        print(f"Row with value {name} not found.")
        raise ValueError(f'{name} does not exist as an entity in the database.')

    except FileNotFoundError:
        print(f"File not found: {excel_file}")
        exit(-1)
    except Exception as e:
        print(f"An error occurred while trying to read label_conversion.csv: {e}")
        exit(-1)

def identify_model(search_term):
    directories = [d for d in os.listdir(root_path)]
    search_type = 'AxDataEntityView' if search_term.endswith("Entity") else 'AxTable'
    for directory in directories:
        directory_path = f'{root_path}/{directory}/{directory}/{search_type}'
        if directory == 'ApplicationSuite':
            directory_path = f'{root_path}/{directory}/Foundation/{search_type}'
        if os.path.exists(directory_path):
            files = [f.lower() for f in os.listdir(directory_path)]
            if search_term.lower()+'.xml' in files:
                return directory
            
def get_references(model_name):
    descriptor_path = f'{root_path}/{model_name}/Descriptor/{model_name}.xml'
    if model_name == 'ApplicationSuite':
        descriptor_path = f'{root_path}/{model_name}/Descriptor/Foundation.xml'
    descriptor_root = ET.parse(descriptor_path).getroot()

    references = []
    for reference in descriptor_root.find('ModuleReferences').findall('{http://schemas.microsoft.com/2003/10/Serialization/Arrays}string'):
        references.append(reference.text)
    return references
