#############################################################################################
##                                                                                         ##
##                                     MAGIC  -  Test stat                                 ##
##                                                                                         ##
#############################################################################################

#############################################################################################
###### Initialisation
# DEFINE PATHS
rm(list = ls())
gc()

events  = c( "CUE", "FIX", "FO1", "FC1", "T0", "T0_EMG", "FO", "FC", "FOG_S", "FOG_E", "TURN_S", "TURN_E")
events  = c( "T0")
# events  = c( "CUE")

if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Indiv_GI"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/"
  sourcFile = "/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
} else {
  DataDir    = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  DataDir_GI = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
  OutputDir  = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Indiv_GI"
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
normtype = c('ldNOR')        # RAW or ldNOR
datatype = 'TF'              #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'
Montage  = 'extended'       # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'TF'             # 'TraceBrut' , 'TF',  'none'

# Contacts_of_interest = c("HotspotFOG","Motor") # Region + "HotspotFOG","Motor" or grouping + "HighestBeta" or "other" + "All"
# GroupingMode         = "Region"
Contacts_of_interest = c("STN-AS-exclusif") # Region + "HotspotFOG","Motor" or grouping + "HighestBeta" or "other" + "All"
GroupingMode         = "other"

reduced = TRUE
VerboseAnova         = FALSE      # Print anova results for each point, each var and interaction
PlotOnlyNoModel      = FALSE      # Load the workspace to only plot the model without computing it
todo_gifplot         = FALSE
todo_tfmapplot       = TRUE
todo_MaskPlot        = FALSE
todo_Plots           = todo_tfmapplot | todo_gifplot | todo_MaskPlot
Load_0Comput         = FALSE      # Only load result and not compute the whole model
Espacement_Freq      = "identity"    # arg for coord_trans : either "identity" or "log10"   => WORK ONLY WITH geom_tile() INSTEAD OF geom_raster(), WHICH IS MUCH SLOWER
PValueLimit          = 0.05
PValueBreaks         = c("none") # c(0.05, 0.01)    # Will show a separate line for all of these pvalue, by default : c(0.05, 0.01)
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



cl = makeCluster(detectCores())
if (Sys.info()["nodename"] == "UMR-LAU-WP011") {
  DataDir   = 'C:/LustreSync/TMP/analyses'
  OutputDir = "C:/LustreSync/03_CartesTF/Indiv_GI"
  MY_PatPCA = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
  MY_PatClin = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/MAGIC+GI_Clinical_scores.xlsx"      
  
  DataDir   = 'Z:/TMP/analyses'
  OutputDir = "Z:/03_CartesTF/Indiv_GI"
  MY_PatPCA = "Z:/DATA/ResAPA_32Pat_forPCA.xlsx" 
  MY_PatClin= "Z:/DATA/MAGIC+GI_Clinical_scores.xlsx"

  cl = makeCluster(detectCores()-2)
}
if (Sys.info()["nodename"] == "ICM-LAU-WF006") {
  DataDir   = 'Z:/TMP/analyses'
  OutputDir = "Z:/03_CartesTF/Indiv_GI"
  MY_PatPCA = "Z:/DATA/ResAPA_32Pat_forPCA.xlsx" 
  MY_PatClin= "Z:/DATA/MAGIC+GI_Clinical_scores.xlsx"
  cl = makeCluster(detectCores()-1)
}
registerDoParallel(cl)
clusterExport(cl, "LoadLibrary_and_RSourceFiles")
clusterEvalQ( cl,  LoadLibrary_and_RSourceFiles())

print("Some custom code can be found in Mathieu Yeche's PhD Scripts => Poster ECCN mai 2023")

if (PlotOnlyNoModel) { 
  todo_SMSfrequent = FALSE
  save.image(file = paste0(OutputDir, '/WorkSpace/Consignes.RData'))
}

nor = normtype
  for (Contact in Contacts_of_interest) { 
      # SET SUBJECT
      if (gp == 'MAGIC_Only') {
        subjects =
          c(
            'ALb_000a',
            'FEp_0536',   
            'VIj_000a',
            'DEp_0535',
            'GAl_000a',
            'SOh_0555',
            'GUg_0634',
            # "FRa_000a",
            # "SAs_000a",
            'FRj_0610'
          )
        
        listnameSubj =
          c(
            "ParkPitie_2020_06_25_ALb",
            "ParkPitie_2020_02_20_FEp",
            "ParkPitie_2021_04_01_VIj",
            "ParkPitie_2020_01_16_DEp",
            "ParkPitie_2020_09_17_GAl",
            "ParkPitie_2020_10_08_SOh",
            "ParkRouen_2020_11_30_GUg",
            # "ParkRouen_2021_10_04_FRa",
            # "ParkPitie_2021_10_21_SAs",
            "ParkRouen_2021_02_08_FRj"
          )
      }
      
      if (gp == 'STN') {
        subjects =
          c(
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
            "REa_0526",
            "SAs_000a",
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
            "ParkPitie_2020_01_09_REa",
            "ParkPitie_2021_10_21_SAs",
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
      
      #############################################################################################
      ###### Chargement du fichier
      
      ##LOAD DATA
      listname = matrix(NaN, nrow = 1, ncol = 15)
      iname = 1
      
      ev = events[1]

      for (ev in events) {
          
          if (!PlotOnlyNoModel) {
          if (ev ==  "FOG_S" ||  ev ==  "FOG_E") {
            subjects =
              c(
                'ALb_000a',
                'VIj_000a',
                'DEj_000a',
                'GAl_000a',
                'SAs_000a',
                #'FRa_000a',
                'GUg_0634',
                'GIs_0550',
                error('sujets ACC')
              )
            
            listnameSubj =
              c(
                "ParkPitie_2020_06_25_ALb",
                "ParkPitie_2021_04_01_VIj",
                "ParkPitie_2019_04_25_DEj",
                "ParkPitie_2020_09_17_GAl",
                "ParkPitie_2021_10_21_SAs",
                #  "ParkRouen_2021_10_04_FRa",
                "ParkRouen_2020_11_30_GUg",
                "ParkPitie_2020_07_02_GIs",
                error('sujets ACC')
              )
          }
          print(Sys.time())
          print(cat ('Nombre de sujets inclus : ', length(subjects), ' / Verifier que cela correspond au nombre attendu '))
                    
          if (!dir.exists(paste0(OutputDir, '/ModelOutputComportement/'))) {
              dir.create(paste0(OutputDir, '/ModelOutputComportement/'))
          } 
          if (!dir.exists(paste0(OutputDir, '/ModelOutput/'))) {
              dir.create(paste0(OutputDir, '/ModelOutput/'))
          } 
          if (!dir.exists(paste0(OutputDir, '/Tables/'))) {
              dir.create(paste0(OutputDir, '/Tables/'))
          }  
          if (!dir.exists(paste0(OutputDir, '/TF.dataframe/'))) {
              dir.create(paste0(OutputDir, '/TF.dataframe/'))
          } 
          if (!dir.exists(paste0(OutputDir, '/ModelOutput/', ev, '-', Contact,'/'))) {
            dir.create(paste0(OutputDir, '/ModelOutput/', ev, '-',  Contact,'/'))
          }


          # Initialisation des matrices de resultats 
          pval = data.frame()
          TFpw = data.frame()
          
          if (GroupingMode == "other"  ) {
              if ("All" != Contact) { 
                LocTable = readxl::read_excel("//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/MAGIC+GI_loc_electrodes.xlsx", sheet = 'LocSara')
              }
          }

          # Initialisationde la liste par Sujet
          TFbySubject = tibble()
          s_count = 0
          

          if(!file.exists(paste0(OutputDir, '/TF.dataframe/', 'TFbySubject_', Contact, '_', ev, '.csv'))){
            for (s in subjects) {

              
              # precise groupe of protocol : GI or GNG
              if (s == 'ParkPitie_2013_03_21_ROe' || s == 'ParkPitie_2013_04_04_REs' || s == 'ParkPitie_2013_06_06_SOj' || s == 'ParkPitie_2013_10_10_COd' || s == 'ParkPitie_2013_10_17_FRl'|| s == 'ParkPitie_2013_10_24_CLn' 
                  || s == 'ParkPitie_2014_04_18_MAd' || s == 'ParkPitie_2014_06_19_LEc' || s == 'ParkPitie_2015_01_15_MEp' || s == 'ParkPitie_2015_03_05_RAt' || s ==  'ParkPitie_2015_04_30_VAp' 
                  || s ==  'ParkPitie_2015_05_07_ALg' || s == 'ParkPitie_2015_05_28_DEm' || s == 'ParkPitie_2015_10_01_SAj') { 
                task_name = 'GI' 
                suff_name = ''
              } else { 
                task_name = 'GNG_GAIT'  
                suff_name = paste('_', Montage,'_', Artefact, sep="")
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
                TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_', 'dNOR', suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
                } else {
                TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_',   nor , suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
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

                if (grepl("inSTN", Contact)) {
                  StrToSearch = "STN"
                } else if (grepl("STN-AS", Contact)) {
                  StrToSearch = "AS"
                } else if (grepl("STN-SM", Contact)) {
                  StrToSearch = "SM"
                } else if (grepl("STNversus-exclusif", Contact)) { #exclusif needed below
                  StrToSearch = "STN"
                } else if (grepl("ZonaIncerta", Contact)) { #exclusif needed below
                  StrToSearch = "ZI"
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
                  if (grepl("ANTI", Contact)) {
                    e01D = !e01D ; e01G = !e01G ; e12D = !e12D ; e12G = !e12G ; e23D = !e23D ; e23G = !e23G
                  }
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
                  
                  if (grepl("ANTI", Contact)) {
                    TF1Pat = subset(TF1Pat,!(TF1Pat$Channel %in% realChan))
                  } else {
                    TF1Pat = subset(TF1Pat,  TF1Pat$Channel %in% realChan)
                  }

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
            
            AllAvailableTimePoints = data.frame(t(data.frame(colnames(TFbySubject))))
            timepoints_number      = ncol(TFbySubject) - 17
            
            data.table::fwrite(AllAvailableTimePoints, file = paste0(OutputDir, '/ModelOutput/', 'TimesNames', Contact, '_', ev, '.csv'))
            
            print(paste0('Nombre de patients : ', length(unique(TFbySubject$Patient)), ' pour une combinaison de ', 
              length(unique(paste0(TFbySubject$Patient , TFbySubject$Channel))), ' canaux / patients '))
            
            
            if (todo_corr_Comport || TRUE==TRUE) {            

              MY_APA = readxl::read_excel(MY_PatPCA, sheet = 1)
              MY_APA = MY_APA %>%
                  mutate( across(c(15:35),~as.numeric(as.character(.x))))

              MY_APA$is_FOG = as.factor(MY_APA$is_FOG)
              MY_APA$Meta_FOG = as.factor(MY_APA$Meta_FOG)


              # Si Subject a 3 lettres alors le copier dans le champ PatID, else 
              MY_APA$PatID = NA
              for (rownumAPA in 1:nrow(MY_APA)) { # nolint: seq_linter.
              if (nchar(MY_APA$Subject[rownumAPA]) == 3) {
                  MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 3, 3)))
              } else {
                  MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 4, 4)))
              }
              }
              MY_APA$Subject = MY_APA$PatID

              MY_APA$Groupe = ifelse((MY_APA$GoNogo == 'R' | MY_APA$GoNogo == 'S') , 'GI', 'MY')
              MY_APA$Groupe = as.factor(MY_APA$Groupe)
              MY_APA$GoNogo = as.factor(MY_APA$GoNogo)
              MY_APA$Subject = as.factor(MY_APA$Subject)

              
              IncludedValuesInPCA = c(1,2, 3,4,5,15:29, 31:35, 43) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
              QualitativeValuesInPCA = c(1, 2, 3, 4, 5, 43-17)
              ToNormalize = c(15, 19:22, 26, 28, 30:32)

              MY_APA_norm = MY_APA
              for (varnum in ToNormalize) {
                  MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] = 
                      (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] - 
                      mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE) ) /
                      sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE)

                  MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] = 
                      (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] - 
                      mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE) ) /
                      sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE)
              }


              All_APA_fitted = missMDA::imputePCA(MY_APA_norm[,IncludedValuesInPCA], 
                              quali.sup = QualitativeValuesInPCA , 
                              ncp = 5)$
                                  completeObs
              res_pca   = FactoMineR::PCA(All_APA_fitted, 
                              quali.sup = QualitativeValuesInPCA , 
                              ncp=9, 
                              scale.unit=TRUE, graph=FALSE)

              manual_todoPCAplot = FALSE
              if (manual_todoPCAplot) {

                plotIndPPT = function(ppt, res_pca, Grouping, Axe1, Axe2, paletteCouleur = "bpalette") {
                    plt = factoextra::fviz_pca_ind(res_pca,
                        geom.ind = "point", 
                        habillage = res_pca$call$quali.sup$quali.sup[[Grouping]],
                        #col.ind = APA$g, # colorer by groups
                        palette = paletteCouleur,
                        addEllipses = TRUE, # Ellipses de concentration
                        legend.title = "Groups",axes = c(Axe1, Axe2)
                        )
                        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
                        ppt = ph_with(ppt, value = plt, location = ph_location_fullsize())
                }

                VerifGeneralePCA = function(ppt, res_pca) {
                    Kaiser = factoextra::fviz_eig(res_pca, addlabels = TRUE, ylim = c(0, 50)) +
                    geom_abline(slope = 0,intercept = 10,color='red')+ 
                    theme_classic()+
                    ggtitle("Composantes principales")
                    
                    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
                    ppt = ph_with(ppt, value = Kaiser, location = ph_location_fullsize())

                    #Correlogrammes
                    COR1 = res_pca$var$coord[, 1:4]
                    COR2 = data.frame(COR1)
                    COR2$Var1 = rownames(COR2) # au lieu de COR2$Var1 =c( "Anteroposterior APA",    "Mediolateral APA "   , "1st Swing time"   ,    "Double Stance time"     ,      "2nd Swing time"   ,    "1st Stride time" ,"First step length"   ,"1st Swing speed"  ,     "1st step lateral speed"    , "Mean Speed during initiation", "Freq gait initiation" ,"Cadence" , "Center of Gravity",     "Max 1st swing vertical speed"  ,"1st contact vertical speed"  )
                    COR       = reshape2::melt(COR2) #pour metre les dimensions sur les lignes 
                    myPalette = grDevices::colorRampPalette(c("#281E78","#ffffff","#ffffff","#ffffff","#fa4616"))
                    cor = ggplot(COR,aes(x = variable, y = Var1, fill = value))+
                    geom_tile()+
                    # increase the y label text size
                    theme(axis.text.y = element_text(size = 500))+
                    theme(text = element_text(size = 500))+
                    scale_fill_gradientn(colours = myPalette(100),lim=c(-1,1))+
                    theme_classic()

                    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
                    ppt = ph_with(ppt, value = cor, location = ph_location_fullsize())
                }

                library(officer)
                library(magrittr)
                ppt = officer::read_pptx()

                VerifGeneralePCA(ppt, res_pca)

                plotIndPPT(ppt, res_pca, Grouping = 'Meta_FOG', Axe1 = 2, Axe2 = 1, paletteCouleur = c("#fa4616", "#d25736", "#281E78"))
                    
                plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
                plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
                plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

                plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
                plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
                plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

                plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
                plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
                plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")
              
                print(ppt, target = "C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/PCA_MYetACC_v2.pptx")

                        print("                                                                           ")
                        print("  --- NA in TFbySubject ---  ")
                        print(" List of Patients: ")
                        print(unique(TFbySubject$Patient[is.na(TFbySubject$FOG)]))
                        TFbySubject$Mcond = paste(TFbySubject$Medication,TFbySubject$Task, TFbySubject$nTrial, sep = '_')
                        for (patNA in unique(TFbySubject$Patient[is.na(TFbySubject$FOG)])) {
                          print("                                                                           ")
                          print(patNA)
                          print(unique(TFbySubject$Mcond[is.na(TFbySubject$FOG) & TFbySubject$Patient == patNA]))
                        }

              }

              pca = res_pca
              vecTF = paste0(sub(".*_", "", TFbySubject$Patient) , TFbySubject$Medication, TFbySubject$nTrial,'_', TFbySubject$Task)
              vecCA = paste0(pca$call$quali.sup$quali.sup$Subject, pca$call$quali.sup$quali.sup$Condition, pca$call$quali.sup$quali.sup$TrialNum, pca$call$quali.sup$quali.sup$GoNogo)
              vecTF = gsub("_fast", "R", vecTF)
              vecTF = gsub("_spon", "S", vecTF)
              vecTF = gsub("_GOc",  "C", vecTF)
              vecTF = gsub("_GOi",  "I", vecTF)
              indices_communs = match(vecTF, vecCA)
              
              TFbySubject$dimension1 = factoextra::get_pca_ind(pca)$coord[indices_communs, 1]
              TFbySubject$dimension2 = factoextra::get_pca_ind(pca)$coord[indices_communs, 2]
              TFbySubject$dimension3 = factoextra::get_pca_ind(pca)$coord[indices_communs, 3]
              TFbySubject$FOG        = pca$call$quali.sup$quali.sup$Meta_FOG[indices_communs]
              
              if (grepl("CalcDim", Contact)) {
                TFbySubject$dimension1 = factoextra::get_pca_ind(pca)$coord[indices_communs, 1] + factoextra::get_pca_ind(pca)$coord[indices_communs, 2] + factoextra::get_pca_ind(pca)$coord[indices_communs, 3] + (factoextra::get_pca_ind(pca)$coord[indices_communs, 5] + factoextra::get_pca_ind(pca)$coord[indices_communs, 4])*(-1)
                TFbySubject$dimension2 = factoextra::get_pca_ind(pca)$coord[indices_communs, 2] + factoextra::get_pca_ind(pca)$coord[indices_communs, 3]
                TFbySubject$dimension3 =(factoextra::get_pca_ind(pca)$coord[indices_communs, 5] + factoextra::get_pca_ind(pca)$coord[indices_communs, 4])*(-1)
              }
            }


            if (todo_corr_Clinique) {
              #Load
              Clinique = readxl::read_excel(MY_PatClin, sheet = 1)
              
              # Match each trial with its corresponding clinical row
              indices_communs = match(TFbySubject$Patient, Clinique$Code)

              # Reimplant the results in the LFP dataframe
              # U3 double on versus preop off
              dU3 = - Clinique$U3_preop_OFF + Clinique$U3_preop_ON
              TFbySubject$dU3 = dU3[indices_communs]
              
              if (todo_All_5ClinicTest) {
                # U3 double on versus preop off
                dU3II = - Clinique$U3_preop_OFF + Clinique$U3_M7M3_doubleON
                TFbySubject$dU3II = dU3II[indices_communs]

                # delta PDQ39 
                dP39 = Clinique$PDQ39_preop 
                TFbySubject$dP39 = dP39[indices_communs]
              }

              # delta FOG-Q 
              dFogQ = Clinique$FOGQ_preop_OFF 
              TFbySubject$dFogQ = dFogQ[indices_communs]

              # U3 correspondant (off/on)
              indices_communs_off = match(paste0(TFbySubject$Patient, TFbySubject$Medication), paste0(Clinique$Code, 'OFF'))
              indices_communs_on  = match(paste0(TFbySubject$Patient, TFbySubject$Medication), paste0(Clinique$Code, 'ON'))
              U3off = Clinique$U3_preop_OFF[indices_communs_off]
              U3on  = Clinique$U3_preop_ON[indices_communs_on]
              U3off[is.na(U3off)] = 0
              U3on[ is.na(U3on )] = 0
              U3merged = U3off + U3on
              U3merged[U3merged==0] = NA

              TFbySubject$U3 = U3merged

              # List of included Clinical test
              if (todo_All_5ClinicTest) {
                ClinicalTests = c('U3', 'dU3', 'dFogQ', 'dU3II', 'dP39')
              } else {
                ClinicalTests = c('U3', 'dU3', 'dFogQ')
              }
              
              # cor(Clinique$FOGQ_M7-Clinique$FOGQ_preop, Clinique$PDQ39_M7-Clinique$PDQ39_preop, use = "complete.obs", method = "spearman")
              
            }

            # Ajustement Meta FOG pour patients dont les données comportementales sont manquantes
            TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2015_05_07_ALg" | TFbySubject$Patient == "ParkPitie_2015_05_28_DEm" | TFbySubject$Patient == "ParkPitie_2020_10_08_SOh" | TFbySubject$Patient == "ParkPitie_2015_03_05_RAt" | TFbySubject$Patient == "ParkPitie_2013_06_06_SOj" | TFbySubject$Patient == "ParkPitie_2015_04_30_VAp"] = "Meta_FOG_0"
            TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Patient == "ParkPitie_2015_10_01_SAj")] = "Meta_FOG_1"
            # ROYO E.
            TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Patient == "ParkPitie_2013_03_21_ROe")] = "Meta_FOG_1"
            TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2013_03_21_ROe" & TFbySubject$Medication == "OFF"  & TFbySubject$Task == "spon" & (TFbySubject$nTrial == 1 | TFbySubject$nTrial == 3 | TFbySubject$nTrial == 4 | TFbySubject$nTrial == 6 | TFbySubject$nTrial == 7 | TFbySubject$nTrial == 8 | TFbySubject$nTrial == 9 | TFbySubject$nTrial == 10 | TFbySubject$nTrial == 11 | TFbySubject$nTrial == 12 | TFbySubject$nTrial == 13 | TFbySubject$nTrial == 14 | TFbySubject$nTrial == 15 | TFbySubject$nTrial == 19 | TFbySubject$nTrial == 20)] = "Meta_FOG_2"
            # Claivaz N.
            TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Patient == "ParkPitie_2013_10_24_CLn")] = "Meta_FOG_1"
            TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2013_10_24_CLn" & TFbySubject$Medication == "OFF"  & TFbySubject$Task == "spon" & (TFbySubject$nTrial == 19 )] = "Meta_FOG_2"
            TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2013_10_24_CLn" & TFbySubject$Medication == "OFF"  & TFbySubject$Task == "fast" & (TFbySubject$nTrial == 6 | TFbySubject$nTrial == 7 )] = "Meta_FOG_2" 


            # Save the LFP dataframe
            vroom::vroom_write(TFbySubject, file = paste0(OutputDir, '/TF.dataframe/', 'TFbySubject_', Contact, '_', ev, '.csv'), delim = ";")

          } else { 
            TFbySubject = vroom::vroom(     file = paste0(OutputDir, '/TF.dataframe/', 'TFbySubject_', Contact, '_', ev, '.csv'))
            AllAvailableTimePoints = vroom::vroom(     file = paste0(OutputDir, '/ModelOutput/', 'TimesNames', Contact, '_', ev, '.csv'))
            timepoints_number      = ncol(AllAvailableTimePoints) - 17 
          }
          
          # timeOfPassage = Sys.time()
          # 
          # for (Freqpoint in as.numeric(fqStart):100) {
          #   # print(paste0('##### ',Freqpoint, 'Hz ##### ', Sys.time(), ' /// temps last freq : ', round(Sys.time()-timeOfPassage, digits = 2), ' min'))
          #   # timeOfPassage = Sys.time()
          #   
          #   for (timefreq in 1:timepoints_number) {
          #     
                   
              if (RestrictTimeCalculated) {
                colname   = colnames(TFbySubject)[18:(17+timepoints_number)]
                timepoint = gsub("x_", "-", colname, fixed = TRUE)
                timepoint = gsub("_" , ".", timepoint)
                timepoint = gsub("x" , "" , timepoint)
                timepoint = as.numeric(timepoint)
                # Trouver le plus proche de 1 et de -1
                firstIncludedTP = which(timepoint >= -1)[1] -1
                lastIncludedTP = which(timepoint >= 1)[1]
                
              } else {
                firstIncludedTP = 1
                lastIncludedTP = timepoints_number
              } 

              TFbySubject = TFbySubject[complete.cases(TFbySubject[, firstIncludedTP:lastIncludedTP]), ]

 
            Case = 'Vanilla'
            Suf_Case = ''
         

          MAGIC_Colormap = function(Case) {
              if (Case == 'Vanilla') {
                  colormap_to_use  =
                      grDevices::colorRampPalette(
                          c(
                              "#00007F",
                              "blue",
                              "#007FFF",
                              "cyan",
                              "#7FFF7F",
                              "yellow",
                              "#FF7F00",
                              "red",
                              "#7F0000"
                          )
                      )

               
              }
              
              return(colormap_to_use)
          }
          colormap_to_use = MAGIC_Colormap(Case)
          missingValuesColor = "black"
          
          if (PValueBreaks[1] == "none" || length(PValueBreaks) == 0 ) {
            PValueBreaks = c(-1)
            colorpval1 = "black"
            colorpval2 = "black"
          } else {
            colorpval1 = "white"
            colorpval2 = "black"
          }


          for (folderName in unique(TFbySubject$FOG)) {
            if (!dir.exists(paste0(OutputDir, '/', folderName))) {
                 dir.create(paste0(OutputDir, '/', folderName))
            }
          }

            #######################################################################################################
            ## PLOTS ##############################################################################################
            #######################################################################################################
            
              
