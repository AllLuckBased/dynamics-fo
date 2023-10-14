import os
import sys
import pandas as pd
import xml.etree.ElementTree as ET

root_path = "K:/AosService/PackagesLocalDirectory"

def identify_model(search_term):
    directories = [d for d in os.listdir(root_path)]
    for directory in directories:
        directory_path = f"{root_path}/{directory}/{directory}/AxTable"
        if directory == "ApplicationSuite":
            directory_path = f"{root_path}/{directory}/Foundation/AxTable"
        if os.path.exists(directory_path):
            files = [f for f in os.listdir(directory_path)]
            if search_term in files:
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
    referenced_models = get_references(model_name)
    base_path = f"{root_path}/{model_name}/{model_name}"
    if model_name == "ApplicationSuite":
            base_path = f"{root_path}/{model_name}/Foundation"

    main_path = f"{base_path}/AxTable"
    edt_paths = [f"{base_path}/AxEdt"]
    enum_paths = [f"{base_path}/AxEnum"]
    for reference in referenced_models:
        reference1 = "Foundation" if reference == "ApplicationSuite" else reference
        edt_paths.append(f"{root_path}/{reference}/{reference1}/AxEdt")
        enum_paths.append(f"{root_path}/{reference}/{reference1}/AxEnum")

    return [main_path, edt_paths, enum_paths]

def generate_template(staging_table_name):
    ignored_index_fields = ["DefinitionGroup", "ExecutionId"]
    ignored_table_fields = ["DefinitionGroup", "ExecutionId", "IsSelected", "TransferStatus"]

    model_name = identify_model(f"{staging_table_name}.xml")
    main_path, edt_paths, enum_paths = get_required_paths(model_name)

    root = ET.parse(f"{main_path}/{staging_table_name}.xml").getroot()
    
    unique_fields = []
    for index in root.find('Indexes').findall('AxTableIndex'):
        filtered_fields = [
            f.find('DataField').text 
            for f in index.find('Fields').findall('AxTableIndexField') 
            if f.find('DataField').text not in ignored_index_fields
        ]
        if len(filtered_fields) == 1:
            unique_fields.extend(filtered_fields)


    rows = []
    for field in root.find('Fields').findall('AxTableField'):
        name = field.find('Name').text
        if name in ignored_table_fields:
            continue
        
        data_type = field.get('{http://www.w3.org/2001/XMLSchema-instance}type').replace('AxTableField', '')

        string_size = field.find('StringSize')
        if data_type == "String" and string_size is None:
            edt = field.find('ExtendedDataType').text

            for edt_path in edt_paths:
                full_path = f"{edt_path}/{edt}.xml"
                if os.path.exists(full_path):
                    edt_root = ET.parse(full_path).getroot()
                    break
            else:
                print("Error: Could not find EDT: " + edt)
                exit(-1)
                    
            string_size = edt_root.find("StringSize") #TODO: write logic for memo
            while string_size is None:
                edt = edt_root.find("Extends")
                if edt is None:
                    string_size = "10" #If they dont mention it anywhere it defaults to 10
                    break
                edt = edt.text

                for edt_path in edt_paths:
                    full_path = f"{edt_path}/{edt}.xml"
                    if os.path.exists(full_path):
                        edt_root = ET.parse(full_path).getroot()
                        break
                else:
                    print("Error: Could not find EDT: " + edt)
                    exit(-1)
                string_size = edt_root.find("StringSize")
            if not isinstance(string_size, str):
                string_size = string_size.text

        is_unique = "Yes" if name in unique_fields else "No"

        if data_type == "Enum":
            enum_type = field.find('EnumType').text

            if enum_type == "NoYes":
                enum_values = "No, Yes"
            elif enum_type == "Timezone":
                enum_values = "Timezone"
            else:
                for enum_path in enum_paths:
                    full_path = F"{enum_path}/{enum_type}.xml"
                    if os.path.exists(full_path):
                        enum_root = ET.parse(full_path).getroot()
                        break
                else:
                    print("Error: Could not find base Enum: " + enum_type)
                    exit(-1)
                
                names = [value.find('Name').text for value in enum_root.findall('.//AxEnumValue')]
                enum_values = ', '.join(names)
        else:
            enum_values = ''

        mandatory = field.find('Mandatory')

        row = {
            'D365 Column Name': name,
            'Data type': data_type,
            'Length': string_size if string_size is not None else 'NULL',
            'IsUniqueField': is_unique,
            'IsNullable': "No",  # By default and always I think, right?
            'EnumValues': enum_values,
            'Mandatory': mandatory.text if mandatory is not None else 'No'
        }
        
        rows.append(row)
    pd.DataFrame(rows).to_excel(f"{staging_table_name}.xlsx", index=False)

if __name__ == "__main__":
    for staging_table_name in sys.argv[1:]:
        generate_template(staging_table_name)
