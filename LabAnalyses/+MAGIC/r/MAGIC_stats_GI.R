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
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/"
  sourcFile = "/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
} else {
  DataDir    = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  DataDir_GI = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
  OutputDir  = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats_GI"
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
Contacts_of_interest = c("STNversus-exclusif","STN-SM-exclusif", "inSTN-exclusif", "STN-AS-exclusif","All") # Region + "HotspotFOG","Motor" or grouping + "HighestBeta" or "other" + "All"
GroupingMode         = "other"

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
  OutputDir = "C:/LustreSync/03_CartesTF/Stats_GI"
  MY_PatPCA = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
  MY_PatClin = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/MAGIC+GI_Clinical_scores.xlsx"      
  
  DataDir   = 'Z:/TMP/analyses'
  OutputDir = "Z:/03_CartesTF/Stats_GI"
  MY_PatPCA = "Z:/DATA/ResAPA_32Pat_forPCA.xlsx" 
  MY_PatClin= "Z:/DATA/MAGIC+GI_Clinical_scores.xlsx"

  cl = makeCluster(detectCores()-2)
}
if (Sys.info()["nodename"] == "ICM-LAU-WF006") {
  DataDir   = 'Z:/TMP/analyses'
  OutputDir = "Z:/03_CartesTF/Stats_GI"
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
Contact = Contacts_of_interest[1]
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

                  listToExclude = realChan[!(listChan %in% c("01D", "11D", "12D", "22D", "23D", "01G", "11G", "12G", "22G", "23G"))]
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
                    TF1Pat = subset(TF1Pat,!(TF1Pat$Channel %in% listToExclude))
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


ResPar = foreach(Freqpoint = as.numeric(fqStart):100, .combine = 'rbind') %:%   # Execution en parallele, variable de sortie = ResPar 
            foreach(timefreq = firstIncludedTP:lastIncludedTP, .combine = 'rbind') %dopar% {
                             
              cat(paste0(Freqpoint, 'Hz : temps ', timefreq, ' sur ', timepoints_number, ' ----- ', Sys.time()))
              flush.console()
              if (!Load_0Comput) {
                
                # Recuperation du temps frequence
                DAT_LFP = subset(TFbySubject, TFbySubject$Freq == Freqpoint)
                if (ncol(DAT_LFP) == 17+timepoints_number) {
                  DAT_LFP = subset(DAT_LFP, select = c(1:17, timefreq+17)) # keep only 1 timepoint
                } else {
                  DAT_LFP = subset(DAT_LFP, select = c(1:17, timefreq+17, (17+timepoints_number+1):ncol(DAT_LFP))) # keep only 1 timepoint
                }
                
                ## Standadisation des donnees en input
                
                # Nom des variables
                timeName = colnames(DAT_LFP)[18]
                colnames(DAT_LFP)[18] = "value"
                if (GroupingMode == "Region"  ) {DAT_LFP$group = DAT_LFP$Region  }  
                if (GroupingMode == "grouping") {DAT_LFP$group = DAT_LFP$grouping} 
                if (GroupingMode == "other"   ) {DAT_LFP$group = Contact         }
                
                # Transformation en variable numerique de la valeur
                DAT_LFP %>% mutate(num = as.numeric(value)) %>% filter( (is.na(num) & !is.na(value)) | (!is.na(num) & is.na(value)) ) %>% select(Patient, value, num)
                DAT_LFP$value = as.numeric(DAT_LFP$value)
                
                # Remove NA
                if (!stringr::str_detect(ev, 'FC') || !stringr::str_detect(ev, 'FO')) { 
                  DAT_LFP$side = ifelse(is.na(DAT_LFP$side), "None", DAT_LFP$side) # Embetant pour certains events mais pas tous
                } 
                DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "Medication", "Task", "side", "Channel", "nTrial", "value")]), ]
                DAT_LFP = transform(transform(transform(DAT_LFP, 
                                                        hemisphere  = ifelse(stringr::str_detect(Channel, 'D'), 'R',  ifelse(stringr::str_detect(Channel, 'G'), 'L' , NA))), 
                                              ipsi_contra = ifelse(hemisphere == side, 'ipsi', ifelse(side == "None", 'None', 'contra'))),
                                    MetaCond    = paste( group, Event, Medication, Task, hemisphere, ipsi_contra, sep = '_'))  
                
                #######################################################################################################
                ## STATS ##############################################################################################
                #######################################################################################################
                
                # Preparation de la matrice de sortie
                Stats = reshape2::dcast(ddply(ddply(DAT_LFP,
                                          .(MetaCond, Patient), summarise, Patient = unique(Patient)), 
                                    .(MetaCond), mutate, nb_Patient = length(unique(Patient))) 
                              %>% arrange(desc(nb_Patient)), MetaCond + nb_Patient ~ Patient, fun.aggregate = length) 
                Stats = transform(Stats, 
                                  evenement  = unique(DAT_LFP$Event), 
                                  position   = unique(DAT_LFP$Freq),
                                  time       = timeName,
                                  group      = sapply(strsplit(MetaCond, '_'), '[[', 1), 
                                  Medication = sapply(strsplit(MetaCond, '_'), '[[', 3), 
                                  Task       = sapply(strsplit(MetaCond, '_'), '[[', 4),
                                  hemisphere = sapply(strsplit(MetaCond, '_'), '[[', 5),
                                  ipsi_contra= sapply(strsplit(MetaCond, '_'), '[[', 6))
                
                
                if (!grepl('STNversus', Contact) && !grepl('Indiv', Contact)) {

                # Modèle 
                model = lme4::lmer(10*log(value,base=10) ~ FOG + Medication*Task*hemisphere*ipsi_contra + nStep + (1|Patient/Channel), data = DAT_LFP)
                # 10*log(value,base=10) transforme en dB, pas d'outlier trop transformés, distribution gaussienne 
                # Medication*Task       Paradigme experimental
                # hemisphere 
                # ipsi_contra           Que dans ce modèle et pas en dessous, ou on supprime cette var. En interaction avec hémisphère et med
                # nStep                 Lorsqu'il y a plusieurs fois l'evenement dans 1 Trial (FO, FC, FOG)
                # (1|Patient/Channel)   Generalement, 1 seul channel par evenement (generalement)
                
                # NON PRIS EN COMPTE : 
                # nTrial                ne semble pas avoir une influence tres importante (et extrêmement corrélé à Task)
                # grouping              peu de diff entre les diff sites possible d'enregistrement sur l electrode
                # Run                   variable technique indiquant la division du fichier d'enregistrement
          
                if (VerboseAnova == TRUE) {
                  print(paste0( Contact, ev, ' Freq', Freqpoint, 'Time', timeName ))
                  car::Anova(model)          #For Visual inspection
                  print(' ')
                  performance::check_model(model)  
                } 
                
                # Insertion dans la matrice de sortie
                
                # 1) 
                # Toutes les variables :
                # toutes les conditions
                EMMean  = emmeans(model, ~  Medication*Task*hemisphere*ipsi_contra)        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres 
                emmean  = data.frame(EMMean)
                emGlobal= data.frame(contrast(EMMean,       
                                              setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))),  # nolint
                                                        apply(       emmean , 1, function(x) paste(x[1], x[2], x[3], x[4], sep = '_')))))
                # OFF - ON
                emmMED  = data.frame(contrast(EMMean,        
                                              setNames(lapply(1:(nrow(emmean)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emmean)/2-i), rep(0, nrow(emmean)/2-i))),                                                  # nolint 
                                                       lapply(1:(nrow(emmean)/2),   function(i)   paste(paste0(emmean[i*2-1,1], '-',emmean[i*2,1]), emmean[i*2,2], emmean[i*2,3], emmean[i*2,4], sep = '_')))))                             # nolint
                
                # 2)                
                # AllInOne 
                # Deux approches : un modele avec parametres reduit ou un t.test simple contre 0
                model2   = lme4::lmer(10*log(value,base=10) ~ hemisphere + (1|Patient/Channel)+ (1|Task) + (1|hemisphere), data = DAT_LFP)
                EMMean  = emmeans(model2, ~  hemisphere)      
                emmean  = data.frame(EMMean)
                emmALL  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                              lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelOld')))))
                tresult = t.test(10*log10(DAT_LFP$value))
                temp.df = data.frame(contrast = "AllInOne-ttest", 
                        estimate = tresult$estimate, 
                        SE = tresult$stderr,
                        df = tresult$parameter, 
                        z.ratio = tresult$statistic, 
                        p.value = tresult$p.value)
                model2   = lme4::lmer(10*log(value,base=10) ~ hemisphere + (1|Patient/Channel)+ (1|Task) + (1|Medication), data = DAT_LFP)
                EMMean  = emmeans(model2, ~  hemisphere)      
                emmean  = data.frame(EMMean)
                emmAL2  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                              lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelNew')))))                
                EMMean  = emmeans(model2, ~  hemisphere, at = list(Medication = "OFF"))      
                emmean  = data.frame(EMMean)
                emmAL3  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                              lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelNOFF')))))
                emmALL = rbind(emmALL, temp.df, emmAL2, emmAL3)
                rownames(emmALL) = NULL

                # 3)
                # ON vs OFF : Effet fixe de la dopa
                EMBBase = emmeans(model, ~  Medication) 
                emBBase = data.frame(EMBBase)
                emOIall = data.frame(contrast(EMBBase,        
                                              setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                        apply(       emBBase , 1, function(x) paste(x[1], 'AllCond', sep = '_')))))
                emdOIall  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                              setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                       lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), 'AllCond', sep = '_'))))) # nolint
                
                # 4)
                # FOG VERSUS NO FOG
                EMMean  = emmeans(model, ~ FOG, at = list(Medication = "OFF"))      
                emmean  = data.frame(EMMean)
                emVersus= data.frame(contrast(EMMean,       
                                              setNames(lapply(1:1, function(i) c(0.5, 0.5, -1)), 
                                                       lapply(1:1, function(i) paste0('FoGVersus')))))
                # All type of MetaFOG
                emFOG = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                        apply(       emmean , 1, function(x) paste(x[1], sep = '_')))))
                
                # 5)
                # ON - OFF per Task
                EMBBase = emmeans(model, ~  Medication*Task)
                emBBase = data.frame(EMBBase)
                emOItask = data.frame(contrast(EMBBase,        
                                              setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                        apply(       emBBase , 1, function(x) paste(x[1], x[2], sep = '_')))))
                emdOItask  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                              setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                       lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), emBBase[i*2,2], sep = '_'))))) # nolint

                # 6)
                # Ipsi Contra interraction ON OFF
                EMBBase = emmeans(model, ~  Medication*ipsi_contra)
                emBBase = data.frame(EMBBase)
                emOIside = data.frame(contrast(EMBBase,        
                                              setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                        apply(       emBBase , 1, function(x) paste(x[1], x[2], sep = '_')))))
                emdOIside  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                              setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                       lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), emBBase[i*2,2], sep = '_'))))) # nolint

                # 7)
                # Ipsi Contra effet fixe seul
                EMBBase = emmeans(model, ~  ipsi_contra)
                emBBase = data.frame(EMBBase)
                emside = data.frame(contrast(EMBBase,        
                                              setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                        apply(       emBBase , 1, function(x) paste(x[1], sep = '_')))))
                emdside  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                              setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                       lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), sep = '_'))))) # nolint

                
                
              # Put all pvalues in ModelOutput
                rm(ModelOutput)
                emGlobal$categ = 'NoContrast'
                emmMED$categ   = 'OFF-ON-NoContrast'
                emmALL$categ   = 'AllInOne'
                emOIall$categ  = 'OFF-ON-AllCond'
                emdOIall$categ = 'OFF-ON-DeltaAllCond'
                emVersus$categ = 'FOGVersus'
                emFOG$categ    = 'FOG'
                emOItask$categ = 'Task'
                emdOItask$categ= 'OFF-ON-Task'
                emOIside$categ = 'IpsiContra-perONOFF'
                emdOIside$categ= 'OFF-ON-IpsiContra'
                emside$categ   = 'IpsiContra'
                emdside$categ  = 'Ipsi-vs-Contra'
                
                ModelOutput = rbind(emGlobal, emmMED, emmALL, emOIall, emdOIall, emVersus, emFOG, emOItask, emdOItask, emOIside, emdOIside, emside, emdside)
                
                } else if (grepl('STNversus', Contact)) {
                  
                  if (grepl('freezers', Contact)) {
                    DAT_LFP$Region = as.factor(DAT_LFP$Region)
                    DAT_LFP = subset(DAT_LFP, DAT_LFP$FOG != 'Meta_FOG_0')
                    model = lme4::lmer(10*log(value,base=10) ~ Region*FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                        EMMean  = emmeans(model, ~ Region*FOG, at = list(Medication = "OFF"))  
                        emmean  = data.frame(EMMean)
                        emNoCont = data.frame(contrast(EMMean,       
                                                    setNames(lapply(1:nrow(emmean),  function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                            apply(       emmean , 1, function(x) paste(x[1], x[2], sep = '_')))))
                        emVerFog = data.frame(contrast(EMMean,       
                                                    setNames(lapply(1:(nrow(emmean)/2),   function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)/2-i), rep(0, i-1), -1, rep(0, nrow(emmean)/2-i))), # nolint
                                                            lapply(1:(nrow(emmean)/2),   function(i) paste(paste0(emmean[i,2], '-',emmean[i+nrow(emmean)/2,2]), 'inRegion', emmean[i,1], sep = '_')))))       # nolint
                        emVerFReg= data.frame(contrast(EMMean,
                                                    setNames(lapply(1:(nrow(emmean)/3),   function(i) c(rep(0, (i-1)*3), 1, 0, -1, rep(0, nrow(emmean)/2-(i-1)*3))), # nolint
                                                            lapply(1:(nrow(emmean)/3),   function(i) paste(paste0(emmean[i*3-2,1], '-',emmean[i*3,1]), 'for', emmean[i*3,2], sep = '_')))))       # nolint
                    
                    rm(ModelOutput)
                    ModelOutput = rbind(emNoCont, emVerFog, emVerFReg)
                    ModelOutput$categ = 'FOGversus'

                  } else {
                    DAT_LFP$Region = as.factor(DAT_LFP$Region)
                    # Effet fixe :
                    model = lme4::lmer(10*log(value,base=10) ~ Region + FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                        EMMean  = emmeans(model, ~ Region)      
                        emmean  = data.frame(EMMean)
                        emVersus= data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                              lapply(1:1, function(i) paste0('AS-SM_all_fixedeffect')))))
                        emReg = data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                apply(       emmean , 1, function(x) paste(x[1], 'allMed_fixedeffect', sep = '_')))))
                        
                        EMMean  = emmeans(model, ~ Region, at = list(Medication = "OFF"))      
                        emmean  = data.frame(EMMean)
                        emVerOFF= data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                              lapply(1:1, function(i) paste0('AS-SM_OFF_fixedeffect')))))
                        emRegOFF= data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                apply(       emmean , 1, function(x) paste(x[1], 'OFF_fixedeffect', sep = '_')))))

                    # FOG:
                    DAT_LFP$FOG = as.character(DAT_LFP$FOG)
                    DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_0'] = 'NoFOG'
                    DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_1'] = 'NoFOG'
                    DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_2'] = 'FOG'
                    DAT_LFP$FOG = as.factor(DAT_LFP$FOG)

                    model = lme4::lmer(10*log(value,base=10) ~ Region*FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                        EMMean  = emmeans(model, ~ Region*FOG, at = list(Medication = "OFF"))  
                        emmean  = data.frame(EMMean)
                        emNoCont = data.frame(contrast(EMMean,       
                                                    setNames(lapply(1:nrow(emmean),  function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                            apply(       emmean , 1, function(x) paste(x[1], x[2], sep = '_')))))
                        emVerFog = data.frame(contrast(EMMean,       
                                                    setNames(lapply(1:(nrow(emmean)/2),   function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)/2-i), rep(0, i-1), -1, rep(0, nrow(emmean)/2-i))), # nolint
                                                            lapply(1:(nrow(emmean)/2),   function(i) paste(paste0(emmean[i,2], '-',emmean[i+nrow(emmean)/2,2]), 'inRegion', emmean[i,1], sep = '_')))))       # nolint
                        emVerFReg= data.frame(contrast(EMMean,
                                                    setNames(lapply(1:(nrow(emmean)/3),   function(i) c(rep(0, (i-1)*3), 1, 0, -1, rep(0, nrow(emmean)/2-(i-1)*3))), # nolint
                                                            lapply(1:(nrow(emmean)/3),   function(i) paste(paste0(emmean[i*3-2,1], '-',emmean[i*3,1]), 'for', emmean[i*3,2], sep = '_')))))       # nolint
                    
                    # All effects: 
                    model   = lme4::lmer(10*log(value,base=10) ~ Region + (1|Patient/Channel)+ (1|Task) + (1|hemisphere) + (1|Medication), data = DAT_LFP)
                        EMMean  = emmeans(model, ~ Region)      
                        emmean  = data.frame(EMMean)
                        emVersus2= data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                              lapply(1:1, function(i) paste0('AS-SM_all_onlyeffect')))))
                        emReg2 = data.frame(contrast(EMMean,       
                                                    setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                              apply(       emmean , 1, function(x) paste(x[1], 'allMed_onlyeffect', sep = '_')))))
                      
                        EMMean  = emmeans(model, ~ Region, at = list(Medication = "OFF"))      
                        emmean  = data.frame(EMMean)
                        emVerOFF2= data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                              lapply(1:1, function(i) paste0('AS-SM_OFF_onlyeffect')))))
                        emRegOFF2= data.frame(contrast(EMMean,       
                                                      setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                apply(       emmean , 1, function(x) paste(x[1], 'OFF_onlyeffect', sep = '_')))))

                    rm(ModelOutput)
                    ModelOutput = rbind(emVersus, emReg, emVerOFF, emRegOFF, emNoCont, emVerFog, emVerFReg, emVersus2, emReg2, emVerOFF2, emRegOFF2)
                    ModelOutput$categ = 'STNversus'
                    }
                  } else if (grepl('Indiv', Contact)) {
                      todo_corr_Clinique = FALSE
                      todo_corr_Comport  = FALSE

                      rm(ModelOutput)

                      for (patID in unique(DAT_LFP$Patient)) {
                        DAT_Pat = DAT_LFP[DAT_LFP$Patient == patID, ]
                          
                          DAT_Pat$value = 10*log10(DAT_Pat$value)

                          tmp1 = data.frame(contrast = "MeanALL", 
                                estimate = mean(DAT_Pat$value, na.rm = TRUE), 
                                SE = 1, df = 0, t.ratio = 0, p.value = 0)

                          tmp2 = data.frame(contrast = "MeanOFF", 
                                estimate = mean(DAT_Pat$value[DAT_Pat$Medication == "OFF"], na.rm = TRUE), 
                                SE = 1, df = 0, t.ratio = 0, p.value = 0)

                          tmp3 = data.frame(contrast = "MeanON", 
                                estimate = mean(DAT_Pat$value[DAT_Pat$Medication == "ON"], na.rm = TRUE), 
                                SE = 1, df = 0, t.ratio = 0, p.value = 0)

                          rm(tmp4)
                          for (metaf in unique(DAT_Pat$FOG) ) {
                            NameCase = paste0('MeanFog', readr::parse_number(metaf))
                            tmp41 = data.frame(contrast = NameCase, 
                                estimate = mean(DAT_Pat$value[DAT_Pat$FOG == metaf], na.rm = TRUE), 
                                SE = 1, df = 0, t.ratio = 0, p.value = 0)

                            if (!exists("tmp4")) {
                              tmp4 = tmp41
                            } else {
                              tmp4 = rbind(tmp4, tmp41)
                            }
                          }

                          emGlobal = rbind(tmp1, tmp2, tmp3, tmp4)
                          rownames(emGlobal) = NULL
                          
                        # Try catch loop
                        ModelOutputLocal = tryCatch({
                          model = lme4::lmer(value ~ FOG + Medication*Task*hemisphere*ipsi_contra + nStep + (1|hemisphere), data = DAT_Pat)
                          
                          # AllInOne 
                          model2   = lme4::lmer(value ~ hemisphere + (1|hemisphere)+ (1|Task) , data = DAT_Pat)
                          EMMean  = emmeans(model2, ~  hemisphere)      
                          emmean  = data.frame(EMMean)
                          emmALL  = data.frame(contrast(EMMean,       
                                                        setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                        lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelOld')))))
                          # ON vs OFF : Effet fixe de la dopa
                          EMBBase = emmeans(model, ~  Medication) 
                          emBBase = data.frame(EMBBase)
                          emOIall = data.frame(contrast(EMBBase,        
                                                        setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                                  apply(       emBBase , 1, function(x) paste(x[1], 'AllCond', sep = '_')))))
                          
                          # FOG VERSUS NO FOG
                          EMMean  = emmeans(model, ~ FOG, at = list(Medication = "OFF"))      
                          emmean  = data.frame(EMMean)
                          emFOG = data.frame(contrast(EMMean,       
                                                        setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                  apply(       emmean , 1, function(x) paste(x[1], sep = '_')))))
                          
                          emGlobal$categ = 'MeanNoModel'
                          emmALL$categ   = 'AllInOne'
                          emOIall$categ  = 'OFF-ON-AllCond'
                          emFOG$categ    = 'FOG'
                          
                          ModelOutputLocal = rbind(emGlobal, emmALL, emOIall, emFOG)
                          ModelOutputLocal
                      } , error = function(e) {
                        emGlobal$categ = 'MeanNoModel'
                        emGlobal
                      })

                          ModelOutputLocal$categ = paste0('Indiv-', ModelOutputLocal$categ)
                          ModelOutputLocal$contrast = paste0(ModelOutputLocal$contrast ,'-', patID)
                          
                          if (!exists("ModelOutput")) {
                            ModelOutput = ModelOutputLocal
                          } else {
                            ModelOutput = rbind(ModelOutput, ModelOutputLocal)
                          }
                      }

                } # end if (Contact = STNversus)

                ModelOutput = ModelOutput[stats::complete.cases(ModelOutput[, c("estimate", "contrast", "df")]), ]
                
                
                # Save
                data.table::fwrite(Stats,       file = paste0(OutputDir, '/Tables/',      Contact, ev, '-Freq', Freqpoint, '-Time_', timeName, 'Stats.csv'))
                data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutput/', ev, '-',  Contact,  '/Freq', Freqpoint, '-Time_', timeName, 'ModelOutput.csv'))
              
              } else { # else de if(!Load_0Comput)
                timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutput/', ev, '-',  Contact, '/Freq', Freqpoint, '-Time_', timeName, 'ModelOutput.csv'))
              }
              
              ## Pass to next step (plots)
               
                pval = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                TFpw = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                
                
              # initialize first column
              if (dim(pval)[2] == 0) {
                while (dim(pval)[1] < length(ModelOutput$contrast)) {
                  pval = tibble::add_row(pval)
                  TFpw = tibble::add_row(TFpw)
                }
                pval$categ    = ModelOutput$categ
                TFpw$categ    = ModelOutput$categ
                pval$MetaCond = ModelOutput$contrast
                TFpw$MetaCond = ModelOutput$contrast
              }
              
              # Assign Values
              pval[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$p.value
              TFpw[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$estimate
               
              ## Variables comportementales
              if (todo_corr_Comport) {
                DAT_LFPsave = DAT_LFP
                DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "value", "dimension1")]), ]
                
                for (dimension in 1:3) {
                  remove(ModelOutput)
                  if (!Load_0Comput) {
                    DAT_LFP$Comportement = NULL
                    DAT_LFP$Comportement = DAT_LFP[[ paste0('dimension', dimension)]]  
                    
                    if (!grepl('STNversus', Contact)) {

                    # Model + emTrends
                    model  = lme4::lmer(10*log(value,base=10) ~ FOG + Comportement*Medication*Task*hemisphere*ipsi_contra + nStep + (1|Patient/Channel), data = DAT_LFP)
                    EMMean = emtrends(model, ~ Medication*Task*hemisphere*ipsi_contra, var="Comportement")

                    emmean  = data.frame(EMMean)
                    emGlobal= data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))),  # nolint
                                                            apply(       emmean , 1, function(x) paste(x[1], x[2], x[3], x[4], sep = '_')))))
                    
                    # 2)                
                    # AllInOne 
                    # Deux approches : un modele avec parametres reduit ou un t.test simple contre 0
                    model2   = lme4::lmer(10*log(value,base=10) ~ Comportement*hemisphere + (1|Patient/Channel)+ (1|Task)+ (1|hemisphere), data = DAT_LFP)
                    EMMean  = emtrends(model2, ~  hemisphere, var="Comportement")      
                    emmean  = data.frame(EMMean)
                    emmALL  = data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                  lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelOld')))))
                    tresult = cor.test(10*log10(DAT_LFP$value), DAT_LFP$Comportement, method = "spearman")
                    temp.df = data.frame(contrast = "AllInOne-spearman", 
                            estimate = tresult$estimate, 
                            SE = 1,
                            df = 0, 
                            z.ratio = tresult$statistic, 
                            p.value = tresult$p.value)
                    model2   = lme4::lmer(10*log(value,base=10) ~ Comportement*hemisphere + (1|Patient/Channel)+ (1|Task) + (1|Medication), data = DAT_LFP)
                    EMMean  = emtrends(model2, ~  hemisphere, var="Comportement")      
                    emmean  = data.frame(EMMean)
                    emmAL2  = data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                  lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelNew')))))                
                    EMMean  = emtrends(model2, ~  hemisphere, at = list(Medication = "OFF"), var="Comportement")      
                    emmean  = data.frame(EMMean)
                    emmAL3  = data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                  lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelNOFF')))))
                    emmALL = rbind(emmALL, temp.df, emmAL2, emmAL3)
                        rownames(emmALL) = NULL

                    # 3)
                    # ON vs OFF : Effet fixe de la dopa
                    EMBBase = emtrends(model, ~  Medication, var="Comportement") 
                    emBBase = data.frame(EMBBase)
                    emOIall = data.frame(contrast(EMBBase,        
                                                  setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                            apply(       emBBase , 1, function(x) paste(x[1], 'AllCond', sep = '_')))))
                    emdOIall  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                                  setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                          lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), 'AllCond', sep = '_'))))) # nolint
                    
                    # 4)
                    # FOG VERSUS NO FOG
                    EMMean  = emtrends(model, ~ FOG, at = list(Medication = "OFF"), var="Comportement")      
                    emmean  = data.frame(EMMean)
                    emVersus= data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:1, function(i) c(0.5, 0.5, -1)), 
                                                          lapply(1:1, function(i) paste0('FoGVersus')))))
                    # All type of MetaFOG
                    emFOG = data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                            apply(       emmean , 1, function(x) paste(x[1], sep = '_')))))
                    
                    # 5)
                    # ON - OFF per Task
                    EMBBase = emtrends(model, ~  Medication*Task, var="Comportement")
                    emBBase = data.frame(EMBBase)
                    emOItask = data.frame(contrast(EMBBase,        
                                                  setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                            apply(       emBBase , 1, function(x) paste(x[1], x[2], sep = '_')))))
                    emdOItask  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                                  setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                          lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), emBBase[i*2,2], sep = '_'))))) # nolint

                    # Put all pvalues in ModelOutput
                    rm(ModelOutput)
                    emGlobal$categ = 'NoContrast'
                    emmMED$categ   = 'OFF-ON-NoContrast'
                    emmALL$categ   = 'AllInOne'
                    emOIall$categ  = 'OFF-ON-AllCond'
                    emdOIall$categ = 'OFF-ON-DeltaAllCond'
                    emVersus$categ = 'FOGVersus'
                    emFOG$categ    = 'FOG'
                    emOItask$categ = 'Task'
                    emdOItask$categ= 'OFF-ON-Task'
                    
                    ModelOutput = rbind(emGlobal, emmMED, emmALL, emOIall, emdOIall, emVersus, emFOG, emOItask, emdOItask)
                    
                    } else if (grepl('STNversus', Contact)) {
                        if (grepl('freezers', Contact)) {
                          DAT_LFP$Region = as.factor(DAT_LFP$Region)
                          DAT_LFP = subset(DAT_LFP, DAT_LFP$FOG != 'Meta_FOG_0')
                          model = lme4::lmer(10*log(value,base=10) ~ Region*FOG*Comportement + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                              EMMean  = emtrends(model, ~ Region*FOG, at = list(Medication = "OFF"), var="Comportement")  
                              emmean  = data.frame(EMMean)
                              emNoCont = data.frame(contrast(EMMean,       
                                                          setNames(lapply(1:nrow(emmean),  function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                  apply(       emmean , 1, function(x) paste(x[1], x[2], sep = '_')))))
                              emVerFog = data.frame(contrast(EMMean,       
                                                          setNames(lapply(1:(nrow(emmean)/2),   function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)/2-i), rep(0, i-1), -1, rep(0, nrow(emmean)/2-i))), # nolint
                                                                  lapply(1:(nrow(emmean)/2),   function(i) paste(paste0(emmean[i,2], '-',emmean[i+nrow(emmean)/2,2]), 'inRegion', emmean[i,1], sep = '_')))))       # nolint
                              emVerFReg= data.frame(contrast(EMMean,
                                                          setNames(lapply(1:(nrow(emmean)/3),   function(i) c(rep(0, (i-1)*3), 1, 0, -1, rep(0, nrow(emmean)/2-(i-1)*3))), # nolint
                                                                  lapply(1:(nrow(emmean)/3),   function(i) paste(paste0(emmean[i*3-2,1], '-',emmean[i*3,1]), 'for', emmean[i*3,2], sep = '_')))))       # nolint
                          
                          rm(ModelOutput)
                          ModelOutput = rbind(emNoCont, emVerFog, emVerFReg)
                          ModelOutput$categ = 'FOGversusCompt'

                        } else {
                          DAT_LFP$Region = as.factor(DAT_LFP$Region)
                          # Effet fixe :
                          model = lme4::lmer(10*log(value,base=10) ~ Comportement*Region + FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                              EMMean  = emtrends(model, ~ Region, var="Comportement")       
                              emmean  = data.frame(EMMean)
                              emVersus= data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                    lapply(1:1, function(i) paste0('AS-SM_all_fixedeffect')))))
                              emReg = data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                      apply(       emmean , 1, function(x) paste(x[1], 'allMed_fixedeffect', sep = '_')))))
                              
                              EMMean  = emtrends(model, ~ Region, at = list(Medication = "OFF"), var="Comportement")       
                              emmean  = data.frame(EMMean)
                              emVerOFF= data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                    lapply(1:1, function(i) paste0('AS-SM_OFF_fixedeffect')))))
                              emRegOFF= data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                      apply(       emmean , 1, function(x) paste(x[1], 'OFF_fixedeffect', sep = '_')))))

                          # FOG:
                          DAT_LFP$FOG = as.character(DAT_LFP$FOG)
                          DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_0'] = 'NoFOG'
                          DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_1'] = 'NoFOG'
                          DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_2'] = 'FOG'
                          DAT_LFP$FOG = as.factor(DAT_LFP$FOG)

                          model = lme4::lmer(10*log(value,base=10) ~ Comportement*Region*FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                              EMMean  = emtrends(model, ~ Region*FOG, at = list(Medication = "OFF"), var="Comportement")   
                              emmean  = data.frame(EMMean)
                              emNoCont = data.frame(contrast(EMMean,       
                                                          setNames(lapply(1:nrow(emmean),  function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                  apply(       emmean , 1, function(x) paste(x[1], x[2], sep = '_')))))
                              emVerFog = data.frame(contrast(EMMean,       
                                                          setNames(lapply(1:(nrow(emmean)/2),   function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)/2-i), rep(0, i-1), -1, rep(0, nrow(emmean)/2-i))), # nolint
                                                                  lapply(1:(nrow(emmean)/2),   function(i) paste(paste0(emmean[i,2], '-',emmean[i+nrow(emmean)/2,2]), 'inRegion', emmean[i,1], sep = '_')))))       # nolint
                              emVerFReg= data.frame(contrast(EMMean,
                                                          setNames(lapply(1:(nrow(emmean)/3),   function(i) c(rep(0, (i-1)*3), 1, 0, -1, rep(0, nrow(emmean)/2-(i-1)*3))), # nolint
                                                                  lapply(1:(nrow(emmean)/3),   function(i) paste(paste0(emmean[i*3-2,1], '-',emmean[i*3,1]), 'for', emmean[i*3,2], sep = '_')))))       # nolint
                          
                          # All effects: 
                          model   = lme4::lmer(10*log(value,base=10) ~ Comportement*Region + (1|Patient/Channel)+ (1|Task) + (1|hemisphere) + (1|Medication), data = DAT_LFP)
                              EMMean  = emtrends(model, ~ Region, var="Comportement")       
                              emmean  = data.frame(EMMean)
                              emVersus2= data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                    lapply(1:1, function(i) paste0('AS-SM_all_onlyeffect')))))
                              emReg2 = data.frame(contrast(EMMean,       
                                                          setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                    apply(       emmean , 1, function(x) paste(x[1], 'allMed_onlyeffect', sep = '_')))))
                            
                              EMMean  = emtrends(model, ~ Region, at = list(Medication = "OFF"), var="Comportement")       
                              emmean  = data.frame(EMMean)
                              emVerOFF2= data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                    lapply(1:1, function(i) paste0('AS-SM_OFF_onlyeffect')))))
                              emRegOFF2= data.frame(contrast(EMMean,       
                                                            setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                      apply(       emmean , 1, function(x) paste(x[1], 'OFF_onlyeffect', sep = '_')))))

                          rm(ModelOutput)
                          ModelOutput = rbind(emVersus, emReg, emVerOFF, emRegOFF, emNoCont, emVerFog, emVerFReg, emVersus2, emReg2, emVerOFF2, emRegOFF2)
                          ModelOutput$categ = 'STNversusCompt'
                        }
                    } # end if (Contact = STNversus)
 
                    ModelOutput = ModelOutput[stats::complete.cases(ModelOutput[, c("contrast", "df")]), ]
                    
                    # Save
                    data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutputComportement/', Contact, '_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Dim', dimension, 'ModelOutput.csv'))
                  
                  } else { # else de if(!Load_0Comput)
                    timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                    ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutputComportement/', Contact, '_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Dim', dimension, 'ModelOutput.csv'))
                  }
                  
                  ## Pass to next step (plots)
                  
                    pcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    Tcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    
                    
                  # initialize first column
                  if (dim(pcomp)[2] == 0) {
                    while (dim(pcomp)[1] < length(ModelOutput$contrast)) {
                      pcomp = tibble::add_row(pcomp)
                      Tcomp = tibble::add_row(Tcomp)
                    }
                    pcomp$categ    = ModelOutput$categ
                    Tcomp$categ    = ModelOutput$categ
                    pcomp$MetaCond = ModelOutput$contrast
                    Tcomp$MetaCond = ModelOutput$contrast
                  }
                  
                  # Assign Values
                  pcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$p.value
                  Tcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$estimate
                  
                  if (dimension == 1) {
                    pcomp1 = pcomp
                    Tcomp1 = Tcomp
                    } else if (dimension == 2) {
                    pcomp2 = pcomp
                    Tcomp2 = Tcomp
                    } else if (dimension == 3) {
                    pcomp3 = pcomp
                    Tcomp3 = Tcomp
                    }

                } # end for dimension
              } # end if todo_corr_Comport


                if (todo_corr_Clinique && todo_corr_Comport) { DAT_LFP = DAT_LFPsave }
                if (todo_corr_Clinique) {
                  
                  DAT_LFPsave = DAT_LFP
                
                    pcompC1 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC1 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC2 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC2 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC3 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC3 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    if (todo_All_5ClinicTest) {
                      pcompC4 = data.frame()
                      TcompC4 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                      pcompC5 = data.frame()
                      TcompC5 = data.frame()
                    }

                  for (Test in ClinicalTests) {
                    
                    if (!Load_0Comput) {
                      
                      DAT_LFP = DAT_LFPsave
                      DAT_LFP$Clinique = DAT_LFP[[Test]]  
                      DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "value", "Clinique")]), ]

                      DAT_LFP$Comportement = DAT_LFP$Clinique

                    ####################################################
                    ## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ##
                    ## !!!!    Copie de la partie Comportement   !!!! ##
                    ## !!!!        Ne pas modifier ici            !!!! ##
                    ## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ##
                    ####################################################

                                          if (!grepl('STNversus', Contact)) {

                                            # Model + emTrends
                                            model  = lme4::lmer(10*log(value,base=10) ~ FOG + Comportement*Medication*Task*hemisphere*ipsi_contra + nStep + (1|Patient/Channel), data = DAT_LFP)
                                            EMMean = emtrends(model, ~ Medication*Task*hemisphere*ipsi_contra, var="Comportement")

                                            emmean  = data.frame(EMMean)
                                            emGlobal= data.frame(contrast(EMMean,       
                                                                          setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))),  # nolint
                                                                                    apply(       emmean , 1, function(x) paste(x[1], x[2], x[3], x[4], sep = '_')))))
                                            
                                            # 2)                
                                            # AllInOne 
                                            # Deux approches : un modele avec parametres reduit ou un t.test simple contre 0
                                            
                                            model2   = lme4::lmer(10*log(value,base=10) ~ Comportement*hemisphere + (1|Patient/Channel)+ (1|Task)+ (1|hemisphere), data = DAT_LFP)
                                            EMMean  = emtrends(model2, ~  hemisphere, var="Comportement")      
                                            emmean  = data.frame(EMMean)
                                            emmALL  = data.frame(contrast(EMMean,       
                                                                          setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                                          lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelOld')))))
                                            tresult = cor.test(10*log10(DAT_LFP$value), DAT_LFP$Comportement, method = "spearman")
                                            temp.df = data.frame(contrast = "AllInOne-spearman", 
                                                    estimate = tresult$estimate, 
                                                    SE = 1,
                                                    df = 0, 
                                                    z.ratio = tresult$statistic, 
                                                    p.value = tresult$p.value)
                                            model2   = lme4::lmer(10*log(value,base=10) ~ Comportement*hemisphere + (1|Patient/Channel)+ (1|Task) + (1|Medication), data = DAT_LFP)
                                            EMMean  = emtrends(model2, ~  hemisphere, var="Comportement")      
                                            emmean  = data.frame(EMMean)
                                            emmAL2  = data.frame(contrast(EMMean,       
                                                                          setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                                          lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelNew')))))                
                                            EMMean  = emtrends(model2, ~  hemisphere, at = list(Medication = "OFF"), var="Comportement")      
                                            emmean  = data.frame(EMMean)
                                            emmAL3  = data.frame(contrast(EMMean,       
                                                                          setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                                                          lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne-ModelNOFF')))))
                                            emmALL = rbind(emmALL, temp.df, emmAL2, emmAL3)
                                            rownames(emmALL) = NULL

                                            # 3)
                                            # ON vs OFF : Effet fixe de la dopa
                                            EMBBase = emtrends(model, ~  Medication, var="Comportement") 
                                            emBBase = data.frame(EMBBase)
                                            emOIall = data.frame(contrast(EMBBase,        
                                                                          setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                                                    apply(       emBBase , 1, function(x) paste(x[1], 'AllCond', sep = '_')))))
                                            emdOIall  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                                                          setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                                                  lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), 'AllCond', sep = '_'))))) # nolint
                                            
                                            # 4)
                                            # FOG VERSUS NO FOG
                                            EMMean  = emtrends(model, ~ FOG, at = list(Medication = "OFF"), var="Comportement")      
                                            emmean  = data.frame(EMMean)
                                            emVersus= data.frame(contrast(EMMean,       
                                                                          setNames(lapply(1:1, function(i) c(0.5, 0.5, -1)), 
                                                                                  lapply(1:1, function(i) paste0('FoGVersus')))))
                                            # All type of MetaFOG
                                            emFOG = data.frame(contrast(EMMean,       
                                                                          setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                                    apply(       emmean , 1, function(x) paste(x[1], sep = '_')))))
                                            
                                            # 5)
                                            # ON - OFF per Task
                                            EMBBase = emtrends(model, ~  Medication*Task, var="Comportement")
                                            emBBase = data.frame(EMBBase)
                                            emOItask = data.frame(contrast(EMBBase,        
                                                                          setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                                                    apply(       emBBase , 1, function(x) paste(x[1], x[2], sep = '_')))))
                                            emdOItask  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                                                          setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                                                  lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), emBBase[i*2,2], sep = '_'))))) # nolint

                                            # Put all pvalues in ModelOutput
                                            rm(ModelOutput)
                                            emGlobal$categ = 'NoContrast'
                                            emmMED$categ   = 'OFF-ON-NoContrast'
                                            emmALL$categ   = 'AllInOne'
                                            emOIall$categ  = 'OFF-ON-AllCond'
                                            emdOIall$categ = 'OFF-ON-DeltaAllCond'
                                            emVersus$categ = 'FOGVersus'
                                            emFOG$categ    = 'FOG'
                                            emOItask$categ = 'Task'
                                            emdOItask$categ= 'OFF-ON-Task'
                                            
                                            ModelOutput = rbind(emGlobal, emmMED, emmALL, emOIall, emdOIall, emVersus, emFOG, emOItask, emdOItask)
                                            
                                            } else if (grepl('STNversus', Contact)) {
                                                DAT_LFP$Region = as.factor(DAT_LFP$Region)
                                                # Effet fixe :
                                                model = lme4::lmer(10*log(value,base=10) ~ Comportement*Region + FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                                                    EMMean  = emtrends(model, ~ Region, var="Comportement")       
                                                    emmean  = data.frame(EMMean)
                                                    emVersus= data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                                          lapply(1:1, function(i) paste0('AS-SM_all_fixedeffect')))))
                                                    emReg = data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                                            apply(       emmean , 1, function(x) paste(x[1], 'allMed_fixedeffect', sep = '_')))))
                                                    
                                                    EMMean  = emtrends(model, ~ Region, at = list(Medication = "OFF"), var="Comportement")       
                                                    emmean  = data.frame(EMMean)
                                                    emVerOFF= data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                                          lapply(1:1, function(i) paste0('AS-SM_OFF_fixedeffect')))))
                                                    emRegOFF= data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                                            apply(       emmean , 1, function(x) paste(x[1], 'OFF_fixedeffect', sep = '_')))))

                                                # FOG:
                                                DAT_LFP$FOG = as.character(DAT_LFP$FOG)
                                                DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_0'] = 'NoFOG'
                                                DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_1'] = 'NoFOG'
                                                DAT_LFP$FOG[DAT_LFP$FOG == 'Meta_FOG_2'] = 'FOG'
                                                DAT_LFP$FOG = as.factor(DAT_LFP$FOG)

                                                model = lme4::lmer(10*log(value,base=10) ~ Comportement*Region*FOG + Medication*Task*hemisphere*ipsi_contra + (1|Patient/Channel), data = DAT_LFP)
                                                    EMMean  = emtrends(model, ~ Region*FOG, at = list(Medication = "OFF"), var="Comportement")   
                                                    emmean  = data.frame(EMMean)
                                                    emNoCont = data.frame(contrast(EMMean,       
                                                                                setNames(lapply(1:nrow(emmean),  function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                                        apply(       emmean , 1, function(x) paste(x[1], x[2], sep = '_')))))
                                                    emVerFog = data.frame(contrast(EMMean,       
                                                                                setNames(lapply(1:(nrow(emmean)/2),   function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)/2-i), rep(0, i-1), -1, rep(0, nrow(emmean)/2-i))), # nolint
                                                                                        lapply(1:(nrow(emmean)/2),   function(i) paste(paste0(emmean[i,2], '-',emmean[i+nrow(emmean)/2,2]), 'inRegion', emmean[i,1], sep = '_')))))       # nolint
                                                    emVerFReg= data.frame(contrast(EMMean,
                                                                                setNames(lapply(1:(nrow(emmean)/3),   function(i) c(rep(0, (i-1)*3), 1, 0, -1, rep(0, nrow(emmean)/2-(i-1)*3))), # nolint
                                                                                        lapply(1:(nrow(emmean)/3),   function(i) paste(paste0(emmean[i*3-2,1], '-',emmean[i*3,1]), 'for', emmean[i*3,2], sep = '_')))))       # nolint
                                                
                                                # All effects: 
                                                model   = lme4::lmer(10*log(value,base=10) ~ Comportement*Region + (1|Patient/Channel)+ (1|Task) + (1|hemisphere) + (1|Medication), data = DAT_LFP)
                                                    EMMean  = emtrends(model, ~ Region, var="Comportement")       
                                                    emmean  = data.frame(EMMean)
                                                    emVersus2= data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                                          lapply(1:1, function(i) paste0('AS-SM_all_onlyeffect')))))
                                                    emReg2 = data.frame(contrast(EMMean,       
                                                                                setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                                          apply(       emmean , 1, function(x) paste(x[1], 'allMed_onlyeffect', sep = '_')))))
                                                  
                                                    EMMean  = emtrends(model, ~ Region, at = list(Medication = "OFF"), var="Comportement")       
                                                    emmean  = data.frame(EMMean)
                                                    emVerOFF2= data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:1, function(i) c(1, 0, -1)), 
                                                                                          lapply(1:1, function(i) paste0('AS-SM_OFF_onlyeffect')))))
                                                    emRegOFF2= data.frame(contrast(EMMean,       
                                                                                  setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), # nolint
                                                                                            apply(       emmean , 1, function(x) paste(x[1], 'OFF_onlyeffect', sep = '_')))))

                                                rm(ModelOutput)
                                                ModelOutput = rbind(emVersus, emReg, emVerOFF, emRegOFF, emNoCont, emVerFog, emVerFReg, emVersus2, emReg2, emVerOFF2, emRegOFF2)
                                                ModelOutput$categ = 'STNversusCompt'
                                              } # end if (Contact = STNversus)
                        
                                            ModelOutput = ModelOutput[stats::complete.cases(ModelOutput[, c("contrast", "df")]), ]
                                            



                      if (grepl('STNversus', Contact)) {
                        ModelOutput$categ = 'STNversusClin'
                      }
                      
                      # Save
                      if (!dir.exists(paste0(OutputDir, '/ModelOutputClinique/'))) {
                        dir.create(paste0(OutputDir, '/ModelOutputClinique/'))
                      }
                      data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutputClinique/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Test_', Test, 'ModelOutput.csv'))

                    } else { # else de if(!Load_0Comput)
                      timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                      ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutputClinique/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Test_', Test, 'ModelOutput.csv'))
                    } 
                    
                    ## Pass to next step (plots)
                  
                    pcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    Tcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    
                    
                    # initialize first column
                    if (dim(pcomp)[2] == 0) {
                      while (dim(pcomp)[1] < length(ModelOutput$contrast)) {
                        pcomp = tibble::add_row(pcomp)
                        Tcomp = tibble::add_row(Tcomp)
                      }
                      pcomp$categ    = ModelOutput$categ
                      Tcomp$categ    = ModelOutput$categ
                      pcomp$MetaCond = ModelOutput$contrast
                      Tcomp$MetaCond = ModelOutput$contrast
                    }
                    
                    # Assign Values
                    pcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$p.value
                    Tcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$estimate
                    
                    if (Test == 'U3') {
                      pcompC1 = pcomp
                      TcompC1 = Tcomp
                      } else if (Test == 'dU3') {
                      pcompC2 = pcomp
                      TcompC2 = Tcomp
                      } else if (Test == 'dFogQ') {
                      pcompC3 = pcomp
                      TcompC3 = Tcomp
                      } else if (Test == 'dP39') {
                      pcompC4 = pcomp
                      TcompC4 = Tcomp
                      } else if (Test == 'dU3II') {
                      pcompC5 = pcomp
                      TcompC5 = Tcomp
                      }

                      
                  } # End for Test
                } # End if todo_corr_Clinique


              remove(ModelOutput)
              remove(Stats)
              remove(DAT_LFP) # Remove pour que la prochaine itération ne calcule pas ces données en plus.
              
              
              output = list(pval, TFpw) #### ONLY FOR PARALLEL COMPUTING 
              if (todo_corr_Comport) { output = c(output, list(pcomp1, Tcomp1, pcomp2, Tcomp2, pcomp3, Tcomp3)) } #### ONLY FOR PARALLEL COMPUTING
              if (todo_corr_Clinique && !todo_All_5ClinicTest) { output = c(output, list(pcompC1, TcompC1, pcompC2, TcompC2, pcompC3, TcompC3)) } #### ONLY FOR PARALLEL COMPUTING
              if (todo_corr_Clinique &&  todo_All_5ClinicTest) { output = c(output, list(pcompC1, TcompC1, pcompC2, TcompC2, pcompC3, TcompC3,pcompC4, TcompC4, pcompC5, TcompC5)) } #### ONLY FOR PARALLEL COMPUTING
              
              output
          } # End Parallel          
          
          if (!dir.exists(paste0(OutputDir, '/WorkSpace/'))) {
                 dir.create(paste0(OutputDir, '/WorkSpace/'))
          }

          save.image(file = paste0(OutputDir, '/WorkSpace/WorkSpace', Contact, '_', ev, '.RData'))
        
        } else  if (PlotOnlyNoModel) {
          load(            paste0(OutputDir, '/WorkSpace/WorkSpace', Contact, '_', ev, '.RData'))
          print(paste0('Loaded WorkSpace : ', Contact, '_', ev, '.RData'))
          load(            paste0(OutputDir, '/WorkSpace/Consignes.RData')) 
        }


          if (!dir.exists(paste0(OutputDir, '/ProcessedData/'))) {
                 dir.create(paste0(OutputDir, '/ProcessedData/'))
          } 

        ## Loop over ResPar Results 
        for (i_colrespar in seq(1,ncol(ResPar),by=2)) {
          
          rm(Suf_Case)
          if (PlotOnlyNoModel) {
            if (i_colrespar > 1 && !todo_corr_Comport && !todo_corr_Clinique) {next}
            if (i_colrespar > 8 && !todo_corr_Clinique) {next}
            if (i_colrespar > 1 && ncol(ResPar) > 8 && i_colrespar < 9 && !todo_corr_Comport) {next}
          }

          if (i_colrespar == 1) {
            Case = 'Vanilla'
            Suf_Case = ''
          } else if (i_colrespar < 8 && todo_corr_Comport) {
            Case = 'Comportement'
            Suf_Case = paste0('_ComptDim', (i_colrespar-1)/2)
            if (grepl("CalcDim", Contact)) {
              if ((i_colrespar-1)/2 == 1) {
                Suf_Case = '_Compt5Dim'
              }
              if ((i_colrespar-1)/2 == 2) {
                Suf_Case = '_ComptDim23'
              }
              if ((i_colrespar-1)/2 == 3) {
                Suf_Case = '_ComptDimn45'
              }
            }
          } else if (i_colrespar > 8 && todo_corr_Comport && todo_corr_Clinique) {
            Case = 'Clinique'
            if (i_colrespar ==  9) { Suf_Case = '_U3'    }
            if (i_colrespar == 11) { Suf_Case = '_dU3'   }
            if (i_colrespar == 13) { Suf_Case = '_dFogQ' }
            if (i_colrespar == 15) { Suf_Case = '_dU3II' }
            if (i_colrespar == 17) { Suf_Case = '_dP39'  }
          } else if (i_colrespar > 1 && !todo_corr_Comport && todo_corr_Clinique) {
            Case = 'Clinique'
            if (i_colrespar ==  3) { Suf_Case = '_U3'    }
            if (i_colrespar ==  5) { Suf_Case = '_dU3'   }
            if (i_colrespar ==  7) { Suf_Case = '_dFogQ' }
            if (i_colrespar ==  9) { Suf_Case = '_dU3II' }
            if (i_colrespar == 11) { Suf_Case = '_dP39'  }
          }

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

                    initialColormapToRenforce = colorspace::diverge_hcl(7, palette = "Tropic")
                    if (grepl("darktheme", Contact)) {
                      for (i in seq_along(initialColormapToRenforce)) {
                        HCL = farver::decode_colour(initialColormapToRenforce[i], to = "hcl")
                        HCL[3] = 100 - HCL[3]
                        initialColormapToRenforce[i] = grDevices::hcl(HCL[1], HCL[2], HCL[3])
                      }
                    }
                    colormap_to_use  = grDevices::colorRampPalette(c(initialColormapToRenforce[1], initialColormapToRenforce[1:2], initialColormapToRenforce[4], initialColormapToRenforce[6:7], initialColormapToRenforce[7])  )
                      


              } else if (Case == 'Comportement') {
                  colormap_to_use  = colorRamps::ygobb
                # BrBG aussi interessant
                # colormap_to_use  = colorRamps::blue2yellow
              } else if (Case == 'Clinique') {
                  colormap_to_use  = colorRamps::blue2green
              }
              
              return(colormap_to_use)
          }
          colormap_to_use = MAGIC_Colormap(Case)
          missingValuesColor = "black"
          
          if (PValueBreaks[1] == "none" || length(PValueBreaks) == 0 ) {
            PValueBreaks = c(-1)
            colorpval1 = "black"
            colorpval2 = "black"
            if (grepl("darktheme", Contact)) {
              colorpval1 = "white"
              colorpval2 = "white"
            }
          } else {
            colorpval1 = "white"
            colorpval2 = "black"
          }

          if (grepl("darktheme", Contact)) {
            theme_to_apply = ggdark::dark_theme_classic()
          } else {
            theme_to_apply = theme_classic()
          }

          ## Get back results from foreach iteration
          pval = ResPar[1,i_colrespar  ][[1]]
          TFpw = ResPar[1,i_colrespar+1][[1]]
        
          for (i_rowrespar in 2:nrow(ResPar)) {
            tfname = colnames(ResPar[i_rowrespar, i_colrespar    ][[1]])[3]
            pval[[tfname]]  = ResPar[i_rowrespar, i_colrespar    ][[1]][[3]]
            TFpw[[tfname]]  = ResPar[i_rowrespar, i_colrespar + 1][[1]][[3]]
          }
        
          for (folderName in unique(pval$categ)) {
            if (!dir.exists(paste0(OutputDir, '/', folderName))) {
                 dir.create(paste0(OutputDir, '/', folderName))
            }
          }

            #######################################################################################################
            ## PLOTS ##############################################################################################
            #######################################################################################################
            
            if (todo_Plots) {
              
              
              ## Plot All contre 0 => No contrast
              foreach(MetCondnum = 1:length(unique(pval$MetaCond))) %dopar% { # nolint
                # if (PlotOnlyNoModel && "OFF-ON-DeltaAllCond" != pval$categ[MetCondnum]) {next}
                MetCond  = pval$MetaCond[MetCondnum]
                PlotName = paste0('TF_', ev, '_', Contact, '_', MetCond, '_', PValueLimit , Suf_Case )
                PlotFolder  = paste0('/', pval$categ[MetCondnum], '/')
                
                print(paste0('PLOTS : Metacondition ', MetCondnum, ' sur ', length(pval$MetaCond), ' ----- ', Sys.time()))
                
                # Preparer la table
                data = data.frame(Freq = numeric(0), Time = numeric(0), Power = numeric(0), pvalue = numeric(0))
                
                #Recuperer les parametres de temps et frequence
                for (colnum in 3:length(colnames(pval))){
                  colname   = colnames(pval)[colnum]
                  timepoint = strsplit(colname, '-')[[1]][2]
                  timepoint = gsub("x_", "-", timepoint, fixed = TRUE)
                  timepoint = gsub("_" , ".", timepoint)
                  timepoint = gsub("x" , "" , timepoint)
                  timepoint = as.numeric(timepoint)
                  
                  freqpt  = strsplit(colname, '-')[[1]][1]
                  freqpt  = gsub("Freq" , "" , freqpt)
                  freqpt  = as.numeric(freqpt)
                  
                  # Ajouter dans la table finale la valeur
                  data                    = add_row(data)
                  data$Freq[  nrow(data)] = freqpt
                  data$Time[  nrow(data)] = timepoint
                  data$Power[ nrow(data)] = TFpw[MetCondnum,colnum]
                  data$pvalue[nrow(data)] = pval[MetCondnum,colnum]
                }  # end for (colnum...)
                
                # Write data to a file
                data.table::fwrite(data, file = paste0(OutputDir, '/ProcessedData/', PlotName, '.csv'))
                
                ## Plot Video (gif)
                if (todo_gifplot) {
                  lim  = max(abs(data$Power))
                  
                  # get time limit
                  includedCenterValues = subset(data, 
                                                (data$Time >= min(data$Time) + SlidingWindowHalfSize & 
                                                  data$Time <= max(data$Time) - SlidingWindowHalfSize))
                  
                  # Create a function that will plot each frame 
                  # Same ggplot as below (mais titre et centre du plot modifiés)
                  gif.frame = function(count){
                    
                    center = includedCenterValues$Time[count]
                    dat4frame = subset(data, 
                                      (data$Time >= center - SlidingWindowHalfSize  & 
                                          data$Time <= center + SlidingWindowHalfSize))
                    Switch = (0 >= center - SlidingWindowHalfSize  & 0 <= center + SlidingWindowHalfSize)
                    
                    a = ggplot(dat4frame, aes(x = Time, y = Freq, fill = Power)) +
                      # coord_trans(y = Espacement_Freq) +              # scale en log10
                      geom_raster(interpolate = TRUE) +  
                      geom_density_2d_filled(data = dat4frame[dat4frame$pvalue < PValueLimit,], aes(z = pvalue), show.legend = FALSE, n = 100) +  
                      scale_fill_gradientn(colours = colormap_to_use(100), lim = c(-lim, lim), na.value = missingValuesColor) +
                      {if (Switch) geom_vline(xintercept = 0, linewidth = .2)} +  # add a vertical line at x = 0 conditionnaly
                      # geom_contour(data = dat4frame[dat4frame$pvalue < PValueLimit,], aes(z = pvalue, colour = "black"), show.legend = FALSE, breaks = PValueBreaks) +
                      theme_classic() + 
                      ggtitle(paste0(PlotName, " - Temps = ", round(center, digits = 2))) +
                      theme(plot.title = element_text(hjust = 0.5)) + # center the plot title
                      scale_colour_manual("", values = "black")       # For the geom contour
                    
                    print(a)
                  }
                  
                  gif.anim = function() lapply(1:length(unique(includedCenterValues$Time)), function(i)  gif.frame(i) )   # nolint
                  
                  saveGIF(gif.anim(), movie.name=paste0(OutputDir, PlotFolder , PlotName, '.gif'))
                  
                  rm(includedCenterValues)
                  
                } # End gif
                
                
                ## Plot Image fixe
                
                if (todo_tfmapplot) {
                  
                  data = subset(data, (data$Time >= -1 & data$Time <= 1))
                  lim  = max(abs(data$Power))

                  # Data final preprocessing
                  if (Case == "Vanilla") { # Not used for now
                    lim  = 8
                  } else if (Case == "Comportement") {
                    lim  = 2.5
                  } else if (Case == "Clinique") {
                    lim  = 2.5
                  }
                  

                  # FDR correction
                  data$pvalueFDR = p.adjust(data$pvalue, method = "fdr")
                  
                  # Plot
                  ggplot(data, aes(x = Time, y = Freq, fill = Power)) +
                    # coord_trans(y = Espacement_Freq) +              # scale en log10
                    geom_raster(interpolate = TRUE) + 
                    scale_fill_gradientn(colours = colormap_to_use(100), lim = c(-lim, lim), na.value = missingValuesColor) +
                    geom_vline(xintercept = 0, linewidth = .2, coulour = colorpval2) +         # add a vertical line at x = 0
                    geom_contour(data = data, aes(z = pvalue, colour = ..level..), show.legend = TRUE, breaks = PValueBreaks) +
                    theme_to_apply +
                    ggtitle(PlotName) +
                    geom_hline(yintercept = 12, linetype = "dashed", color = colorpval2, size = 0.5) +
                    geom_hline(yintercept = 35, linetype = "dashed", color = colorpval2, size = 0.5) +
                    theme(plot.title = element_text(hjust = 0.5)) + # center the plot title
                    scale_colour_continuous("PValue", low = colorpval1, high = colorpval2)  +
                    geom_contour(data = data, aes(z = pvalueFDR, colour = ..level..), show.legend = TRUE, breaks = PValueLimit)

                  ## sauvegarde des graphes
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '.png'), width = FigWidth, height = FigHigh, units = "cm")
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '.svg'), width = FigWidth, height = FigHigh, units = "cm")
                }  # end fixed image plot
                
                if (todo_MaskPlot) {
                  
                  data = subset(data, (data$Time >= -1 & data$Time <= 1))
                  lim  = max(abs(data$Power))
                  
                  # FDR correction
                  data$pvalueFDR = p.adjust(data$pvalue, method = "fdr")
                  
                  # Plot
                  ggplot(data[data$pvalueFDR < PValueLimit,], aes(x = Time, y = Freq, fill = Power)) +
                    geom_raster(interpolate = TRUE) + 
                    scale_fill_gradientn(colours = colormap_to_use(100), lim = c(-lim, lim), na.value = missingValuesColor) +
                    geom_vline(xintercept = 0, linewidth = .2) +         # add a vertical line at x = 0
                    theme_classic() +
                    ggtitle(PlotName) +
                    geom_hline(yintercept = 12, linetype = "dashed", color = "#000000", size = 0.5) +
                    geom_hline(yintercept = 35, linetype = "dashed", color = "#000000", size = 0.5) +
                    theme(plot.title = element_text(hjust = 0.5)) 
                  
                  ## sauvegarde des graphes
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '_Mask.png'), width = FigWidth, height = FigHigh, units = "cm")
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '_Mask.svg'), width = FigWidth, height = FigHigh, units = "cm")
                }  # end fixed image plot
              } # end for MetCond
              rm(data)
              print(paste0("success" , Suf_Case))
            } #end plot
            
          } # end for ResPar
          
          print(" ")
          if ((Sys.info()["nodename"] == "UMR-LAU-WP011"  || Sys.info()["nodename"] == "ICM-LAU-WF006") && todo_SMSfrequent) {
            system(paste0('matlab -nodisplay -nosplash -nodesktop -r \" addpath(\'\\\\l2export\\iss02.home\\mathieu.yeche\\Cluster\\Matlab\') ; SMS_Mathieu(\'R_Stats ', ev, ' pour loc ', Contact , ' fait \');exit\"')) 
          }

        } # end for event
    
  }


