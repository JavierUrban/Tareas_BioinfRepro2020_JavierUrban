
# Bioinformatic Pipeline 

## Genomic structure 

 **Pipeline summary:**
 
![](https://github.com/JavierUrban/Proyecto_Bioinf2020/blob/master/bin/pipeline.png?raw=true)

Molecular markers were obtained using a Sequence-Based Genotyping method, following a reference-based SNP calling. Because genome size in Copepoda is highly variable (up to 70-fold) and up to date an assembled genome for this species or any other *Leptodiaptomus* is unavailable, a reference genome draft was first assembled.  A shotgun sequencing paired-end (2 x 150 bp) library was prepared with DNA of an individual from El Carmen. Sequencing adapters were removed, and sequences were trimmed using Trimommatic software (Bolger *et al.,* 2014). Reads were de-novo assembled using Discovar. Contigs were then artificially concatenated in 14 “superscaffolds” of 50 GB in length.  
93 dual indexed libraries were prepared from double digested DNA with MSPI and NsiI-HF enzymes, following the UMGC standard protocol for SBG library preparation and individual barcoding (Truong *et al.,* 2012). Libraries were combined in a single pool and sequenced on an Illumina®️ NextSeq 550 1x150-bp run. All barcodes were recovered. Each sample produced > 1 M reads, with a mean read quality score (phred) > 30.  Reads were mapped against genomic databases (human, mouse, E. coli, yeast, PhiX virus and chloroplast) to detect DNA contamination.

SNP calling, genotyping and SNP filtering
Sequences that passed quality filters were mapped against the reference genome previously assembled, using the BWA software (Li & Durbin, 2009). Between 80 and 93% of reads aligned correctly. SNP calling and genotyping were performed with SAMtools 1.6 and Freebayes.  From the dataset of 665 320 polymorphic sites identified, individuals with > 20% of missing genotypes, and variants with missing calls in more than 5% of samples were removed, as well as variants with Minimum Allele Frequency (MAF) < 0.01. All individuals passed the filtering process and were retained. The resulting set of 109 299 SNPs was delivered by the UMGC in a vcf (variant call format) file. 

Afterwards, we applied a second series of filters to identify independent orthologous SNPs, following mainly Benestan *et al.,* (2016) recommendations (Benestan *et al.,* 2016). Using the software VCFtools v.0.1.15, we retained only variants with no missing calls 1.0 and eliminated non-informative sites (MAF < 0.05), leaving variants present in at least 4 individuals. 


```
$vcftools --vcf data/variants.copepodos.vcf

#calculates the frequency of alleles in the file variants.copepodos.vcf
$vcftools --vcf data/variants.copepodos.vcf --freq --out data/frecuencias_copes

#filter for allele frequency less than equal 0.5, filtered by missing data,
$vcftools --vcf data/variants.copepodos.vcf --max-maf 0.5 --max-missing 1.0 --out --recode
#After filtering, kept 11254 out of a possible 109299 Sites genera un output out.recode.vcf

#convert vcf files to plink format
$vcftools --vcf data/out.recode.vcf --plink

```

At this point, 11 254 SNPs remained. And they were used to calculate the population structure and genotypic clustering (Distance tree, MSN, PCA and DAPC) whit R software (R Core Team, 2013). 

```
##load file with filtered variants in VCFtools
copepods.vcf <- read.vcfR("../data/out.recode.vcf")
copepods.vcf
##load table with population data
pop_names <- read.table("../data/pop_nom_copepods.txt", sep = "\t", header = TRUE)
all(colnames(copepods.vcf@gt)[-1]==pop_names$Individula.ID)
##Create genligth object with SNPs and delimited populations to use adegenet and poppr
gl.copepods <- vcfR2genlight(copepods.vcf)
##indicate ploidy and concatenate data from SNPs and populations
##check that the data is correct
ploidy(gl.copepods) <- 2
pop(gl.copepods) <- pop_names$Pop
gl.copepods

```

Poppr (Kamvar, Brooks, & Grünwald, 2015) was used to identify patterns of molecular differentiation by genetic distance. To test if populations were significantly different, a Monte-Carlo randomisation test was performed using the function randtest from the ade4 package using 1000 random permutations. To visualise population structure, a Minimum Spanning Network (MSN) was performed using genetic distances between genotypes with the bitwise.dist function. 

```
##Calculate genetic distance for analysis of genetic structure 
copes.dis <- dist(gl.copepods)
copes.dis <- poppr::bitwise.dist(gl.copepods) 
##Genetic distance tree
PhyloCopes <- aboot(gl.copepods, tree = "upgma", distance = bitwise.dist, sample = 100, showtree = F, cutoff = 50, quiet = T)
cols <- brewer.pal(n = nPop(gl.copepods), name = "Dark2")
##graphical of the population structure based on a minimum spanning network (MSN)
library(igraph)
copes.msn <- poppr.msn(gl.copepods, copes.dis, showplot = FALSE, include.ties = T)
node.size <- rep(2, times = nInd(gl.copepods))
names(node.size) <- indNames(gl.copepods)
vertex_attr(copes.msn$graph)$size <- node.size
set.seed(9)
plot_poppr_msn(gl.copepods, copes.msn, palette = cols)

```
![Structure *MSN*](https://github.com/JavierUrban/Proyecto_Bioinf2020/blob/master/bin/structurMSN.png?raw=true)

We run a Discriminant Analysis of Principal Components (DAPC) to identify and describe genetic clusters maximising the variance among populations. To assess the proportion of explained molecular variance, a Principal Component Analysis (PCA).

``` 
##Analysis of PCA
library(ggplot2)
copes.pca.scores <- as.data.frame(copes.pca$scores)
copes.pca.scores$pop <- pop(gl.copepods)
set.seed(9)
plotpca <- ggplot(copes.pca.scores, aes(x=PC1, y=PC2, colour=pop))+
  geom_point(size=3)+ 
  scale_color_manual(values=cols)+
  geom_hline(yintercept=0)+
  geom_vline(xintercept=0)+
  theme_bw()
plotpca

```
![PCA](https://github.com/JavierUrban/Proyecto_Bioinf2020/blob/master/bin/PCAcopepods.png?raw=true)

A DAPC (labelled DAPC-1) was run using one component to calculate the probability of membership of each individual to local populations. 

```
##The DAPC object includes the population membership probability for each sample to each of the predetermined populations
copes.dapc <- dapc(gl.copepods, n.pca = 3, n.da = 2)
scatter(copes.dapc, col=cols, cex=3, legend = TRUE, clabel=F, posi.leg = "bottomleft", scree.pca = TRUE, posi.pca = "topright", cleg = 0.5)

```
![](https://github.com/JavierUrban/Proyecto_Bioinf2020/blob/master/bin/DAPC.png?raw=true)

[Benestan, L. M., Ferchaud, A. L., Hohenlohe, P. A., Garner, B. A., Naylor, G. J., Baums, I. B., & Luikart, G. (2016). Conservation genomics of natural and managed populations: building a conceptual and practical framework. Molecular ecology, 25(13), 2967-2977.](https://doi.org/10.1111/mec.13647)

[Bolger, A. M., Lohse, M., y Usadel, B. (2014). Trimmomatic: a flexible trimmer for Illumina sequence data. Bioinformatics, 30(15), 2114-2120.](https://doi.org/10.1093/bioinformatics/btu170)

[Li, H., & Durbin, R. (2009). Fast and accurate short read alignment with Burrows–Wheeler transform. bioinformatics, 25(14), 1754-1760.](https://doi.org/10.1093/bioinformatics/btp324)

[Truong, H. T., Ramos, A. M., Yalcin, F., de Ruiter, M., van der Poel, H. J., Huvenaars, K. H., y van Eijk, M. J. (2012). Sequence-based genotyping for marker discovery and co-dominant scoring in germplasm and populations. PloS one, 7(5).](https://doi.org/10.1371/journal.pone.0037565)