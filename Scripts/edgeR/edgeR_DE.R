# BRC RNA-seq Workshop (edgeR session) -------------------------------
# This script demonstrates:
# 1. loading a count matrix from StringTie / prepDE
# 2. defining metadata for a 3-group experiment
# 3. exploratory QC on all samples before normalization
# 4. subsetting to a pairwise comparison
# 5. filtering low-count genes
# 6. TMM normalization
# 7. quasi-likelihood differential expression testing in edgeR

# Notes:
# - rows = genes
# - columns = samples
# - first column contains gene IDs
# - sample names in the count matrix match sample names in the metadata
# - the experiment has 3 groups total, but the DE test below only compares CP vs EP

# SETUP --------------------------------------------------------------
#if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
#BiocManager::install("edgeR")

library(edgeR)

# LOAD GENE COUNT MATRIX ---------------------------------------------
pipefish_data <- read.csv(
  file = "gene_count_matrix.csv",
  stringsAsFactors = FALSE,
  row.names = 1,
  header = TRUE
)

# CHECK DATA ---------------------------------------------------------
head(pipefish_data, 5)
colnames(pipefish_data)
dim(pipefish_data) 
cat("Genes with some level of expression:", nrow(pipefish_data), "\n")

# We have 4 male brood pouch samples for each condition:
# Control-Not Pregnant: Control1_NP, Control2_NP, Control3_NP, Control4_NP
# Control-Pregnant:     Control1_P,  Control2_P,  Control3_P,  Control4_P
# Estrogen-Exposed P:   EE1_P,       EE2_P,       EE3_P,       EE4_P

# METADATA -----------------------------------------------------------
sample_info <- c(
  Control1_NP = "CNP",
  Control2_NP = "CNP",
  Control3_NP = "CNP",
  Control4_NP = "CNP",
  
  Control1_P  = "CP",
  Control2_P  = "CP",
  Control3_P  = "CP",
  Control4_P  = "CP",
  
  EE1_P       = "EP",
  EE2_P       = "EP",
  EE3_P       = "EP",
  EE4_P       = "EP"
)

sample_info

# Assign group labels in the same order as the count matrix columns
group <- factor(sample_info[colnames(pipefish_data)])

# Double check sample counts per group
table(group)

# CREATE DGEList FOR ALL SAMPLES ------------------------------------
y_all <- DGEList(counts = pipefish_data, group = group)
y_all
y_all$samples

# BEFORE NORMALIZATION: QC ON ALL 3 GROUPS --------------------------

# 1. Raw library sizes
barplot(y_all$samples$lib.size / 1e6,
        names = colnames(y_all),
        las = 2,
        ylab = "Millions of reads",
        main = "Raw library sizes")

# 2. Raw logCPM distributions
boxplot(cpm(y_all, log = TRUE, prior.count = 2),
        las = 2,
        ylab = "logCPM",
        main = "Before normalization")

# 3. Exploratory fold-change distribution for EP vs CP
# This is only a visualization of average logCPM differences,
# not the formal edgeR DE test
logcpm_all <- cpm(y_all, log = TRUE, prior.count = 2, normalized.lib.sizes = FALSE)

cp_samples_all <- group == "CP"
ep_samples_all <- group == "EP"

cp_mean_all <- rowMeans(logcpm_all[, cp_samples_all, drop = FALSE])
ep_mean_all <- rowMeans(logcpm_all[, ep_samples_all, drop = FALSE])

mean_logFC_all <- ep_mean_all - cp_mean_all

hist(mean_logFC_all,
     breaks = 100,
     col = "steelblue",
     border = "white",
     main = "Distribution of Mean logCPM Differences\n(EP vs CP, before normalization)",
     xlab = "Mean logCPM difference",
     ylab = "Frequency")

abline(v = 0, col = "red", lwd = 2, lty = 2)

# 4. MDS plot on all 3 groups
plotMDS(y_all,
        labels = colnames(y_all),
        col = as.numeric(group),
        main = "MDS plot before normalization")

legend("topright",
       legend = levels(group),
       col = 1:length(levels(group)),
       pch = 16,
       cex = 0.8)

# PAIRWISE DE ANALYSIS: CP vs CNP ONLY -------------------------------
# From this point onward, we leave out one of the groups (the CNP samples).
# This means filtering, normalization, dispersion estimation,
# and DE testing are all done using only CP and CNP.

keep_samples <- group %in% c("CP", "CNP")
y_pair <- y_all[, keep_samples]
group_pair <- droplevels(group[keep_samples])

# Update the DGEList group info
y_pair$samples$group <- group_pair

# Check that only CP and CNP remain
table(group_pair)
colnames(y_pair)

# FILTER LOW-COUNT GENES --------------------------------------------
# Remove genes with too little information for reliable DE testing
keep_genes <- filterByExpr(y_pair, group = group_pair)
y_pair <- y_pair[keep_genes, , keep.lib.sizes = FALSE]

cat("Genes retained after filtering (CP vs CNP only):", nrow(y_pair), "\n")

# TMM NORMALIZATION --------------------------------------------------
# Adjust for compositional bias between libraries
y_pair <- normLibSizes(y_pair)

# View normalization factors
y_pair$samples

# Interpretation:
# - norm.factors < 1: a small number of high-count genes dominate that library
# - norm.factors > 1: the library is scaled in the opposite direction

# DESIGN MATRIX ------------------------------------------------------
# Set CP as the reference level so logFC is CNP relative to CP
group_pair <- relevel(group_pair, ref = "CP")

design <- model.matrix(~ group_pair)
colnames(design)
design

# ESTIMATE DISPERSION ------------------------------------------------
y_pair <- estimateDisp(y_pair, design)

plotBCV(y_pair)

# BCV plot interpretation:
# - black points = tagwise dispersion (gene-specific estimates after shrinkage)
# - blue line = trended dispersion
# - red line = common dispersion

# Optional: compare BCV before filtering for the same CP vs CNP subset
y_pair_unfiltered <- y_all[, keep_samples]
y_pair_unfiltered$samples$group <- group_pair
y_pair_unfiltered <- estimateDisp(y_pair_unfiltered, design)

plotBCV(y_pair_unfiltered)

# FIT QUASI-LIKELIHOOD MODEL ----------------------------------------
fit <- glmQLFit(y_pair, design)

# TEST CNP vs CP ------------------------------------------------------
# coef = 2 corresponds to group_pairCNP
qlf <- glmQLFTest(fit, coef = 2)

# TOP RESULTS --------------------------------------------------------
topTags(qlf)

# Save all genes
result <- topTags(qlf, n = Inf)
result_table <- result$table

# Number of DE genes at FDR < 0.05
sum(result_table$FDR < 0.05)

# Summary of the significant genes at FDR < 0.05
summary(decideTests(qlf))
# - Up = higher expression in CNP
# - Down = higher expression in CP

# Save results
 write.csv(result_table, file = "pipefish_CP_vs_CNP_edgeR_results.csv")
# - positive logFC = higher expression in CNP
# - negative logFC = higher expression in CP

# FIGURE -------------------------------------------------------------
# Plot all the logFCs against average count size, highlighting the DE genes
# Blue lines indicate 2-fold up or down
plotMD(qlf)
abline(h=c(-1,1), col="blue")

# SAVE ONLY SIG DEGS -------------------------------------------------
# Save only significant genes
sig_result_table <- result_table[result_table$FDR < 0.05, ]

write.csv(
  sig_result_table,
  file = "pipefish_CP_vs_CNP_edgeR_results_significant_FDR.csv"
)

