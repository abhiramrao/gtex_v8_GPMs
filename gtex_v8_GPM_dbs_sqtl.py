'''
Create SQLite DBs per tissue containing colocalization results 
'''

import json
import sqlite3
import os
import pandas as pd

def main():

	wd = '@@@@@@@@@@@@@@@@@'
	os.chdir(wd)
	filenames = os.listdir()

	# read in tissue names
	tissues = []
	with open('../../tissues.txt', 'r') as f:
		tissues = f.read().splitlines()

	# metadata for information across all tissues/traits/methods
	metadata = dict()

	for tissue in tissues:

		tissue_filenames = [x for x in filenames if tissue in x]

		dbname = tissue + '_GTEx_v8_GPMs_sqtl.db'
		tablenames = []
		conn = sqlite3.connect(dbname)
		# c = conn.cursor()

		for file in tissue_filenames:

			tablename = file.split("__")[0]
			filedata = pd.read_csv(file, header=0)
			modified_df = pd.DataFrame(filedata.columns).T
			modified_df.columns = filedata.columns
			modified_df = modified_df.append(filedata, ignore_index=True)
			modified_df.to_sql(name=tablename, con=conn, if_exists='replace', index_label=None) # does not include column headers
			tablenames.append(tablename)
			print(tablename)

		metadata[dbname] = {"tissue": tissue, "tablenames": tablenames}

	with open('../gtex_v8_GPMs_eqtl.json', 'w', encoding='utf-8') as f: # json 
		json.dump(metadata, f, ensure_ascii=False, indent=4)

	print(tissue + ': DONE' + '\n\n')

if __name__ == '__main__':
	main()
