import os
import sys
import pandas as pd
import xml.etree.ElementTree as ET

referenced_models = []

def get_model_name(absolute_path):
    return absolute_path.split('/')[3]

def search_staging_table(search_term):
    root_path = "K:/AosService/PackagesLocalDirectory/"

    matches = [] #TODO: Cache models
    for root, _, files in os.walk(root_path):
        for filename in files:
            if search_term in filename:
                matches.append(os.path.join(root, filename))
                break
    return matches

print()

for item in sys.argv[1:]:
    referenced_models.append(get_model_name(search_staging_table("K:/AosService/PackagesLocalDirectory/")[0]))

print(referenced_models)

#model_name = get_model_name(search_staging_table(sys))
#root_path = 

# Check if there are at least two command-line arguments (the script name counts as one)
if len(sys.argv) < 2:
    print("Please provide Staging Table name as command line arguments.")
    exit(0)


# root_path = "K:/AosService/PackagesLocalDirectory/EnterpriseAssetManagementAppSuite/EnterpriseAssetManagementAppSuite/AxTable/"
# staging_table_name = sys.argv[1]
# print(staging_table_name)

# edt_paths = [
#     "K:/AosService/PackagesLocalDirectory/EnterpriseAssetManagementAppSuite/EnterpriseAssetManagementAppSuite/AxEdt/",
#     "K:/AosService/PackagesLocalDirectory/ApplicationPlatform/ApplicationPlatform/AxEdt/",
#     "K:/AosService/PackagesLocalDirectory/PersonnelCore/PersonnelCore/AxEdt/"
# ]
# enum_paths = [
#     "K:/AosService/PackagesLocalDirectory/EnterpriseAssetManagementAppSuite/EnterpriseAssetManagementAppSuite/AxEnum/", 
#     "K:/AosService/PackagesLocalDirectory/ApplicationSuite/Foundation/AxEnum/"
# ]

# ignored_fields = ["DefinitionGroup", "ExecutionId", "IsSelected", "TransferStatus"]

# # Parse the XML file
# tree = ET.parse(root_path + staging_table_name + ".xml")
# root = tree.getroot()

# unique_fields = []
# # Check the conditions for IsUnique
# indexes = root.find('Indexes')
# if indexes is not None:
#     for index in indexes.findall('AxTableIndex'):
#         fields = index.find('Fields')
#         # Filter out default fields from index fields
#         filtered_fields = []

#         # Iterate over each <AxTableIndexField> element in <Fields>
#         for f in fields.findall('AxTableIndexField'):
            
#             # Find the <DataField> element and get its text content
#             data_field_text = f.find('DataField').text
            
#             # If the text content is not "DefinitionGroup" or "ExecutionId", append to the list
#             if data_field_text not in ["DefinitionGroup", "ExecutionId"]:
#                 filtered_fields.append(data_field_text)

        
#         if len(filtered_fields) == 1:
#             unique_fields.extend(filtered_fields)

# rows = []

# continue_one = False
# # Iterate through each 'AxTableField' element
# for field in root.find('Fields').findall('AxTableField'):
#     name = field.find('Name').text
#     if name in ignored_fields:
#         continue
    
#     data_type = field.get('{http://www.w3.org/2001/XMLSchema-instance}type').replace('AxTableField', '')

#     string_size = field.find('StringSize')
#     if data_type == "String" and string_size is None:
#         edt = field.find('ExtendedDataType')
#         if edt is None:
#             edt = field.find('Extends')
#         edt = edt.text

#         for edt_path in edt_paths:
#             if os.path.exists(edt_path + edt + ".xml"):
#                 edt_root = ET.parse(edt_path + edt + ".xml").getroot()
#                 break
#             if edt_path == edt_paths[len(edt_paths) - 1]:
#                 print("Error: Could not find EDT: " + edt)
#                 continue_one = True
                
#         if continue_one:
#             continue_one = False
#             continue
#         string_size = edt_root.find("StringSize")

#     is_unique = "Yes" if name in unique_fields else "No"
#     is_nullable = "No"  # By default

#     if data_type == "Enum":
#         enum_type = field.find('EnumType').text

#         if enum_type == "NoYes":
#             enum_values = "No, Yes"
#         else:
#             for enum_path in enum_paths:
#                 if os.path.exists(enum_path + enum_type + ".xml"):
#                     enum_root = ET.parse(enum_path + enum_type + ".xml").getroot()
#                     break
#                 if enum_path == enum_paths[len(enum_paths) - 1]:
#                     print("Error: Could not find base Enum: " + enum_type)
#                     exit(-1)
            
#             names = [value.find('Name').text for value in enum_root.findall('.//AxEnumValue')]
#             enum_values = ', '.join(names)
#     else:
#         enum_values = ''

#     mandatory = field.find('Mandatory')

#     row = {
#         'D365 Column Name': name,
#         'Data type': data_type,
#         'Length': string_size.text if string_size is not None else 'NULL',
#         'IsUniqueField': is_unique,
#         'IsNullable': is_nullable,
#         'EnumValues': enum_values,
#         'Mandatory': mandatory.text if mandatory is not None else 'No'
#     }
    
#     rows.append(row)

# # Convert rows to DataFrame
# df = pd.DataFrame(rows)

# # Write to Excel
# df.to_excel('output.xlsx', index=False)
