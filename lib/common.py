import re
import os
import shutil
import Levenshtein
import pandas as pd
import xml.etree.ElementTree as ET

root_path = 'K:/AosService/PackagesLocalDirectory'

def list_files_recursive(directory):
    file_list = []
    main_directory = os.path.abspath(directory)
    
    for root, _, files in os.walk(directory):
        relative_path = os.path.relpath(root, main_directory)
        for file in files:
            file_name, file_extension = os.path.splitext(file)
            file_list.append((relative_path, file_name, file_extension))
    return file_list

def find_closest_strings(target_string, string_list, num_results=1):
    target_string_lower = target_string.lower()
    distances = [(s, Levenshtein.distance(target_string_lower, s.lower())) if isinstance(s, str) else (s, s) for s in string_list]
    sorted_distances = sorted(distances, key=lambda x: x[1])[:num_results]
    return sorted_distances

def getEntityInfo(name, interact = True):
    excel_file = 'res/label_conversion.csv'
    try:
        df = pd.read_csv(excel_file, skiprows=1, header=None, 
                         names=['Data Entity', 'Staging Table', 'Target Entity'])
        closest_match = None
        for col in df.columns:
            row = df.loc[df[col] == name]
            if row.empty and interact:
                new_closest_match = find_closest_strings(name, df[col].tolist())
                if closest_match is None or new_closest_match[0][1] < closest_match[0][1]:
                    closest_match = new_closest_match
            elif not row.empty:
                return row
        if not interact: return None
        if(closest_match[0][1] <= 3):
            return getEntityInfo(closest_match[0][0])
        else:
            user_input = input(f'{name} was not found. Replace with "{closest_match[0][0]}"?(Y/n) ')
            if user_input.capitalize().startswith('N'):
                user_input = input(f'Please enter proper entity name for {name}: ')
                if user_input != '':
                    return getEntityInfo(user_input)
                else: return None
            else:
                return getEntityInfo(closest_match[0][0])

    except FileNotFoundError:
        print(f"File not found: {excel_file}")
        print(f"Hint: Open appropriate VM and export the results of the following into {excel_file}:")
        print("\tSELECT EntityName, EntityTable, TargetEntity FROM DMFENTITY")
        exit(-1)
    except Exception as e:
        print(f"An error occurred while trying to read label_conversion.csv:\n{e}")
        exit(-1)

def correctExcel(excel_file_path, output_file_path):
    try:
        df = pd.read_excel(excel_file_path, header=None)\
            if os.path.splitext(excel_file_path)[1] == '.xlsx'\
            else pd.read_csv(excel_file_path, header=None)
    except:
        raise FileNotFoundError()

    for index, row in df.iterrows():
        entity_info = getEntityInfo(str(row.iloc[0]))
        if entity_info is not None:
            df.at[index, 0] = entity_info['Data Entity'].astype(str).iloc[0]
        else:
            df = df.drop(index, axis=0)
    df.to_excel(f'{output_file_path}', index=False, header=False)

def correctFolder(datapath, output_datapath, scope_path='res/scope.xlsx'):
    def rename_file(old_filename, new_filename, relative_path):
        old_path = os.path.join(f'{datapath}/{relative_path}', old_filename)
        old_path_renamed = os.path.join(f'{datapath}/{relative_path}', new_filename)
        
        new_path = os.path.join(f'{output_datapath}/{relative_path}', new_filename)
        os.makedirs(f'{output_datapath}/{relative_path}', exist_ok=True)

        duplicated_files = os.path.join(output_datapath, 'duplicates')
        #If the filenames are the same when converted to lowercase, then its just a capitalization issue
        if old_filename.lower() != new_filename.lower() and os.path.exists(old_path_renamed):
            os.makedirs(duplicated_files, exist_ok=True)
            user_input = input(f'{new_filename} already exists. Rename?(Y/n) ')
            if user_input.capitalize().startswith('N'):
                shutil.move(old_path, os.path.join(duplicated_files, old_filename))
                return
            else:
                shutil.move(old_path_renamed, os.path.join(duplicated_files, new_filename))
        os.rename(old_path, new_path)

    scope_df = None
    unmatched_files = os.path.join(output_datapath, 'unmatched')

    try:
        scope_df = correctExcel(scope_path, f'cache/{os.path.basename(scope_path)}')
    except FileNotFoundError:
        print(f"Warning: No scope specified for data migration project. To specify add: {scope_path}")
    
    #TODO: relative path might cause issues while renaming in some cases where same name exist in diff relative paths.
    for relative_path, file_name, extension in list_files_recursive(datapath):
        correct_name = getEntityInfo(file_name)['Data Entity'].astype(str).iloc[0]
        if scope_df is not None:
            closest_in_scope = find_closest_strings(
                correct_name, scope_df['Data Entity'].tolist(), num_results=1)
            if(closest_in_scope[0][1] <= 5):
                correct_name = closest_in_scope[0][0]
            else:
                input = input(f'{name} was not found. Replace with "{closest_match[0][0]}"?(Y/n) ')
                if not input.capitalize().startswith('Y'):
                    os.makedirs(unmatched_files, exist_ok=True)
                    old_path = os.path.join(f'{datapath}/{relative_path}', file_name + '.csv')
                    shutil.move(old_path, os.path.join(unmatched_files, file_name + '.csv'))
                else:
                    correct_name = closest_in_scope[0][0]
        rename_file(f'{file_name}{extension}', f'{correct_name}{extension}', relative_path)

def format_for_windows_filename(input_string):
    forbidden_characters = r'<>:"/\|?*'
    cleaned_string = re.sub(f'[{re.escape(forbidden_characters)}]', '_', input_string)
    cleaned_string = cleaned_string.strip()
    return cleaned_string

def identify_model(search_term):
    directories = [d for d in os.listdir(root_path)]
    search_types = ['AxTable'] if 'Staging' in search_term else ['AxDataEntityView', 'AxView']
    for search_type in search_types:
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
    for reference in descriptor_root.find('ModuleReferences')\
        .findall('{http://schemas.microsoft.com/2003/10/Serialization/Arrays}string'):
        references.append(reference.text)
    return references
