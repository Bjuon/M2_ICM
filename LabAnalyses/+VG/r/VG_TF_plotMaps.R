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
# DataDir   = '//lexport/iss01.dbs/data/analyses/'
InputDir  = "//l2export/iss02.pf-marche/02_protocoles_data/02_protocoles_data/MarcheVirtuelle/03_outputs"
# InputDir  = "F:/DBStmp/TF"
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_protocoles_data/MarcheVirtuelle/03_outputs/02_TFmaps"
PLotInd    = 1 # plot individual plots
PlotAll    = 1 # plot all pat plots
ElecGroup  = 1 # 1 if electrodes averaged by region
AvgHem     = 1 # 1 if electrodes averaged by region
plot_allFq = 0 # plot TF with one line per fq and not in TF

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('ldNOR')
datatype = 'FqBdes' #'TF' #meanTF' #'PE' # TF
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
# SELECT EVENTS
events = c('GAIT', 'DOOR', 'END')
# events = c('DOOR', 'END')
# funType = c('median', 'mean')
funType = c('median')
funAllPat = 'median'


OutPutFold = datatype
if (ElecGroup == 1) {
  OutPutFold = paste(OutPutFold, 'byRegion', sep='_')
}

if (AvgHem == 1) {
  OutPutFold = paste(OutPutFold, 'AvgHem', sep='_')
}

