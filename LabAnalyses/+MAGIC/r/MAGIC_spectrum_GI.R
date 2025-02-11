#############################################################################################
##                                                                                         ##
##                                     MAGIC  -  Spectrum                                  ##
##                                                                                         ##
#############################################################################################
rm(list = ls())

PART_1_Baseline = TRUE
PART_2_TF       = FALSE

indiv = "Subject" # "Subject" or "Channel"
fqStartbarBSL = 12
fqEndbarBSL = 35
#############################################################################################
###### Initialisation
# DEFINE PATHS
Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()

gc()


events   = c( "BSL")
PlotType = 
if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "/network/iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/"
  sourcFile = "/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
} else {
  DataDir    = '//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  DataDir_GI = '//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
  OutputDir  = "//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats_GI"
  LogDir     = "//l2export/iss02.home/mathieu.yeche/Cluster/outputs/"
  sourcFile  = "//l2export/iss02.home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
}


## LIBRARY
LoadLibrary_and_RSourceFiles = function() {
library(sp)
library(tibble)
library(reshape2)
library(RColorBrewer)
library(colorRamps)
library(vroom)
library(grDevices)
library(ggplot2)
library(svglite)
library(animation)
library(FedData)
library(lme4)
library(parallel)
library(plyr)
library(dplyr)
library(reshape2)
library(missMDA)
library(FactoMineR)
library(factoextra)
library(stringr)
library(performance)
library(emmeans)
library(carData)
library(car)
library(foreach)
library(doParallel)
library(colorspace)
}
LoadLibrary_and_RSourceFiles()

segType  = 'step'            #'trial'   'step' 
normtype = c('RAW')        # RAW or ldNOR
datatype = 'TF'              #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'
Montage  = 'GaitInitiation'       # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'none'             # 'TraceBrut' , 'TF',  'none'

# Contacts_of_interest = c("HotspotFOG","Motor") # Region + "HotspotFOG","Motor" or grouping + "HighestBeta" or "other" + "All"
# GroupingMode         = "Region"
Contacts_of_interest = c("STN-SM-exclusif", "STN-AS-exclusif") # Region + "HotspotFOG","Motor" or grouping + "HighestBeta" or "other" + "All"
GroupingMode         = "other"
Contacts_of_interest = c("All") ; print("All contacts! \n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!")

VerboseAnova         = FALSE      # Print anova results for each point, each var and interaction
PlotOnlyNoModel      = FALSE      # Load the workspace to only plot the model without computing it
todo_gifplot         = FALSE
todo_tfmapplot       = TRUE
todo_MaskPlot        = FALSE
todo_Plots           = todo_tfmapplot | todo_gifplot | todo_MaskPlot
Load_0Comput         = FALSE      # Only load result and not compute the whole model
Espacement_Freq      = "identity"    # arg for coord_trans : either "identity" or "log10"   => WORK ONLY WITH geom_tile() INSTEAD OF geom_raster(), WHICH IS MUCH SLOWER
PValueLimit          = 0.05
PValueBreaks         = c(0.05, 0.01)    # Will show a separate line for all of these pvalue, by default : c(0.05, 0.01)
SlidingWindowHalfSize= 1
todo_corr_Comport    = TRUE # To do correlation with comportement
todo_corr_Clinique   = TRUE # To do correlation with clinical scores
todo_All_5ClinicTest = FALSE # False, only U3, dU3 et FOG-Q
todo_SMSfrequent     = TRUE # Envoi des SMS a chaque fin de event / contact
FigHigh = 24
FigWidth = 18

if (!todo_gifplot) {
         RestrictTimeCalculated = TRUE   # Change here to TRUE to prevent statistical computing outside [-1 ; 1]
} else { RestrictTimeCalculated = FALSE }# DO NOT CHANGE 
  gp   = c('STN')
# gp   = c('MAGIC_Only')



if (Sys.info()["nodename"] == "UMR-LAU-WP011") {
  DataDir   = 'C:/LustreSync/TMP/analyses'
  OutputDir = "C:/LustreSync/03_CartesTF/Stats_GI"
  MY_PatPCA = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
  MY_PatClin = "//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/MAGIC+GI_Clinical_scores.xlsx"      
  
  DataDir   = 'Z:/TMP/analyses'
  OutputDir = "Z:/03_CartesTF/Stats_GI"
  MY_PatPCA = "Z:/DATA/ResAPA_32Pat_forPCA.xlsx" 
  MY_PatClin= "Z:/DATA/MAGIC+GI_Clinical_scores.xlsx"

}
if (Sys.info()["nodename"] == "ICM-LAU-WF006") {
  DataDir   = 'Z:/TMP/analyses'
  OutputDir = "Z:/03_CartesTF/Stats_GI"
  MY_PatPCA = "Z:/DATA/ResAPA_32Pat_forPCA.xlsx" 
  MY_PatClin= "Z:/DATA/MAGIC+GI_Clinical_scores.xlsx"
}


