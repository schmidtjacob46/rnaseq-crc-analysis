library(DESeq2)

dir.create("results", showWarnings = FALSE)

counts <- read.table(
  "counts/gene_counts.txt",
  header = TRUE,
  sep = "\t",
  comment.char = "#",
  stringsAsFactors = FALSE
)

counts <- counts[, -(2:6)]
rownames(counts) <- counts$Geneid
counts <- counts[, -1]

colnames(counts) <- c(
  "P01_Normal","P01_Tumor",
  "P02_Normal","P02_Tumor",
  "P03_Normal","P03_Tumor"
)

coldata <- data.frame(
  row.names = colnames(counts),
  condition = c("Normal","Tumor","Normal","Tumor","Normal","Tumor")
)

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = coldata,
  design = ~ condition
)

keep <- rowSums(counts(dds) >= 10) >= 2
dds <- dds[keep, ]

dds$condition <- relevel(dds$condition, ref = "Normal")
dds <- DESeq(dds)

res <- results(dds)
res <- res[order(res$padj), ]

gtf <- read.delim(
  "reference/gencode.v26.annotation.gtf",
  header = FALSE,
  sep = "\t",
  comment.char = "#",
  stringsAsFactors = FALSE
)

colnames(gtf) <- c("seqname","source","feature","start","end","score","strand","frame","attribute")
gtf_genes <- subset(gtf, feature == "gene")

extract_field2 <- function(x, field) {
  out <- sub(paste0(".*", field, " ([^;]+);.*"), "\\1", x)
  out[!grepl(paste0(field, " [^;]+;"), x)] <- NA_character_
  out
}

annot <- data.frame(
  gene_id = extract_field2(gtf_genes$attribute, "gene_id"),
  gene_name = extract_field2(gtf_genes$attribute, "gene_name"),
  stringsAsFactors = FALSE
)

annot$gene_id <- sub("\\..*", "", annot$gene_id)
annot <- annot[!duplicated(annot$gene_id), ]

res_df <- as.data.frame(res)
res_df$gene_id <- sub("\\..*", "", rownames(res_df))
res_df <- merge(res_df, annot, by = "gene_id", all.x = TRUE)
res_df <- res_df[order(res_df$padj), ]

top_res <- res_df[, c("gene_id","gene_name","baseMean","log2FoldChange","pvalue","padj")]

write.csv(top_res, "results/deseq2_results_annotated.csv", row.names = FALSE)

vsd <- vst(dds, blind = FALSE)

png("results/pca_plot.png", width = 900, height = 700)
plotPCA(vsd, intgroup = "condition")
dev.off()

res_df$significant <- ifelse(!is.na(res_df$padj) & res_df$padj < 0.05 & abs(res_df$log2FoldChange) > 1, "yes", "no")

png("results/volcano_plot.png", width = 900, height = 700)
plot(res_df$log2FoldChange,
     -log10(res_df$pvalue),
     pch = 20,
     col = ifelse(res_df$significant == "yes", "red", "black"),
     xlab = "Log2 Fold Change",
     ylab = "-Log10 p-value",
     main = "Tumor vs Normal RNA-seq")
dev.off()

top_up <- subset(top_res, log2FoldChange > 1)
top_up <- top_up[order(top_up$padj), ]
write.csv(head(top_up, 20), "results/top_upregulated_genes.csv", row.names = FALSE)

top_down <- subset(top_res, log2FoldChange < -1)
top_down <- top_down[order(top_down$padj), ]
write.csv(head(top_down, 20), "results/top_downregulated_genes.csv", row.names = FALSE)
