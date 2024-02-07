import os
import shutil
import argparse
import pandas as pd

from entity_source_map import *
from template_from_table import *

def merge_template_with_map(filename, path_to_sample_data):
    if not os.path.exists('template&maps'):
        os.makedirs('template&maps')
    try:
        with pd.ExcelWriter(f'template&maps/{filename}.xlsx') as writer:
            if path_to_sample_data:
                df1 = pd.read_excel(f'{path_to_sample_data}/{filename}.xlsx')
                df1.to_excel(writer, sheet_name='Sample data', index=False)

            df2 = pd.read_excel(f'templates/{filename}.xlsx')
            df2.to_excel(writer, sheet_name='Template', index=False)

            df3 = pd.read_excel(f'entity_maps/{filename}.xlsx')
            df3.to_excel(writer, sheet_name='Source Map', index=False)
    except:
        print('Failed to merge for ' + filename)

parser = argparse.ArgumentParser()
parser.add_argument('-e', '--excel', help='List of entity names in excel sheet')
parser.add_argument('-m', '--merge', help='Pass the path to the sample data folder.')
parser.add_argument('-f', '--force', action='store_true', help='Ignore and omit the columns which are throwing errors.')
args, names = parser.parse_known_args()

if not os.path.exists('templates'):
    os.makedirs('templates')
if not os.path.exists('entity_maps'):
    os.makedirs('entity_maps')

if args.excel:
    inputs = pd.read_excel(args.excel, header=None)
    names = inputs.iloc[:, 0].astype(str).tolist()

for name in names:
    try:
        entityInfo = getEntityInfo(name)
    except ValueError:
        continue

    if not os.path.exists('templates/'):
        os.makedirs('templates/')
    if not os.path.exists('entity_maps/'):
        os.makedirs('entity_maps/')

    template_rows = generate_template(entityInfo['Staging Table'].astype(str).iloc[0], False)
    fileName = format_for_windows_filename(entityInfo['Data Entity'].astype(str).iloc[0])
    pd.DataFrame(template_rows[0]).to_excel(f'templates/{fileName}.xlsx', index=False)
    
    write_to_excel(get_all_data_sources(entityInfo['Target Entity'].astype(str).iloc[0]), f'entity_maps/{fileName}.xlsx')
    merge_template_with_map(fileName, args.merge)

    try:
        shutil.rmtree('templates/')
        shutil.rmtree('entity_maps/')
    except OSError as e:
        print(f"Error while trying to remove directories: {e}")