if (PART_1_Baseline){

nor = normtype
      # SET SUBJECT
      
      if (gp == 'STN') {
        subjects =
          c(
            "SAs_000a",
            "REa_0526",
            'DEj_000a',
            'ALb_000a',
            'FEp_0536',   
            'VIj_000a',
            'DEp_0535',
            'GAl_000a',
            'SOh_0555',
            'GUg_0634',
            'FRj_0610',
            'BAg_0496',
            'DRc_000a',
            'COm_000a',
            'BEm_000a',
            "GIs_0550",
            # "FRa_000a",
            'LOp_000a',
            'ParkPitie_2013_03_21_ROe',
            'ParkPitie_2013_04_04_REs',
            'ParkPitie_2013_06_06_SOj',
            'ParkPitie_2013_10_10_COd',
            'ParkPitie_2013_10_17_FRl',
            'ParkPitie_2013_10_24_CLn',
            'ParkPitie_2014_04_18_MAd',
            'ParkPitie_2014_06_19_LEc',
            'ParkPitie_2015_01_15_MEp',
            'ParkPitie_2015_03_05_RAt',
            'ParkPitie_2015_04_30_VAp',
            'ParkPitie_2015_05_07_ALg',
            'ParkPitie_2015_05_28_DEm',
            'ParkPitie_2015_10_01_SAj'
          )
        
        listnameSubj =
          c(
            "ParkPitie_2021_10_21_SAs",
            "ParkPitie_2020_01_09_REa",
            "ParkPitie_2019_04_25_DEj",      #GOGAIT_POSTOP_DESJO20
            "ParkPitie_2020_06_25_ALb",
            "ParkPitie_2020_02_20_FEp",
            "ParkPitie_2021_04_01_VIj",
            "ParkPitie_2020_01_16_DEp",
            "ParkPitie_2020_09_17_GAl",
            "ParkPitie_2020_10_08_SOh",
            "ParkRouen_2020_11_30_GUg",
            "ParkRouen_2021_02_08_FRj",
            "ParkPitie_2019_02_21_BAg",      #GOGAIT_POSTOP_BARGU14
            "ParkPitie_2019_03_14_DRc",      #GOGAIT_POSTOP_DROCA16
            "ParkPitie_2019_10_24_COm",
            "ParkPitie_2019_10_03_BEm",
            "ParkPitie_2020_07_02_GIs",
            #  "ParkRouen_2021_10_04_FRa",
            "ParkPitie_2019_11_28_LOp",
            'ParkPitie_2013_03_21_ROe',
            'ParkPitie_2013_04_04_REs',
            'ParkPitie_2013_06_06_SOj',
            'ParkPitie_2013_10_10_COd',
            'ParkPitie_2013_10_17_FRl',
            'ParkPitie_2013_10_24_CLn',
            'ParkPitie_2014_04_18_MAd',
            'ParkPitie_2014_06_19_LEc',
            'ParkPitie_2015_01_15_MEp',
            'ParkPitie_2015_03_05_RAt',
            'ParkPitie_2015_04_30_VAp',
            'ParkPitie_2015_05_07_ALg',
            'ParkPitie_2015_05_28_DEm',
            'ParkPitie_2015_10_01_SAj'
          )
          
      }
      

      ev = events[1]
            LocTable = readxl::read_excel("//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/MAGIC+GI_loc_electrodes.xlsx", sheet = 'LocSara')
         

for (Contact in Contacts_of_interest) {
  
      TFbySubject = tibble()
      s_count = 0
for (s in subjects) {

              
              # precise groupe of protocol : GI or GNG
              if (s == 'ParkPitie_2013_03_21_ROe' || s == 'ParkPitie_2013_04_04_REs' || s == 'ParkPitie_2013_06_06_SOj' || s == 'ParkPitie_2013_10_10_COd' || s == 'ParkPitie_2013_10_17_FRl'|| s == 'ParkPitie_2013_10_24_CLn' 
                  || s == 'ParkPitie_2014_04_18_MAd' || s == 'ParkPitie_2014_06_19_LEc' || s == 'ParkPitie_2015_01_15_MEp' || s == 'ParkPitie_2015_03_05_RAt' || s ==  'ParkPitie_2015_04_30_VAp' 
                  || s ==  'ParkPitie_2015_05_07_ALg' || s == 'ParkPitie_2015_05_28_DEm' || s == 'ParkPitie_2015_10_01_SAj') { 
                task_name = 'GI' 
                suff_name = ''
              } else { 
                task_name = 'GNG_GAIT' 
                MontageLocal = ifelse( s %in% c("GIs_0550", "REa_0526", "SAs_000a"), 'extended', Montage)
                suff_name = paste('_', MontageLocal,'_', Artefact, sep="")
              }
              
              #######################################################################################################
              ## CHARGEMENT #########################################################################################
              #######################################################################################################
              
              s_count = s_count + 1
              print(paste0('########## Patient ', s_count, ' of ', length(subjects), ' /// ', s, ' ', ev, ' ##########' ))
              
              
              # define recdir depending on protocol group
              if (task_name == 'GI'){
                WorkDir = paste(DataDir , s, sep = "/")
              } else {
                RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
                WorkDir = paste(RecDir, '/POSTOP', sep = "") 
              }
              
              if (task_name == 'GI' || s == 'DEj_000a' || s == 'DRc_000a'|| s == 'BEm_000a' || s == 'BAg_0496' || s == 'LOp_000a'|| s == 'GIs_0550' || s == 'COm_000a'|| s == 'REa_0526' ) { 
                protocol = 'GBMOV' 
              } else { 
                protocol = 'MAGIC'  
              }
              outputname = listnameSubj[s_count]
              
              if ((nor == 'ldNOR') && segType  == 'step') {
                TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_meanTF_', 'dNOR', suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
                } else {
                if ( s %in% c("GIs_0550", "REa_0526", "SAs_000a")) {
                  TF1Pat = read.csv2(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_meanTF_',   nor , suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
                }
                  TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_meanTF_',   nor , suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
                }

              if (task_name == 'GI') {
                TF1Pat$Task = TF1Pat$Condition
                TF1Pat$Condition = TF1Pat$Segment
                TF1Pat$Segment = NULL
              }
              
            
            if (GroupingMode == "other"  ) {
              if ("All" == Contact) {  #Keep All electrodes
                ;

              } else if (grepl("STN", Contact)) {

                # Select which contacts to keep
                pat_row = which(LocTable$Pat == s)    
                if (is.na(LocTable$D0[pat_row])) {
                  print(paste0('Patient ', s, ' not found in LocTable'))
                  TF1Pat = tibble()
                  next
                }
                
                rm(StrToSearch)
                if (grepl("inSTN", Contact)) {
                  StrToSearch = "STN"
                } else if (grepl("STN-AS", Contact)) {
                  StrToSearch = "AS"
                } else if (grepl("STN-SM", Contact)) {
                  StrToSearch = "SM"
                } else if (grepl("STNversus-exclusif", Contact)) { #exclusif needed below
                  StrToSearch = "STN"
                }

                if (grepl("exclusif", Contact)) {
                  e01D = (grepl(StrToSearch, LocTable$D0[pat_row]) & grepl(StrToSearch, LocTable$D1[pat_row]))
                  e01G = (grepl(StrToSearch, LocTable$G0[pat_row]) & grepl(StrToSearch, LocTable$G1[pat_row]))
                  e12D = (grepl(StrToSearch, LocTable$D1[pat_row]) & grepl(StrToSearch, LocTable$D2[pat_row]))
                  e12G = (grepl(StrToSearch, LocTable$G1[pat_row]) & grepl(StrToSearch, LocTable$G2[pat_row]))
                  e23D = (grepl(StrToSearch, LocTable$D2[pat_row]) & grepl(StrToSearch, LocTable$D3[pat_row]))
                  e23G = (grepl(StrToSearch, LocTable$G2[pat_row]) & grepl(StrToSearch, LocTable$G3[pat_row]))
                } else if (grepl("elargi", Contact)) {
                  e01D = (grepl(StrToSearch, LocTable$D0[pat_row]) | grepl(StrToSearch, LocTable$D1[pat_row]))
                  e01G = (grepl(StrToSearch, LocTable$G0[pat_row]) | grepl(StrToSearch, LocTable$G1[pat_row]))
                  e12D = (grepl(StrToSearch, LocTable$D1[pat_row]) | grepl(StrToSearch, LocTable$D2[pat_row]))
                  e12G = (grepl(StrToSearch, LocTable$G1[pat_row]) | grepl(StrToSearch, LocTable$G2[pat_row]))
                  e23D = (grepl(StrToSearch, LocTable$D2[pat_row]) | grepl(StrToSearch, LocTable$D3[pat_row]))
                  e23G = (grepl(StrToSearch, LocTable$G2[pat_row]) | grepl(StrToSearch, LocTable$G3[pat_row]))
                } 
                
                # Keep only the selected contacts

                if (task_name == 'GI') {
                  if (!e01D) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "01D")}
                  if (!e01G) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "01G")}
                  if (!e12D) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "12D")}
                  if (!e12G) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "12G")}
                  if (!e23D) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "23D")}
                  if (!e23G) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "23G")}

                } else if (task_name == 'GNG_GAIT') {
                  listChan = unique(TF1Pat$Channel)
                  listChan = listChan[nchar(listChan) == 3]

                  realChan = listChan
                  listChan = gsub("1", "0", listChan)
                  listChan = gsub("[2-4]", "1", listChan)
                  listChan = gsub("[5-7]", "2", listChan)
                  listChan = gsub("8", "3", listChan)

                  realChan = realChan[grep("^(01|12|23|11|22)", listChan)]
                  listChan = listChan[grep("^(01|12|23|11|22)", listChan)]

                  if (!e01D) {realChan = realChan[listChan != "01D"] ; listChan = listChan[listChan != "01D"]}
                  if (!e01G) {realChan = realChan[listChan != "01G"] ; listChan = listChan[listChan != "01G"]}
                  if (!e12D) {realChan = realChan[listChan != "12D"] ; listChan = listChan[listChan != "12D"]}
                  if (!e12G) {realChan = realChan[listChan != "12G"] ; listChan = listChan[listChan != "12G"]}
                  if (!e23D) {realChan = realChan[listChan != "23D"] ; listChan = listChan[listChan != "23D"]}
                  if (!e23G) {realChan = realChan[listChan != "23G"] ; listChan = listChan[listChan != "23G"]}

                  # Ajout de la possibilité d'avoir un montage 42, 23, 56, ...
                  if (!grepl(StrToSearch, LocTable$D1[pat_row])) {
                    realChan = realChan[listChan != "11D"] ; listChan = listChan[listChan != "11D"]
                  }
                  if (!grepl(StrToSearch, LocTable$G1[pat_row])) {
                    realChan = realChan[listChan != "11G"] ; listChan = listChan[listChan != "11G"]
                  }
                  if (!grepl(StrToSearch, LocTable$D2[pat_row])) {
                    realChan = realChan[listChan != "22D"] ; listChan = listChan[listChan != "22D"]
                  }
                  if (!grepl(StrToSearch, LocTable$G2[pat_row])) {
                    realChan = realChan[listChan != "22G"] ; listChan = listChan[listChan != "22G"]
                  }

                  TF1Pat = subset(TF1Pat, TF1Pat$Channel %in% realChan)

                  }

                    if (grepl("STNversus", Contact)) {
                      
                      TF1Pat$Region = 0
                      for (RegToSearch in c("AS", "SM")) { #bien dans cet ordre
                        StrToSearch = RegToSearch
                        e01D = (grepl(StrToSearch, LocTable$D0[pat_row]) & grepl(StrToSearch, LocTable$D1[pat_row]))
                        e01G = (grepl(StrToSearch, LocTable$G0[pat_row]) & grepl(StrToSearch, LocTable$G1[pat_row]))
                        e12D = (grepl(StrToSearch, LocTable$D1[pat_row]) & grepl(StrToSearch, LocTable$D2[pat_row]))
                        e12G = (grepl(StrToSearch, LocTable$G1[pat_row]) & grepl(StrToSearch, LocTable$G2[pat_row]))
                        e23D = (grepl(StrToSearch, LocTable$D2[pat_row]) & grepl(StrToSearch, LocTable$D3[pat_row]))
                        e23G = (grepl(StrToSearch, LocTable$G2[pat_row]) & grepl(StrToSearch, LocTable$G3[pat_row]))

                        listChan = unique(TF1Pat$Channel)
                        realChan = listChan
                        if (task_name == 'GNG_GAIT') {
                          listChan = gsub("1", "0", listChan)
                          listChan = gsub("[2-4]", "1", listChan)
                          listChan = gsub("[5-7]", "2", listChan)
                          listChan = gsub("8", "3", listChan)
                        }
                        
                        if (!e01D) {realChan = realChan[listChan != "01D"] ; listChan = listChan[listChan != "01D"]}
                        if (!e01G) {realChan = realChan[listChan != "01G"] ; listChan = listChan[listChan != "01G"]}
                        if (!e12D) {realChan = realChan[listChan != "12D"] ; listChan = listChan[listChan != "12D"]}
                        if (!e12G) {realChan = realChan[listChan != "12G"] ; listChan = listChan[listChan != "12G"]}
                        if (!e23D) {realChan = realChan[listChan != "23D"] ; listChan = listChan[listChan != "23D"]}
                        if (!e23G) {realChan = realChan[listChan != "23G"] ; listChan = listChan[listChan != "23G"]}

                        if (!grepl(StrToSearch, LocTable$D1[pat_row])) {
                          realChan = realChan[listChan != "11D"] ; listChan = listChan[listChan != "11D"]
                        }
                        if (!grepl(StrToSearch, LocTable$G1[pat_row])) {
                          realChan = realChan[listChan != "11G"] ; listChan = listChan[listChan != "11G"]
                        }
                        if (!grepl(StrToSearch, LocTable$D2[pat_row])) {
                          realChan = realChan[listChan != "22D"] ; listChan = listChan[listChan != "22D"]
                        }
                        if (!grepl(StrToSearch, LocTable$G2[pat_row])) {
                          realChan = realChan[listChan != "22G"] ; listChan = listChan[listChan != "22G"]
                        }
                        
                        if (RegToSearch == "AS") {
                          TF1Pat$Region = ifelse(TF1Pat$Channel %in% realChan, 1+TF1Pat$Region, TF1Pat$Region)
                        } else if (RegToSearch == "SM") {
                          TF1Pat$Region = ifelse(TF1Pat$Channel %in% realChan, 3-TF1Pat$Region, TF1Pat$Region)
                        }
                        
                      } # End for RegToSearch

                      # petit checkpoint
                        if (nrow(filter(TF1Pat, Region == 0)) != 0) {
                          print(paste0(unique(TF1Pat$Channel[TF1Pat$Region == 0]) , ' contacts ne sont pas exclusivement dans une region du STN (regime exclusif)'))
                        }
                      
                      TF1Pat = subset(TF1Pat, TF1Pat$Region != 0)
                      TF1Pat$Region = ifelse(TF1Pat$Region == 1, "AS", ifelse(TF1Pat$Region == 2, "MidSTN", "SM"))

                    }
              } 
            }

            if (GroupingMode == "Region"  ) {TF1Pat = subset(TF1Pat, TF1Pat$Region   == Contact)}  #Keep Only 1 electrode
              if (GroupingMode == "grouping") {
                if ("HighestBeta" == Contact) {
                  if (1 == sum(unique(TF1Pat$Region) == "HotspotFOG", na.rm = TRUE)) {
                    TF1Pat = subset(TF1Pat, TF1Pat$Region   == "HotspotFOG")
                  } else {
                    # Implementation de l'HighestBeta
                    TFPat2 = subset(TF1Pat, TF1Pat$Freq > 13 & TF1Pat$Freq < 30)
                    TFPat2 = subset(TFPat2, TFPat2$quality == 1)

                    startTimeBeta = 18 + 0.5*ncol(TFPat2)
                    endTimeBeta   = ncol(TFPat2) - 0.25*ncol(TFPat2)

                    # Gauche
                    TFPat3 = subset(TFPat2, grepl('G', TFPat2$Channel))
                    TFPat3 = TFPat3[nchar(TFPat3$Channel) == 3,]
                    valuelist = c()
                    for (ch in unique(TFPat3$Channel)){
                      TFPat4 = subset(TFPat3, TFPat3$Channel == ch)
                      valuelist[ch] = sum(sum(TFPat4[, startTimeBeta:endTimeBeta], na.rm = TRUE), na.rm = TRUE)
                    }
                    ChOfInterestG = names(which.max(valuelist))
                    
                    # Droite
                    TFPat3 = subset(TFPat2, grepl('D', TFPat2$Channel))
                    TFPat3 = TFPat3[nchar(TFPat3$Channel) == 3,]
                    valuelist = c()
                    for (ch in unique(TFPat3$Channel)){
                      TFPat4 = subset(TFPat3, TFPat3$Channel == ch)
                      valuelist[ch] = sum(sum(TFPat4[, startTimeBeta:endTimeBeta], na.rm = TRUE), na.rm = TRUE)
                    }
                    ChOfInterestD = names(which.max(valuelist))

                    print(paste0(s, " BestBeta : ", ChOfInterestG, ' et ', ChOfInterestD))
                    TF1Pat = subset(TF1Pat, TF1Pat$Channel == ChOfInterestG | TF1Pat$Channel == ChOfInterestD)
                  }
                } else {
                  TF1Pat = subset(TF1Pat, TF1Pat$grouping == Contact)
                }  #Keep Only 1 electrode
              }
              TF1Pat = subset(TF1Pat, TF1Pat$quality == 1)
              
              # Blacklisted trials (due to bad baseline mainly)
              if (s == 'COm_000a') {
                TF1Pat = subset(TF1Pat, 
                                !((TF1Pat$Channel == '25D' && TF1Pat$Medication == 'ON') | 
                                    (TF1Pat$Channel == '23D' && TF1Pat$Medication == 'ON') | 
                                    (TF1Pat$Channel == '36D' && TF1Pat$Medication == 'ON')))
              }
              
              if (s == 'VIj_000a') {
                TF1Pat = subset(TF1Pat, 
                                !((TF1Pat$Channel == '75D' && TF1Pat$Medication == 'OFF') | 
                                    (TF1Pat$Channel == '67D' && TF1Pat$Medication == 'OFF') | 
                                    (TF1Pat$Channel == '47D' && TF1Pat$Medication == 'OFF')))
              }
              
              if (s == 'GAl_000a') {
                TF1Pat = subset(TF1Pat, 
                                !((TF1Pat$Channel == '25D' && TF1Pat$Medication == 'ON') | 
                                    (TF1Pat$Channel == '23D' && TF1Pat$Medication == 'ON') | 
                                    (TF1Pat$Channel == '47G' && TF1Pat$Medication == 'ON') | 
                                    (TF1Pat$Channel == '75G' && TF1Pat$Medication == 'ON') | 
                                    (TF1Pat$Channel == '42D' && TF1Pat$Medication == 'ON')))
              }
              
              if (nrow(TF1Pat) == 0) {
                print(paste0('No electrodes kept for patient ', s, ' ', ev))
                next
              }
              
              TFbySubject = bind_rows(TFbySubject, TF1Pat)
              rm(TF1Pat)
              gc()
              
            } #  End for all subjects : chargement global

      # Artefact removal
      TFbySubject %<>% dplyr::rename(TempOut = Condition, TrialNum = nTrial, Condition = Medication, Subject = Patient) %>% global_remove_artifacts()
      
      TFbySubject %<>% dplyr::rename(nTrial = TrialNum, Medication = Condition, Patient = Subject, Condition = TempOut) 
      
      TFbySubject = TFbySubject[TFbySubject$isValid == 1,]
      
      if (grepl("STN-AS", Contact)) {
        TFbySubjectAS = TFbySubject
        TFbySubjectAS$Loc = "AS"
        TFbySubjectAS %<>% dplyr::rename(TempOut = Condition, TrialNum = nTrial, Condition = Medication) %>% 
          mutate(Patient = str_sub(subject, -3, -1)) %>% 
          global_remove_artifacts()
        TFbySubjectAS %<>% dplyr::rename(nTrial = TrialNum, Medication = Condition, Condition = TempOut) 
        OFF_AS = TFbySubject[TFbySubject$Medication == "OFF",]
        ON__AS = TFbySubject[TFbySubject$Medication == "ON",]
      }
      if (grepl("STN-SM", Contact)) {
        TFbySubjectSM = TFbySubject 
        TFbySubjectSM$Loc = "SM"
        TFbySubjectSM %<>% dplyr::rename(TempOut = Condition, TrialNum = nTrial, Condition = Medication) %>% 
          mutate(Patient = str_sub(subject, -3, -1)) %>% 
          global_remove_artifacts()
        TFbySubjectSM %<>% dplyr::rename(nTrial = TrialNum, Medication = Condition, Condition = TempOut) 
        OFF_SM = TFbySubject[TFbySubject$Medication == "OFF",]
        ON__SM = TFbySubject[TFbySubject$Medication == "ON",]
      }

}
            
