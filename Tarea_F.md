# Correr stacks en docker

```
docker run -v /Users/javier/Docker/GBS:/DatosGBS biocontainers/stacks-web:v2.2dfsg-1-deb_cv1 
```
### process_radtags

Revisar calidad y formato de secuencias para ver como esta el código de barcodes, ejemplo de estas muestras: `TTCCATAC+TCATTACG`

``` 
zcat ../DatosGBS/raw1/ATX5_HHTTHBGX5_s_1_fastq.gz | head -n 20
```
![muestras](https://github.com/JavierUrban/Tareas_BioinfRepro2020_JavierUrban/blob/master/muestras.jpg?raw=true)

Muestras de barcodes usadas para el demultiplex:
```
TTCCATAC	TCATTACG	ATX14_HHTTHBGX5
GGTCATCC	TATACCAG	ATX21_HHTTHBGX5
TATCTGAG	TATACCAG	ATX5_HHTTHBGX5
CTCGGTAG	TATACCAG	CAR12_HHTTHBGX5
AGACCGAC	AGACACTA	CAR22_HHTTHBGX5
GAGACGTC	CTTCAATC	CAR2_HHTTHBGX5
GAGACGTC	TATACCAG	CAR4_HHTTHBGX5
CAATAGCC	TATACCAG	PRE12_HHTTHBGX5
CAATAGCC	ATGGTAAC	PRE15_HHTTHBGX5
GCGGTAAC	CACGAAGC	PRE17_HHTTHBGX5
GCGGTAAC	CTTCAATC	PRE18_HHTTHBGX5
GCGGTAAC	ATGGTAAC	PRE23_HHTTHBGX5
CCTCCTAC	AGACACTA	PRE6_HHTTHBGX5
GTAATCTC	ACACCTCT	QUE10_HHTTHBGX5
CGATCAAG	CTTCAATC	QUE12_HHTTHBGX5
CGATCAAG	TCATTACG	QUE15_HHTTHBGX5
GGTCATCC	ATGGTAAC	QUE1_HHTTHBGX5
GTAATCTC	CTTCAATC	QUE4_HHTTHBGX5
```
Comandos usados para correr process_radtags: 
`--index_index`se uso por el tipo de barcodes y `--renz_1 mspI --renz_2 nsiI` son las enzimas de restricción con las cual fue digerido el DNA

``` 
stacks process_radtags -P -p ../DatosGBS/raw1/ --interleaved -b infocope/barcodes_copes_db.tsv \
-o cleaned1 -c -q -r --index_index --renz_1 mspI --renz_2 nsiI
```
Datos para denovo_map y resultados de correr process_radtags,
muestras:

![](https://github.com/JavierUrban/Tareas_BioinfRepro2020_JavierUrban/blob/master/Rprocess_Rad.png?raw=true)

Mapa de poblaciones con cada individuo: 

```
ATX14_HHTTHBGX5		ATX
ATX21_HHTTHBGX5		ATX
ATX5_HHTTHBGX5 		ATX
CAR12_HHTTHBGX5		CAR
CAR22_HHTTHBGX5		CAR
CAR2_HHTTHBGX5		CAR
CAR4_HHTTHBGX5		CAR
PRE12_HHTTHBGX5		PRE
PRE15_HHTTHBGX5		PRE
PRE17_HHTTHBGX5		PRE
PRE18_HHTTHBGX5		PRE
PRE23_HHTTHBGX5		PRE
PRE6_HHTTHBGX5		PRE
QUE10_HHTTHBGX5		QUE
QUE12_HHTTHBGX5		QUE
QUE15_HHTTHBGX5		QUE
QUE1_HHTTHBGX5		QUE
QUE4_HHTTHBGX5		QUE
```
Codigo para correr denovo_map.pl:

```
stacks denovo_map.pl --samples cleaned1/ --popmap infocope/popmap_copes_raw1.tsv -o testdeNovo/ -M 2 -n 1 -m 3
```
Erorr en pantantalla

```
Indentifying unique stacks...
  /usr/lib/stacks/bin/ustacks -t gzfastq -f cleaned1/ATX14_HHTTHBGX5.1.fq.gz -o testdeNovo -i 1 -m 3 --name ATX14_HHTTHBGX5 -M 2

denovo_map.pl: Aborted because the last command failed (1); see log file.

```
Error en denovo_map.log

```
ustacks
==========

Sample 1 of 18 'ATX14_HHTTHBGX5'
----------
/usr/lib/stacks/bin/ustacks -t gzfastq -f cleaned1/ATX14_HHTTHBGX5.1.fq.gz -o testdeNovo -i 1 -m 3 --name ATX14_HHTTHBGX5 -M 2
ustacks parameters selected:
  Input file: 'cleaned1/ATX14_HHTTHBGX5.1.fq.gz'
  Sample ID: 1
  Min depth of coverage to create a stack (m): 3
  Repeat removal algorithm: enabled
  Max distance allowed between stacks (M): 2
  Max distance allowed to align secondary reads: 4
  Max number of stacks allowed per de novo locus: 3
  Deleveraging algorithm: disabled
  Gapped assembly: enabled
  Minimum alignment length: 0.8
  Model type: SNP
  Alpha significance level for model: 0.05

Loading RAD-Tags...
Error: Unable to form any primary stacks.

denovo_map.pl: Aborted because the last command failed (1).
```
Eh leído a cerca del error, pero no e podido resolverlo, en algunos casos decía que podría ser por la memoria ram, después corrí lo mismo, con los mismos datos en el cluster de la CONABIO, pero me dio exactamente el mismo error. 

Leí el manual de ustacks y al parecer el comando que esta fallando es `-i = 1` que es el ID en número asignado a cada muestra, intente cambiar el numero de las muestras de manera ordenada pero tampoco sirvió, espero puedan ayudarme, intente buscar el los foros, pero no encontré alguna respuesta clara, creo que tiene que ver con la identificación en número de cada muestra, pero no lo e podido modificar, ¡¡gracias!!






