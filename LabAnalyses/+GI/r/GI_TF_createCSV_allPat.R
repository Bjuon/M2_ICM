#############################################################################################
##                                                                                         ##
##                       GI  -  cartes TF individuelles                      ##
##                                                                                         ##
#############################################################################################



#############################################################################################
###### Initialisation
# DEFINE PATHS

DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/03_outputs"
# DataDir   = 'D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/data/analyses'
# OutputDir = "D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/TF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')

segType  = 'step' #'trial'   'step' 
normtype = c('ldNOR')
datatype = 'TF' #'meanTF' #'PE' #  'FqBdes' LFP_EMG_CO
tBlock   = '05' #'0375'
fqStart  = '1'
CO_meth  = c('JNcoh') #'JNcoh' 'MVcoh'
rect     = c('rect')
# PRECISE GROUPS
groups   = c('STN')
# groups   = c('PPN')

funType = 'mean' #  c('median', 'mean')
FqBdesLim  = c(1, 4, 8, 13, 21, 36, 61, 81)


#SELECT EVENTS
if (segType == 'step') {
  events  = c('FOG_S', 'FOG_E') #c('T0', 'T0_EMG', 'FO1', 'FC1') #, 'FO', 'FOG_S', 'FOG_E') #, 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E')
} else if (segType == 'trial') {
  events  = c('BSL')
}