TFbySubject$Mcond = paste(TFbySubject$Patient, TFbySubject$Medication,TFbySubject$Task, TFbySubject$nTrial, TFbySubject$Channel, TFbySubject$FOG, sep = '_')
 
              foreach(MetCondnum = 1:length(unique(TFbySubject$Mcond))) %dopar% { # nolint
                
                localTF = subset(TFbySubject, Mcond == unique(TFbySubject$Mcond)[MetCondnum])
               
                MetCond  = unique(TFbySubject$Mcond)[MetCondnum]

                PlotName = paste0('TF_', ev, '_', Contact, '_', MetCond )
                PlotFolder  = paste0('/', unique(localTF$FOG), '/', Contact, '/')
                if (!dir.exists(paste0(OutputDir, PlotFolder))) {
                dir.create(paste0(OutputDir, PlotFolder))
                }
                
                print(paste0('PLOTS : Metacondition ', MetCondnum, ' sur ', length(unique(TFbySubject$Mcond)), ' ----- ', Sys.time()))
                
                # Preparer la table
                data = data.frame(Freq = numeric(0), Time = numeric(0), Power = numeric(0))
                
                #Recuperer les parametres de temps et frequence
                for (colnum in 18:120){
                  timepoint = colnames(localTF)[colnum]
                  timepoint = gsub("x_", "-", timepoint, fixed = TRUE)
                  timepoint = gsub("_" , ".", timepoint)
                  timepoint = gsub("x" , "" , timepoint)
                  timepoint = as.numeric(timepoint)
                  
                  for (rownum in 1:nrow(localTF)) {
                    data                    = add_row(data)
                    data$Freq[  nrow(data)] = localTF$Freq[rownum]
                    data$Time[  nrow(data)] = timepoint
                    data$Power[ nrow(data)] = 10*log10(as.numeric(localTF[rownum,colnum]))
                  }

                }  # end for (colnum...)
                
                ## Plot Image fixe
                
                if (todo_tfmapplot) {
                  
                  data = subset(data, (data$Time >= -1 & data$Time <= 1))
                  lim  = max(abs(data$Power))

                  # Data final preprocessing
                  if (Case == "Vanilla") { # Not used for now
                    lim  = 16
                  }
                  

                  # Plot
                  ggplot(data, aes(x = Time, y = Freq, fill = Power)) +
                    # coord_trans(y = Espacement_Freq) +              # scale en log10
                    geom_raster(interpolate = TRUE) + 
                    scale_fill_gradientn(colours = colormap_to_use(100), lim = c(-lim, lim), na.value = missingValuesColor) +
                    geom_vline(xintercept = 0, linewidth = .2) +         # add a vertical line at x = 0
                    #  ggtitle(PlotName) + theme(plot.title = element_text(hjust = 0.5)) + # center the plot title
                    theme_classic() 
                    #geom_hline(yintercept = 12, linetype = "dashed", color = "#000000", size = 0.5) +
                    #geom_hline(yintercept = 35, linetype = "dashed", color = "#000000", size = 0.5) +
                    
                  ## sauvegarde des graphes
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '.png'), width = FigWidth, height = FigHigh, units = "cm")
                # ggsave(paste0(OutputDir, PlotFolder , PlotName, '.svg'), width = FigWidth, height = FigHigh, units = "cm")
                }  # end fixed image plot
                
              } # end for MetCond
              rm(data)
              print(paste0("success" , Suf_Case))
            } #end plot
            
          } # end for ResPar
          
        } # end for event
    

stopCluster(cl)



#############################################################################################
###### Sortie


print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")

IdForNotification = paste(ev,collapse ="_")
Timing = format(Sys.time(), "%F_%H-%M-%S")
filename = paste(LogDir, Timing, "-R_Stats" , IdForNotification , "SUCCESS", ".txt",sep = "")
fileSuccess=file(filename)
writeLines("Hello", fileSuccess)#aa9898#bd2d2d
close(fileSuccess)

if (Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006") {
  system(paste0('matlab -nodisplay -nosplash -nodesktop -r \" addpath(\'\\\\l2export\\iss02.home\\mathieu.yeche\\Cluster\\Matlab\') ; SMS_Mathieu(\'R_Stats Fin du script : SUCCESS !!!\');exit\"'))
}
