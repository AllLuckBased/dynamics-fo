import os
import argparse
import pandas as pd

from entity_source_map import *
from template_from_table import *

def merge_template_with_map(filename, staging_table_name, entity_name):
    if not os.path.exists('output/merged'):
        os.makedirs('output/merged')
    try:
        with pd.ExcelWriter(f'output/merged/{filename}.xlsx') as writer:
            df1 = pd.read_excel(f'output/Templates/{staging_table_name}.xlsx')
            df1.to_excel(writer, sheet_name='Template', index=False)

            df2 = pd.read_excel(f'output/Source Mappings/{entity_name}.xlsx')
            df2.to_excel(writer, sheet_name='Source Map', index=False)
    except:
        print('Failed to merge for ' + filename)

parser = argparse.ArgumentParser()
parser.add_argument('-f', '--force', action='store_true', help='Ignore and omit the columns which are throwing errors.')
parser.add_argument('-e', '--excel', help='Pass "" to generate excel template required in this program.')
args, strings = parser.parse_known_args()

if not os.path.exists('output/Templates'):
    os.makedirs('output/Templates')
if not os.path.exists('output/Source Mappings'):
    os.makedirs('output/Source Mappings')

if args.excel:
    inputs = pd.read_excel(args.excel)
    for _, row in inputs.iterrows():
        template_rows = generate_template(row['Staging Table'], args.force)[0]
        pd.DataFrame(template_rows).to_excel(f'output/Templates/{row['Staging Table']}.xlsx', index=False)
        write_to_excel(get_all_data_sources(row['Target Entity']), f'output/Source Mappings/{row['Target Entity']}.xlsx')
        merge_template_with_map(row['Data Entity'], row['Staging Table'], row['Target Entity'])
elif args.excel == "":
        pd.DataFrame(columns=['Data Entity', 'Target Entity', 'Staging Table']).to_excel('entity_input.xlsx', index=False)
else:
    for name in strings:
        template_rows = generate_template(name, args.force)[0]
        pd.DataFrame(template_rows).to_excel(f'output/Templates/{name}.xlsx', index=False)
        write_to_excel(get_all_data_sources(name), f'output/Source Mappings/{name}.xlsx')
        merge_template_with_map(name, name, name)