TFglobal = bind_rows(TFbySubjectAS, TFbySubjectSM)

TFglobal %<>% mutate(TrialId = paste(Patient, Channel, Task, nTrial, Medication, sep = "_"))
trialdup = TFglobal %>% select(TrialId) %>% group_by(TrialId) %>% count() %>% filter(freq > 100)
TFglobal %<>% filter(!((TrialId %in% trialdup$TrialId) & (Loc == "AS")))
TFglobal %<>% mutate(Loc = ifelse(TrialId %in% trialdup$TrialId, "IN", Loc))
TFglobal %<>% select(-TrialId)

save(TFglobal, file = paste(OutputDir, '/Baseline_allTrial.RData', sep = ""))

OFF_AS_allTrial = OFF_AS
OFF_SM_allTrial = OFF_SM
ON__AS_allTrial = ON__AS
ON__SM_allTrial = ON__SM


##############
## Spectre  ##
##############

colors = colorspace::diverge_hcl(100, palette = "Tropic")
colors = colors[c(1,100,30,70)]


OFF_AS = aggregate(OFF_AS, by = list(OFF_AS$Freq, OFF_AS$Patient, OFF_AS$Medication, OFF_AS$Channel), FUN = mean)
OFF_SM = aggregate(OFF_SM, by = list(OFF_SM$Freq, OFF_SM$Patient, OFF_SM$Medication, OFF_SM$Channel), FUN = mean)
ON__AS = aggregate(ON__AS, by = list(ON__AS$Freq, ON__AS$Patient, ON__AS$Medication, ON__AS$Channel), FUN = mean)
ON__SM = aggregate(ON__SM, by = list(ON__SM$Freq, ON__SM$Patient, ON__SM$Medication, ON__SM$Channel), FUN = mean)

