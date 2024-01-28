import os
import xml.etree.ElementTree as ET

root_path = 'K:/AosService/PackagesLocalDirectory'

def verifyStagingTable(axObject):
    if axObject.endswith("Staging"):
        return axObject
    else:
        print(f"Error: Provided input object: {axObject} is not of type staging table")
        exit(-1)

def verifyDataEntity(axObject):
    if axObject.endswith("Entity"):
        return axObject
    else:
        print(f"Error: Provided input object: {axObject} is not of type data entity")
        exit(-1)

def identify_model(search_term):
    directories = [d for d in os.listdir(root_path)]
    search_type = 'AxDataEntityView' if search_term.endswith("Entity") else 'AxTable'
    for directory in directories:
        directory_path = f'{root_path}/{directory}/{directory}/{search_type}'
        if directory == 'ApplicationSuite':
            directory_path = f'{root_path}/{directory}/Foundation/{search_type}'
        if os.path.exists(directory_path):
            files = [f for f in os.listdir(directory_path)]
            if search_term+'.xml' in files:
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
