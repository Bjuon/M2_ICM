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
DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
InputDir  = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/03_outputs"
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/03_outputs/02_TFmaps"
# DataDir   = 'D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/data'
# InputDir  = "D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/TF"
# OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/04_Traitement/03_CartesTF"
PLotInd    = 1 # plot individual plots
PlotAll    = 0 # plot all pat plots
ElecGroup  = 0 # 1 if electrodes averaged by region
TimeLim    = 1
FreqLim    = 1
ColLim     = 10
plot_allFq = 0 # plot TF with one line per fq and not in TF


# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')
segType  = 'step'  #'trial' , 'step' 
normtype = c('ldNOR')
datatype = 'TF' #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05' # '05'
fqStart  = '1'
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
# SELECT EVENTS
# Segments = c('APA', 'step', 'turn', 'FOG')
Segments = c('step')
# funType = c('median', 'mean')
funType   = c('mean') # 'median'
funAllPat = 'mean' # 'median'

OutPutFold = paste('Lim_Time', TimeLim, 's_Freq', FreqLim, 'Hz_Col', ColLim, sep='')
if (ElecGroup == 1) {
  OutPutFold = paste(OutPutFold, 'byRegion', sep='_')
} 

if (plot_allFq == 1) {
  OutPutFold = paste(OutPutFold, 'plot_allFq', sep='_')
}

if (datatype == 'LFP_EMG_CO') {
  if (CO_meth == 'JNcoh') {
    file_suff = paste('_tBlock', tBlock, '_', nor, sep = "")
  } else if (CO_meth == 'MVcoh') {
    file_suff = paste('_', nor, sep = "")
  }
  if (rect == 'rect') {
    file_suff = paste(file_suff, 'rect', sep = '_')
  }
}

### loop by fun type
for (favg in funType) {
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
        read.table(paste('GI_temp_', datatype, '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', favg, '.csv', sep = ""))

      
      ### Mise en forme des données des colonnes Channels et Hemisphere
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
      
      temp2$HEM_o <- as.factor(temp2$HEM_o)
      levels(temp2$HEM_o)
      temp2$HEM_o <-
        factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
      
      
      temp2$Event <- as.factor(temp2$Event)
      
      # # aggregate values
      # if (ElecGroup == 1) {
      #   temp2 = temp2[, c("Patient", "Medication", "Segment", "isValid", "Freq", "Event", "value", "times", "grouping", "HEM_o")] # , "side" )]
      #   temp2 = aggregate( value ~ Patient + Medication + Segment + isValid + Event + Freq + times + grouping + HEM_o, temp2, # + side
      #                      FUN = favg,
      #                      na.rm = T,
      #                      na.action = NULL)
      # } else if (ElecGroup == 0) {
      #   temp2 = temp2[, c("Patient", "Medication", "Segment", "isValid", "Freq", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
      #   temp2 = aggregate( value ~ Patient + Medication + Segment + isValid + Event + Freq + times + Chan_o + HEM_o , temp2,  # + side
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
      ### 1 plot per Segment
      ############################################################################################
      #############################################################################################
      for (cond in Segments) {
        

        
        if (cond == 'APA') {
          temp3 <- subset(temp2, temp2$Segment == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("T0", "T0_EMG", "FO1", "FC1"))
        } else if (cond == 'FOG'){
          temp3 <- subset(temp2, temp2$Segment == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        } else if (cond == 'turn'){
          temp3 <- subset(temp2, temp2$Segment == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("TURN_S", "TURN_E"))
        } else if (cond == 'step'){
          temp3 <- subset(temp2, temp2$Segment == cond)
          temp3 <- subset(temp3, temp3$isValid == 1)
          temp3$Event <- factor(temp3$Event, levels = c("FO", "FC"))
        } else if (cond == 'FOGturn'){
          temp3 <- subset(temp2, temp2$Segment == 'FOG')
          temp3 <- subset(temp3, temp3$isValid == 0)
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        } else if (cond == 'FOGall'){
          temp3 <- subset(temp2, temp2$Segment == 'FOG')
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        }
        
        temp3 <- temp3[temp3$Freq >= FreqLim,]
        
        
        
        # aggregate values
        if (ElecGroup == 1) {
          temp3 = temp3[, c("Patient", "Medication", "Segment", "Freq", "Event", "value", "times", "grouping", "HEM_o")] # , "side" )]
          temp3 = aggregate( value ~ Patient + Medication + Segment + Event + Freq + times + grouping + HEM_o, temp3, # + side
                             FUN = favg,
                             na.rm = T,
                             na.action = NULL)
        } else if (ElecGroup == 0) {
          temp3 = temp3[, c("Patient", "Medication", "Segment", "Freq", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
          temp3 = aggregate( value ~ Patient + Medication + Segment + Event + Freq + times + Chan_o + HEM_o , temp3,  # + side
                             FUN = favg,
                             na.rm = T,
                             na.action = NULL)
        }
        
        
        if ((nor == 'RAW' | nor == 'dNOR') & segType  == 'trial'){
          temp3$value = 10*log10(Re(temp3$value))
        } else {
          temp3$value = Re(temp3$value)
        }
        
        if (ElecGroup == 1) {
          temp3 <- subset(temp3, temp3$grouping != "")
        }
        

        if (PLotInd == 1) {
          for (s in listnameSubj) {
            remove(temp4_ind)
            temp4_ind <- temp3[temp3$Patient == s,]
            
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
                  ggtitle(paste(s, nor, cond, favg , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5))
              } else if (ElecGroup == 0) {
                ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                  geom_raster(interpolate = F) + 
                  scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#7F0000") +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() +
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, nor, cond, favg , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5))
              }
              ## sauvegarde des graphes
              ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, favg, sep = "_"), '.png', sep = ""),
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
              ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, favg, 'verylowFq', sep = "_"), '.png', sep = ""),
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
              ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, favg, 'lowFq', sep = "_"), '.png', sep = ""),
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
              ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, favg, 'HighFq', sep = "_"), '.png', sep = ""),
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
              ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, favg, 'veryHighFq', sep = "_"), '.png', sep = ""),
                     width = 32, height =18, units = "cm")
              remove(temp4_ind_fq1)
            }
              
          }
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