OFF_AS = OFF_AS[,c(2,4,17,22)]
OFF_SM = OFF_SM[,c(2,4,17,22)]
ON__AS = ON__AS[,c(2,4,17,22)]
ON__SM = ON__SM[,c(2,4,17,22)]

colnames(OFF_AS)[1] = "Subject"
colnames(OFF_SM)[1] = "Subject"
colnames(ON__AS)[1] = "Subject"
colnames(ON__SM)[1] = "Subject"

colnames(OFF_AS)[2] = "Channel"
colnames(OFF_SM)[2] = "Channel"
colnames(ON__AS)[2] = "Channel"
colnames(ON__SM)[2] = "Channel"

OFF_AS$Channel = paste0(OFF_AS$Subject, "-", OFF_AS$Channel)
OFF_SM$Channel = paste0(OFF_SM$Subject, "-", OFF_SM$Channel)
ON__AS$Channel = paste0(ON__AS$Subject, "-", ON__AS$Channel)
ON__SM$Channel = paste0(ON__SM$Subject, "-", ON__SM$Channel)

colnames(OFF_AS)[4] = "OFF_AS"
colnames(OFF_SM)[4] = "OFF_SM"
colnames(ON__AS)[4] = "ON__AS"
colnames(ON__SM)[4] = "ON__SM"

