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
DataDir   = 'F:/IR-IHU-ICM/Donnees/Analyses/DBS/DBStmp_Matthieu/data'
# InputDir  = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/DIVINE/04_Traitement"
InputDir  = "F:/IR-IHU-ICM/Donnees/Analyses/DBS/DBStmp_Matthieu/TF"
# OutputDir  = "F:/IR-IHU-ICM/Donnees/Analyses/DBS/DBStmp_Matthieu/TF"
OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/04_Traitement/03_CartesTF"
PLotInd    = 1 # plot individual plots
PlotAll    = 0 # plot all pat plots
ElecGroup  = 1 # 1 if electrodes averaged by region
ColLim     = 'noLim' # 'noLim'
FreqLim    = 100 # 100
filt       = '' # 'noHP_'
tBlock     = '05'
fqStart    = '1'
noLog      = 0 # force no log even if RAW

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')
segType  = 'trial' # if 'step' keep ''
normtype = c('ldNOR')
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('PPN')
# SELECT EVENTS
# conditions = c('APA', 'step', 'turn', 'FOG')
conditions = c('trial')
# funType = c('median', 'mean')
funType   = c('median') # 'median'
funAllPat = 'mean' # 'median'


OutPutFold = paste(filt, 'LimFreq', FreqLim,'Hz_Col', ColLim, sep='')
if (nor == 'RAW' & noLog == 1)  {
  OutPutFold = paste(OutPutFold, '_noLog', sep='')
} 
if (ElecGroup == 1) {
  OutPutFold = paste(OutPutFold, '_byRegion', sep='')
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
      
      OutputPathAll = paste(OutputDir, gp, nor, paste('meanTF_', segType, '_', favg, 'Ind-', funAllPat, 'All', sep=""), sep = "/")
      OutputPathInd = paste(OutputDir, gp, nor, paste('meanTF_', segType, '_', favg, '_', OutPutFold,  sep=""), sep = "/")
      
      dir.create(paste(OutputDir, gp, sep = "/")) 
      dir.create(paste(OutputDir, gp, nor, sep = "/")) 
      dir.create(OutputPathInd)
      
      #### Lecture fichier
      remove(temp2)
      temp2 <- read.table(paste('GI_temp_meanTF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', favg, '.csv', sep = ""))
      
      
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
      
      
      ### Mise en forme des donn�es des colonnes Channels et Hemisphere
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
        temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(2,3)]) # PPN
      }
      
      temp2$HEM_o <- as.factor(temp2$HEM_o)
      levels(temp2$HEM_o)
      temp2$HEM_o <-
        factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour pr�senter gauche � gauche et droite � droite sur les graphes
      
      
      temp2$Event <- as.factor(temp2$Event)
      temp2$TOI <- as.factor(temp2$TOI)

      if (ElecGroup == 1) {
        temp2 = temp2[, c("Patient", "Medication", "Condition", "Event", "value", "Freq", "grouping", "HEM_o", "isValid", "TOI")] # , "side" )]
        temp2 = aggregate( value ~ Patient + Medication + Condition  + Event + Freq + grouping + HEM_o + isValid + TOI, temp2, # + side
                           FUN = favg,
                           na.rm = T,
                           na.action = NULL)
      } else if (ElecGroup == 0) {
        temp2 = temp2[, c("Patient", "Medication", "Condition", "Event", "value", "Freq", "Chan_o", "HEM_o", "isValid", "TOI" )] # , "side" )]
        temp2 = aggregate( value ~ Patient + Medication + Condition + Event + Freq + Chan_o + HEM_o + isValid + TOI, temp2, # + side
                           FUN = favg,
                           na.rm = T,
                           na.action = NULL)
      }
      
      
      if ((nor == 'RAW' ) & (noLog == 0)){
        temp2$value = 10*log10(Re(temp2$value))
      } else if (nor == 'zNOR' | nor == 'dNOR') {
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
        
        if (segType == '') {
          temp3 <- subset(temp2, temp2$Condition == cond)
          
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
        }
        else if (segType == 'trial') {
          temp3 <- temp2
          temp3$Condition <- factor(temp3$Condition, levels = c("BSL", "APA", "exec", "step", "turn", "FOG", "FOGnoTurn", "FOGturn"))
        }
        
        if (PLotInd == 1) {
          for (s in listnameSubj) {
            remove(temp4_ind)
            temp4_ind <- temp3[temp3$Patient == s,]
            
            temp4_ind <- temp4_ind[temp4_ind$Freq <= FreqLim, ] #0.5
            
            # lim  <- max(abs(temp4_ind$value))
            lim = ColLim
            
            ## GRAPH
            if (segType == '') {
              if (ElecGroup == 1) {
                ggplot(temp4_ind, aes(x = Freq, y= value, color = TOI)) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'meanTF', cond, favg , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5))
                
              } else if (ElecGroup == 0) {
                ggplot(temp4_ind, aes(x = Freq, y= value, color = TOI)) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'meanTF', cond, favg , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5))
              }
            }  
            else if (segType == 'trial') {
              if (ElecGroup == 1) {
                ggplot(temp4_ind, aes(x = Freq, y= value, color = Condition)) +
                  geom_line() + # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(grouping ~ isValid + Medication + HEM_o, drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'meanTF', favg , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5))
                
              } else if (ElecGroup == 0) {
                ggplot(temp4_ind, aes(x = Freq, y= value, color = Condition)) +
                  geom_line() +  # ylim(-lim, lim) +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + 
                  facet_grid(Chan_o ~ isValid + Medication + HEM_o , drop = TRUE,scales = "free_x") +
                  ggtitle(paste(s, 'meanTF', favg , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5))
              }
            }
            ## sauvegarde des graphes
            ggsave(paste(OutputPathInd, '/', paste('meanTF', s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, favg, sep = "_"), '.png', sep = ""),
                   width = 32, height =18, units = "cm")
          }
        } 
        remove(temp3)
      }
    }
  }
}