##Scrip ejemplo stacks tarea 2.5
##Javier Urbán
#creo o sube tus datyos
src=$HOME/research/project 

files=”sample_01 
sample_02 
sample_03” 


##1.- Alinear con GSnap y convetir en formato BAM
 
for file in $files
do
	gsnap -t 36 -n 1 -m 5 -i 2 --min-coverage=0.90 \
			-A sam -d gac_gen_broads1_e64 \
			-D ~/research/gsnap/gac_gen_broads1_e64 \
			$src/samples/${file}.fq > $src/aligned/${file}.sam
	samtools view -b -S -o $src/aligned/${file}.bam $src/aligned/${file}.sam 
	rm $src/aligned/${file}.sam 
done


##2.- Correr Stacks en el gsnap datos; la i variable sera el ID de cada muestra procesada.
 
i=1 
for file in $files 
do 
	pstacks -p 36 -t bam -m 3 -i $i \
	 		 -f $src/aligned/${file}.bam \
	 		 -o $src/stacks/ 
	let "i+=1"; 
done 


##3.- Este loop crea una lista de archivos para correr en cstacks.
 
samp="" 
for file in $files 
do 
	samp+="-s $src/stacks/$file "; 
done 


##4.- Construir catalogo; El "&>>" para capturar la salida y agregar a los registros.
 
cstacks -g -p 36 -b 1 -n 1 -o $src/stacks $samp &>> $src/stacks/Log 

for file in $files 
do 
	sstacks -g -p 36 -b 1 -c $src/stacks/batch_1 \
			 -s $src/stacks/${file} \ 
			 -o $src/stacks/ &>> $src/stacks/Log 
done 


##5.- Calculos de estadísticas de poblaciones y se exportan en 3 archivos de salida.
 
populations -t 36 -b 1 -P $src/stacks/ -M $src/popmap \
			  -p 9 -f p_value -k -r 0.75 -s --structure --phylip --genepop