OFF_AS_mean = aggregate(OFF_AS, by = list(OFF_AS$Freq), FUN = median)
OFF_SM_mean = aggregate(OFF_SM, by = list(OFF_SM$Freq), FUN = median)
ON__AS_mean = aggregate(ON__AS, by = list(ON__AS$Freq), FUN = median)
ON__SM_mean = aggregate(ON__SM, by = list(ON__SM$Freq), FUN = median)

OFF_AS_sd = OFF_AS_mean ; OFF_AS_sd$OFF_AS = NA
OFF_SM_sd = OFF_SM_mean ; OFF_SM_sd$OFF_SM = NA
ON__AS_sd = ON__AS_mean ; ON__AS_sd$ON__AS = NA
ON__SM_sd = ON__SM_mean ; ON__SM_sd$ON__SM = NA

for (frq in min(OFF_AS_sd$Freq):max(OFF_AS_sd$Freq)) {
  OFF_AS_sd[OFF_AS_sd$Freq == frq, "OFF_AS"] = IQR(OFF_AS[OFF_AS$Freq == frq, "OFF_AS"])
  OFF_SM_sd[OFF_SM_sd$Freq == frq, "OFF_SM"] = IQR(OFF_SM[OFF_SM$Freq == frq, "OFF_SM"])
  ON__AS_sd[ON__AS_sd$Freq == frq, "ON__AS"] = IQR(ON__AS[ON__AS$Freq == frq, "ON__AS"])
  ON__SM_sd[ON__SM_sd$Freq == frq, "ON__SM"] = IQR(ON__SM[ON__SM$Freq == frq, "ON__SM"])
}

dfmean = merge(OFF_AS_mean, OFF_SM_mean, by = c("Freq" ))
dfmean = merge(dfmean, ON__AS_mean, by = c("Freq" ))
dfmean = merge(dfmean, ON__SM_mean, by = c("Freq" ))

dfsd = merge(OFF_AS_sd, OFF_SM_sd, by = c("Freq" ))
dfsd = merge(dfsd, ON__AS_sd, by = c("Freq" ))
dfsd = merge(dfsd, ON__SM_sd, by = c("Freq" ))

dfmean = dfmean[,c(1,5,9,13,17)]
dfsd = dfsd[,c(1,5,9,13,17)]

