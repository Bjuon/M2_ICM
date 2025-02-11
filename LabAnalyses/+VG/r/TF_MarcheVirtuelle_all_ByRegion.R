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
PLotInd    = 1 # plot individual plots
PlotAll    = 1 # plot all pat plots

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('zNOR')
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
# SELECT EVENTS
events = c('GAIT', 'DOOR', 'END')
# events = c('DOOR', 'END')
# funType = c('median', 'mean')
funType = c('median')
funAllPat = 'median'


### loop by fun type
for (favg in funType) {
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
      OutputPathAll = paste(OutputDir, gp, nor, paste(favg, 'Ind-', funAllPat, 'All', sep=""), sep = "/")
      OutputPathInd = paste(OutputDir, gp, nor, favg, sep = "/")
      
      #### Lecture fichier
      remove(temp2)
      temp2 <-
        read.table(paste('temp', '_', gp, '_', nor, favg, '.csv', sep = ""))
      
      
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
      
      
      temp2$grouping <- as.factor(temp2$grouping)
      levels(temp2$grouping)
      if (gp == 'STN') {
        # temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(3, 2)]) # STN
        # merge STNa and STNs
        # temp2$grouping <- factor(substr(temp2$grouping, 1, 3))
      } else if (gp == 'PPN') {
        temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(4,2,3)]) # PPN
      }
      
      temp2$HEM_o <- as.factor(temp2$HEM_o)
      levels(temp2$HEM_o)
      temp2$HEM_o <-
        factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
      
      
      temp2$Event <- as.factor(temp2$Event)
      levels(temp2$Event)
      temp2$Event <-
        factor(temp2$Event, levels = levels(temp2$Event)[c(3, 1, 2)]) # On inverse l'ordre des events pour avoir gait-door-end
      
      
      temp2 = temp2[, c("Patient", "Medication", "Condition", "IsDoor", "Freq", "Event", "value", "times", "grouping", "HEM_o" )]
      temp2 = aggregate( value ~ Patient + Medication + Condition + IsDoor + Event + Freq + times + grouping + HEM_o, temp2,
                         FUN = favg,
                         na.rm = T,
                         na.action = NULL
      )
      
      if (nor == 'RAW' | nor == 'dNOR') {
        temp2$value = 10*log10(Re(temp2$value))
      } else {
        temp2$value = Re(temp2$value)
      }
      
      
      temp2 <- subset(temp2, temp2$grouping != "")
      
      ############################################################################################
      #############################################################################################
      ### Tapis / Marche / Marche-tapis ; (Porte + Pas Porte) / porte / pas porte
      ############################################################################################
      #############################################################################################
      conditions = c('marche', 'tapis', 'marche-tapis')
      doorCond   = c('allDoor', 'noDoor', 'Door', 'Door-noDoor')
      for (cond in conditions) {
        
        if (cond == 'marche' | cond == 'tapis') {
          temp3 <- subset(temp2, temp2$Condition == cond)
        } else if (cond == 'marche-tapis') {
          ## Delta
          temp3       = temp2[temp2$Condition == 'marche', c('Patient', 'Medication', 'Event', 'IsDoor', 'Freq', 'times', 'grouping', 'HEM_o')] # 'Chan_o', 'HEM_o')]
          temp3$value = temp2[temp2$Condition == 'marche', c('value')] - temp2[temp2$Condition == 'tapis', c('value')]
        }
        
        for (d in doorCond) {
          if (d == 'noDoor') {
            temp4 <- subset(temp3, temp3$IsDoor == 0)
          } else if (d == 'Door') {
            temp4 <- subset(temp3, temp3$IsDoor == 1)
          } else if (d == 'allDoor') {
            temp4 = temp3
          } else if (d == 'Door-noDoor') {
            temp4       = temp3[temp3$IsDoor == 1, c('Patient', 'Medication', 'Event', 'Freq', 'times', 'grouping', 'HEM_o')] # 'Chan_o', 'HEM_o')]
            temp4$value = temp3[temp3$IsDoor == 1, c('value')] - temp3[temp3$IsDoor == 0, c('value')]
          }
          
          
          ###### individual plots############################################################
          ###################################################################################
          if (PLotInd == 1) {
            for (s in listnameSubj) {
              remove(temp4_ind)
              temp4_ind <- temp4[temp4$Patient == s,]
              
              lim  <- max(abs(temp4_ind$value))
              
              
              ## GRAPH
              ggplot(temp4_ind, aes(
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
                facet_grid(grouping ~ Medication + HEM_o + Event,
                           drop = TRUE,
                           scales = "free_x") +
                ggtitle(paste(s, nor, cond, d, favg , sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5))
              
              ## sauvegarde des graphes
              ggsave(paste(OutputPathInd, '/', paste(s, nor, cond, d, favg, sep = "_"), '.png', sep = ""),
                     width = 6,
                     height = 8)
            }
          }
          
          ####### all patients ############################################################
          #################################################################################
          
          if (PlotAll == 1) {
            temp4 = aggregate(value ~ Medication + Event + Freq + times + grouping + HEM_o,temp4,
                              FUN = funAllPat,
                              na.rm = T,
                              na.action = NULL)
            
            # 
            # lim  <- max(abs(temp4$value)) # limites différentes pour chaque patient
            # 
            lim = 15
            # lim  <- max(abs(temp2$value)) # mêmes limites pour tous les sujets
            
            ## GRAPH
            ggplot(temp4, aes(
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
              facet_grid(grouping ~ Medication + HEM_o + Event,
                         drop = TRUE,
                         scales = "free_x") +
              ggtitle(paste(gp, nor, cond, d, favg, funAllPat, sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
            
            
            
            
            ## sauvegarde des graphes
            ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, d, favg, funAllPat, sep = "_"), '.png', sep = ""),
                   width = 6,
                   height = 8)
            
            
            remove(temp4)
          }
        }
        remove(temp3)
      }
    }
  }
}