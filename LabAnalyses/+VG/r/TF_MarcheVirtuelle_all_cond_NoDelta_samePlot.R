#############################################################################################
##                                                                                         ##
##                       Marche Virtuelle  -  Delta TF Porte - NoPorte                     ##
##                                                                                         ##
#############################################################################################

# test analyse 1 fichier 22/10/19


############################################################################################
#############################################################################################
###### Initialisation
# DEFINE PATHS
DataDir   = '//lexport/iss01.dbs/data/analyses/'
InputDir  = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheVirtuelle/04_Traitement"
# InputDir  = "F:/DBStmp/TF"
OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheVirtuelle/04_Traitement/03_CartesTF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('dNOR')
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('PPN')
# SELECT EVENTS
events = c('GAIT', 'DOOR', 'END')
# events = c('DOOR', 'END')

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
        c('AVl_0444',
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
    
    ### LIBRARY ----
    library(reshape2)
    library(RColorBrewer)
    library(ggplot2)
    
    ### Chemin
    setwd(InputDir)
    OutputPath = paste(OutputDir, gp, nor, sep = "/")
    
    #### Lecture fichier
    # tempp <- read.table('temp_PPN.csv')
    # tempp <- read.table('temp_STN.csv')
    temp2 <-
      read.table(paste('temp', '_', gp, '_', nor, '.csv', sep = ""))

    
    ### Patients
    # subjects <-  c('AVl_0444',  'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
    # listname = c('PPNPitie_2018_07_05_AVl','PPNPitie_2016_11_17_CHd','PPNPitie_2018_04_26_DEm','PPNPitie_2017_11_09_HAg','PPNPitie_2017_06_08_LEn','PPNPitie_2017_03_09_SOd')
    # subjects <-  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
    # listname = c("ParkPitie_2016_10_13_AUa", "ParkPitie_2018_03_08_BEe", "ParkPitie_2017_09_14_BEv", "ParkPitie_2017_01_26_GUa", "ParkPitie_2017_09_28_GUd",
    #             "ParkPitie_2018_01_18_MAn", "ParkPitie_2018_02_08_OGb", "ParkPitie_2016_12_15_PHj", "ParkPitie_2018_03_22_RUm", "ParkPitie_2018_02_01_VEm")
    
    ### Protocole
    # protocol <- 'GAITPARK'
    # if (s == 'AUa_0342' | s == 'PHj_0351') {protocol = 'GBMOV'} else {protocol = 'GBxxx'}
    
    
    ### Definition des couleurs
    myPalette  <-
      colorRampPalette(
        c(
          "#00007F",
          "#00007F",
          "blue",
          "#007FFF",
          "cyan",
          "#7FFF7F",
          "yellow",
          "#FF7F00",
          "red",
          "#7F0000",
          "#7F0000"
        )
      )
    
    # temp2 = tempp
    
    ### Mise en forme des données des colonnes Channels et Hemisphere
    temp2$Chan_o <- as.character(temp2$Chan_o)
    temp2$Chan_o[temp2$Chan_o %in% c("1")] <- "01"
    temp2$Chan_o <- as.factor(temp2$Chan_o)
    levels(temp2$Chan_o)
    
     
    #ORDER (on veut 01 en bas)
    if (gp == 'STN') {
      temp2$Chan_o <- factor(temp2$Chan_o, levels = levels(temp2$Chan_o)[c(3, 2, 1)]) # STN
    } else if (gp == 'PPN') {
      temp2$Chan_o <- factor(temp2$Chan_o, levels = levels(temp2$Chan_o)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
    }
    
    temp2$HEM_o <- as.factor(temp2$HEM_o)
    levels(temp2$HEM_o)
    temp2$HEM_o <-
      factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
    
    
    temp2$Event <- as.factor(temp2$Event)
    levels(temp2$Event)
    temp2$Event <-
      factor(temp2$Event, levels = levels(temp2$Event)[c(3, 1, 2)]) # On inverse l'ordre des events pour avoir gait-door-end
    
    
    temp2 = temp2[, c(
      "Patient",
      "Medication",
      "Condition",
      "IsDoor",
      "Freq",
      "Event",
      "value",
      "times",
      "Chan_o",
      "HEM_o"
    )]
    temp2 = aggregate(
      value ~ Patient + Medication + Condition + IsDoor + Event + Freq + times + Chan_o + HEM_o,
      temp2,
      FUN = 'median',
      na.rm = T,
      na.action = NULL
    )
    
    
    if (nor == 'RAW' | nor == 'dNOR') {
      temp2$value = 10*log10(Re(temp2$value))
    } else {
      temp2$value = Re(temp2$value)
    }
    
    
    ############################################################################################
    #############################################################################################
    ### TAPIS / Marche (Porte + Pas Porte)
    ############################################################################################
    #############################################################################################
    conditions = c('marche', 'tapis')
    for (cond in conditions) {
      temp3 <- subset(temp2, temp2$Condition == cond)
      temp3 = aggregate(
        value ~ Medication + Event + Freq + times + Chan_o + HEM_o,
        temp3,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      # 
      lim  <- max(abs(temp3$value)) # limites différentes pour chaque patient
      # 
      # lim = 0.5
        # lim  <- max(abs(temp2$value)) # mêmes limites pour tous les sujets
      
      ## GRAPH
      ggplot(temp3, aes(
        x = times,
        y = Freq,
        fill = value
      )) +
        geom_raster(interpolate = F) + scale_fill_gradientn(
          colours = myPalette(100),
          #lim = c(-lim, lim),
          na.value = "#7F0000"
        ) +
        geom_vline(xintercept = 0, size = .1) +
        theme_classic() +
        facet_grid(Chan_o ~ Medication + HEM_o + Event,
                   drop = TRUE,
                   scales = "free_x") +
        ggtitle(paste(gp, nor, cond, "median" , sep = "_")) +
        theme(plot.title = element_text(hjust = 0.5))
      
      ## sauvegarde des graphes
      ggsave(paste(
        OutputPath,
        '/',
        paste(gp, 'TF', nor, cond, 'median.png', sep = "_"),
        sep = ""
      ),
      width = 6,
      height = 8)
      
      
      remove(temp3)
    }

    
    ############################################################################################
    #############################################################################################
    ### Marche - Tapis (Porte + Pas Porte)
    ############################################################################################
    #############################################################################################
    
    ## Delta
    temp3       = temp2[temp2$Condition == 'marche', c('Patient', 'Medication', 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o')]
    temp3$value = temp2[temp2$Condition == 'marche', c('value')] - temp2[temp2$Condition == 'tapis', c('value')]
    
    temp3 = aggregate(
      value ~ Medication + Event + Freq + times + Chan_o + HEM_o,
      temp3,
      FUN = 'median',
      na.rm = T,
      na.action = NULL
    )

    lim  <- max(abs(temp3$value)) # limites différentes pour chaque patient
    # 
      # lim  = 0.01
    
    ## GRAPH
    ggplot(temp3, aes(
      x = times,
      y = Freq,
      fill = value
    )) +
      geom_raster(interpolate = F) + scale_fill_gradientn(
        colours = myPalette(100),
        lim = c(-lim, lim),
        na.value = "#7F0000"
      ) +
      geom_vline(xintercept = 0, size = .1) +
      theme_classic() +
      facet_grid(Chan_o ~ Medication + HEM_o + Event,
                 drop = TRUE,
                 scales = "free_x") +
      ggtitle(paste(gp, nor, 'marche-tapis', "median" , sep = "_")) +
      theme(plot.title = element_text(hjust = 0.5))
    
    ## sauvegarde des graphes
    ggsave(paste(
      OutputPath,
      '/',
      paste(gp, 'TF', nor, 'marche-tapis', 'median.png', sep = "_"),
      sep = ""
    ),
    width = 6,
    height = 8)
    
    
    remove(temp3)
    
    
    ############################################################################################
    #############################################################################################
    ### Porte / Pas Porte (Tapis + Marche)
    ############################################################################################
    #############################################################################################
    
    door = c(0,1)
    for (d in door) {
      if (d == 0) {
        figName = 'noPorte'
      }
      else {
        figName = 'porte'
      }
      
      
      temp3 <- subset(temp2, temp2$IsDoor == d)
      temp3 = aggregate(
        value ~ Medication + Event + Freq + times + Chan_o + HEM_o,
        temp3,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      # 
      lim  <- max(abs(temp3$value)) # limites différentes pour chaque patient
      # 
      # lim = 0.5
      
      # lim  <- max(abs(temp2$value)) # mêmes limites pour tous les sujets
      
      ## GRAPH
      ggplot(temp3, aes(
        x = times,
        y = Freq,
        fill = value
      )) +
        geom_raster(interpolate = F) + scale_fill_gradientn(
          colours = myPalette(100),
          # lim = c(-lim, lim),
          na.value = "#7F0000"
        ) +
        geom_vline(xintercept = 0, size = .1) +
        theme_classic() +
        facet_grid(Chan_o ~ Medication + HEM_o + Event,
                   drop = TRUE,
                   scales = "free_x") +
        ggtitle(paste(gp, nor, figName, "median" , sep = "_")) +
        theme(plot.title = element_text(hjust = 0.5))
      
      ## sauvegarde des graphes
      ggsave(paste(
        OutputPath,
        '/',
        paste(gp, 'TF', nor, figName, 'median.png', sep = "_"),
        sep = ""
      ),
      width = 6,
      height = 8)
      
      
      remove(temp3)
      
    }
      
    ############################################################################################
    #############################################################################################
    ### Porte - Pas Porte (Tapis + Marche)
    ############################################################################################
    #############################################################################################
    
    ## Delta
    temp4 <- subset(temp2, temp2$Event != 'DOOR')
    temp3       = temp4[temp4$IsDoor == 1, c('Patient', 'Medication', 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o')]
    temp3$value = temp4[temp4$IsDoor == 1, c('value')] - temp4[temp4$IsDoor == 0, c('value')]
    
    temp3 = aggregate(
      value ~ Medication + Event + Freq + times + Chan_o + HEM_o,
      temp3,
      FUN = 'median',
      na.rm = T,
      na.action = NULL
    )
    
    lim  <- max(abs(temp3$value)) # limites différentes pour chaque patient
    # 
    
    # lim = 0.01
    
    ## GRAPH
    ggplot(temp3, aes(
      x = times,
      y = Freq,
      fill = value
    )) +
      geom_raster(interpolate = F) + scale_fill_gradientn(
        colours = myPalette(100),
        lim = c(-lim, lim),
        na.value = "#7F0000"
      ) +
      geom_vline(xintercept = 0, size = .1) +
      theme_classic() +
      facet_grid(Chan_o ~ Medication + HEM_o + Event,
                 drop = TRUE,
                 scales = "free_x") +
      ggtitle(paste(gp, nor, 'porte-noPorte', "median" , sep = "_")) +
      theme(plot.title = element_text(hjust = 0.5))
    
    ## sauvegarde des graphes
    ggsave(paste(
      OutputPath,
      '/',
      paste(gp, 'TF', nor, 'porte-pasPorte', 'median.png', sep = "_"),
      sep = ""
    ),
    width = 6,
    height = 8)
    
    
    remove(temp4)
    remove(temp3)
    remove(temp2)
  }
}