# Make spectrum
ggplot(dfmean, aes(x = Freq)) +
  geom_line(aes(y = OFF_AS, color = "OFF_AS"), linetype = "dashed") +
  geom_line(aes(y = OFF_SM, color = "OFF_SM"), linetype = "dashed") +
  geom_line(aes(y = ON__AS, color = "ON__AS")) +
  geom_line(aes(y = ON__SM, color = "ON__SM")) +
  scale_color_manual(
    name = "Condition",
    values = c("OFF_AS" = colors[1], "OFF_SM" = colors[2], "ON__AS" = colors[1], "ON__SM" = colors[2])
  ) +
  # geom_ribbon(data = dfsd, aes(ymin = dfmean$OFF_AS - dfsd$OFF_AS/2, ymax = dfmean$OFF_AS + dfsd$OFF_AS/2), fill = colors[1], alpha = 0.2) +
  # geom_ribbon(data = dfsd, aes(ymin = dfmean$OFF_SM - dfsd$OFF_SM/2, ymax = dfmean$OFF_SM + dfsd$OFF_SM/2), fill = colors[2], alpha = 0.2) +
  # geom_ribbon(data = dfsd, aes(ymin = dfmean$ON__AS - dfsd$ON__AS/2, ymax = dfmean$ON__AS + dfsd$ON__AS/2), fill = colors[1], alpha = 0.2) +
  # geom_ribbon(data = dfsd, aes(ymin = dfmean$ON__SM - dfsd$ON__SM/2, ymax = dfmean$ON__SM + dfsd$ON__SM/2), fill = colors[2], alpha = 0.2) +
  theme_bw() +
  theme(
    legend.position = "none",
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(size = 20),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  xlab("Frequency (Hz)") +
  ylab("Power (mV)") +
  scale_x_continuous(breaks = seq(0, 100, 10)) +
  scale_y_log10() + 
  geom_vline(xintercept = 12, linetype = "dotted", color = "#000000", size = 0.5) +
  geom_vline(xintercept = 35, linetype = "dotted", color = "#000000", size = 0.5) 
                    

# Make barplot

dfpatAS = merge(OFF_AS, ON__AS, by = c("Freq", "Subject", "Channel"), all = TRUE)
dfpatSM = merge(OFF_SM,ON__SM , by = c("Freq", "Subject", "Channel"), all = TRUE)

dfpatAS = dfpatAS[dfpatAS$Freq >= fqStartbarBSL & dfpatAS$Freq <= fqEndbarBSL,]
dfpatSM = dfpatSM[dfpatSM$Freq >= fqStartbarBSL & dfpatSM$Freq <= fqEndbarBSL,]


if (indiv == "Subject") {
  dfpatAS = aggregate(dfpatAS, by = list(dfpatAS$Subject), FUN = median)
  dfpatSM = aggregate(dfpatSM, by = list(dfpatSM$Subject), FUN = median)
} else if (indiv == "Channel") {
  dfpatAS = aggregate(dfpatAS, by = list(dfpatAS$Channel), FUN = median)
  dfpatSM = aggregate(dfpatSM, by = list(dfpatSM$Channel), FUN = median)
}

colnames(dfpatAS)[1] = indiv
colnames(dfpatSM)[1] = indiv
dfpatAS = dfpatAS[,c(1,5,6)]
dfpatSM = dfpatSM[,c(1,5,6)]
dfpatAS = reshape2::melt(dfpatAS, id.vars = indiv)
dfpatSM = reshape2::melt(dfpatSM, id.vars = indiv)
dfpatAS$variable = factor(dfpatAS$variable, levels = c("OFF_AS", "ON__AS"))
dfpatSM$variable = factor(dfpatSM$variable, levels = c("OFF_SM", "ON__SM"))

for (i in 1:2) {
  if (i == 1) {
    df2 = dfpatAS
  } else {
    df2 = dfpatSM
  }

  ggplot(df2, aes(x = variable, y = value)) + 
      geom_bar(aes(fill = variable), stat = "identity", position = position_dodge()) +
      scale_fill_manual(
        name = "Condition",
        values = c("OFF_AS" = colors[3], "OFF_SM" = colors[4], "ON__AS" = colors[3], "ON__SM" = colors[4])
      ) +
      scale_y_log10() +
      ggbeeswarm::geom_beeswarm(aes(color = variable), size = 1) +
      scale_color_manual(
        name = "Condition",
        values = c("OFF_AS" = colors[1], "OFF_SM" = colors[2], "ON__AS" = colors[1], "ON__SM" = colors[2])
      ) +
      theme(
        legend.position = "none",
        axis.title.x = element_text(size = 20),
        axis.title.y = element_text(size = 20),
        axis.text.x = element_text(size = 20),
        axis.text.y = element_text(size = 20),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      ) +
      xlab("Condition") +
      ylab("Power (mV)") +
      ggtitle(paste0("BarPlot "," - ", indiv, ' : Freq ', fqStartbarBSL, 'Hz a ', fqEndbarBSL,'Hz')) +
      theme_bw() +
      # line between points for each subject
      geom_line(data = df2, aes(x = variable, y = value, group = get(indiv)), color = "black", alpha = 0.2) 
}


## Pour Verifs

# OFF_AS = OFF_ASsave
# OFF_SM = OFF_SMsave
# ON__AS = ON__ASsave
# ON__SM = ON__SMsave

OFF_AS = OFF_AS[OFF_AS$Task == "spon" | OFF_AS$Task == "fast",]
OFF_SM = OFF_SM[OFF_SM$Task == "spon" | OFF_SM$Task == "fast",]
ON__AS = ON__AS[ON__AS$Task == "spon" | ON__AS$Task == "fast",]
ON__SM = ON__SM[ON__SM$Task == "spon" | ON__SM$Task == "fast",]

OFF_AS = OFF_AS[OFF_AS$Task == "GOc" | OFF_AS$Task == "GOi",]
OFF_SM = OFF_SM[OFF_SM$Task == "GOc" | OFF_SM$Task == "GOi",]
ON__AS = ON__AS[ON__AS$Task == "GOc" | ON__AS$Task == "GOi",]
ON__SM = ON__SM[ON__SM$Task == "GOc" | ON__SM$Task == "GOi",]



OFF_AS = OFF_AS[OFF_AS$Patient != "ParkPitie_2019_10_03_BEm" ,]
OFF_SM = OFF_SM[OFF_SM$Patient != "ParkPitie_2019_10_03_BEm" ,]
ON__AS = ON__AS[ON__AS$Patient != "ParkPitie_2019_10_03_BEm" ,]
ON__SM = ON__SM[ON__SM$Patient != "ParkPitie_2019_10_03_BEm" ,]


if (F) {
  TFglobal %>% group_by(Freq,Patient,Medication) %>% summarise(x0 = mean(x0)) %>% ggplot(aes(x = Freq, y = x0, color = Medication)) +
    geom_line() +
    facet_wrap(~Patient) +
    scale_x_continuous(breaks = seq(0, 100, 10)) +
    scale_y_log10() + 
    theme_Publication()
  
  TFglobal %>% filter(Subject == "VIj" ) %>% group_by(Freq,Channel,Medication) %>% summarise(x0 = mean(x0)) %>% ggplot(aes(x = Freq, y = x0, color = Medication)) +
    geom_line() +
    facet_wrap(~Channel) +
    scale_x_continuous(breaks = seq(0, 100, 10)) +
    scale_y_log10() + 
    theme_Publication()
  
  TFglobal %>% filter(Subject == "VIj" & Channel %in% c("47D","67D","75D")) %>% group_by(Freq,nTrial,Medication) %>% summarise(x0 = mean(x0)) %>% ggplot(aes(x = Freq, y = x0, color = Medication)) +
    geom_line() +
    facet_wrap(~nTrial) +
    scale_x_continuous(breaks = seq(0, 100, 10)) +
    scale_y_log10() + 
    theme_Publication()
  
}

}




