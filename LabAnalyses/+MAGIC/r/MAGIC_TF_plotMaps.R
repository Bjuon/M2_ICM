#############################################################################################
##                                                                                         ##
##                            MAGIC  -  Delta TF Porte - NoPorte                           ##
##                                                                                         ##
#############################################################################################


############################################################################################
#############################################################################################
###### Initialisation
# DEFINE PATHS
rm(list = ls())
gc()

if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  InputDir  = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/" 
} else {
  DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  InputDir  = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF"
  LogDir    = "//l2export/iss02.home/mathieu.yeche/Cluster/outputs/"
  library(svglite)
}
print(Sys.time())
# SELECT EVENTS
# conditions = c('INIT')
conditions = c( 'INIT', 'APA', 'step', 'turn', 'FOGall', 'FOGstep', 'FOGturn')


PlotInd             = 0 # plot individual plots
PlotAll             = 0 # plot all pat plots
PLotMentalChargeInd = 0
PLotMentalChargeAll = 0
PlotOnOffInd        = 0
PlotOnOffAll        = 0
PlotNogoGoiAll      = 0
PlotFogStartEndAll  = 0
PlotAllPatFreqBand  = 0

Laterality = 0       # 1 => homo- vs. controlateral // 0 => classic (left / right hemisphere)
ElecGroup  = 0       # electrodes averaged by region --//--  0 = Non  1 = grouping large   2 = region precise 
TimeLim    = 1
FreqLim    = 1
ColLim     = 10      # 0 for variable between figs ; 10 for [-10;10Hz]
plot_allFq = 0       # plot TF with one line per fq and not in TF
FigWidth   = 16*2      # 32
FigHigh    = 18*2
Notch50Hz  = 5        # 0 for none / 5 => for a  [50-5 ; 50+5Hz] notch
DoNotDepass= FALSE    # Si la valeur depasse Collim elle est set to collim => graphes plus propres mais perte d'information sur les contrastes

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')
segType  = 'step'  #'trial' , 'step' 
normtype = 'RAW'
datatype = 'TF' #meanTF' #'PE' # TF
tBlock   = '05' # '05'
fqStart  = '1'
Montage  = 'extended';         # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'none';             # 'TraceBrut' , 'TF',  'none'


# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
lim        = ColLim     

# funType = c('median', 'mean')
funType   = c('median') # 'median'
funAllPat = 'median' # 'median'

OutPutFold = paste('LimTime', TimeLim, 's_Freq', FreqLim, 'Hz_Col', ColLim, '_', Montage,'_', Artefact, '_',normtype,  sep='')

