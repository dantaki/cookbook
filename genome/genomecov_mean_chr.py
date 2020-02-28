import sys
import pandas as pd

df = pd.read_csv(sys.argv[1],sep="\t",header=None)
df.columns = ['chrom','depth','freq','leng','frac']
contigs = set(df['chrom'])

cov = {}
for c in contigs:
	tmp = df.loc[df['chrom']==c]
	meandoc = sum(tmp['depth']*tmp['freq'])/sum(tmp['freq'])
	cov[c]=meandoc

for c,doc in cov.items():
	print('{}\t{}'.format(c,doc))
