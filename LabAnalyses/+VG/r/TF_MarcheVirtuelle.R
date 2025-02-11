#############################################################################################
##                                                                                         ##
##                       Marche Virtuelle  -  cartes TF individuelles                      ##
##                                                                                         ##
#############################################################################################

# test analyse 1 fichier 02/10/19


#############################################################################################
###### Initialisation
# DEFINE PATHS
DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_protocoles_data/MarcheVirtuelle/02_electrophy'
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_protocoles_data/MarcheVirtuelle/03_outputs"
# OutputDir = "F:/DBStmp/TF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('ldNOR')
datatype = 'FqBdes' #'meanTF' #'PE' # TF 'FqBdes'
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
#SELECT EVENTS
events  = c('GAIT', 'DOOR', 'END')
funType = 'median' #  c('median', 'mean')
FqBdesLim  = c(1, 4, 8, 13, 21, 36, 61, 81)

for (nor in normtype) {
  for (gp in groups) {
    # SET SUBJECT
    if (gp == 'STN') {
      subjects <-
        c(
          'AUa_0342',
          'BEe_0412',
          'BEv_0474',
          'GUa_0357',
          'GUd_0327',
          'MAn_0397',
          'OGb_0403',
          'PHj_0351',
          'RUm_0418',
          'VEm_0402'
        )
      
      listnameSubj =
        c(
          "ParkPitie_2016_10_13_AUa",
          "ParkPitie_2018_03_08_BEe",
          "ParkPitie_2017_09_14_BEv",
          "ParkPitie_2017_01_26_GUa",
          "ParkPitie_2017_09_28_GUd",
          "ParkPitie_2018_01_18_MAn",
          "ParkPitie_2018_02_08_OGb",
          "ParkPitie_2016_12_15_PHj",
          "ParkPitie_2018_03_22_RUm",
          "ParkPitie_2018_02_01_VEm"
        )
    }
    else if (gp == 'PPN') {
      subjects <-
        c(
          'AVl_0444',
          'CHd_0343',
          'DEm_0423',
          'HAg_0372',
          'LEn_0367',
          'SOd_0363')
      listnameSubj =
        c(
          'PPNPitie_2018_07_05_AVl',
          'PPNPitie_2016_11_17_CHd',
          'PPNPitie_2018_04_26_DEm',
          'PPNPitie_2017_11_09_HAg',
          'PPNPitie_2017_06_08_LEn',
          'PPNPitie_2017_03_09_SOd'
        )
    }
    
    ## LIBRARY
    library(reshape2)
    library(RColorBrewer)
    library(ggplot2)
    
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    iname = 1
    
    # for (s in subjects) {
    for (s in listnameSubj) {
      # s=subjects
      
      # Chemin
      # RecDir = list.dirs(paste(DataDir , s, sep = ""),
      #                    full.names = T,
      #                    recursive = F)
      # setwd(paste(RecDir, '/POSTOP', sep = ""))
      setwd(paste(DataDir, s, sep = "/"))
      
      #SET PROTOCOL
      if (gp == 'STN') {
        # if (s == 'AUa_0342' |
        #     s == 'PHj_0351') {
        if (s == 'ParkPitie_2016_10_13_AUa' |
            s == 'ParkPitie_2016_12_15_PHj') {
          protocol = 'GBMOV'
        }
        else {
          protocol = 'GBxxx'
        }
      }
      else if (gp == 'PPN') {
        protocol = 'GAITPARK'
      }
      
      # Récupération nom de base du fichier
      name = list.files(
        # path = paste(RecDir, '/POSTOP', sep = ""),
        path = paste(DataDir, s, sep = "/"),
        pattern = NULL,
        all.files = FALSE,
        full.names = FALSE,
        recursive = FALSE,
        ignore.case = FALSE,
        include.dirs = FALSE,
        no.. = FALSE
      )
      name       <- matrix(unlist(strsplit(name[1], '_', fixed = FALSE, perl = FALSE, useBytes = FALSE)), ncol = 13, nrow = T)
      outputname <- paste(name[1], name[2], name[3], name[4], name[5], sep = "_")
      listname[iname] = outputname
      
      for (ev in events) {
        # Lecture du fichier
        if (nor == 'ldNOR') {
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_VG_SIT_TF_', 'dNOR', '_', ev, '.csv', sep = ""))
        } else {
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_VG_SIT_TF_', nor, '_', ev, '.csv', sep = ""))
        }
        
        # Vérifier nom des colonnes
        # On ne sélectionne que les channels stimulés
        temp <- temp[, c("Protocol", "Patient", "Medication", "Condition", "IsDoor", "Channel", "Freq", "Region", "grouping", "Run", "Event", "DoorCond", "quality",
            colnames(temp)[16:length(colnames(temp))] # 11:length(colnames(temp))]
          )]
        temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Condition", "IsDoor", "Freq", "Channel", "Region", "grouping", "Run", "Event", "DoorCond", "quality"))
        
        # keep only quality == 1 (reject events rejected by visual inspection)
        temp <- subset(temp, temp$quality == 1)
        
        
        # keep only doors <= P=3
        temp <- subset(temp, temp$DoorCond != "P=4")
        temp <- subset(temp, temp$DoorCond != "P=5")
        
        # transform to log if dNOR before averaging
        if (nor == 'ldNOR') {
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
        # temp <- aggregate(
        #     value  ~ Protocol + Patient + Medication + Condition + IsDoor + variable + Freq + Channel + Region + grouping + Run + Event ,
        #     temp, FUN = funType, na.rm = T, na.action = NULL)
        temp <- aggregate(
          value  ~ Protocol + Patient + Medication + Condition + IsDoor + variable + Freq + Channel + Region + grouping + Event ,
          temp, FUN = funType, na.rm = T, na.action = NULL)
        
        # On compile les données de tous les patients
        if (exists('DAT_LFP')) {DAT_LFP <- rbind(DAT_LFP, temp)
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
    DAT_LFP <- DAT_LFP[DAT_LFP$times > -1 & DAT_LFP$times < 1, ] #0.5
    
    DAT_LFP       <- DAT_LFP[, -which(colnames(DAT_LFP) == 'variable')]
    gc(verbose = FALSE)
    
    #HEM
    DAT_LFP$HEM   <- factor(substr(DAT_LFP$Channel, 3, 3))
    
    #Chan
    DAT_LFP$Chan  <- factor(substr(DAT_LFP$Channel, 1, 2))
    
    
    #############################################################################################
    ###### Moyennages
    
    temp <- DAT_LFP

    #ORDER
    if (protocol == 'GBMOV' | protocol == 'GBxxx') {
      temp$Chan_o <-
        factor(temp$Chan, levels = levels(temp$Chan)[c(3, 2, 1)]) # STN
    } else {
      temp$Chan_o <-
        factor(temp$Chan, levels = levels(temp$Chan)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
    }

    temp$HEM_o <-
      factor(temp$HEM, levels = levels(temp$HEM)[c(2, 1)]) # On inverse l'ordre des facteurs pour pr?senter gauche ? gauche et droite ? droite sur les graphes
    
    rm(DAT_LFP)
    
    
    #############################################################################################
    #### GRAPHES - Données individuelles
    ## Creation de la matrice pour enregistrer les lim dans chaque condition pour chaque patient
    iname = 1
    ivar = 1
    
    
    limlist = matrix(NaN, nrow = length(subjects), ncol = 17) #10
    colnames(limlist) = c(
      'Patient',
      'ON_D_Marche_NoPorte',
      'ON_D_Marche_Porte',
      'ON_D_Tapis_NoPorte',
      'ON_D_Tapis_Porte',
      'ON_G_Marche_NoPorte',
      'ON_G_Marche_Porte',
      'ON_G_Tapis_NoPorte',
      'ON_G_Tapis_Porte',
      'OFF_D_Marche_NoPorte',
      'OFF_D_Marche_Porte',
      'OFF_D_Tapis_NoPorte',
      'OFF_D_Tapis_Porte',
      'OFF_G_Marche_NoPorte',
      'OFF_G_Marche_Porte',
      'OFF_G_Tapis_NoPorte',
      'OFF_G_Tapis_Porte'
    )

    rownames(limlist) = subjects
    
    
    ## On sélectionne le patient dont on veut tracer la carte TF
    
    for (s in listnameSubj) {
      ivar  = 1
      temp2 <- temp[temp$Patient == s,]

      ## Selection de la MedCondition
      if (s == "PPNPitie_2018_04_26_DEm") {
        medCond = 'ON'
      } else{
        medCond = c('ON', 'OFF')
      }
      for (medcondi in medCond) {
        # medcondi = 'OFF'
        temp3 <- temp2[temp2$Medication == medcondi, ]
        # temp3 = temp2
        
        ## Sélection del'hémisphère
        hem = c('D', 'G')
        for (h in hem) {
          # h = 'G'
          temp4 <- temp3[temp3$HEM == h,]
          # temp4 <- temp3
          
          
          ## Sélection de la tâche
          task = c('marche', 'tapis')
          for (t in task) {
            # t = 'tapis'
            temp5 <-
              temp4[temp4$Condition == t, ] # Marche virtuelle sur tapis roulant
            
            ## Sélection de l'instruction
            inst = c('NoPorte', 'Porte')
            for (i in c(0, 1)) {
              # i = 0
              if (i == 0) {
                ii = inst[1]
              } else{
                ii = inst[2]
              }
              temp6 <- temp5[temp5$IsDoor == i,]
              
              
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp6$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
               ivar = ivar + 1
              rm(temp6)
            }
            rm(temp5)
          }
          rm(temp4)
        }
        rm(temp3)
      }
      iname = iname + 1
      rm(temp2)
    }
    
    # Write table des lim
    # setwd("F:/D/13_GAITPARK/MarcheVirtuelle/04_Traitement")
    setwd(OutputDir)
    # write.table(limlist, "limites_STN.csv")#, rownames = TRUE, colnames = TRUE)
    write.table(limlist, paste('limites', '_', datatype, '_', gp, '_', nor, '.csv', sep = ""))#, rownames = TRUE, colnames = TRUE)
    
    temp$Chan_o <- as.character(temp$Chan_o)
    temp$HEM_o <- as.character(temp$HEM_o)
    # write.table(temp, 'temp_STN.csv')
    write.table(temp, paste('temp', '_', datatype, '_', gp, '_', nor, funType, '.csv', sep = ""))
    
  }
}



