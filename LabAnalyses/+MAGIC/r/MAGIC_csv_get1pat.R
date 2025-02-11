#############################################################################################
##                                                                                         ##
##                             MAGIC  -  cartes TF individuelles                           ##
##                                                                                         ##
#############################################################################################

#############################################################################################
###### Initialisation
# DEFINE PATHS
rm(list = ls())
gc()

conditions = c( 'APA')
events     = c( 'T0')

if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/"
} else {
  DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  LogDir    = "//l2export/iss02.home/mathieu.yeche/Cluster/outputs/"
}

## LIBRARY
library(sp)
library(reshape2)
library(RColorBrewer)
library(ggplot2)
library(FedData)

segType  = 'step'            #'trial'   'step' 
normtype = c('ldNOR')        # RAW or ldNOR
datatype = 'TF'              #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'
Montage  = 'extended';       # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'TF';             # 'TraceBrut' , 'TF',  'none'




# PRECISE GROUPS
groups   = c('STN')
# groups   = c('PPN')
# conditions = c('INIT', APA', 'step', 'turn', 'FOG')

funType = 'median' #  c('median', 'mean')
FqBdesLim  = c(1, 4, 8, 13, 21, 36, 61, 81)

for (nor in normtype) {
  for (gp in groups) {
    # SET SUBJECT
    if (gp == 'STN') {
      subjects <-
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
          'LOp_000a'
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
          "ParkPitie_2019_11_28_LOp"
        )
    }
    
    
    
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    iname = 1
    
    s_count = 0
    
    
    
    
    for (phase in conditions) {
      if (exists('longform')){print(cat ('longform : ', phase, ' '))} else {print(phase)}
      
      if (phase == 'FOGall') {
        subjects <-
          c(
            'ALb_000a',
            'VIj_000a',
            'DEj_000a',
            'GAl_000a',
            'SAs_000a',
            #'FRa_000a',
            'GUg_0634',
            'GIs_0550'
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
            "ParkPitie_2020_07_02_GIs"
            
          )
      }
      print(cat ('Nombre de sujets inclus : ', length(subjects), ' / Verifier que cela correspond au nombre attendu '))
      
      
      for (s in subjects) {
        # s=subjects
        s_count = s_count + 1
        
        #if (s == 'ALb_000a' | s == 'VIj_000a' | s == 'DEj_000a' || s == 'SAs_000a' || s == 'GAl_000a' || s == 'GIs_0550' || s == 'GUg_0634' || s == 'FRa_000a') {events  = c('FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E')} else {events  = c('FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E')}
        
        # Chemin
        RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
        setwd(paste(RecDir, '/POSTOP', sep = ""))
        
        
        #SET PROTOCOL
        if (gp == 'STN') {
          if (s == 'AUa_0342' | s == 'PHj_0351' || s == 'DEj_000a' || s == 'DRc_000a'|| s == 'BEm_000a' || s == 'BAg_0496' || s == 'LOp_000a'|| s == 'GIs_0550' || s == 'COm_000a'|| s == 'REa_0526' ) {
            protocol = 'GBMOV'
          } else {
            protocol = 'MAGIC'
          }
        }
        
        outputname <- listnameSubj[s_count]
        
        for (ev in events) {
          # Lecture du fichier
          print(cat (phase, s, ev, ' ' ))
          print(Sys.time())
          
          if (datatype == 'TF' | datatype == 'FqBdes') {
            if ((nor == 'ldNOR') & segType  == 'step') {
              temp <- vroom::vroom(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_TF_', 'dNOR', '_', Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
            } else {
              temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_TF_',   nor , '_', Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
            }
            temp$TOI = 'EVT' # Time Of Interest
          }
          
          temp <- subset(temp, temp$quality == 1)
          
          print ("rejection")
          
          gc()
          
          # keep only 1 freq
          temp = subset(temp, temp$Freq == 1)
          # keep only 1 timepoint
          temp = subset(temp, select = c(1:18))
          
          gc()
          
          # On compile les donnees de tous les patients
          if (exists('DAT_LFP')) {
            DAT_LFP <- rbind(DAT_LFP, temp)
          } else {
            DAT_LFP <- temp
          }
          print ("select")
          
          
          rm('temp')
          gc()
        }
        iname = iname + 1
      }
      
      
      #############################################################################################
      ###### Mise en forme du fichier
      
      #TIMES
      # verifier fenetre de temps selectionnee
      print ("Verifs")
      
      #############################################################################################
      #### GRAPHES - Donnees individuelles
      ## Creation de la matrice pour enregistrer les lim dans chaque condition pour chaque patient
      iname = 1
      ivar = 1
      
      setwd(OutputDir)
      
      if (datatype == 'TF') {
        write.table(DAT_LFP, paste('MAGIC_1pointFreqTime_AllPat', '_', segType, '_', gp, '_', nor, '_',  Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '_', phase, '.csv', sep = ""))
      }
      print ("export")
      print(Sys.time())
      remove(DAT_LFP)
      gc()
    }
  }
}


print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")

IdForNotification = paste(conditions,collapse ="_")
Timing = format(Sys.time(), "%F_%H-%M-%S")
filename = paste(LogDir, Timing, "-R_CSV" , IdForNotification , "SUCCESS", ".txt",sep = "")
fileSuccess<-file(filename)
writeLines("Hello", fileSuccess)
close(fileSuccess)
