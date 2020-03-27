library(data.table)
library(tidyverse)

# some functions
"%&%" <- function(a,b) paste(a,b,sep="")
cf <- function(method, x) method %&% x

# set working directory
wd <- "@@@@@@@@@"
setwd(wd)

# these are downloaded from Zenodo and Google Drive
multi <- "/eqtl_smultixcan" # performed across tissues, so same across all dbs
predix <- "/eqtl_spredixcan"
enloc <- "/results_eqtl_eur_enloc"
smr <- "/smr_gtex_v8_eqtl_results"
coloc <- "/results_enloc_priors"
combined_output <- "/combined/eqtl"
if (!file.exists(combined_output)) {
	system("mkdir combined")
	system("mkdir combined/eqtl")
}

# read in v8 traits and tissues
traits <- fread(wd %&% "/traits.txt", data.table = F, header = F)
traits <- traits$V1
tissues <- fread(wd %&% "/tissues.txt", data.table = F, header = F)
tissues <- tissues$V1

# make temp files and have a separate python script put all of them into a db using os.lisrdir()

for (tissue in tissues) {

	for (trait in traits) {

		to_combine = vector()

		# read in smultixcan
		mfile <- wd %&% multi %&% '/' %&% trait %&% "_smultixcan_imputed_gwas_gtexv8mashr_ccn30.txt"
		if (file.exists(mfile)) {
			m <- fread(mfile, data.table = F, header = T)
			colnames(m) = sapply(colnames(m), cf, method = "smultix_")
			colnames(m)[1] = "gene" # column to merge on
			to_combine = append(to_combine, "m")
		}

		# read in spredixcan
		pfile <- wd %&% predix %&% '/spredixcan_igwas_gtexmashrv8_' %&% trait %&% "__PM__" %&% tissue %&% ".csv"
		if (file.exists(pfile)) {
			p <- fread(pfile, data.table = F, header = T)
			colnames(p) = sapply(colnames(p), cf, method = "spredix_")
			colnames(p)[1] = "gene" # column to merge on
			to_combine = append(to_combine, "p")
		} 

		# read in enloc
		efile <- wd %&% enloc %&% '/' %&% trait %&% "__PM__" %&% tissue %&% ".enloc.rst.gz"
		if (file.exists(efile)) {
			e <- fread(efile, data.table = F, header = T) # read in gzip file
			colnames(e) = sapply(colnames(e), cf, method = "enloc_")
			colnames(e)[2] = "gene" # column to merge on
			to_combine = append(to_combine, "e")
		}  

		# read in smr
		sfile <- wd %&% smr %&% '/' %&% tissue %&% "/" %&% trait %&% "_" %&% tissue %&% ".smr"
		if (file.exists(sfile)) {
			s <- fread(sfile, data.table = F, header = T) # read in gzip file
			colnames(s) = sapply(colnames(s), cf, method = "smr_")
			colnames(s)[1] = "gene" # column to merge on
			to_combine = append(to_combine, "s")
		} 

		# read in coloc enloc priors
		cfile <- wd %&% coloc %&% '/' %&% trait %&% "__PM__" %&% tissue %&% ".txt.gz"
		if (file.exists(cfile)) {
			c <- fread(cfile, data.table = F, header = T) # read in gzip file
			colnames(c) = sapply(colnames(c), cf, method = "coloc_")
			colnames(c)[1] = "gene" # column to merge on
			to_combine = append(to_combine, "c")
		} 

		# combine dataframes (Reduce is more efficient, but issue with row numbers)
		if (length(to_combine) == 1) {
			cmd <- "merged <- " %&% to_combine[1]
		} else if (length(to_combine) > 1) {
			cmd <- "merge(" %&% to_combine[1] %&% ", " %&% to_combine[2] %&% ", by = \"gene\", all = TRUE)"
			if (length(to_combine) > 2) {
				for (i in 3:length(to_combine)) {
					cmd <- "merge(" %&% cmd %&% ", " %&% to_combine[i] %&% ", by = \"gene\", all = TRUE)"
				}
			}
			cmd <- "merged <- " %&% cmd
		} else if (length(to_combine) == 0) {
			#next
		}
		
		eval(parse(text = cmd))

		# remove rows with all NAs in rows other than gene name
		merged <- merged[rowSums(is.na(merged[ , 2:ncol(merged)])) < ncol(merged) - 1, ]

		# write merged dataframe to intermediate file
		write.table(merged, wd %&% combined_output %&% "/" %&% trait %&% "__PM__" %&% tissue %&% "_combined.csv", sep=",", row.names = F, col.names = T)
		cat(tissue, trait, "DONE\n")
	}
	
}