# Programme maitre de génération de documents multiples (Sweave)
# 29/08/2013 : Paralelisation et simplification du processus (from Master.R)
# 02/09/2013 : Création fonction d'affectation des dossiers (Thibault)
# 3/04/2015 : adapté pour projet CRS-VRS avec Vincent

# Remove all

rm(list=ls())

### DO NOT FORGET TO COMMENT THE WORKING DIRECTORY IN THE RNW FILE !!!!!

## Second change the working directory

setwd("D:/progs/CRS")
# setwd("C:/Chris/progs/CRS")


library(foreign)
library("snowfall")

#Secteur <-"D152Z"

sweave.paral = function(Secteur)
{
  #setwd("c:/Chris/progs/CRS")              # chemin où j'ai mon fichier "standard" .rnw
  setwd("D:/progs/CRS")
  #On créée et on remplit les répertoires des données et du fichier Sweave.

  dir.create(paste("Rapports/Secteur",Secteur, sep =""), showWarnings = FALSE)
  dir.create(paste("Rapports/Secteur",Secteur,"/Data", sep =""), showWarnings = FALSE)
  dir.create(paste("Rapports/Secteur",Secteur,"/Graphics", sep =""), showWarnings = FALSE)
  dir.create(paste("Rapports/Secteur",Secteur,"/progs", sep =""), showWarnings = FALSE)


  #Copie du Sweave et des données (et des fonction annexe si necessaire)
  file.copy(from="CRSSecteur.Rnw",to=paste("Rapports","/","Secteur",Secteur,"/",paste("CRSSecteur",Secteur,"_temp.rnw",sep=""),sep=""),
  overwrite=TRUE)
  file.copy(from=paste("Data","/",Secteur,"Stat.dta",sep=""),to=paste("Rapports/Secteur",Secteur,"/Data/",
  sep =""),overwrite=TRUE)
  file.copy(from="progs/FunctionsBadubenko2.R",to=paste("Rapports","/","Secteur",Secteur,"/progs/FunctionsBadubenko2.R",sep=""),
  overwrite=TRUE)

  # Je me place dans le répertoire spécifique au Secteur

  setwd(paste("Rapports/Secteur",Secteur, sep =""))

  # Ecriture dans le fichier de paramètres

  write(Secteur, file="Secteur.dat", append=FALSE)

  # On execute Sweave + texi2pdf

  utils::Sweave(paste("CRSSecteur",Secteur,"_temp.rnw",sep="")) # je fais mon Sweave
  tools::texi2pdf(paste("CRSSecteur",Secteur,"_temp.tex",sep=""),  clean = TRUE)    # je fais mon
  .pdf
  # Je renomme le tex et le pdf
  file.rename(from=paste("CRSSecteur",Secteur,"_temp.tex",sep="") ,
  to=paste("CRSSecteur",Secteur,".tex",sep=""))
  file.rename(from=paste("CRSSecteur",Secteur,"_temp.pdf",sep="") ,
  to=paste("CRSSecteur",Secteur,".pdf",sep=""))
  # Menage !!!!
  file.remove(paste("CRSSecteur",Secteur,"_temp.rnw",sep=""))
  file.remove(paste("CRSSecteur",Secteur,"_temp-concordance.tex",sep=""))
  file.remove("progs/FunctionsBadubenko2.R")
}


# Ensemble de fichiers

ListAll <-c("D151E", "D152Z", "D153E", "D158K", "D158V",  "D159F",
"D159G","D151A","D151C","D155A", "D155C", "D156A",  "D157A", "D158A")

#On teste avec 4
#List4 <-c("D151E",  "D153E",  "D158K")

#Parallelisation
nb.cpus=8
SecList <-ListAll
sfInit(parallel=TRUE, cpus=nb.cpus)

toto <-system.time(
sfClusterApplyLB(SecList, sweave.paral)
)
# arret de la paralelisation
sfStop()

toto