if (Laterality == 0) {
  OutPutFold = paste(OutPutFold, 'SideLeftR', sep='_')
  print('L0 SideLeftR')
} 
if (Laterality == 1) {
  OutPutFold = paste(OutPutFold, 'HomoContr', sep='_')
  print('L1 HomoContr')
} 
if (ElecGroup == 1) {
  OutPutFold = paste(OutPutFold, 'byGroup', sep='_')
  print('E1 Par Groupe d electrode')
} 
if (ElecGroup == 2) {
  OutPutFold = paste(OutPutFold, 'byRegion', sep='_')
  print('E2 Par Region')
} 
if (ElecGroup == 0) {
  OutPutFold = paste(OutPutFold, 'byContact', sep='_')
  print('E0 Par Contact (Montage Bipolaire)')
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
            'DEj_000a',
            'ALb_000a',
            'FEp_0536',   
            'VIj_000a',
            'DEp_0535',
            'GAl_000a',
            'SOh_0555',
            'GUg_0634',
            'FRj_0610',
            'BAg_0496',
            'DRc_000a',
            'COm_000a',
            'BEm_000a',
            "REa_0526",
            "SAs_000a",
            "GIs_0550",
            # "FRa_000a",
            'LOp_000a'
          )
        
        listnameSubj =
          c(
            "ParkPitie_2019_04_25_DEj",      #GOGAIT_POSTOP_DESJO20
            "ParkPitie_2020_06_25_ALb",
            "ParkPitie_2020_02_20_FEp",
            "ParkPitie_2021_04_01_VIj",
            "ParkPitie_2020_01_16_DEp",
            "ParkPitie_2020_09_17_GAl",
            "ParkPitie_2020_10_08_SOh",
            "ParkRouen_2020_11_30_GUg",
            "ParkRouen_2021_02_08_FRj",
            "ParkPitie_2019_02_21_BAg",      #GOGAIT_POSTOP_BARGU14
            "ParkPitie_2019_03_14_DRc",      #GOGAIT_POSTOP_DROCA16
            "ParkPitie_2019_10_24_COm",
            "ParkPitie_2019_10_03_BEm",
            "ParkPitie_2020_01_09_REa",
            "ParkPitie_2021_10_21_SAs",
            "ParkPitie_2020_07_02_GIs",
            #  "ParkRouen_2021_10_04_FRa",
            "ParkPitie_2019_11_28_LOp"
          )
      }
      print('FRa non inclus')
      
      ### LIBRARY ----
      library(reshape2)
      library(RColorBrewer)
      library(ggplot2)
      
      
      ### Definition des couleurs
      myPalette  <-
        colorRampPalette(
          c(
            "#00007F",
            "blue",
            "#007FFF",
            "cyan",
            "#7FFF7F",
            "yellow",
            "#FF7F00",
            "red",
            "#7F0000"
          )
        )
      
      ### Chemin
      OutputPathAll = paste(OutputDir, gp, paste(funAllPat, '_All_', OutPutFold, sep=""), sep = "/")
      OutputPathInd = paste(OutputDir, gp, paste(favg,      '_Ind_', OutPutFold, sep=""), sep = "/")
      
      dir.create(paste(OutputDir, gp, sep = "/")) 
      dir.create(OutputPathInd)
      dir.create(OutputPathAll)
      
      #### Lecture fichier
      remove(temp1)
      remove(temp2)
      
      for (cond in conditions) {
      
      print(cond)
      FogTreated = FALSE
      
      # print(paste(InputDir,'/', 'MAGIC_temp_', datatype, '_', segType, '_', gp, '_', nor, '_', Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', favg, '_', cond, '.csv', sep = ""))
      temp2 <- read.table(paste(InputDir,'/', 'MAGIC_temp_', datatype, '_', segType, '_', gp, '_', nor, '_', Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', favg, '_', cond, '.csv', sep = ""), header = TRUE)
                       
      ### Suppression des valeurs manquantes
      temp2 = temp2[!is.na(temp2$value),]
      
      temp2$Event <- as.factor(temp2$Event)
      
      if (cond == 'INIT') {
        temp2 <- subset(temp2, temp2$Event == 'FIX' | temp2$Event == 'CUE')
        temp2 <- subset(temp2, temp2$isValid == 1)
        temp2$Event <- droplevels(temp2$Event)
        temp2$Event <- factor(temp2$Event, levels = c("FIX", "CUE"))
      } else if (cond == 'APA') {
        temp2 <- subset(temp2, temp2$Event == 'T0' | temp2$Event == 'T0_EMG' | temp2$Event == 'FO1' | temp2$Event == 'FC1' )
        temp2$Event = gsub("T0_EMG","T0",temp2$Event)
        temp2$Event = as.factor(temp2$Event)
        temp2 <- subset(temp2, temp2$isValid == 1)
        # temp2$Event <- droplevels(temp2$Event)
        #temp2$Event <- factor(temp2$Event, levels = c("T0", "T0_EMG", 'FO1', 'FC1'))
        temp2$Event <- factor(temp2$Event, levels = c("T0", 'FO1', 'FC1'))
      } else if (cond == 'FOGstep'){
        temp2 <- subset(temp2, temp2$Condition == 'FOG')
        temp2 <- subset(temp2, temp2$isValid == 1)
        temp2$Event <- factor(temp2$Event, levels = c("FOG_S", "FOG_E"))
        FogTreated = TRUE
      } else if (cond == 'turn'){
        temp2 <- subset(temp2, temp2$Condition == cond)
        temp2 <- subset(temp2, temp2$isValid == 1)
        temp2$Event <- factor(temp2$Event, levels = c("TURN_S", "TURN_E"))
        
      } else if (cond == 'step'){
        temp2 <- subset(temp2, temp2$Condition == cond)
        temp2 <- subset(temp2, temp2$isValid == 1)
        temp2$Event <- factor(temp2$Event, levels = c("FO", "FC"))
      } else if (cond == 'FOGturn'){
        temp2 <- subset(temp2, temp2$Condition == 'FOG')
        temp2 <- subset(temp2, temp2$isValid == 0)
        temp2$Event <- factor(temp2$Event, levels = c("FOG_S", "FOG_E"))
        FogTreated = TRUE
      } else if (cond == 'FOGall'){
        temp2 <- subset(temp2, temp2$Condition == 'FOG')
        temp2$Event <- factor(temp2$Event, levels = c("FOG_S", "FOG_E"))
        FogTreated = TRUE
      }
      
      ### Plot by Channel, Group or Region
      temp2$grouping <- as.factor(temp2$grouping)
      levels(temp2$grouping)
      temp2$Region <- as.factor(temp2$Region)
      levels(temp2$Region)
      if (ElecGroup == 1) {
        temp2$Chan_o <- as.character(temp2$grouping)
        temp2        =  subset(temp2, temp2$grouping != "")
      } else if (ElecGroup == 2) {
        temp2$Chan_o <- as.character(temp2$Region)
        temp2        =  subset(temp2, temp2$Region != "")
      } else if (ElecGroup == 0) {
        temp2$Chan_o <- as.character(temp2$Chan)
        temp2$Chan_o[temp2$Chan_o %in% c("1")] <- "01"
      }
      
      temp2$Chan_o <- as.factor(temp2$Chan_o)
      levels(temp2$Chan_o)
      temp2$Chan_o <- factor(temp2$Chan_o)
      
      
      #if (gp == 'STN') {
        # temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(3, 2)]) # STN
        # merge STNa and STNs
        # temp2$grouping <- factor(substr(temp2$grouping, 1, 3))
      #} else if (gp == 'PPN') {
        # temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(4,2,3)]) # PPN
        #temp2$grouping <- factor(temp2$grouping, levels = levels(temp2$grouping)[c(2,3)]) # PPN
      #}
     
      
      ## Notch a 50Hz
      
      if (Notch50Hz != 0) {
        temp2 = temp2[temp2$Freq > 50+Notch50Hz | temp2$Freq < 50-Notch50Hz , ]
      }
      
      if (Laterality == 1) {
        temp2$HEM_o = ifelse((temp2$side == 'R' & temp2$HEM == 'D') | 
                               (temp2$side == 'L' & temp2$HEM == 'G'), 'H',
                             ifelse(temp2$side != '', 'C' , '' ))
        hemis_param = c('H','C')
        alert = sum(temp2$HEM_o == '')
        if (alert > 1) {print('Pourcentage de donnees sans cote etabli : ') ; print(alert/nrow(temp2))}
      } else { hemis_param = c('G','D') }
      temp2$HEM_o <- as.factor(temp2$HEM_o)
      levels(temp2$HEM_o)
      temp2$HEM_o <- factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour presenter gauche ? gauche et droite ? droite sur les graphes
      
      
      #Affiche les valeurs depassant la limite en valeur saturante
      if (ColLim != 0 && DoNotDepass == TRUE) {
        temp2$value[temp2$value > ColLim  ] =  ColLim
        temp2$value[temp2$value < -ColLim ] = -ColLim
      }
      
      
      
      ############################################################################################
      #############################################################################################
      ### 1 plot per condition
      ############################################################################################
      #############################################################################################
      
        print(Sys.time())
        
        
        
        
        temp3 <- temp2[temp2$Freq >= FreqLim,]
        
        tasks = unique(temp3$Task)
        
        
        if (PlotOnOffAll == 1 & (cond == 'INIT' | cond == 'APA')) {
          print("OFF-ON-all")
          temp4 <- subset(temp3, (temp3$Task != 'NoGO' ))
          temp4 = aggregate(value ~ Medication + Event + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          
          temp4 <- merge(temp4[temp4$Medication == "OFF",],temp4[temp4$Medication == "ON",],by=c('Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE)
          temp4$value =  temp4$value.x -  temp4$value.y
          
          for (hemis in hemis_param) {
            temp5_lat = temp4[temp4$HEM_o == hemis,]
            
            if (length(temp5_lat[,1]) != 0) {
              ggplot(temp5_lat, aes(x = times, y = Freq, fill = value)) +
                geom_raster(interpolate = TRUE) + 
                scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim)) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + # scale_y_log10() +
                facet_grid(Chan_o ~ Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste("OFF-ON-all", cond, hemis, nor,  "median" , sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5)) +
                theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
              
              ## sauvegarde des graphes
              nameplot = paste("OFF-ON-all", cond, hemis, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
              ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                     width = FigWidth, height = FigHigh, units = "cm")
              if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                        width = FigWidth, height = FigHigh, units = "cm")}
            }
          }
          
          remove(temp4)
          remove(temp4_ON_)
          remove(temp4_OFF)
          remove(temp5)
          remove(temp5_lat)
        }
        
        
        
        if (PLotMentalChargeAll == 1 & (cond == 'INIT' | cond == 'APA')) {
          print("PLotMentalChargeAll")
          temp4 <- subset(temp3, (temp3$Task != 'NoGO'))
          temp4 = aggregate(value ~ Task + Medication + Event + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          temp4_GOc = temp4[temp4$Task == "GOc",]
          temp4_GOi = temp4[temp4$Task == "GOi",]
          
          temp5 <- merge(temp4_GOc,temp4_GOi,by=c('Medication' , 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE)
          temp5$value =  temp5$value.x -  temp5$value.y
          
          for (hemis in hemis_param) {
            temp5_la = temp5[temp5$HEM_o == hemis,]
            
            for (medi in c('ON','OFF')) {
              temp5_lat = temp5_la[temp5_la$Medication == medi,]
              if (length(temp5_lat[,1]) != 0) {
                ggplot(temp5_lat, aes(x = times, y = Freq, fill = value)) +
                  geom_raster(interpolate = TRUE) + 
                  scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + # scale_y_log10() +
                  facet_grid(Chan_o ~ Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste("Cert-inc-all", cond, medi, hemis, nor,  "median" , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5)) +
                  theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
                
                
                ## sauvegarde des graphes
                nameplot = paste("Cert-inc-all", cond, medi, hemis, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
                ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                       width = FigWidth, height = FigHigh, units = "cm")
                if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                          width = FigWidth, height = FigHigh, units = "cm")}
              }
            }
          }
          
          remove(temp4)
          remove(temp4_GOc)
          remove(temp4_GOi)
          remove(temp5)
          remove(temp5_lat)
          remove(temp5_la)
        }
        
        if (PlotNogoGoiAll == 1 & cond == 'INIT') {
          print("NoGO-GOi-all")
          temp4 <- subset(temp3, (temp3$Task != 'GOc'))
          temp4 = aggregate(value ~ Task + Medication + Event + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          temp4_NGO = temp4[temp4$Task == "NoGO",]
          temp4_GOi = temp4[temp4$Task == "GOi",]
          
          temp5 <- merge(temp4_NGO,temp4_GOi,by=c('Medication' , 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE)
          temp5$value =  temp5$value.x -  temp5$value.y
          
          for (hemis in hemis_param) {
            temp5_la = temp5[temp5$HEM_o == hemis,]
            
            for (medi in c('ON','OFF')) {
              temp5_lat = temp5_la[temp5_la$Medication == medi,]
              if (length(temp5_lat[,1]) != 0) {
                ggplot(temp5_lat, aes(x = times, y = Freq, fill = value)) +
                  geom_raster(interpolate = TRUE) + 
                  scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() + # scale_y_log10() +
                  facet_grid(Chan_o ~ Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste("NoGO-GOi-all", cond, medi, hemis, nor,  "median" , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5)) +
                  theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
                
                
                ## sauvegarde des graphes
                nameplot = paste("NoGO-GOi-all", cond, medi, hemis, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
                ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                       width = FigWidth, height = FigHigh, units = "cm")
                if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                          width = FigWidth, height = FigHigh, units = "cm")}
              }
            }
          }
          
          remove(temp4)
          remove(temp4_ON_)
          remove(temp4_OFF)
          remove(temp5)
          remove(temp5_lat)
          
        }
        
        if (PlotNogoGoiAll == 1 & cond == 'INIT') {
          print("NoGO-GOi-all bis : fusion off et on")
          temp4 <- subset(temp3, (temp3$Event == 'CUE' & temp3$Task != 'GOc' ))
          temp4 = aggregate(value ~ Task + Medication + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          temp4_NGO = temp4[temp4$Task == "NoGO",]
          temp4_GOi = temp4[temp4$Task == "GOi",]
          
          temp5 <- merge(temp4_NGO,temp4_GOi,by=c('Medication' , 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE)
          temp5$value =  temp5$value.x - temp5$value.y
          
          for (hemis in hemis_param) {
            temp5_lat = temp5[temp5$HEM_o == hemis,]
            
            if (length(temp5_lat[,1]) != 0) {
              ggplot(temp5_lat, aes(x = times, y = Freq, fill = value)) +
                geom_raster(interpolate = TRUE) + 
                scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + # scale_y_log10() +
                facet_grid(Chan_o ~ Medication, drop = TRUE,scales = "free_x") +
                ggtitle(paste("NoGO-GOi-CUE", cond,  hemis, nor,  "median" , sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5)) +
                theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
              
              
              ## sauvegarde des graphes
              nameplot = paste("NoGO-GOi-CUE", cond, hemis, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
              ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                     width = FigWidth, height = FigHigh, units = "cm")
              if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                        width = FigWidth, height = FigHigh, units = "cm")}
            }
            
          }
          
          remove(temp4)
          remove(temp4_ON_)
          remove(temp4_OFF)
          remove(temp5)
          remove(temp5_lat)
          
        }
        
        if (PlotFogStartEndAll == 1 & FogTreated == TRUE) {
          print("PlotFogStartEndAll")
          if (ElecGroup == 0)
          {temp4 <- subset(temp3, (temp3$Chan_o == 18 | temp3$Chan_o == 25 | temp3$Chan_o == 47 | temp3$Chan_o == 36))}
          else {temp4 = temp3}
          temp4$times = (round(temp4$times,4))
          print("pbm de valeur differentes sur l'axe du temps empechant toute fusion")
          temp4 = aggregate(value ~ Event + Freq + times + Chan_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          temp4_StF = temp4[temp4$Event == "FOG_S",]
          temp4_StF$times = (round(temp4_StF$times + 0.0039,4))
          temp4_EnF = temp4[temp4$Event == "FOG_E",]
          
          rownames(temp4_StF) = seq(length=nrow(temp4_StF))
          rownames(temp4_EnF) = seq(length=nrow(temp4_EnF))
          temp4_StF$times[temp4_StF$times != temp4_EnF$times] = temp4_EnF$times[temp4_StF$times != temp4_EnF$times]
          
          temp5 <- merge(temp4_StF,temp4_EnF,by=c('Freq', 'times', 'Chan_o'), all.x=FALSE, all.y = FALSE)
          temp5$value =  temp5$value.x -  temp5$value.y
          temp5$Event = "Delta"
          temp5 = temp5[,c("Event", "Freq", 'times', 'Chan_o', "value" )]
          
          temp6 = rbind(temp5,temp4)
          temp6$Event <- factor(temp6$Event, levels = c("FOG_S", "FOG_E", "Delta"))
          
          
          if (length(temp6[,1]) != 0) {
            ggplot(temp6, aes(x = times, y = Freq, fill = value)) +
              geom_raster(interpolate = TRUE) + 
              scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() + # scale_y_log10() +
              facet_grid(Chan_o ~ Event, drop = TRUE,scales = "free_x") +
              ggtitle(paste("FOG-Start-End-all", cond, nor,  "median" , sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5)) +
              theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
            
            
            ## sauvegarde des graphes
            nameplot = paste("FOG-Start-End-all", cond, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
            ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                   width = FigWidth, height = FigHigh, units = "cm")
            if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                      width = FigWidth, height = FigHigh, units = "cm")}
          }
          
          remove(temp4)
          remove(temp4_ON_)
          remove(temp4_OFF)
          remove(temp5)
          remove(temp5_lat)
          
        }
        
        # if (PlotFogStartEndAll == 1 & FogTreated == TRUE) {
        #   print("PLotf13 Inverse")
        #   temp4 <- subset(temp3, (temp3$Chan_o == 18 | temp3$Chan_o == 25 | temp3$Chan_o == 47 | temp3$Chan_o == 36))
        #   temp4$times = (round(temp4$times,4))
        #   print("pbm de valeur differentes sur l'axe du temps empechant toute fusion")
        #   temp4 = aggregate(value ~ Event + Freq + times + Chan_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
        #   temp4_StF = temp4[temp4$Event == "FOG_S",]
        #   temp4_StF$times = -temp4_StF$times 
        #   temp4_StF$times = (round(temp4_StF$times - 0.0137,4))
        #   temp4_EnF = temp4[temp4$Event == "FOG_E",]
        #   
        #   ordered_temp4_EnF <- temp4_EnF[order(temp4_EnF$times, temp4_StF$Freq, temp4_StF$Chan_o), ]
        #   ordered_temp4_StF <- temp4_StF[order(temp4_StF$times, temp4_StF$Freq, temp4_StF$Chan_o), ]
        #   rownames(ordered_temp4_EnF) = seq(length=nrow(ordered_temp4_EnF))
        #   rownames(ordered_temp4_StF) = seq(length=nrow(ordered_temp4_StF))
        #   ordered_temp4_StF$times[ordered_temp4_StF$times != ordered_temp4_EnF$times] = ordered_temp4_EnF$times[ordered_temp4_StF$times != ordered_temp4_EnF$times]
        #   
        #   temp5 <- merge(ordered_temp4_StF,ordered_temp4_EnF,by=c('Freq', 'times', 'Chan_o'), all.x=FALSE, all.y = FALSE)
        #   temp5$value =  temp5$value.x -  temp5$value.y
        #   temp5$Event = "Delta"
        #   temp5 = temp5[,c("Event", "Freq", 'times', 'Chan_o', "value" )]
        #   
        #   temp6 = rbind(temp5,temp4)
        #   temp6$Event <- factor(temp6$Event, levels = c("FOG_S", "FOG_E", "Delta"))
        #   
        #   
        #   if (length(temp6[,1]) != 0) {
        #     ggplot(temp6, aes(x = times, y = Freq, fill = value)) +
        #       geom_raster(interpolate = TRUE) + 
        #       scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
        #       geom_vline(xintercept = 0, size = .1) +
        #       theme_classic() + # scale_y_log10() +
        #       facet_grid(Chan_o ~ Event, drop = TRUE,scales = "free_x") +
        #       ggtitle(paste("FOG-Start-End-all", cond, nor,  "median" , sep = "_")) +
        #       theme(plot.title = element_text(hjust = 0.5)) +
        #       theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
        #     
        #     ## sauvegarde des graphes
        #     nameplot = paste("FOG-Start-End-all", cond, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
        #     ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
        #            width = FigWidth, height = FigHigh, units = "cm")
        #     if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
        #                                               width = FigWidth, height = FigHigh, units = "cm")}
        #   }
        #   
        #   remove(temp4)
        #   remove(temp4_ON_)
        #   remove(temp4_OFF)
        #   remove(temp5)
        #   remove(temp5_lat)
        #   
        # }
        
        
        for (task_count in tasks) {
          temp3_task = subset(temp3, temp3$Task == task_count)
          print(task_count)
          
          if ((nor == 'RAW' | nor == 'dNOR') & segType  == 'trial'){
            temp3_task$value = 10*log10(Re(temp3_task$value))
          } else {
            temp3_task$value = Re(temp3_task$value)
          }
          
          # if (PlotHemisphere==1){
          #   temp3_task = temp3_task[, c("Patient", "Medication","Condition", "Freq", "side", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
          #   temp3_task = aggregate( value ~ Patient + Medication + Condition + Event + side + Freq + times + Chan_o + HEM_o , temp3_task,  # + side
          #                           FUN = favg,
          #                           na.rm = T,
          #                           na.action = NULL)
          # }
          
          
          # aggregate values
          if (ElecGroup == 1) {
            temp3_task = temp3_task[, c("Patient", "Medication", "Condition", "Freq", "Event", "value", "times", "Chan_o", "grouping", "HEM_o")] # , "side" )]
            temp3_task = aggregate( value ~ Patient + Medication + Condition + Event + Freq + times + Chan_o + grouping + HEM_o, temp3_task, # + side
                                    FUN = favg,
                                    na.rm = T,
                                    na.action = NULL)
          } else if (ElecGroup == 2) {
            temp3_task = temp3_task[, c("Patient", "Medication", "Condition", "Freq", "Event", "value", "times", "Chan_o", "Region", "HEM_o")] # , "side" )]
            temp3_task = aggregate( value ~ Patient + Medication  + Condition + Event + Freq + times + Chan_o + Region + HEM_o, temp3_task, # + side
                                    FUN = favg,
                                    na.rm = T,
                                    na.action = NULL)
          } else if (ElecGroup == 0) {
            temp3_task = temp3_task[, c("Patient", "Medication","Condition", "Freq", "Event", "value", "times", "Chan_o", "HEM_o" )] # , "side" )]
            temp3_task = aggregate( value ~ Patient + Medication + Condition + Event + Freq + times + Chan_o + HEM_o , temp3_task,  # + side
                                    FUN = favg,
                                    na.rm = T,
                                    na.action = NULL)
          }
          
          
          
          
          if (ElecGroup == 1) {
            temp3_task <- subset(temp3_task, temp3_task$grouping != "")
          }
          if (ElecGroup == 2) {
            temp3_task <- subset(temp3_task, temp3_task$Region != "")
          }
          
          
          if (PlotInd == 1) {
            print("plotting indiv")
            for (s in listnameSubj) { 
              if (s != 'FEp_0536' | FogTreated == FALSE) {
                # print(s)
                remove(temp4_ind)
                temp4_ind <- temp3_task[temp3_task$Patient == s,]
                
                if (FogTreated == TRUE) {
                  temp4_ind <- temp4_ind[temp4_ind$times >= (-2 * TimeLim) & temp4_ind$times <= TimeLim, ]
                } else {
                  temp4_ind <- temp4_ind[temp4_ind$times >= (-1 * TimeLim) & temp4_ind$times <= TimeLim, ] }
                
                # lim  <- max(abs(temp4_ind$value))
                lim = ColLim
                
                
                if (nrow(temp4_ind) == 0) {
                  next
                }
                
                # temp4_ind$value[is.na(temp4_ind$value)] = 0
                
                ## GRAPH
                
                if (plot_allFq == 0) {
                  
                  if (ElecGroup == 1) {
                    ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                      geom_raster(interpolate = F) + 
                      scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                      geom_vline(xintercept = 0, size = .1) +
                      theme_classic() +
                      facet_grid(grouping ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                      ggtitle(paste(s, nor, cond, task_count, favg , sep = "_")) +
                      theme(plot.title = element_text(hjust = 0.5)) +
                      theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
                    
                  } else if (ElecGroup == 2) {
                    ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                      geom_raster(interpolate = F) + 
                      scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                      geom_vline(xintercept = 0, size = .1) +
                      theme_classic() +
                      facet_grid(Region ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                      ggtitle(paste(s, nor, cond, task_count, favg , sep = "_")) +
                      theme(plot.title = element_text(hjust = 0.5)) +
                      theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
                    
                  } else if (ElecGroup == 0) {
                    ggplot(temp4_ind, aes(x = times, y = Freq, fill = value)) +
                      geom_raster(interpolate = F) + 
                      scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                      geom_vline(xintercept = 0, size = .1) +
                      theme_classic() +
                      facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                      ggtitle(paste(cond, task_count, s, nor, favg , sep = "_")) +
                      theme(plot.title = element_text(hjust = 0.5)) +
                      theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
                    
                  }
                  ## sauvegarde des graphes
                  ggsave(paste(OutputPathInd, '/', paste(cond, task_count, s, nor, 'tBlock', tBlock, 'fqStart', fqStart, favg, sep = "_"), '.png', sep = ""),
                         width = FigWidth, height = FigHigh, units = "cm")
                  if (.Platform$OS.type != "unix")  { ggsave(paste(OutputPathInd, '/', paste(cond, task_count, s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, sep = "_"), '.svg', sep = ""),
                                                             width = FigWidth, height = FigHigh, units = "cm")}
                  
                } else if (plot_allFq == 1) {
                  if (cond == 'APA') {
                    temp4_ind2 <- temp4_ind[(temp4_ind$Event == 'T0' | temp4_ind$Event == "T0_EMG" | temp4_ind$Event == 'FO1'| temp4_ind$Event == 'FC1'),]
                    temp4_ind2$Event <- factor(temp4_ind2$Event, levels = c("T0", "T0_EMG", "FO1", "FC1"))
                  } else if (cond == 'step') {
                    temp4_ind2 <- temp4_ind[temp4_ind$Event == 'FO'| temp4_ind$Event == 'FC',]
                  } else if (cond == 'turn') {
                    temp4_ind2 <- temp4_ind[temp4_ind$Event == 'TURN_S'| temp4_ind$Event == 'TURN_E',]
                  } else if (cond == 'FOG' | cond == 'FOGturn' | cond == 'FOGall') {
                    temp4_ind2 <- temp4_ind[(temp4_ind$Event == 'FOG_S' | temp4_ind$Event == 'FOG_E'),]
                    temp4_ind2$Event <- factor(temp4_ind2$Event, levels = c("FOG_S", "FOG_E"))
                  } else if (cond == 'INIT') {
                    temp4_ind2 <- temp4_ind[(temp4_ind$Event == 'FIX' | temp4_ind$Event == 'CUE'),]
                  }   
                  
                  # very low freq : 1 - 15
                  temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq <= 15,]
                  
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'verylowFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5)) 
                  
                  ## sauvegarde des graphes
                  ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, 'verylowFq', sep = "_"), '.png', sep = ""),
                         width = FigWidth, height = FigHigh, units = "cm")
                  remove(temp4_ind_fq1)
                  
                  
                  # low freq : 12 - 35
                  temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq >= 12,]
                  temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 35,]
                  
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'lowFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5)) 
                  
                  ## sauvegarde des graphes
                  ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, 'lowFq', sep = "_"), '.png', sep = ""),
                         width = FigWidth, height = FigHigh, units = "cm")
                  remove(temp4_ind_fq1)              
                  
                  
                  # high freq : 30 - 65              
                  temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq >= 30,]
                  temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 65,]
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'HighFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5)) 
                  
                  ## sauvegarde des graphes
                  ggsave(paste(OutputPathInd, '/', paste(cond, task_count, s, nor, 'tBlock', tBlock, 'fqStart', fqStart, favg, 'HighFq', sep = "_"), '.png', sep = ""),
                         width = FigWidth, height = FigHigh, units = "cm")
                  remove(temp4_ind_fq1)
                  
                  
                  # very high freq : 60 - 80              
                  temp4_ind_fq1 <- temp4_ind2[temp4_ind2$Freq >= 60,]
                  temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 80,]
                  ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
                    geom_line() +  # ylim(-lim, lim) +
                    geom_vline(xintercept = 0, size = .1) +
                    theme_classic() + 
                    facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste(s, 'veryHighFq', favg , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                  
                  ## sauvegarde des graphes
                  ggsave(paste(OutputPathInd, '/', paste(cond, task_count, s, nor, 'tBlock', tBlock, 'fqStart', fqStart, favg, 'veryHighFq', sep = "_"), '.png', sep = ""),
                         width = FigWidth, height = FigHigh, units = "cm")
                  remove(temp4_ind_fq1)
                  gc()
                }
                
              }
            }
          } 
          
          
          
          if (PlotOnOffInd == 1) {
            
            print("PLotOnOffDiff")
            temp4 = aggregate(value ~ Patient + Medication + Event + Freq + times + Chan_o + HEM_o, temp3_task, FUN = 'median', na.rm = T, na.action = NULL)
            
            
            for (s in listnameSubj) { 
              
              print(s)
              remove(temp4_ind)
              remove(temp4_On)
              remove(temp4_Off)
              remove(temp5)
              gc()
              
              temp4_ind <- temp4[temp4$Patient == s,]
              
              temp4_On  <- temp4_ind[temp4_ind$Medication == "ON",]
              temp4_Off <- temp4_ind[temp4_ind$Medication == "OFF",]
              temp4_On  = subset(temp4_On, select = -c(Medication))
              temp4_Off = subset(temp4_Off, select = -c(Medication))
              
              temp5 <- merge(temp4_Off,temp4_On,by=c('Patient', 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE) 
              temp5$value =  temp5$value.x - temp5$value.y
              
              
              
              # print("PLotOnOffDiff")
              # remove(temp4_On)
              # remove(temp4_Off)
              # temp4_On  <- temp3[temp3$Medication == "ON",]
              # temp4_Off <- temp3[temp3$Medication == "OFF",]
              # print(length(temp4_Off[,1]))
              # temp4_On = aggregate( value ~ Condition + Event + Freq + times + Chan_o + HEM_o , temp4_On, FUN = 'median', na.rm = T, na.action = NULL)
              # temp4_Off = aggregate( value ~ Condition + Event + Freq + times + Chan_o + HEM_o , temp4_Off, FUN = 'median', na.rm = T, na.action = NULL)
              # temp4_On$fusion <- paste(temp4_On$Medication, temp4_On$Condition, temp4_On$Event, temp4_On$Freq, temp4_On$times , temp4_On$Chan_o , temp4_On$HEM_o , sep = '_')
              # temp4_Off$fusion <- paste(temp4_Off$Medication, temp4_Off$Condition, temp4_Off$Event, temp4_Off$Freq, temp4_Off$times , temp4_Off$Chan_o , temp4_Off$HEM_o , sep = '_')
              # temp4_diff = within(merge(temp4_Off,temp4_On,by="fusion"), {value <- value.x - value.y }) #all.x = TRUE , all.y = TRUE
              # print(length(temp4_diff[,1]))
              # 
              if (length(temp5[,1]) != 0) {
                ggplot(temp5, aes(x = times, y = Freq, fill = value)) +
                  geom_raster(interpolate = F) + 
                  scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                  geom_vline(xintercept = 0, size = .1) +
                  theme_classic() +
                  facet_grid(Chan_o ~ HEM_o + Event, drop = TRUE,scales = "free_x") +
                  ggtitle(paste("OFF-ON", s, task_count, nor, cond, "median" , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5)) +
                  theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
                
                
                ## sauvegarde des graphes
                nameplot = paste("OFF-ON", cond, task_count, s, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
                ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                       width = FigWidth, height = FigHigh, units = "cm")
                if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                          width = FigWidth, height = FigHigh, units = "cm")}
              }
              remove(temp4_On)
              remove(temp4_Off)
              remove(temp4_ind)
              remove(temp5)
              gc()
            }
            
          }
          ####### all patients ############################################################
          #################################################################################
          
          # if (PlotAll == 1 & (s != 'FEp_0536' | FogTreated == FALSE) ) {
          if (PlotAll == 1) {
            print("PLotAll") 
            temp4 = aggregate(value ~ Medication + Event + Freq + times + Chan_o + HEM_o, temp3_task, FUN = funAllPat, na.rm = T, na.action = NULL)
            
            #
            #lim  <- max(abs(temp4$value)) # limites diff?rentes pour chaque patient
            #
            lim = ColLim
            # lim  <- max(abs(temp2$value)) # m?mes limites pour tous les sujets
            
            ## GRAPH
            if (length(temp4[,1]) != 0) {
              ggplot(temp4, aes(x = times, y = Freq, fill = value )) +
                geom_raster(interpolate = F) + scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#FFFFFF") +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() +
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE, scales = "free_x") +
                ggtitle(paste("AllPat", cond, task_count, nor, sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5)) +
                theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
              
              
              ## sauvegarde des graphes
              nameplot = paste("AllPat", cond, task_count, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
              # paste(gp, nor, cond, task_count, favg, funAllPat, sep = "_")
              ggsave(paste(OutputPathAll, '/', nameplot , '.png', sep = ""), width = 6, height = 8)
              if (.Platform$OS.type != "unix") {
                ggsave(paste(OutputPathAll, '/', nameplot, '.svg', sep = ""), width = 6, height = 8)
              }
            }
            
            remove(temp4)
          }
          
          if (PlotAllPatFreqBand == 1) {
            temp4_allfreq = aggregate(value ~ Medication + Event + Freq + times + Chan_o + HEM_o, temp3_task, FUN = funAllPat, na.rm = T, na.action = NULL)
            
            # very low freq : 1 - 15
            temp4_ind_fq1 <- temp4_allfreq[temp4_allfreq$Freq <= 15,]
            
            ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
              geom_line() + # ylim(-lim, lim) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() + 
              facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
              ggtitle(paste('AllPat_AlphaTheta', favg , sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(paste(OutputPathAll, '/', paste('AllPat', nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, 'AlphaThet', sep = "_"), '.png', sep = ""),
                   width = FigWidth, height = FigHigh, units = "cm")
            
            
            # low freq : 12 - 35
            temp4_ind_fq1 <- temp4_allfreq[temp4_allfreq$Freq >= 12,]
            temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 35,]
            
            ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
              geom_line() +  # ylim(-lim, lim) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() + 
              facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
              ggtitle(paste('AllPat_Beta', favg , sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(paste(OutputPathAll, '/', paste('AllPat', nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, 'Beta', sep = "_"), '.png', sep = ""),
                   width = FigWidth, height = FigHigh, units = "cm")
            remove(temp4_ind_fq1)              
            
            
            # high freq : 30 - 65              
            temp4_ind_fq1 <- temp4_allfreq[temp4_allfreq$Freq >= 30,]
            temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 65,]
            
            
            ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
              geom_line() +  # ylim(-lim, lim) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() + 
              facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
              ggtitle(paste('AllPat', 'LowGamma', favg , sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(paste(OutputPathInd, '/', paste('AllPat', nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, 'LowGamma', sep = "_"), '.png', sep = ""),
                   width = FigWidth, height = FigHigh, units = "cm")
            remove(temp4_ind_fq1)
            
            
            # very high freq : 60 - 80              
            temp4_ind_fq1 <- temp4_allfreq[temp4_allfreq$Freq >= 60,]
            temp4_ind_fq1 <- temp4_ind_fq1[temp4_ind_fq1$Freq <= 80,]
            
            ggplot(temp4_ind_fq1, aes(x = times, y= value, color = as.factor(Freq))) +
              geom_line() +  # ylim(-lim, lim) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() + 
              facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
              ggtitle(paste('AllPat', 'HighGamma', favg , sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5)) 
            
            ## sauvegarde des graphes
            ggsave(paste(OutputPathInd, '/', paste( 'AllPat', nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, task_count, favg, 'HighGamma', sep = "_"), '.png', sep = ""),
                   width = FigWidth, height = FigHigh, units = "cm")
            
            
            remove(temp4_ind_fq1)
            remove(temp4_ind_fq1)
            
            gc()
          }
          remove(temp4)
          
        }
        remove(temp3_task)
        gc()
        
        if (PLotMentalChargeInd == 1 & length(temp3[,1]) != 0) {
          lim = ColLim
          
          ## Delta
          print("PLotMentalCharge")
          temp4 <- subset(temp3, temp3$Task != 'NoGO')
          temp4 = aggregate(value ~ Patient + Medication + Task + Event + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          
          
          for (s in listnameSubj) { 
            
            
            print(s)
            remove(temp4_goi)
            remove(temp4_goc)
            remove(temp4_ind) 
            remove(temp5)   
            gc()
            
            temp4_ind <- temp4[temp4$Patient == s,]
            
            temp4_goc <- temp4_ind[temp4_ind$Task == "GOc",]
            temp4_goi <- temp4_ind[temp4_ind$Task == "GOi",]
            temp4_goi = subset(temp4_goi, select = -c(Task))
            temp4_goc = subset(temp4_goc, select = -c(Task))
            
            temp5 <- merge(temp4_goc,temp4_goi,by=c('Patient','Medication', 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE) 
            temp5$value =  temp5$value.x -  temp5$value.y
            
            
            
            
            # temp5 = temp4_ind[temp4_ind$Task == "GOi", c('Medication', 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o')]
            # temp5$value = temp4_ind[temp4_ind$Task == "GOi", c('value')] - temp4_ind[temp4_ind$Task == "GOc", c('value')]
            # 
            # 
            
            # 
            # 
            # print("PLotMentalCharge")
            # remove(temp4_goi)
            # remove(temp4_goc)
            # temp4_goi <- temp3[temp3$Task == "GOi",]
            # temp4_goc <- temp3[temp3$Task == "GOc",]
            # print(length(temp4_goi[,1]))
            # temp4_goi = aggregate( value ~ Medication + Condition + Event + Freq + times + Chan_o + HEM_o , temp4_goi, FUN = 'median', na.rm = T, na.action = NULL)
            # temp4_goc = aggregate( value ~ Medication + Condition + Event + Freq + times + Chan_o + HEM_o , temp4_goc, FUN = 'median', na.rm = T, na.action = NULL)
            # temp4_goi$fusion <- paste(temp4_goi$Medication, temp4_goi$Condition, temp4_goi$Event, temp4_goi$Freq, temp4_goi$times , temp4_goi$Chan_o , temp4_goi$HEM_o , sep = '_')
            # temp4_goc$fusion <- paste(temp4_goc$Medication, temp4_goc$Condition, temp4_goc$Event, temp4_goc$Freq, temp4_goc$times , temp4_goc$Chan_o , temp4_goc$HEM_o , sep = '_')
            # temp4_diff = within(merge(temp4_goc,temp4_goi,by="fusion"), {value <- value.x - value.y }) #all.x = TRUE , all.y = TRUE
            # print(length(temp4_diff[,1]))
            # 
            
            #  scale_x_discrete(breaks = c(0, 5, 10, 15, 20, 25))
            
            if (length(temp5[,1]) != 0) {
              ggplot(temp5, aes(x = times, y = Freq, fill = value)) +
                geom_raster(interpolate = TRUE) + 
                scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() + # scale_y_log10() +
                facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
                ggtitle(paste("Certitude", cond, s, nor,  "median" , sep = "_")) +
                theme(plot.title = element_text(hjust = 0.5)) +
                theme(panel.background = element_rect(fill = "black", colour = "black", size = 0.5, linetype = "solid"))
              
              ## sauvegarde des graphes
              nameplot = paste("Certitude", cond, s, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
              ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                     width = FigWidth, height = FigHigh, units = "cm")
              if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                        width = FigWidth, height = FigHigh, units = "cm")}
            }
            
            remove(temp4_goi)
            remove(temp4_goc)
            remove(temp4_ind) 
            remove(temp5)   
            gc()
          } remove(temp4)
        }
      }
    }       remove(temp3)
  }
}


print('END Plot')
print(Sys.time())


IdForNotification = paste(paste(conditions,collapse ="_"), '_Lat' , Laterality,'_Grp' ,ElecGroup,sep = '')
Timing = format(Sys.time(), "%F_%H-%M-%S")
filename = paste(LogDir, Timing, "-R_Plot" , IdForNotification , "SUCCESS", ".txt",sep = "")
fileSuccess<-file(filename)
writeLines("Hello", fileSuccess)
close(fileSuccess)
