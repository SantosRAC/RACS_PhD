import argparse
import pandas as pd

parser = argparse.ArgumentParser(description='XXX', add_help=False)
parser.add_argument('-i','--in', dest='infile', metavar='infile', type=str, required=True)
# Value passed to -log2fc_filter must be a positive value
parser.add_argument('-log2fc_filter', dest='log2fcfilter', metavar='log2fcfilter', type=float, required=False, default=0)
args = parser.parse_args()
infileOBJ = args.infile
log2fcCutOff = args.log2fcfilter

expressTable = pd.read_table(infileOBJ,sep="\t")

print('Gene\tdescription\tbaseMean\tlog2FoldChange\tlfcSE\tstat\tpvalue\tpadj\tstatus')
for index, row in expressTable.iterrows():
 if (row['log2FoldChange'] <= -log2fcCutOff) or (row['log2FoldChange'] >= log2fcCutOff):
  #Gene	description	baseMean	log2FoldChange	lfcSE	stat	pvalue	padj
  if row['log2FoldChange'] < 0:
   print(row['Gene'] + '\t' + row['description'] + '\t' + str(row['baseMean']) + '\t' + str(row['log2FoldChange']) + '\t' + str(row['lfcSE']) + '\t' + str(row['stat']) + '\t' + str(row['pvalue']) + '\t' + str(row['padj']) + '\tdown')
  elif row['log2FoldChange'] > 0:
   print(row['Gene'] + '\t' + row['description'] + '\t' + str(row['baseMean']) + '\t' + str(row['log2FoldChange']) + '\t' + str(row['lfcSE']) + '\t' + str(row['stat']) + '\t' + str(row['pvalue']) + '\t' + str(row['padj']) + '\tup')
  else:
   sys.exit('A gene does not show difference of gene expression')