stopCluster(cl)

if (manual_todoPCAplot) {
  WS = list.files(paste0(OutputDir, '/WorkSpace/'))
  for (i in seq_along(WS)) {
    load(paste0(OutputDir, '/WorkSpace/', WS[i]))
    print(paste0('Loaded WorkSpace : ', WS[i]))
    print(paste0('Nombre de patients : ', length(unique(TFbySubject$Patient)), ' pour une combinaison de ', 
        length(unique(paste0(TFbySubject$Patient , TFbySubject$Channel))), ' canaux / patients '))  
    print(" ")
  }
}

#############################################################################################
###### Sortie


print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")

IdForNotification = paste(ev,collapse ="_")
Timing = format(Sys.time(), "%F_%H-%M-%S")
filename = paste(LogDir, Timing, "-R_Stats" , IdForNotification , "SUCCESS", ".txt",sep = "")
fileSuccess=file(filename)
writeLines("Hello", fileSuccess)
close(fileSuccess)

if (Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006") {
  system(paste0('matlab -nodisplay -nosplash -nodesktop -r \" addpath(\'\\\\l2export\\iss02.home\\mathieu.yeche\\Cluster\\Matlab\') ; SMS_Mathieu(\'R_Stats Fin du script : SUCCESS !!!\');exit\"'))
}
