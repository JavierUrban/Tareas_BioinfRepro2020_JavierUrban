##Se crea un directorio llamado data 
mkdir data 

## descargar de:Schweizer, Rena M. et al. (2015), Data from: Targeted capture and resequencing of 1040 genes reveal environmentally driven functional variation in gray wolves, Dryad, Dataset, https://doi.org/10.5061/dryad.8g0s3
## El archivo volves en formato vcf (6226)
wget ../data/https://datadryad.org/stash/downloads/file_stream/6226

##Se movera el archivo descargado 6226 a wolves
mv ../data/6226 ../data/wolves

##Ahora se convierte el archivo wolves.vcf a formatos Plink 
##simpre que plinck ya este como ejecutable Plink
plink --file ../data/wolves --make-bed --out ../data/wolves

##Se hace un reporte de equilibriio de Hardy-Weinberg usando Plink
##utilisando el flag --hardy
plink --file ../data/wolves --hardy --out ../data/wolves

##Se revisan los resultados del reporte Hardy-weinberg con un head
head ../data/wolves.hwe 
