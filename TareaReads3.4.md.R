
#Script para resolver el ejercicio de read 
  
#Cargar un escript guardado en PracUni3/ejemplosgenerales/bin y que:
  
read_plots <- read.delim(file ="../data/reads.txt")


#Hacer un bar plot de reads de cada libreria ubicado en: PracUni3/ejemplosgenerales/data/reads y poner titulo a los ejes

graficas_reads <- barplot(read_plots$nreads,
                          col = read_plots$Library,
                          xlab = "Librerias",
                          ylab = "Reads")  

#Crear paleta

palette(c("#a4bdeb",
          "#d7d09e",
          "#9adbc5"))

#Agregar leyenda de muestras

legend(x="topleft", legend = levels(read_plots$Library), 
       fill = palette()[1:3])

