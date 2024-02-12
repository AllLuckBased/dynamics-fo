import os
import shutil
import argparse
import Levenshtein
import pandas as pd

def find_closest_strings(target_string, string_list, num_results=1):
    target_string_lower = target_string.lower()
    distances = [(s, Levenshtein.distance(target_string_lower, s.lower())) if isinstance(s, str) else (s, s) for s in string_list]
    sorted_distances = sorted(distances, key=lambda x: x[1])[:num_results]
    return sorted_distances

def correctFolder(datapath, reference_file):
    def rename_file(old_filename, new_filename, existsCheck = True):
        old_path = os.path.join(datapath, old_filename + '.csv')
        new_path = os.path.join(datapath, new_filename + '.csv')

        if existsCheck:
            suffix = 1
            while os.path.exists(new_path):
                new_filename = f"`{new_filename} ({suffix})"
                new_path = os.path.join(datapath, new_filename + '.csv')
                suffix += 1

        os.rename(old_path, new_path)
        print(f'Renamed {old_filename}.csv -> {new_filename}.csv')

    reference_df = pd.read_csv(reference_file, header=None)
    references = reference_df.iloc[:, 0].tolist()

    filenames = [os.path.splitext(filename)[0] for filename in os.listdir(datapath) 
                if os.path.isfile(os.path.join(datapath, filename))]

    for input_string in filenames:
        if input_string in references:
            print(f'Exact match found for {input_string}. Moving on...')
            continue
        result = find_closest_strings(input_string, references) 
        if(result[0][1] <= 5):
            if(input_string.lower() == result[0][0].lower()):
                rename_file(input_string, result[0][0], False)
            rename_file(input_string, result[0][0])
        else:
            print(f"No close match found for '{input_string}'. Moving file to 'unmatched_files' directory.")
            unmatched_dir = 'unmatched_files'
            os.makedirs(unmatched_dir, exist_ok=True)
            old_path = os.path.join(datapath, input_string + '.csv')
            new_path = os.path.join(unmatched_dir, input_string + '.csv')
            shutil.move(old_path, new_path)

def correctExcel(excel_file_path, reference_file):
    reference_df = pd.read_csv(reference_file, header=None)
    references = reference_df.iloc[:, 0].tolist()
    reference_stagings = reference_df.iloc[:, 1].tolist()
    reference_entities = reference_df.iloc[:, 2].tolist()

    df = pd.read_excel(excel_file_path, header=None)

    for index, row in df.iterrows():
        value = str(row.iloc[0])
        if  value in references:
            continue
        result = find_closest_strings(value, references) 
        if result[0][1] <= 5:
            df.at[index, 0] = result[0][0]
        else:
            result1 = find_closest_strings(value, reference_stagings)
            result2 = find_closest_strings(value, reference_entities)
            if result1[0][1] == 0:
                df.at[index, 0] = result1[0][0]
            elif result2[0][1] == 0:
                df.at[index, 0] = result2[0][0]
            else:
                print(f"No close match found for '{value} at index {index}'.")
    df.to_excel(f'corrected_{excel_file_path}', index=False, header=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--datapath', help='Path to data directory (in case file renames)')
    parser.add_argument('-e', '--excel', help='Path to excel entity list sheet (case excel correction)')
    args, names = parser.parse_known_args()

    if args.datapath:
        correctFolder(args.datapath, 'label_conversion.csv')
    elif args.excel:
        correctExcel(args.excel, 'label_conversion.csv')
    print("Processing complete.")
