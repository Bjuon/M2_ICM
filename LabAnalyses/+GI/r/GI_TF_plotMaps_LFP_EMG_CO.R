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
DataDir   = 'D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/data'
# InputDir  = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/DIVINE/04_Traitement"
InputDir  = "D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/TF"
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/04_Traitement/03_CartesTF"
PLotInd    = 1 # plot individual plots
PlotAll    = 0 # plot all pat plots
ElecGroup  = 0 # 1 if electrodes averaged by region
TimeLim    = 1
FreqLim    = 1
ColLim     = 1
plot_allFq = 0 # plot TF with one line per fq and not in TF


# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')
segType  = 'step'  #'trial' , 'step' 
normtype = c('sNOR')
datatype = 'LFP_EMG_CO' #'meanTF' #'PE' # TF 'FqBdes'
CO_meth  = c('MVcoh') #'JNcoh' 'MVcoh'
rect     = c('rect')
tBlock   = '02' # '05'
fqStart  = '1'
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('PPN')
# SELECT EVENTS
# conditions = c('APA', 'step', 'turn', 'FOG')
conditions = c('APA')
# funType = c('median', 'mean')
funType   = c('median') # 'median'
funAllPat = 'median' # 'median'

OutPutFold = paste(datatype, '_Lim_Time', TimeLim, 's_Freq', FreqLim, 'Hz_Col', ColLim, sep='')
if (ElecGroup == 1) {
  OutPutFold = paste(OutPutFold, 'byRegion', sep='_')
} 

if (plot_allFq == 1) {
  OutPutFold = paste(OutPutFold, 'plot_allFq', sep='_')
}

