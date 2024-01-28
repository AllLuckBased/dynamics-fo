import os
import argparse
import pandas as pd
import xml.etree.ElementTree as ET

from lib import *

def get_required_paths(model_name):
    referenced_models = get_references(model_name)
    app_suite_paths = [
        f'{root_path}/ApplicationSuite/Foundation/',
        f'{root_path}/ApplicationSuite/SCMControls',
        f'{root_path}/ApplicationSuite/Tax Books Application Suite Integration',
        f'{root_path}/ApplicationSuite/Tax Engine Application Suite Integration',
        f'{root_path}/ApplicationSuite/Electronic Reporting Application Suite Integration'
    ]

    base_paths = [f'{root_path}/{model_name}/{model_name}']
    if model_name == 'ApplicationSuite':
        base_paths = app_suite_paths

    main_paths = [f'{base_path}/AxTable' for base_path in base_paths]
    edt_paths = [f'{base_path}/AxEdt' for base_path in base_paths]
    enum_paths = [f'{base_path}/AxEnum' for base_path in base_paths]

    for reference in referenced_models:
        if reference == 'ApplicationSuite':
            edt_paths += [f'{app_suite_path}/AxEdt' for app_suite_path in app_suite_paths]
            enum_paths += [f'{app_suite_path}/AxEnum' for app_suite_path in app_suite_paths]
        else:
            edt_paths.append(f'{root_path}/{reference}/{reference}/AxEdt')
            enum_paths.append(f'{root_path}/{reference}/{reference}/AxEnum')
    return [main_paths, edt_paths, enum_paths]

# Some EDTs are present in the System Documentation section of the AOT and cant be found.
# The string size values for these EDTs are hardcoded as a python dictionary.
edt_from_docs = {
    'UserId': 20, 
    'FieldName': 81, 
    'DataAreaId': 4, 
    'ClassName': 120, 
    'SelectableDataArea': 4,
} 

enum_from_docs = {
    'NoYes': 'No, Yes', 
    'Timezone': 'Timezone',
    'boolean': 'false, true', 
    'RoleAssignmentMode': 'None, Manual, Automatic',
    'RoleAssignmentStatus': 'None, Enabled, Disabled',
    'PreferredCalendar': 'Gregorian, Hijri, UmAlQura',
    'UserAccountType': 'ADUser, ADGroup, ClaimsUser, ClaimsGroup',
    'UserLicenseType': 'None, SelfService, Task, Functional, Enterprise, Server, Universal, Activity, Finance, SCM, Commerce, Project, HR',
}