for (nor in normtype) {
  for (gp in groups) {
    # SET SUBJECT
    if (gp == 'STN') {
      subjects <-
        c(
          'ALg_0245',
          'CLn_0142',
          'COd_0138',
          'DEm_0250',
          'FRl_0137',
          'LEc_0203',
          'MAd_0186',
          'MEp_0170',
          'RAt_0239',
          'REs_0065',
          'ROe_0063',
          'SAj_0265',
          'SOj_0106',
          'VAp_0249'
        )
      
      listnameSubj =
        c(
          "ParkPitie_2015_05_07_ALg",
          "ParkPitie_2013_10_24_CLn",
          "ParkPitie_2013_10_10_COd",
          "ParkPitie_2015_05_28_DEm",
          "ParkPitie_2013_10_17_FRl",
          "ParkPitie_2014_06_19_LEc",
          "ParkPitie_2014_04_18_MAd",
          "ParkPitie_2015_01_15_MEp",
          "ParkPitie_2015_03_05_RAt",
          "ParkPitie_2013_04_04_REs",
          "ParkPitie_2013_03_21_ROe",
          "ParkPitie_2015_10_01_SAj",
          "ParkPitie_2013_06_06_SOj",
          "ParkPitie_2015_04_30_VAp"
        )
    }
    else if (gp == 'PPN') {
      subjects <-
        c(
          'AVl_0444' ,
          'CHd_0343',
          'LEn_0367',
          'SOd_0363')
      listnameSubj =
        c(
          'PPNPitie_2018_07_05_AVl',
          'PPNPitie_2016_11_17_CHd',
          'PPNPitie_2017_06_08_LEn',
          'PPNPitie_2017_03_09_SOd'
        )
    }
    
    ## LIBRARY
    library(reshape2)
    library(RColorBrewer)
    library(ggplot2)
    library(FedData)
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    iname = 1
    
    #s_count = 0
    s_count = 0
    
    for (s in subjects) {
      # s=subjects
      s_count = s_count + 1
      
      # Chemin
      # RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
      # setwd(paste(RecDir, '/POSTOP', sep = ""))
      RecDir = paste(DataDir , listnameSubj[s_count], sep = "/")
      setwd(RecDir)
      
      #SET PROTOCOL
      if (gp == 'STN') {
          protocol = 'GBMOV'
      } else if (gp == 'PPN') {
        protocol = 'GAITPARK'
      }
      
      outputname <- listnameSubj[s_count]
      
      for (ev in events) {
        # Lecture du fichier
        if (datatype == 'TF' | datatype == 'FqBdes') {
          if ((nor == 'ldNOR') & segType  == 'step') {
            # temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', segType, '_TF_', 'dNOR', '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
            temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_', segType, '_TF_', 'dNOR', '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          } else {
            temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', segType, '_TF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          }
          temp$TOI = 'EVT' # Time Of Interest
          
        } else if (datatype == 'PE') {
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_PE_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
          
        } else if (datatype == 'meanTF') {
          temp     <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', segType, '_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
          if (segType == '') {
            temp_bsl <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_BSL.csv', sep = ""))
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
        } else if (datatype == 'LFP_EMG_CO') {
          if (nor == 'ldNOR') {nor_tmp = 'dNOR'
          } else {nor_tmp = nor}
          
          if (CO_meth == 'JNcoh') {
            file_suff = paste('_tBlock', tBlock, sep = "")
          } else if (CO_meth == 'MVcoh') {
            file_suff = ''
          }
          if (rect == 'rect') {rect_suff = '_rect'
          } else {rect_suff = ''}
          
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_LFP_EMG_', CO_meth, '_', nor_tmp, file_suff,  rect_suff, '_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
        } 
        
        # # # # # for debug only
        # temp$Segment = 'APA'
        # # # # # # 
        
        temp$Region[is.na(temp$Region)] = ''
        temp$grouping[is.na(temp$grouping)] = ''
        temp$nStep[is.na(temp$nStep)] = ''
        temp$side[is.na(temp$side)] = ''
        
        # keep only quality == 1 (reject events rejected by visual inspection)
        temp <- subset(temp, temp$quality == 1)
        
        
        # temp <- temp[, c("Protocol", "Patient", "Medication", "Condition", "Channel", "Freq", "Region", "grouping", "Run", "side","Event", "isValid",
        #                   colnames(temp)[16:length(colnames(temp))])]
        temp <- temp[, c("Protocol", "Patient", "Medication", "Segment", "Condition", "Channel", "Freq", "Region", "grouping", "Run", "side","Event", "isValid",
                         colnames(temp)[17:length(colnames(temp))])]
        temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Condition", "Segment", "Freq", "Channel", "Region", "grouping", "Run", "side", "Event", "isValid", "TOI"))
        
        # transform to log if dNOR before averaging
        if ((nor == 'ldNOR' | nor == 'RAW') & segType  == 'step') {
          temp$value = 10*log10(Re(temp$value))
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
        
        # aggregate duplicates
        temp <- aggregate(value  ~ Protocol + Patient + Medication + Condition + Segment + variable + Freq + Channel + Region + grouping + Run + side + Event + isValid + TOI,
                          temp, FUN = funType, na.rm = T, na.action = NULL)
        
        # On compile les données de tous les patients
        if (exists('DAT_LFP')) {
          DAT_LFP <- rbind(DAT_LFP, temp)
        } else {
          DAT_LFP <- temp
        }
        
        rm('temp')
        gc(verbose = FALSE)
        
      }
      iname = iname + 1
    }
    
    
    #############################################################################################
    ###### Mise en forme du fichier
    
    #TIMES
    # vérifier fenêtre de temps sélectionnée
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
    DAT_LFP$times <- gsub(pattern = '_', replacement = '.', x = DAT_LFP$times, fixed = TRUE)
    
    DAT_LFP$times <- as.numeric(DAT_LFP$times)
    DAT_LFP$times <- round(DAT_LFP$times, 4)
    # DAT_LFP <- DAT_LFP[DAT_LFP$times > -1 & DAT_LFP$times < 1, ] #0.5
    DAT_LFP <- DAT_LFP[DAT_LFP$times > -2 & DAT_LFP$times < 1, ] #0.5
    
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
    if (protocol == 'GBMOV' | protocol == 'GBxxx') {
      DAT_LFP$Chan_o <-
        factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(3, 2, 1)]) # STN
    } else {
      DAT_LFP$Chan_o <-
        factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
    }
    
    
    DAT_LFP$HEM_o <- factor(DAT_LFP$HEM, levels = levels(DAT_LFP$HEM)[c(2, 1)]) # On inverse l'ordre des facteurs pour pr鳥nter gauche ࠧauche et droite ࠤroite sur les graphes
    
    # rm(DAT_LFP)
    
    
    #############################################################################################
    #### GRAPHES - Données individuelles
    ## Creation de la matrice pour enregistrer les lim dans chaque condition pour chaque patient
    iname = 1
    ivar = 1
    
    setwd(OutputDir)
    
    DAT_LFP$Chan_o <- as.character(DAT_LFP$Chan_o)
    DAT_LFP$HEM_o <- as.character(DAT_LFP$HEM_o)
    
    if (datatype == 'TF') {
      write.table(DAT_LFP, paste('GI_temp_TF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'PE') {
      write.table(DAT_LFP, paste('GI_temp_PE', '_', gp, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'meanTF') {
      write.table(DAT_LFP, paste('GI_temp_meanTF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'FqBdes') {
      write.table(DAT_LFP, paste('GI_temp_FqBdes', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'LFP_EMG_CO') {
      write.table(DAT_LFP, paste('GI_temp_LFP_EMG_CO', '_', segType, '_', gp, '_', nor, '_', CO_meth, file_suff, rect_suff, '_', funType, '.csv', sep = ""))
    }
    
  }
}



