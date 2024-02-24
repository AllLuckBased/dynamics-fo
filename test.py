import pandas as pd
import Levenshtein
import os

def find_closest_strings(target_string, string_list, num_results=3):
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
            for it in range(0,3):
                user_input = input(f'{name} was not found. Replace with "{closest_match[it][0]}"?(Y/n) ')
                if user_input.capitalize().startswith('N'):
                    continue
                else:
                    return getEntityInfo(closest_match[0][0])
            else:
                user_input = input(f'Please enter proper entity name for {name}: ')
                if user_input != '':
                    return getEntityInfo(user_input)
                else: return None

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
        df = pd.read_excel(excel_file_path, header=None, names=['Data Entity'])\
            if os.path.splitext(excel_file_path)[1] == '.xlsx'\
            else pd.read_csv(excel_file_path, header=None, names=['Data Entity'])
    except:
        raise FileNotFoundError()

    for index, row in df.iterrows():
        entity_info = getEntityInfo(str(row.iloc[0]))
        if entity_info is not None:
            df.at[index, 0] = entity_info['Data Entity'].astype(str).iloc[0]
        else:
            df = df.drop(index, axis=0)
    df.to_excel(f'{output_file_path}', index=False, header=False)
    return df