def generate_template(staging_table_name, force):
    #print(staging_table_name)
    staging_table_name = verifyStagingTable(staging_table_name)
    ignored_index_fields = ['DefinitionGroup', 'ExecutionId', 'RecId']
    ignored_table_fields = ['DefinitionGroup', 'ExecutionId', 'IsSelected', 'TransferStatus']

    model_name = identify_model(staging_table_name)
    main_paths, edt_paths, enum_paths = get_required_paths(model_name)

    for main_path in main_paths:
        if(os.path.exists(f'{main_path}/{staging_table_name}.xml')):
            root = ET.parse(f'{main_path}/{staging_table_name}.xml').getroot()
            break
    else:
        print(f'Error: Staging table {staging_table_name} was not found!')
        exit(-1)
    
    indexes = []
    unique_fields = []
    for index in root.find('Indexes').findall('AxTableIndex'):
        filtered_fields = [
            f.find('DataField').text 
            for f in index.find('Fields').findall('AxTableIndexField') 
            if f.find('DataField').text not in ignored_index_fields
        ]
        if index.find('AlternateKey') is not None and index.find('AlternateKey').text == 'Yes':
            indexes.append(tuple(filtered_fields))
            if len(filtered_fields) == 1:
                unique_fields.extend(filtered_fields)

    rows = []
    for field in root.find('Fields').findall('AxTableField'):
        name = field.find('Name').text
        if name in ignored_table_fields:
            continue
        
        data_type = field.get('{http://www.w3.org/2001/XMLSchema-instance}type').replace('AxTableField', '')

        # If string size is directly available in the staging table, awesome!
        string_size = field.find('StringSize')
        if string_size is not None: 
            string_size = string_size.text
        
        # If it is not available, make sure its a FieldString before looking into its EDT
        if data_type == 'String' and string_size is None:
            if field.find('ExtendedDataType') is None:
                string_size = 10
            else:
                edt = field.find('ExtendedDataType').text
                # If the EDT is from the System Documentation, search in the hardcoded dict.
                if edt in edt_from_docs:
                    string_size = edt_from_docs[edt]
                # Else locate the EDT file and parse the string size from that file.
                else:
                    for edt_path in edt_paths:
                        full_path = f'{edt_path}/{edt}.xml'
                        if os.path.exists(full_path):
                            edt_root = ET.parse(full_path).getroot()
                            break
                    else:
                        print(f'Error: Could not find EDT: {edt} for table(field): {staging_table_name}({name})')
                        if force: 
                            continue
                        else:
                            exit(-1)
                    if(edt_root.find('StringSize') is not None):
                        string_size = edt_root.find('StringSize').text

            #If it is not even directly available in the immediate field EDT, 
            #then we need to search for the parent which contains this information.
            while string_size is None:
                edt = edt_root.find('Extends')
                #In case no parent has the information, the default string size in X++ is 10.
                if edt is None:
                    string_size = '10'
                    break
                edt = edt.text
                if edt in edt_from_docs:
                    string_size = edt_from_docs[edt]
                    break
                for edt_path in edt_paths:
                    full_path = f'{edt_path}/{edt}.xml'
                    if os.path.exists(full_path):
                        edt_root = ET.parse(full_path).getroot()
                        break
                else:
                    print(f'Error: Could not find EDT: {edt} for table(field): {staging_table_name}({name})')
                    if force: 
                        string_size = '???'
                    else:
                        exit(-1)
                if(edt_root.find('StringSize') is not None):
                    string_size = edt_root.find('StringSize').text
            #There is no limit to the length of the string.
            if string_size == '-1':
                string_size = 'MEMO'

        is_unique = 'Yes' if name in unique_fields else 'No'

        if data_type == 'Enum':
            enum_type = field.find('EnumType').text
            
            if enum_type in enum_from_docs:
                enum_values = enum_from_docs[enum_type]
            else:
                for enum_path in enum_paths:
                    full_path = F'{enum_path}/{enum_type}.xml'
                    if os.path.exists(full_path):
                        enum_root = ET.parse(full_path).getroot()
                        break
                else:
                    print(f'Error: Could not find base Enum: {enum_type} for table(field): {staging_table_name}({name})')
                    if(force): 
                        continue
                    else:
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
            #'IsNullable': 'No', Check how this logic works with Shubhadeep da.
            'EnumValues': enum_values,
            'Mandatory': mandatory.text if mandatory is not None else 'No'
        }
        
        rows.append(row)
    return (rows, indexes)

def merge_excel_files(input_excel, path_to_sample_data):
    inputs = pd.read_excel(input_excel)
    
    if not os.path.exists('templates/merged/'):
        os.makedirs('templates/merged/')
    for _, row in inputs.iterrows():
        try:
            with pd.ExcelWriter(f'templates/merged/{row['Data Entity']}.xlsx') as writer:
                df1 = pd.read_excel(f'templates/{row['Staging Table']}.xlsx')
                df1.to_excel(writer, sheet_name='Template', index=False)

                df2 = pd.read_excel(f'{path_to_sample_data}/{row['Data Entity']}.xlsx')
                df2.to_excel(writer, sheet_name='Sample data', index=False)
        except:
            print('Failed to merge for ' + row['Data Entity'])

if __name__ == '__main__':
    staging_table_name = 'EcoResCategoryTaxInformationAssignmentStaging'
    template_rows = generate_template(staging_table_name, False)
    print(f'Unique indexes:\n{template_rows[1]}')
    pd.DataFrame(template_rows[0]).to_excel(f'{staging_table_name}.xlsx', index=False)
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--merge', help='Pass the path to the sample data folder.')
    parser.add_argument('-e', '--excel', help='Pass "" to generate excel template required in this program.')
    parser.add_argument('-f', '--force', action='store_true', help='Omits the fields which are throwing errors.')
    args, strings = parser.parse_known_args()
    
    if args.excel:
        inputs = pd.read_excel(args.excel)
        if not os.path.exists('templates/'):
            os.makedirs('templates/')
        for _, row in inputs.iterrows():
            template_rows = generate_template(row['Staging Table'], args.force)[0]
            pd.DataFrame(template_rows).to_excel(f'templates/{row['Staging Table']}.xlsx', index=False)
        if args.merge:
            merge_excel_files(args.excel, args.merge)
    elif args.excel == '':
        pass