if (plot_allFq == 1) {
  OutPutFold = paste(OutPutFold, 'plot_allFq', sep='_')
}



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
      library(tidyr)
      
      ### Chemin
      setwd(InputDir)
      
      OutputPathInd = paste(OutputDir, gp, nor, paste(favg, '_', OutPutFold,  sep=""), sep = "/")
      dir.create(paste(OutputDir, gp, sep = "/")) 
      dir.create(paste(OutputDir, gp, nor, sep = "/")) 
      dir.create(OutputPathInd)

      OutputPathAll = paste(OutputDir, gp, nor, paste(favg, 'Ind-', funAllPat, 'All_', OutPutFold, sep=""), sep = "/")
      dir.create(OutputPathAll)
    
      
      #### Lecture fichier
      remove(temp2)
      temp2 <-
        read.table(paste('temp_', datatype, '_', gp, '_', nor, favg, '.csv', sep = ""))
      
      
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
      
      
      ### Mise en forme des donn?es des colonnes Channels et Hemisphere
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
        # temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(4,2,3)]) # PPN
        temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(2,3)]) # PPN
      }
      
      temp2$HEM_o <- as.factor(temp2$HEM_o)
      levels(temp2$HEM_o)
      temp2$HEM_o <-
        factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour pr?senter gauche ? gauche et droite ? droite sur les graphes
      
      
      temp2$Event <- as.factor(temp2$Event)
      levels(temp2$Event)
      temp2$Event <-
        factor(temp2$Event, levels = levels(temp2$Event)[c(3, 1, 2)]) # On inverse l'ordre des events pour avoir gait-door-end
      
      if (ElecGroup == 1) {
        temp2 <- subset(temp2, temp2$grouping != "")
        temp2$Chan_o = temp2$grouping
      } else {
          temp2$Chan_o = paste(temp2$Chan_o, temp2$grouping, sep = "_")
      } 
      
      if (AvgHem == 1) {
        temp2$HEM_o = "DetG"
      }
      
      # aggregate values
      temp2 = temp2[, c("Patient", "Medication", "Condition", "IsDoor", "Freq", "Event", "value", "times", "Chan_o", "HEM_o")]
      temp2 = aggregate( value ~ Patient + Medication + Condition + IsDoor + Event + Freq + times + Chan_o + HEM_o, temp2,
                         FUN = favg, na.rm = T, na.action = NULL)

      
      if (nor == 'RAW' | nor == 'dNOR') {
        temp2$value = 10*log10(Re(temp2$value))
      } else {
        temp2$value = Re(temp2$value)
      }
      
      
      
      ############################################################################################
      #############################################################################################
      ### Tapis / Marche / Marche-tapis ; (Porte + Pas Porte) / porte / pas porte
      ############################################################################################
      #############################################################################################
      conditions = c('allCond', 'marche', 'tapis', 'marche-tapis')
      doorCond   = c('allDoor', 'noDoor', 'Door', 'Door-noDoor')
      for (cond in conditions) {
        
        if (cond == 'marche' | cond == 'tapis') {
          temp3 <- subset(temp2, temp2$Condition == cond)
        } else if (cond == 'allCond') {
          temp3 = temp2
          temp3$Condition = 'marcheETtapis'
          temp3 = aggregate(value ~ Patient + Medication + Event + IsDoor + Freq + times + Chan_o + HEM_o, temp3,
                            FUN = funAllPat, na.rm = T, na.action = NULL)
          
        } else if (cond == 'marche-tapis') {
          ## Delta
          temp3marche   = subset(temp2, temp2$Condition == 'marche')
          temp3tapis    = subset(temp2, temp2$Condition == 'tapis')
          temp3         = merge(temp3marche, temp3tapis, by = c("Patient", "Medication", 'IsDoor', "Event", "Freq", "times", "Chan_o", "HEM_o"))
          temp3$value   = temp3$value.x - temp3$value.y
          temp3        = subset(temp3, select = -c(Condition.x, Condition.y, value.x, value.y))
          remove(temp3marche)
          remove(temp3tapis)
          # temp3       = temp2[temp2$Condition == 'marche', c('Patient', 'Medication', 'Event', 'IsDoor', 'Freq', 'times', 'Chan_o', 'HEM_o')]
          # temp3$value = temp2[temp2$Condition == 'marche', c('value')] - temp2[temp2$Condition == 'tapis', c('value')]
          
        }
        
        for (d in doorCond) {
          if (d == 'noDoor') {
            temp4 <- subset(temp3, temp3$IsDoor == 0)
          } else if (d == 'Door') {
            temp4 <- subset(temp3, temp3$IsDoor == 1)
          } else if (d == 'allDoor') {
            temp4 = temp3
            temp4$IsDoor = 0.5
            temp4 = aggregate(value ~ Patient + Medication + Event + Freq + times + Chan_o + HEM_o, temp4,
                              FUN = funAllPat, na.rm = T, na.action = NULL)
          } else if (d == 'Door-noDoor') {
            temp4door   = subset(temp3, temp3$IsDoor == 1)
            temp4nodoor = subset(temp3, temp3$IsDoor == 0)
            temp4        = merge(temp4door, temp4nodoor, by = c("Patient", "Medication", "Event", "Freq", "times", "Chan_o", "HEM_o"))
            temp4$value  = temp4$value.x - temp4$value.y
            temp4        = subset(temp4, select = -c(IsDoor.x, IsDoor.y, value.x, value.y))
            remove(temp4door)
            remove(temp4nodoor)
            # temp4       = temp3[temp3$IsDoor == 1, c('Patient', 'Medication', 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o')]
            # temp4$value = temp3[temp3$IsDoor == 1, c('value')] - temp3[temp3$IsDoor == 0, c('value')]
            
            
          }
          
          
          ###### individual plots############################################################
          ###################################################################################
          if (PLotInd == 1) {
            for (s in listnameSubj) {
              remove(temp4_ind)
              temp4_ind <- temp4[temp4$Patient == s,]
              
              # lim  <- max(abs(temp4_ind$value))
              lim = 10
              
              ## GRAPH
              
              if (plot_allFq == 0) {
                if (datatype == "TF"){
                  ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                    geom_raster(interpolate = F) + scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim),
                                                                        na.value = "#7F0000") +
                    geom_vline(xintercept = 0, size = .1) + theme_classic() +
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE, scales = "free_x") +
                    ggtitle(paste(s, nor, cond, d, favg, sep = "_")) +
                    theme(text=element_text(size=20))} # plot.title = element_text(hjust = 0.5))
                
                
                if (datatype == "FqBdes"){
                  ggplot(temp4_ind, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event , drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, nor, cond, d, 'FqBdes', favg , sep = "_")) +
                    theme(text = element_text(size=20))}
                
                
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, nor, cond, d, favg, sep = "_"), '.png', sep = ""),
                       width = 32, height = 5)
                
              } else if (plot_allFq == 1) {
                
                # very low freq : 1 - 15
                temp4_ind_fq1 <- temp4_ind[temp4_ind$Freq <= 15,]
                
                ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'verylowFq', favg , sep = "_")) +
                  theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
                
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, nor, cond, favg, 'verylowFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)
                
                
                # low freq : 12 - 35
                temp4_ind_fq1 <- temp4_ind[temp4_ind$Freq >= 12,]
                temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 35,]
                
                ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'lowFq', favg , sep = "_")) +
                  theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, nor, cond, favg, 'lowFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)              
                
                
                # high freq : 30 - 65              
                temp4_ind_fq1 <- temp4_ind[temp4_ind$Freq >= 30,]
                temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 65,]
                
                ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'HighFq', favg , sep = "_")) +
                  theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, nor, cond, favg, 'HighFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)
                
                
                # very high freq : 60 - 80              
                temp4_ind_fq1 <- temp4_ind[temp4_ind$Freq >= 60,]
                temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 80,]
                
                ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'veryHighFq', favg , sep = "_")) +
                  theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, nor, cond, favg, 'veryHighFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)
              }
            }
          }
          
          ####### all patients ############################################################
          #################################################################################
          
          if (PlotAll == 1) {
            # temp4 = aggregate(value ~ Medication + Event + Freq + times + grouping, temp4,
            #                   FUN = funAllPat, na.rm = T, na.action = NULL)
            temp4 = aggregate(value ~ Medication + HEM_o + Event + Freq + times + Chan_o, temp4,
                              FUN = funAllPat, na.rm = T, na.action = NULL)
            
            # 
            # lim  <- max(abs(temp4$value)) # limites diff?rentes pour chaque patient
            # 
            lim = 3
            # lim  <- max(abs(temp2$value)) # m?mes limites pour tous les sujets
            
            ## GRAPH
            if (plot_allFq == 0) {
              if (datatype == "TF"){
                ggplot(temp4, aes(x = times, y = Freq, fill = value)) +
                  geom_raster(interpolate = F) + 
                  scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#7F0000") +
                  geom_vline(xintercept = 0, size = .1) + theme_classic() +
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE, scales = "free_x") +
                  ggtitle(paste(gp, nor, cond, d, favg, funAllPat, sep = "_")) +
                  theme(text=element_text(size=20))} # theme(plot.title = element_text(hjust = 0.5))
              
              if (datatype == "FqBdes"){
                ggplot(temp4, aes(x = times, y= value, color = as.factor(Freq))) +
                  geom_line() +  # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ Medication + HEM_o + Event , drop = TRUE,scales = "free_x") +
                  ggtitle(paste(gp, nor, cond, d, 'FqBdes', favg, funAllPat , sep = "_")) +
                  theme(text = element_text(size=20))}              
              
              ## sauvegarde des graphes
              ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, d, favg, funAllPat, sep = "_"), '.png',sep = ""),
                     width = 32, height = 5)
              
              
            } else if (plot_allFq == 1) {
              
              # very low freq : 1 - 15
              temp4_fq1 <- temp4[temp4$Freq <= 15,]
              
              ggplot(temp4_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                geom_line() + # ylim(-lim, lim) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + 
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste(gp, 'verylowFq', favg , sep = "_")) +
                theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
              ## sauvegarde des graphes
              ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, favg, 'verylowFq', sep = "_"), '.png', sep = ""),
                     width = 32, height =18, units = "cm")
              remove(temp4_ind_fq1)
              
              
              # low freq : 12 - 35
              temp4_fq1 <- temp4[temp4$Freq >= 12,]
              temp4_fq1 <- temp4_fq1[temp4_fq1$Freq <= 35,]
              
              ggplot(temp4_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                geom_line() + # ylim(-lim, lim) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + 
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste(gp, 'lowFq', favg , sep = "_")) +
                theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
              ## sauvegarde des graphes
              ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, favg, 'lowFq', sep = "_"), '.png', sep = ""),
                     width = 32, height =18, units = "cm")
              remove(temp4_ind_fq1)              
              
              
              # high freq : 30 - 65              
              temp4_fq1 <- temp4[temp4$Freq >= 30,]
              temp4_fq1 <- temp4_fq1[temp4_fq1$Freq <= 65,]
              
              ggplot(temp4_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                geom_line() + # ylim(-lim, lim) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + 
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste(gp, 'HighFq', favg , sep = "_")) +
                theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
              ## sauvegarde des graphes
              ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, favg, 'HighFq', sep = "_"), '.png', sep = ""),
                     width = 32, height =18, units = "cm")
              remove(temp4_ind_fq1)
              
              
              # very high freq : 60 - 80              
              temp4_fq1 <- temp4[temp4$Freq >= 60,]
              temp4_fq1 <- temp4_fq1[temp4_fq1$Freq <= 80,]
              
              ggplot(temp4_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                geom_line() + # ylim(-lim, lim) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + 
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste(gp, 'veryHighFq', favg , sep = "_")) +
                theme(text=element_text(size=20)) # theme(plot.title = element_text(hjust = 0.5))
              ## sauvegarde des graphes
              ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, favg, 'veryHighFq', sep = "_"), '.png', sep = ""),
                     width = 32, height =18, units = "cm")
              remove(temp4_fq1)
            }            
            
            remove(temp4)
          }
        }
        remove(temp3)
      }
    }
  }
}