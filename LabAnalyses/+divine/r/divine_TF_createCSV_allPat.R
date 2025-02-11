#############################################################################################
##                                                                                         ##
##                       Divine  -  cartes TF individuelles                      ##
##                                                                                         ##
#############################################################################################



#############################################################################################
###### Initialisation
# DEFINE PATHS

# DataDir   = '//lexport/iss01.dbs/data/analyses/'
# OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/DIVINE/04_Traitement"
DataDir   = 'F:/DBStmp/data/analyses'
OutputDir = "F:/DBStmp/TF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('RAW')
# PRECISE GROUPS
groups   = c('STN')
# groups   = c('PPN')
#SELECT EVENTS
events  = c('sMOVIE', 'sMVT', 'GRASP', 'eMVT')
funType = 'median' #  c('median', 'mean')

for (nor in normtype) {
  for (gp in groups) {
    # SET SUBJECT
    if (gp == 'STN') {
      subjects <-
        c(
          'DEp_0535', 
          'FEp_0536', 
          'GIs_0550', 
          # 'MAs_0534', 
          'MEv_0529', 
          'REa_0526'
        )
      
      listnameSubj =
        c(
          "ParkPitie_2020_01_16_DEp",
          "ParkPitie_2020_02_20_FEp",
          "ParkPitie_2020_07_02_GIs",
          # "TOCPitie_2019_12_19_MAs",
          "TOCPitie_2020_02_10_MEv",
          "ParkPitie_2020_01_09_REa"
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
    library(FedData)
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    iname = 1
    
    for (s in subjects) {
      # s=subjects
      
      # Chemin
      RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
      setwd(paste(RecDir, '/POSTOP', sep = ""))
      
      #SET PROTOCOL
      protocol = 'DIVINE'
      
      
      # Récupération nom de base du fichier
      name = list.files(
        path = paste(RecDir, '/POSTOP', sep = ""),
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
        temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_SIT_TF_', nor, '_', ev, '.csv', sep = ""))
        
        temp$grouping[is.na(temp$grouping)] = ''
        
        # Vérifier nom des colonnes
        # On ne sélectionne que les channels stimulés
        temp <- temp[, c("Protocol", "Patient", "Medication", "Condition", "task", "Channel", "Freq", "Region", "grouping", "Run", "Event",
            colnames(temp)[14:length(colnames(temp))] # 11:length(colnames(temp))]
          )]
        temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Condition", "task", "Freq", "Channel", "Region", "grouping", "Run", "Event"))
        temp <- aggregate(
            value  ~ Protocol + Patient + Medication + Condition + task + variable + Freq + Channel + Region + grouping + Run + Event ,
            temp,
            FUN = funType, # 'mean',
            na.rm = T,
            na.action = NULL
          )
        
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
    DAT_LFP <- DAT_LFP[DAT_LFP$times > -1 & DAT_LFP$times < 1, ] #0.5
    
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
    DAT_LFP$Chan_o <- factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN

    DAT_LFP$HEM_o <- factor(DAT_LFP$HEM, levels = levels(DAT_LFP$HEM)[c(2, 1)]) # On inverse l'ordre des facteurs pour pr�senter gauche � gauche et droite � droite sur les graphes

    # rm(DAT_LFP)
    
    
    #############################################################################################
    #### GRAPHES - Données individuelles
    ## Creation de la matrice pour enregistrer les lim dans chaque condition pour chaque patient
    iname = 1
    ivar = 1
    
    # 
    # limlist = matrix(NaN, nrow = length(subjects), ncol = 17) #10
    # colnames(limlist) = c(
    #   'Patient',
    #   'ON_D_Marche_NoPorte',
    #   'ON_D_Marche_Porte',
    #   'ON_D_Tapis_NoPorte',
    #   'ON_D_Tapis_Porte',
    #   'ON_G_Marche_NoPorte',
    #   'ON_G_Marche_Porte',
    #   'ON_G_Tapis_NoPorte',
    #   'ON_G_Tapis_Porte',
    #   'OFF_D_Marche_NoPorte',
    #   'OFF_D_Marche_Porte',
    #   'OFF_D_Tapis_NoPorte',
    #   'OFF_D_Tapis_Porte',
    #   'OFF_G_Marche_NoPorte',
    #   'OFF_G_Marche_Porte',
    #   'OFF_G_Tapis_NoPorte',
    #   'OFF_G_Tapis_Porte'
    # )

    # rownames(limlist) = subjects
    
    
    ## On sélectionne le patient dont on veut tracer la carte TF
    
    # for (s in listnameSubj) {
    #   ivar  = 1
    #   temp2 <- temp[temp$Patient == s,]
    # 
    #   ## Selection de la MedCondition
    #   if (s == "PPNPitie_2018_04_26_DEm") {
    #     medCond = 'ON'
    #   } else{
    #     medCond = c('ON', 'OFF')
    #   }
    #   for (medcondi in medCond) {
    #     # medcondi = 'OFF'
    #     temp3 <- temp2[temp2$Medication == medcondi, ]
    #     # temp3 = temp2
    #     
    #     ## Sélection del'hémisphère
    #     hem = c('D', 'G')
    #     for (h in hem) {
    #       # h = 'G'
    #       temp4 <- temp3[temp3$HEM == h,]
    #       # temp4 <- temp3
    #       
    #       
    #       ## Sélection de la tâche
    #       task = c('marche', 'tapis')
    #       for (t in task) {
    #         # t = 'tapis'
    #         temp5 <-
    #           temp4[temp4$Condition == t, ] # Marche virtuelle sur tapis roulant
    #         
    #         ## Sélection de l'instruction
    #         inst = c('NoPorte', 'Porte')
    #         for (i in c(0, 1)) {
    #           # i = 0
    #           if (i == 0) {
    #             ii = inst[1]
    #           } else{
    #             ii = inst[2]
    #           }
    #           temp6 <- temp5[temp5$IsDoor == i,]
    #           
    #           
    #           
    #           ## Sélection des limites du graphe
    #           lim  <-
    #             max(abs(temp6$value)) # limites différentes pour chaque patient
    #           limlist[iname, ivar] = lim
    #           
    #            ivar = ivar + 1
    #           rm(temp6)
    #         }
    #         rm(temp5)
    #       }
    #       rm(temp4)
    #     }
    #     rm(temp3)
    #   }
    #   iname = iname + 1
    #   rm(temp2)
    # }
    # 
    # Write table des lim
    # setwd("F:/D/13_GAITPARK/MarcheVirtuelle/04_Traitement")
    setwd(OutputDir)
    # write.table(limlist, "limites_STN.csv")#, rownames = TRUE, colnames = TRUE)
    # write.table(limlist, paste('DIVINE_limites', '_', gp, '_', nor, '.csv', sep = ""))#, rownames = TRUE, colnames = TRUE)
    
    DAT_LFP$Chan_o <- as.character(DAT_LFP$Chan_o)
    DAT_LFP$HEM_o <- as.character(DAT_LFP$HEM_o)

    write.table(DAT_LFP, paste('DIVINE_temp', '_', gp, '_', nor, '_', funType, '.csv', sep = ""))
    
  }
}