if (PART_2_TF) {



###############
## Mean band ##
###############

# parameters

per_trial = TRUE # TRUE for each trial or FALSE global mean

colors = colorspace::diverge_hcl(100, palette = "Tropic")
colors = colors[c(1,100,30,70)]

StartTime = 0
EndTime   = 0.5
breaks = c(20,25,8, 12, 12, 35, 12, 20, 20, 35, 15, 15, 25, 25, 35, 70)

# Load workspace
load(paste0(OutputDir, '/WorkSpace/', 'WorkSpaceSTN-AS-exclusif_T0', '.RData'))
AS = TFbySubject
load(paste0(OutputDir, '/WorkSpace/', 'WorkSpaceSTN-SM-exclusif_T0', '.RData'))
SM = TFbySubject
load(paste0(OutputDir, '/WorkSpace/', 'WorkSpaceinSTN-exclusif_T0', '.RData'))
WholeSTN = TFbySubject

if (per_trial) {
  AS$MetCond = paste0( AS$Patient, '-', AS$Medication, '-', AS$nTrial, '-', AS$Task, '-', AS$Channel)
  SM$MetCond = paste0( SM$Patient, '-', SM$Medication, '-', SM$nTrial, '-', SM$Task, '-', SM$Channel)
  WholeSTN$MetCond = paste0( WholeSTN$Patient, '-', WholeSTN$Medication, '-', WholeSTN$nTrial, '-', WholeSTN$Task, '-', WholeSTN$Channel)
} else {
  AS$MetCond = paste0(AS$Medication, '-', AS$Patient, '-', AS$Channel)
  SM$MetCond = paste0(SM$Medication, '-', SM$Patient, '-', SM$Channel)
  WholeSTN$MetCond = paste0(WholeSTN$Medication, '-', WholeSTN$Patient, '-', WholeSTN$Channel)
}
# Time subset
cpt = 0
for (colnum in 120:18) {
  timepoint = colnames(AS)[colnum]
  timepoint = gsub("x_", "-", timepoint, fixed = TRUE)
  timepoint = gsub("_" , ".", timepoint)
  timepoint = gsub("x" , "" , timepoint)
  timepoint = as.numeric(timepoint)
  if (timepoint < StartTime || timepoint > EndTime) {
    AS[,colnum] = NULL
    SM[,colnum] = NULL
    WholeSTN[,colnum] = NULL
    cpt = cpt + 1
  } else {
    AS[AS[,colnum]=="NaN",colnum] = NA
    SM[SM[,colnum]=="NaN",colnum] = NA
    WholeSTN[WholeSTN[,colnum]=="NaN",colnum] = NA
    AS[,colnum] = 10*log(AS[,colnum], base = 10)
    SM[,colnum] = 10*log(SM[,colnum], base = 10)
    WholeSTN[,colnum] = 10*log10(WholeSTN[,colnum])
  }
}

AS$value = rowMeans(AS[,18:(120-cpt)], na.rm = TRUE)
SM$value = rowMeans(SM[,18:(120-cpt)], na.rm = TRUE)
WholeSTN$value = rowMeans(WholeSTN[,18:(120-cpt)], na.rm = TRUE)

if (per_trial) {
  AS = AS[,c("MetCond", "Freq", "value", "Patient", "Medication", "dimension1", "dimension2", "dimension3", "nTrial", "FOG")]
  SM = SM[,c("MetCond", "Freq", "value", "Patient", "Medication", "dimension1", "dimension2", "dimension3", "nTrial", "FOG")]
  WholeSTN = WholeSTN[,c("MetCond", "Freq", "value", "Patient", "Medication", "dimension1", "dimension2", "dimension3", "nTrial", "FOG")]

  write.csv(AS, file = paste0(OutputDir,'/Barplots/', 'AllTrial_T0_', 'AS','.csv'))
  write.csv(SM, file = paste0(OutputDir,'/Barplots/', 'AllTrial_T0_', 'SM','.csv'))
  write.csv(WholeSTN, file = paste0(OutputDir,'/Barplots/', 'AllTrial_T0_', 'inSTN','.csv'))

} else {

AS = AS[,c("MetCond", "Freq", "value", "Patient", "Medication")]
SM = SM[,c("MetCond", "Freq", "value", "Patient", "Medication")]
WholeSTN = WholeSTN[,c("MetCond", "Freq", "value", "Patient", "Medication")]

exitlist = NA
for (freqgp in 1:(length(breaks)/2)) {
  figname = paste0("MeanBand-", breaks[2*freqgp-1], 'Hz-', breaks[2*freqgp], 'Hz_', 'T0_t' , StartTime, '_to_t', EndTime)
  tmpAS  = AS[AS$Freq >= breaks[2*freqgp-1] & AS$Freq <= breaks[2*freqgp],]
  tmpSM  = SM[SM$Freq >= breaks[2*freqgp-1] & SM$Freq <= breaks[2*freqgp],]
  tmpWholeSTN  = WholeSTN[WholeSTN$Freq >= breaks[2*freqgp-1] & WholeSTN$Freq <= breaks[2*freqgp],]

  tmpAS  = aggregate(tmpAS, by = list(tmpAS$MetCond, tmpAS$Patient, tmpAS$Medication), FUN = mean)
  tmpSM  = aggregate(tmpSM, by = list(tmpSM$MetCond, tmpSM$Patient, tmpSM$Medication), FUN = mean)
  tmpWholeSTN  = aggregate(tmpWholeSTN, by = list(tmpWholeSTN$MetCond, tmpWholeSTN$Patient, tmpWholeSTN$Medication), FUN = mean)
  
  tmpAS$MetCond = NULL
  tmpSM$MetCond = NULL
  tmpWholeSTN$MetCond = NULL

  tmpAS$Patient = NULL
  tmpSM$Patient = NULL
  tmpWholeSTN$Patient = NULL

  tmpAS$Medication = NULL
  tmpSM$Medication = NULL
  tmpWholeSTN$Medication = NULL

  tmpAS$Freq = NULL
  tmpSM$Freq = NULL
  tmpWholeSTN$Freq = NULL

  colnames(tmpAS)[1:3] = c("MetCond", "Patient", "Medication")
  colnames(tmpSM)[1:3] = c("MetCond", "Patient", "Medication")
  colnames(tmpWholeSTN)[1:3] = c("MetCond", "Patient", "Medication")
  
  tmpAS$loc = "AS"
  tmpSM$loc = "SM"

  df = rbind(tmpAS, tmpSM)
  df$variable = paste0(df$Medication, '_', df$loc)
  df$Category = figname
  
  ggplot(df, aes(x = variable, y = value)) + 
    geom_bar(aes(fill = variable), stat = "identity", position = position_dodge()) +
    scale_fill_manual(
      name = "Condition",
      values = c("OFF_AS" = colors[3], "OFF_SM" = colors[4], "ON_AS" = colors[3], "ON_SM" = colors[4])
    ) +
    ggbeeswarm::geom_beeswarm(aes(color = variable), size = 1) +
    scale_color_manual(
      name = "Condition",
      values = c("OFF_AS" = colors[1], "OFF_SM" = colors[2], "ON_AS" = colors[1], "ON_SM" = colors[2])
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      axis.title.x = element_text(size = 20),
      axis.title.y = element_text(size = 20),
      axis.text.x = element_text(size = 20),
      axis.text.y = element_text(size = 20),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    xlab("Condition") +
    ylab("Power (dB)") +
    geom_hline(yintercept = 0, linetype = "dotted", color = "#000000", size = 0.5) 
  
  ggsave(paste0(OutputDir, '/Barplots/', figname, '.png'))

  if (freqgp == 1) {
    exitlist = df
  } else {
    exitlist = rbind(exitlist, df)
  }
}

write.csv(exitlist, file = paste0(OutputDir,'/Barplots/', 'MeanBand_T0.csv'))

}





##############
## AS vs AM ##
## Spectre  ##
##############

colors = colorspace::diverge_hcl(100, palette = "Tropic")
colors = colors[c(1,100,30,70)]


# Load processed data
StartTime = -1
EndTime   =  1

OFF_AS = vroom::vroom(paste0(OutputDir, '/ProcessedData/', 'TF_T0_STN-AS-exclusif_OFF_AllCond_0.05', '.csv'))
OFF_SM = vroom::vroom(paste0(OutputDir, '/ProcessedData/', 'TF_T0_STN-SM-exclusif_OFF_AllCond_0.05', '.csv'))
ON__AS = vroom::vroom(paste0(OutputDir, '/ProcessedData/', 'TF_T0_STN-AS-exclusif_ON_AllCond_0.05', '.csv'))
ON__SM = vroom::vroom(paste0(OutputDir, '/ProcessedData/', 'TF_T0_STN-SM-exclusif_ON_AllCond_0.05', '.csv'))

# Collapse on time
OFF_AS = subset(OFF_AS, (OFF_AS$Time >= StartTime & OFF_AS$Time <= EndTime))
OFF_SM = subset(OFF_SM, (OFF_SM$Time >= StartTime & OFF_SM$Time <= EndTime))
ON__AS = subset(ON__AS, (ON__AS$Time >= StartTime & ON__AS$Time <= EndTime))
ON__SM = subset(ON__SM, (ON__SM$Time >= StartTime & ON__SM$Time <= EndTime))

OFF_AS$pvalue = NULL
OFF_SM$pvalue = NULL
ON__AS$pvalue = NULL
ON__SM$pvalue = NULL

OFF_AS$Time = NULL
OFF_SM$Time = NULL
ON__AS$Time = NULL
ON__SM$Time = NULL

OFF_AS = aggregate(OFF_AS, by = list(OFF_AS$Freq), FUN = mean)
OFF_SM = aggregate(OFF_SM, by = list(OFF_SM$Freq), FUN = mean)
ON__AS = aggregate(ON__AS, by = list(ON__AS$Freq), FUN = mean)
ON__SM = aggregate(ON__SM, by = list(ON__SM$Freq), FUN = mean)

colnames(OFF_AS)[3] = "OFF_AS"
colnames(OFF_SM)[3] = "OFF_SM"
colnames(ON__AS)[3] = "ON__AS"
colnames(ON__SM)[3] = "ON__SM"

df = merge(OFF_AS, OFF_SM, by = "Freq")
df = merge(df, ON__AS, by = "Freq")
df = merge(df, ON__SM, by = "Freq")
df$Group.1.x = NULL
df$Group.1.x = NULL
df$Group.1.y = NULL
df$Group.1.y = NULL

# Stats

# Make spectrum
ggplot(df, aes(x = Freq)) +
  geom_line(aes(y = OFF_AS, color = "OFF_AS"), linetype = "dashed") +
  geom_line(aes(y = OFF_SM, color = "OFF_SM"), linetype = "dashed") +
  geom_line(aes(y = ON__AS, color = "ON__AS")) +
  geom_line(aes(y = ON__SM, color = "ON__SM")) +
  scale_color_manual(
    name = "Condition",
    values = c("OFF_AS" = colors[1], "OFF_SM" = colors[2], "ON__AS" = colors[1], "ON__SM" = colors[2])
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(size = 20),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  xlab("Frequency (Hz)") +
  ylab("Power (dB)") +
  scale_x_continuous(breaks = seq(0, 100, 10)) +
  scale_y_continuous(breaks = seq(-20, 20, 5)) + 
  geom_vline(xintercept = 12, linetype = "dotted", color = "#000000", size = 0.5) +
  geom_vline(xintercept = 35, linetype = "dotted", color = "#000000", size = 0.5) 
                    

# Make barplot

df2 = reshape2::melt(df, id.vars = "Freq")
df2$variable = factor(df2$variable, levels = c("OFF_AS", "OFF_SM", "ON__AS", "ON__SM"))


ggplot(df2, aes(x = variable, y = value)) + 
    geom_bar(aes(fill = variable), stat = "identity", position = position_dodge()) +
    scale_fill_manual(
      name = "Condition",
      values = c("OFF_AS" = colors[3], "OFF_SM" = colors[4], "ON__AS" = colors[3], "ON__SM" = colors[4])
    ) +
    ggbeeswarm::geom_beeswarm(aes(color = variable), size = 1) +
    scale_color_manual(
      name = "Condition",
      values = c("OFF_AS" = colors[1], "OFF_SM" = colors[2], "ON__AS" = colors[1], "ON__SM" = colors[2])
    ) +
    theme(
      legend.position = "none",
      axis.title.x = element_text(size = 20),
      axis.title.y = element_text(size = 20),
      axis.text.x = element_text(size = 20),
      axis.text.y = element_text(size = 20),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    xlab("Condition") +
    ylab("Power (dB)") +
    geom_hline(yintercept = 0, linetype = "dotted", color = "#000000", size = 0.5) 










}