### loop by fun type
for (favg in funType) {
  for (nor in normtype) {
    
    if (datatype == 'LFP_EMG_CO') {
      if (nor == 'ldNOR') {nor_tmp = 'dNOR'
      } else {nor_tmp = nor}
      if (CO_meth == 'JNcoh') {
        file_suff = paste('_tBlock', tBlock, sep = "")
      } else if (CO_meth == 'MVcoh') {
        file_suff = ''
      }
      if (rect == 'rect') {rect_suff = '_rect'
      } else {rect_suff = ''}
    }
    
    
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
            'LEn_0367',
            'SOd_0363'
        )
        listnameSubj =
          c(
            'PPNPitie_2018_07_05_AVl',
            'PPNPitie_2016_11_17_CHd',
            'PPNPitie_2017_06_08_LEn',
            'PPNPitie_2017_03_09_SOd'
          )
      }
      
      ### LIBRARY ----
      library(reshape2)
      library(RColorBrewer)
      library(ggplot2)

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
      
      ### Chemin
      setwd(InputDir)
      
      OutputPathAll = paste(OutputDir, gp, nor, paste(favg, 'Ind-', funAllPat, 'All', sep=""), sep = "/")
      OutputPathInd = paste(OutputDir, gp, nor, paste(favg, '_', OutPutFold,  sep=""), sep = "/")
      
      dir.create(paste(OutputDir, gp, sep = "/")) 
      dir.create(paste(OutputDir, gp, nor, sep = "/")) 
      dir.create(OutputPathInd)
      
      #### Lecture fichier
      remove(temp2)
      temp2 <-
        read.table(paste('GI_temp_LFP_EMG_CO', '_', segType, '_', gp, '_', nor, '_', CO_meth, file_suff, rect_suff, '_', funType, '.csv', sep = ""))
      
      
      
      ### Mise en forme des données des colonnes Channels et Hemisphere et EMG
      temp2$Chan_o   <- factor(substr(temp2$Channel, 1, 2)) 
      temp2$EMG      <- factor(substr(temp2$Channel, 5, 7))
      temp2$HEM  <- factor(substr(temp2$Channel, 3, 3)) 
      temp2$Chan_o <- as.character(temp2$Chan_o)
      temp2$Chan_o[temp2$Chan_o %in% c("1")] <- "01"
      temp2$Chan_o <- as.factor(temp2$Chan_o)
      levels(temp2$Chan_o)
      #ORDER (on veut 01 en bas)
      temp2$Chan_o <- factor(temp2$Chan_o, levels = levels(temp2$Chan_o)[c(7, 6, 5, 4, 3, 2, 1)])
      
      
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
      
      temp2$HEM_o <- as.factor(temp2$HEM)
      levels(temp2$HEM_o)
      temp2$HEM_o <-
        factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
      
      
      temp2$Event <- as.factor(temp2$Event)
      
      # # aggregate values
      # if (ElecGroup == 1) {
      #   temp2 = temp2[, c("Patient", "Medication", "Condition", "isValid", "Freq", "Event", "value", "times", "grouping", "HEM_o")] # , "side" )]
      #   temp2 = aggregate( value ~ Patient + Medication + Condition + isValid + Event + Freq + times + grouping + HEM_o, temp2, # + side
      #                      FUN = favg,
      #                      na.rm = T,
      #                      na.action = NULL)
      # } else if (ElecGroup == 0) {
      #   temp2 = temp2[, c("Patient", "Medication", "Condition", "isValid", "Freq", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
      #   temp2 = aggregate( value ~ Patient + Medication + Condition + isValid + Event + Freq + times + Chan_o + HEM_o , temp2,  # + side
      #                      FUN = favg,
      #                      na.rm = T,
      #                      na.action = NULL)
      # }
      # 
      # 
      # if ((nor == 'RAW' | nor == 'dNOR') & segType  == 'trial'){
      #   temp2$value = 10*log10(Re(temp2$value))
      # } else {
      #   temp2$value = Re(temp2$value)
      # }
      # 
      # if (ElecGroup == 1) {
      #   temp2 <- subset(temp2, temp2$grouping != "")
      # }
 
      # # keep only valid == 1 (event without FOG)
      # temp2 <- subset(temp2, temp2$isValid == 1)
      # 
      
      ############################################################################################
      #############################################################################################
      ### 1 plot per condition
      ############################################################################################
      #############################################################################################
      for (cond in conditions) {
        

        
        if (cond == 'APA') {
          temp3 <- subset(temp2, temp2$Condition == 'trial')
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("T0", "T0_EMG", "FO1", "FC1"))
        } else if (cond == 'FOG'){
          temp3 <- subset(temp2, temp2$Condition == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        } else if (cond == 'turn'){
          temp3 <- subset(temp2, temp2$Condition == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("TURN_S", "TURN_E"))
        } else if (cond == 'step'){
          temp3 <- subset(temp2, temp2$Condition == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("FO", "FC"))
        } else if (cond == 'FOGturn'){
          temp3 <- subset(temp2, temp2$Condition == 'FOG')
          temp3 <- subset(temp3, temp3$isValid == 0)
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        } else if (cond == 'FOGall'){
          temp3 <- subset(temp2, temp2$Condition == 'FOG')
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        }
        
        temp3 <- temp3[temp3$Freq >= FreqLim,]
        
        
        
        for (EMGch in unique(temp3$EMG)) {
          temp3_EMG <- subset(temp3, temp3$EMG == EMGch)
          
          # aggregate values
          if (ElecGroup == 1) {
            temp3_EMG = temp3_EMG[, c("Patient", "Medication", "Condition", "Freq", "Event", "value", "times", "grouping", "HEM_o")] # , "side" )]
            temp3_EMG = aggregate( value ~ Patient + Medication + Condition + Event + Freq + times + grouping + HEM_o, temp3_EMG, # + side
                               FUN = favg,
                               na.rm = T,
                               na.action = NULL)
          } else if (ElecGroup == 0) {
            temp3_EMG = temp3_EMG[, c("Patient", "Medication", "Condition", "Freq", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
            temp3_EMG = aggregate( value ~ Patient + Medication + Condition + Event + Freq + times + Chan_o + HEM_o , temp3_EMG,  # + side
                               FUN = favg,
                               na.rm = T,
                               na.action = NULL)
          }
          
          
          if ((nor == 'RAW' | nor == 'dNOR') & segType  == 'trial'){
            temp3_EMG$value = 10*log10(Re(temp3_EMG$value))
          } else {
            temp3_EMG$value = Re(temp3_EMG$value)
          }
          
          if (ElecGroup == 1) {
            temp3_EMG <- subset(temp3_EMG, temp3_EMG$grouping != "")
          }
          
          
          if (PLotInd == 1) {
            for (s in listnameSubj[2:4]) {
              remove(temp4_ind)
              temp4_ind <- temp3_EMG[temp3_EMG$Patient == s,]
              
              temp4_ind <- temp4_ind[temp4_ind$times >= (-1 * TimeLim) & temp4_ind$times <= TimeLim, ] #0.5
              
              # lim  <- max(abs(temp4_ind$value))
              lim = ColLim
              
              
              if (nrow(temp4_ind) == 0) {
                next
              }
              
              
              ## GRAPH
              
              if (plot_allFq == 0) {
                
                if (ElecGroup == 1) {
                  ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                    geom_raster(interpolate = F) + 
                    scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#7F0000") +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() +
                    facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, nor, EMGch, CO_meth, cond, favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                } else if (ElecGroup == 0) {
                  ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                    geom_raster(interpolate = F) + 
                    scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#7F0000") +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() +
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, nor, EMGch, CO_meth, cond, favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                }
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, nor, EMGch, paste(CO_meth, file_suff, rect_suff, sep = ''), cond, favg, sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                
              } else if (plot_allFq == 1) {
                if (cond == 'APA') {
                  temp4_ind2 <- temp4_ind[(temp4_ind$Event == 'T0' | temp4_ind$Event == "T0_EMG" | temp4_ind$Event == 'FO1'),]
                  temp4_ind2$Event <- factor(temp4_ind2$Event, levels = c("T0", "T0_EMG", "FO1"))
                } else if (cond == 'step') {
                  temp4_ind2 <- temp4_ind[temp4_ind$Event == 'FO',]
                } else if (cond == 'turn') {
                  temp4_ind2 <- temp4_ind[temp4_ind$Event == 'turn_S',]
                } else if (cond == 'FOG' | cond == 'FOGturn' | cond == 'FOGall') {
                  temp4_ind2 <- temp4_ind[(temp4_ind$Event == 'FOG_S' | temp4_ind$Event == 'FOG_E'),]
                  temp4_ind2$Event <- factor(temp4_ind2$Event, levels = c("FOG_S", "FOG_E"))
                }  
                
                # very low freq : 1 - 15
                temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq <= 15,]
                
                if (ElecGroup == 1) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() + # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'verylowFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                  
                } else if (ElecGroup == 0) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'verylowFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                }
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, EMGch, paste(CO_meth, file_suff, rect_suff, sep = ''), cond, favg, 'verylowFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)
                
                
                # low freq : 12 - 35
                temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq >= 12,]
                temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 35,]
                
                if (ElecGroup == 1) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() + # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'lowFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                  
                } else if (ElecGroup == 0) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'lowFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                }
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, EMGch, paste(CO_meth, file_suff, rect_suff, sep = ''), cond, favg, 'lowFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)              
                
                
                # high freq : 30 - 65              
                temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq >= 30,]
                temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 65,]
                
                if (ElecGroup == 1) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() + # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'HighFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                  
                } else if (ElecGroup == 0) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'HighFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                }
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, EMGch, paste(CO_meth, file_suff, rect_suff, sep = ''), cond, favg, 'HighFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)
                
                
                # very high freq : 60 - 80              
                temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq >= 60,]
                temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 80,]
                
                if (ElecGroup == 1) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() + # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'veryHighFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                  
                } else if (ElecGroup == 0) {
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'veryHighFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                }
                ## sauvegarde des graphes
                ggsave(paste(OutputPathInd, '/', paste(s, EMGch, paste(CO_meth, file_suff, rect_suff, sep = ''), cond, favg, 'veryHighFq', sep = "_"), '.png', sep = ""),
                       width = 32, height =18, units = "cm")
                remove(temp4_ind_fq1)
              }
              
            }
          } 
          
          remove(temp3_EMG)
        }
        remove(temp3)
      }
      
      #     ####### all patients ############################################################
      #     #################################################################################
      #     
      #     if (PlotAll == 1) {
      #       temp4 = aggregate(value ~ Medication + Event + Freq + times + grouping + HEM_o,temp4,
      #                         FUN = funAllPat,
      #                         na.rm = T,
      #                         na.action = NULL)
      #       
      #       # 
      #       # lim  <- max(abs(temp4$value)) # limites différentes pour chaque patient
      #       # 
      #       lim = 15
      #       # lim  <- max(abs(temp2$value)) # mêmes limites pour tous les sujets
      #       
      #       ## GRAPH
      #       ggplot(temp4, aes(
      #         x = times,
      #         y = Freq,
      #         fill = value
      #       )) +
      #         geom_raster(interpolate = F) + scale_fill_gradientn(
      #           colours = myPalette(100),
      #           lim = c(-lim, lim),
      #           na.value = "#7F0000"
      #         ) +
      #         geom_vline(xintercept = 0, size = .1) +
      #         theme_classic() +
      #         facet_grid(grouping ~ Medication + HEM_o + Event,
      #                    drop = TRUE,
      #                    scales = "free_x") +
      #         ggtitle(paste(gp, nor, cond, d, favg, funAllPat, sep = "_")) +
      #         theme(plot.title = element_text(hjust = 0.5))
      #       
      #       
      #       
      #       
      #       ## sauvegarde des graphes
      #       ggsave(paste(OutputPathAll, '/', paste(gp, nor, cond, d, favg, funAllPat, sep = "_"), '.png', sep = ""),
      #              width = 6,
      #              height = 8)
      #       
      #       
      #       remove(temp4)
      #     }
      #   }
      #   remove(temp3)
      # }
    }
  }
}