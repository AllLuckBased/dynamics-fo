import os
import argparse
import pandas as pd
import xml.etree.ElementTree as ET

root_path = "K:/AosService/PackagesLocalDirectory"
model_name = "ApplicationSuite"

def identify_model(search_term):
    directories = [d for d in os.listdir(root_path)]
    for directory in directories:
        directory_path = f"{root_path}/{directory}/{directory}/AxDataEntityView"
        if directory == "ApplicationSuite":
            directory_path = f"{root_path}/{directory}/Foundation/AxDataEntityView"
        if os.path.exists(directory_path):
            files = [f for f in os.listdir(directory_path)]
            if search_term+".xml" in files:
                return directory

def get_references(model_name):
    descriptor_path = f"{root_path}/{model_name}/Descriptor/{model_name}.xml"
    if model_name == "ApplicationSuite":
            descriptor_path = f"{root_path}/{model_name}/Descriptor/Foundation.xml"
    descriptor_root = ET.parse(descriptor_path).getroot()

    references = []
    for reference in descriptor_root.find("ModuleReferences").findall("{http://schemas.microsoft.com/2003/10/Serialization/Arrays}string"):
        references.append(reference.text)
    return references

def get_required_paths(model_name):
    base_path = f"{root_path}/{model_name}/{model_name}"
    if model_name == "ApplicationSuite":
            base_path = f"{root_path}/{model_name}/Foundation"

    return [f"{base_path}/AxDataEntityView"]

def get_all_data_sources(entity_name):     
    base_model = identify_model(entity_name)
    if base_model is None:
         return {}
    
    required_path = get_required_paths(base_model)
    root = ET.parse(f"{required_path[0]}/{entity_name}.xml").getroot()

    field_table_map = {}
    for index in root.find('Fields').findall('AxDataEntityViewField'):
        name_text = index.find('Name').text
        
        data_field = index.find('DataField')
        data_source = index.find('DataSource')
        if data_source is not None:        
            if 'Entity' in data_source.text:
                return get_all_data_sources(data_source.text)
            else:
                field_table_map[name_text] = [data_source.text, data_field.text]
        else:
            field_table_map[f"{name_text}"] = '??'
    return field_table_map


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    _, strings = parser.parse_known_args()
    for entity_name in strings:
        field_table_map = get_all_data_sources(entity_name)
        rows = []
        for field_name in field_table_map:
            if "??" in field_table_map[field_name]:
                rows.append({
                'Source Table': '',
                'Source Field': '',
                'Entity Field': field_name
                })
            else:
                rows.append({
                    'Source Table': field_table_map[field_name][0],
                    'Source Field': field_table_map[field_name][1],
                    'Entity Field': field_name
                })
        pd.DataFrame(rows).to_excel(f"{entity_name}.xlsx", index=False)
