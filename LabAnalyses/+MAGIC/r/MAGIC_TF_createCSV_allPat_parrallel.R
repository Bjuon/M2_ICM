#############################################################################################
##                                                                                         ##
##                             MAGIC  -  cartes TF individuelles                           ##
##                                                                                         ##
#############################################################################################

print("MAGIC  -  cartes TF individuelles", quote = FALSE)   

#############################################################################################
###### Initialisation
# DEFINE PATHS
rm(list = ls())
gc()

if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  
} else {
  DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
}

## LIBRARY
library(sp)
library(reshape2)
library(RColorBrewer)
library(ggplot2)
library(FedData)
library(foreach)
library(doParallel)

segType  = 'step' #'trial'   'step' 
normtype = c('ldNOR')
datatype = 'TF' #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'
# PRECISE GROUPS
groups   = c('STN')
# groups   = c('PPN')
# conditions = c('INIT', APA', 'step', 'turn', 'FOG')

funType = 'median' #  c('median', 'mean')
FqBdesLim  = c(1, 4, 8, 13, 21, 36, 61, 81)

print("boucle sur conditions ici ou plus bas si besoin")
#SELECT EVENTS
if (segType == 'step') {
  #   if (cond == 'INIT') {
  #     events  = c('FIX', 'CUE')
  #   } else if (cond == 'APA') {
  #     events  = c('T0', 'T0_EMG', 'FO1', 'FC1')
  #   } 
  events  = c('FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E') #, 'FO', 'FOG_S', 'FOG_E') #, 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E')
  events  = c('FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E')
} else if (segType == 'trial') {
  events  = c('BSL')
}


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
          "ParkRouen_2021_02_08_FRJ",
          "ParkPitie_2019_02_21_BAg",      #GOGAIT_POSTOP_BARGU14
          "ParkPitie_2019_03_14_DRc",      #GOGAIT_POSTOP_DROCA16
          "ParkPitie_2019_10_24_COm",
          "ParkPitie_2019_11_28_LOp"
        )
    }
    
    
    
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    iname = 1
    
    s_count = 0
    registerDoParallel(makeCluster(detectCores()))
    
    DAT_LFP = foreach (s_count = 1:length(subjects), .combine = rbind.data.frame, .packages=c("FedData", "ggplot2","sp","reshape2","RColorBrewer")) %dopar% { 
      # s=subjects
      s = subjects[s_count]
      
      # Chemin
      RecDir  = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
      RecDir2 = paste(RecDir, '/POSTOP', sep = "")

      
 #     if (s == 'ALb_000a' | s == 'VIj_000a' | s == 'DEj_000a' || s == 'SAs_000a' || s == 'GAl_000a' || s == 'GIs_0550' || s == 'GUg_0634' || s == 'FRa_000a') {
 #       events  = c('FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E')
 #     } else {
 #         events  = c('FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E')
 #         }
      print('temp a rechanger')
      events  = c('FIX')
      
      #SET PROTOCOL
      if (gp == 'STN') {
        if (s == 'AUa_0342' | s == 'PHj_0351' || s == 'DEj_000a' || s == 'DRc_000a'|| s == 'BEm_000a' || s == 'BAg_0496' || s == 'LOp_000a'|| s == 'GIs_0550' || s == 'COm_000a'|| s == 'REa_0526' ) {
          protocol = 'GBMOV'
        } else {
          protocol = 'MAGIC'
        }
      } else if (gp == 'PPN') {
        protocol = 'GAITPARK'
      }
      
      outputname <- listnameSubj[s_count]
      
      for (ev in events) {
        # Lecture du fichier
        print(s)
        print(ev)
        print(Sys.time())
        
        if (datatype == 'TF' | datatype == 'FqBdes') {
          if ((nor == 'ldNOR') & segType  == 'step') {
            temp <- read.delim(paste(RecDir2, '/', outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_TF_', 'dNOR', '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          } else {
            temp <- read.delim(paste(RecDir2, '/', outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_TF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          }
          temp$TOI = 'EVT' # Time Of Interest
          
        } else if (datatype == 'PE') {
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_PE_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
          
        } else if (datatype == 'meanTF') {
          temp     <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
          if (segType == '') {
            temp_bsl <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_BSL.csv', sep = ""))
            temp_bsl$TOI   = 'BSL' # Time Of Interest
            temp_bsl$Event = ev # Time Of Interest
            temp_bsl$Condition = temp$Condition[1]
            temp <- rbind(temp, temp_bsl)
            remove(temp_bsl)
          } else if (segType == 'trial' & nor == 'RAW') {
            temp_bsl <- read.delim(paste(outputname, '_', protocol, '_POSTOP_BLEO_STAND_', segType, '_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_BSL.csv', sep = ""))
            temp_bsl$TOI   = 'BSL' # Time Of Interest
            temp_bsl$Event = ev # Time Of Interest
            #temp_bsl$Condition = temp_bsl$Condition[1]
            temp_bsl$nStep[is.na(temp_bsl$nStep)] = ''
            temp_bsl$side[is.na(temp_bsl$side)] = ''
            temp <- rbind(temp, temp_bsl)
            remove(temp_bsl)
          }
        }
        
        
        # temp$grouping[is.na(temp$grouping)] = ''
        # temp$nStep[is.na(temp$nStep)] = ''
        # temp$side[is.na(temp$side)] = ''
        
        # keep only quality == 1 (reject events rejected by visual inspection)
        temp <- subset(temp, temp$quality == 1)
        
        
        temp <- temp[, c("Protocol", "Patient", "Medication", "Task", "Condition", "Channel", "Freq", "Region", "grouping", "Run", "side","Event", "isValid", 'isFOG',
                         colnames(temp)[18:length(colnames(temp))])]
        temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Task", "Condition", "Freq", "Channel", "Region", "grouping", "Run", "side", "Event", "isValid", 'isFOG', "TOI"))
        
        print ("rejection")
        
        BadValueList = is.na(temp$value)
        temp$value[BadValueList]  = 9999
        temp[is.na(temp)]=0
        # temp[temp == '' | temp == ' '] = 0
        temp$value[BadValueList]= NA
        rm('BadValueList')
        gc()
        
        # transform to log if dNOR before averaging
        if ((nor == 'ldNOR' | nor == 'RAW') & segType  == 'step') {
          temp$value = 10*log10(Re(temp$value))
          print ("log")
        }
        
        
        # average frequency bands if FqBdes
        if (datatype == 'FqBdes') {
          temp$FqBde = 'FqBde'
          # temp$FqBde[temp$Freq >= FqBdesLim[1] & temp$Freq <= FqBdesLim[1+1]] = paste(FqBdesLim[1], FqBdesLim[1+1], sep = '-')
          for (ifq in 1:(length(FqBdesLim)-1)) {
            temp$FqBde[temp$Freq >= FqBdesLim[ifq] & temp$Freq < FqBdesLim[ifq+1]] = paste(FqBdesLim[ifq], FqBdesLim[ifq+1]-1, sep = '-')
          }
          temp <- subset(temp, temp$FqBde != 'FqBde')
          temp$Freq = temp$FqBde
        }
        
        gc()
        
        # aggregate duplicates
        temp <- aggregate(value  ~ Protocol + Patient + Medication + Task + Condition + variable + Freq + Channel + Region + grouping + Run + side + Event + isValid + isFOG + TOI,
                          temp, FUN = funType, na.rm = T, na.action = NULL)
        
        gc()
        
        # On compile les donnees de tous les patients
 #       if (exists('DAT_LFP')) {
  #        DAT_LFP <- rbind(DAT_LFP, temp)
   #     } else {
    #      DAT_LFP <- temp
     #   }
      #  print ("aggregate")
        
        
        
#        if (length(DAT_LFP$value) == 0) {stop()} #debugging tool
 #       
  #      rm('temp')
        gc()
      }
      iname = iname + 1
    }
    
    
    stopImplicitCluster()
    
    #############################################################################################
    ###### Mise en forme du fichier
    
    #TIMES
    # verifier fenetre de temps selectionnee
    DAT_LFP$times <- substr(DAT_LFP$variable, 2, 10)
    DAT_LFP$times[DAT_LFP$times == "_1"] = "_1_000"
    DAT_LFP$times[DAT_LFP$times == "_2"] = "_2_000"
    DAT_LFP$times[DAT_LFP$times == "_3"] = "_3_000"
    DAT_LFP$times[DAT_LFP$times == "_4"] = "_4_000"
    DAT_LFP$times[DAT_LFP$times == "_5"] = "_5_000"
    DAT_LFP$times <- gsub(pattern = '_0_', replacement = '-0.', x = DAT_LFP$times, fixed = TRUE)
    DAT_LFP$times <- gsub(pattern = '_1_', replacement = '-1.', x = DAT_LFP$times, fixed = TRUE)
    DAT_LFP$times <- gsub(pattern = '_2_', replacement = '-2.', x = DAT_LFP$times, fixed = TRUE)
    DAT_LFP$times <- gsub(pattern = '_3_', replacement = '-3.', x = DAT_LFP$times, fixed = TRUE)
    DAT_LFP$times <- gsub(pattern = '_4_', replacement = '-4.', x = DAT_LFP$times, fixed = TRUE)
    DAT_LFP$times <- gsub(pattern = '_5_', replacement = '-5.', x = DAT_LFP$times, fixed = TRUE)
    DAT_LFP$times <- gsub(pattern = '_'  , replacement = '.'  , x = DAT_LFP$times, fixed = TRUE)
    
    DAT_LFP$times <- as.numeric(DAT_LFP$times)
    DAT_LFP$times <- round(DAT_LFP$times, 4)
    if (ev == 'FOG_S' | ev == 'FOG_E') {
      DAT_LFP <- DAT_LFP[DAT_LFP$times > -2 & DAT_LFP$times < 1, ] #0.5
    } else {
      DAT_LFP <- DAT_LFP[DAT_LFP$times > -1 & DAT_LFP$times < 1, ] #0.5
    }
    print ("Verifs")
    
    DAT_LFP       <- DAT_LFP[, -which(colnames(DAT_LFP) == 'variable')]
    gc(verbose = FALSE)
    
    #HEM
    DAT_LFP$HEM   <- as.character(DAT_LFP$Channel)
    DAT_LFP$HEM   <- factor(substr(DAT_LFP$HEM, nchar(DAT_LFP$HEM), nchar(DAT_LFP$HEM)))
    
    #Chan
    DAT_LFP$Chan  <- as.character(DAT_LFP$Channel)
    DAT_LFP$Chan  <- factor(substr(DAT_LFP$Chan, 1, nchar(DAT_LFP$Chan)-1))
    
    # temp <- DAT_LFP
    #############################################################################################
    # ###### Moyennages
    # 
    
    # 
    #ORDER
    gc()
    
    if (protocol == 'GBMOV' | protocol == 'GBxxx') {
      DAT_LFP$Chan_o <-
        factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(7, 6, 5, 4, 3, 2, 1)]) # STN
    } else {
      DAT_LFP$Chan_o <-
        factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
    }
    
    
    DAT_LFP$HEM_o <- factor(DAT_LFP$HEM, levels = levels(DAT_LFP$HEM)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
    
    # rm(DAT_LFP)
    print ("transformation des donnees")
    
    #############################################################################################
    #### GRAPHES - Donnees individuelles
    ## Creation de la matrice pour enregistrer les lim dans chaque condition pour chaque patient
    iname = 1
    ivar = 1
    
    setwd(OutputDir)
    
    DAT_LFP$Chan_o <- as.character(DAT_LFP$Chan_o)
    DAT_LFP$HEM_o <- as.character(DAT_LFP$HEM_o)
    
    if (datatype == 'TF') {
      write.table(DAT_LFP, paste('MAGIC_temp_TF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'PE') {
      write.table(DAT_LFP, paste('MAGIC_temp_PE', '_', gp, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'meanTF') {
      write.table(DAT_LFP, paste('MAGIC_temp_meanTF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'FqBdes') {
      write.table(DAT_LFP, paste('MAGIC_temp_FqBdes', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    print ("export")
    print(Sys.time())
  }
}



