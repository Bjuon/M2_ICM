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
DataDir   = 'F:/DBStmp_Matthieu/data'
# InputDir  = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/DIVINE/04_Traitement"
InputDir  = "F:/DBStmp_Matthieu/TF"
OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/04_Traitement/03_CartesTF"
PLotInd    = 1 # plot individual plots
PlotAll    = 0 # plot all pat plots
ElecGroup  = 0 # 1 if electrodes averaged by region
TimeLim    = 1
ColLim     = 20
filt = 'noHP_'


# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('')
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('PPN')
# SELECT EVENTS
# conditions = c('APA', 'step', 'turn', 'FOG')
conditions = c('step')
# funType = c('median', 'mean')
funType   = c('mean') # 'median'
funAllPat = 'median' # 'median'


OutPutFold = paste(filt, 'Lim_Time', TimeLim, 's_Col', ColLim, sep='')
if (ElecGroup == 1) {
  OutPutFold = paste(OutPutFold, 'byRegion', sep='')
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
      
      ### Chemin
      setwd(InputDir)
      
      OutputPathAll = paste(OutputDir, gp, nor, paste('PE_', favg, 'Ind-', funAllPat, 'All', sep=""), sep = "/")
      OutputPathInd = paste(OutputDir, gp, nor, paste('PE_', favg, '_', OutPutFold,  sep=""), sep = "/")
      
      dir.create(paste(OutputDir, gp, sep = "/")) 
      dir.create(OutputPathInd)
      
      #### Lecture fichier
      remove(temp2)
      temp2 <- read.table(paste('GI_temp_PE', '_', gp, '_', favg, '.csv', sep = ""))
      
      
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
      # levels(temp2$Event)
      # temp2$Event <-
      #   factor(temp2$Event, levels = levels(temp2$Event)[c(7, 4, 2, 3, 1, 9, 8, 6, 5)]) # On inverse l'ordre des events pour avoir gait-door-end
      # temp2$Event <-
      #   factor(temp2$Event, levels = levels(temp2$Event)[c(5, 4, 2, 3, 1)])
      # temp2$Event <-
      #   factor(temp2$Event, levels = levels(temp2$Event)[c(3, 2, 1)])
      
      # if (ElecGroup == 1) {
      #   temp2 = temp2[, c("Patient", "Medication", "Condition", "quality", "isValid", "Freq", "Event", "value", "times", "grouping", "HEM_o", "side" )]
      #   temp2 = aggregate( value ~ Patient + Medication + Condition + quality + isValid + Event + Freq + times + grouping + HEM_o, temp2, side,
      #                      FUN = favg,
      #                      na.rm = T,
      #                      na.action = NULL)
      # } else if (ElecGroup == 0) {
      #   temp2 = temp2[, c("Patient", "Medication", "Condition", "quality", "isValid", "Freq", "Event", "value", "times", "Chan_o", "HEM_o", "side" )]
      #   temp2 = aggregate( value ~ Patient + Medication + Condition + quality + isValid + Event + Freq + times + Chan_o + HEM_o, temp2, side,
      #                      FUN = favg,
      #                      na.rm = T,
      #                      na.action = NULL)
      # }
      
      if (ElecGroup == 1) {
        temp2 = temp2[, c("Patient", "Medication", "Condition", "Event", "value", "times", "grouping", "HEM_o")] # , "side" )]
        temp2 = aggregate( value ~ Patient + Medication + Condition  + Event + times + grouping + HEM_o, temp2, # + side
                           FUN = favg,
                           na.rm = T,
                           na.action = NULL)
      } else if (ElecGroup == 0) {
        temp2 = temp2[, c("Patient", "Medication", "Condition", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
        temp2 = aggregate( value ~ Patient + Medication + Condition + Event + times + Chan_o + HEM_o , temp2,  # + side
                           FUN = favg,
                           na.rm = T,
                           na.action = NULL)
      }
      
      
      if (nor == 'RAW' | nor == 'dNOR') {
        temp2$value = 10*log10(Re(temp2$value))
      } else if (nor == 'zNOR') {
        temp2$value = Re(temp2$value)
      }
      
      if (ElecGroup == 1) {
        temp2 <- subset(temp2, temp2$grouping != "")
      }
      
      #############################################################################################
      ### select quality and validity
      ############################################################################################
      
      
      
      ############################################################################################
      #############################################################################################
      ### 1 plot per condition
      ############################################################################################
      #############################################################################################
      for (cond in conditions) {
        temp3 <- subset(temp2, temp2$Condition == cond)
        # if (ElecGroup == 1) {
        #   temp3 = aggregate( value ~ Patient + Medication + Event + Freq + times + grouping + HEM_o, temp3,
        #                      FUN = favg,
        #                      na.rm = T,
        #                      na.action = NULL)
        # }  else if (ElecGroup == 0) {
        #   temp3 = aggregate( value ~ Patient + Medication + Event + Freq + times + Chan_o + HEM_o, temp3,
        #                    FUN = favg,
        #                    na.rm = T,
        #                    na.action = NULL)
        # }
        
        if (cond == 'APA') {
          # temp3$Event <- factor(temp3$Event, levels = levels(temp3$Event)[c(3, 2, 1)])
          temp3$Event <- factor(temp3$Event, levels = c("T0", "FO1", "FC1"))
        } else if (cond == 'FOG'){
          # temp3$Event <- factor(temp3$Event, levels = levels(temp3$Event)[c(2, 1)])
          temp3$Event <- factor(temp3$Event, levels = c("FOG_S", "FOG_E"))
        } else if (cond == 'turn'){
          # temp3$Event <- factor(temp3$Event, levels = levels(temp3$Event)[c(2, 1)])
          temp3$Event <- factor(temp3$Event, levels = c("turn_S", "turn_E"))
        } else if (cond == 'step'){
          # temp3$Event <- factor(temp3$Event, levels = levels(temp3$Event)[c(2, 1)])
          temp3$Event <- factor(temp3$Event, levels = c("FO", "FC"))
        } 
        
        
        if (PLotInd == 1) {
          for (s in listnameSubj) {
            remove(temp4_ind)
            temp4_ind <- temp3[temp3$Patient == s,]
            
            temp4_ind <- temp4_ind[temp4_ind$times >= (-1 * TimeLim) & temp4_ind$times <= TimeLim, ] #0.5
            
            # lim  <- max(abs(temp4_ind$value))
            lim = ColLim
            
            ## GRAPH
 
            if (ElecGroup == 1) {
              ggplot(temp4_ind, aes(x = times, y= value)) +
                geom_line() + ylim(-lim, lim) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + 
                facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste(s, 'PE', cond, favg , sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5))
              
            } else if (ElecGroup == 0) {
              ggplot(temp4_ind, aes(x = times, y= value)) +
                geom_line() + ylim(-lim, lim) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + 
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste(s, 'PE', cond, favg , sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5))
            }
            ## sauvegarde des graphes
            ggsave(paste(OutputPathInd, '/', paste('PE', s, cond, favg, sep = "_"), '.png', sep = ""),
                   width = 32, height =18, units = "cm")
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