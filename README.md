# Results from Gene Prioritization Methods applied to GTEx v8 gene expression data
This repo contains information to access results from gene prioritization methods (GPMs) applied across 87 traits and 49 tissues from the Genotype Tissue Expression (GTEx v8) consortium.

SQLite eQTL and sQTL databases containing results across S-PrediXcan, S-MultiXcan, ENLOC, SMR(+HEIDI) and COLOC (for eQTLs only) are available for download here: https://drive.google.com/drive/folders/1NqFzWZu1ZZ48YlgNIuOjgi5k6VrBjjOW?usp=sharing

Results across the GPMs for each tissue are in a separate database. The json metadata files provide a list of table names in each DB. Here is some sample code to obtain a dataframe containing all results for Type 1 Diabetes in Subcutanous Adipose tissue.

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('Adipose_Subcutaneous_GTEx_v8_GPMs_eqtl.db')
c = conn.cursor()

# get tablenames
tablenames = [x[1] for x in c.execute("select * from sqlite_master where type='table';").fetchall()]

# get a table corresponding to results from a specific trait into a dataframe
gpm_df = pd.DataFrame(c.execute('select * from UKB_20002_1222_self_reported_type_1_diabetes').fetchall())
df_header = gpm_df.iloc[0] 
gpm_df = gpm_df[1:] 
gpm_df.columns = df_header
```

If you use these results, please cite the associated publication: 

*Barbeira, Alvaro N., et al. "Widespread dose-dependent effects of RNA expression and splicing on complex diseases and traits." BioRxiv (2019): 814350. [accessible here](https://doi.org/10.1101/814350)*
