#############################################################################################
##                                                                                         ##
##                                           MAGIC  -  Stats                               ##
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
conditions = c( 'INIT')


PlotInd             = 0 # plot individual plots
PlotAll             = 0 # plot all pat plots
PLotMentalChargeInd = 0
PLotMentalChargeAll = 1
PlotOnOffInd        = 0
PlotOnOffAll        = 0
PlotNogoGoiAll      = 1
PlotFogStartEndAll  = 0
PlotAllPatFreqBand  = 0

Laterality = 0       # 1 => homo- vs. controlateral // 0 => classic (left / right hemisphere)
ElecGroup  = 2       # electrodes averaged by region --//--  0 = Non  1 = grouping large   2 = region precise 
TimeLim    = 1
FreqLim    = 2
ColLim     = 5      # 0 for variable between figs ; 10 for [-10;10Hz]
plot_allFq = 0       # plot TF with one line per fq and not in TF
FigWidth   = 16*2      # 32
FigHigh    = 18*2
Notch50Hz  = 0        # 0 for none / 5 => for a  [50-5 ; 50+5Hz] notch
DoNotDepass= FALSE    # Si la valeur depasse Collim elle est set to collim => graphes plus propres mais perte d'information sur les contrastes

p_lim = 0.01


# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')
segType  = 'step'  #'trial' , 'step' 
normtype = 'ldNOR'
datatype = 'TF' #meanTF' #'PE' # TF
tBlock   = '05' # '05'
fqStart  = '1'
Montage  = 'extended';         # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'TF';             # 'TraceBrut' , 'TF',  'none'


# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
lim        = ColLim     

# funType = c('median', 'mean')
funType   = c('median') # 'median'
funAllPat = 'median' # 'median'

OutPutFold = paste('STATS_LimTime', TimeLim, 's_Freq', FreqLim, 'Hz_Col', ColLim, '_', Montage,'_', Artefact, '_',normtype,  sep='')

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
      dir.create(paste(OutputDir, gp, nor, sep = "/")) 
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
        
temp2 = temp2[temp2$Chan_o =="HotspotFOG" | temp2$Chan_o == "Motor", ]
        
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
                                 (temp2$side == 'L' & temp2$HEM == 'G'), 'C',
                               ifelse(temp2$side != '', 'H' , '' ))
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
        
        
        
        
        
        
        
        for (l in unique(temp2$Chan_o)){
          
          temp3 <- temp2[temp2$Chan_o == l,]
          temp3 <- temp3[temp3$Freq >= FreqLim,]
          
        
        if (PLotMentalChargeAll == 1 & (cond == 'INIT' | cond == 'APA')) {
          print("PLotMentalChargeAll")
          temp4 <- subset(temp3, (temp3$Task != 'NoGO'))
          temp4 = aggregate(value ~ Task + Patient + Medication + Event + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          temp4_GOc = temp4[temp4$Task == "GOc",]
          temp4_GOi = temp4[temp4$Task == "GOi",]
          
          temp5 <- merge(temp4_GOc,temp4_GOi,by=c('Patient', 'Medication' , 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE)
          temp5$value =  temp5$value.x -  temp5$value.y
          
          for (hemis in hemis_param) {
            temp5_la = temp5[temp5$HEM_o == hemis,]
            
            for (medi in c('ON','OFF')) {
              temp5_lat_1 = temp5_la[temp5_la$Medication == medi,]
              
              for (ev in unique(temp5_la$Event)) {
                temp5_lat = temp5_lat_1[temp5_lat_1$Event == ev,]
                
                if (length(temp5_lat[,1]) != 0) {
              
                
                  mask = data.frame(matrix(ncol = 3, nrow = length(unique(temp5_lat$times))*length(unique(temp5_lat$Freq))))
                  indice = 0
                  colnames(mask) = c('Freq','times','value')
                  for (timepoint in unique(temp5_lat$times)){
                    for (freqpoint in unique(temp5_lat$Freq)){
                      indice = indice+1
                      temp6 = subset(temp5_lat, (temp5_lat$times == timepoint))
                      temp6 = subset(temp6,     (temp6$Freq      == freqpoint))
                      test  = t.test(temp6$value.x, temp6$value.y , paired=TRUE)  
                      mask$times[indice] = timepoint
                      mask$Freq[indice] = freqpoint
                      if ( test$p.value < p_lim){
                        mask$value[indice] = 1
                      } else {
                        mask$value[indice] = 0
                      }
                    }
                  }
                  
                  
                
                
                ggplot(temp5_lat, aes(x = times, y = Freq, fill = value)) +
                  # scale_y_continuous(trans='log10') +
                  geom_raster(interpolate = TRUE) + 
                  scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                  geom_vline(xintercept = 0, size = .1) +
                  geom_contour(data = mask,mapping = aes(x = times, y = Freq, z = value),colour = "black", bins = 1, linewidth=1.2)
                  theme_classic() + # scale_y_log10() +
                  # facet_grid(Chan_o, drop = TRUE,scales = "free_x") +
                  ggtitle(paste("Cert-inc-all", l, ev, cond, medi, hemis, nor,  "median" , sep = "_")) +
                  theme(plot.title = element_text(hjust = 0.5)) 
                
                ## sauvegarde des graphes
                nameplot = paste("Cert-inc-all", l,ev, cond, medi, hemis, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
                ggsave(paste(OutputPathInd, '/', nameplot, '.png', sep = ""),
                       width = FigWidth, height = FigHigh, units = "cm")
                if (.Platform$OS.type != "unix")  {ggsave(paste(OutputPathInd, '/', nameplot, '.svg', sep = ""),
                                                          width = FigWidth, height = FigHigh, units = "cm")}
                }
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
          temp4 <- temp4[temp4$Event =='FIX',]
          temp4 = aggregate(value ~ Task + Medication + Event + Patient + Freq + times + Chan_o + HEM_o, temp4, FUN = 'median', na.rm = T, na.action = NULL)
          temp4_NGO = temp4[temp4$Task == "NoGO",]
          temp4_GOi = temp4[temp4$Task == "GOi",]
          
          temp5 <- merge(temp4_NGO,temp4_GOi,by=c('Patient', 'Medication' , 'Event', 'Freq', 'times', 'Chan_o', 'HEM_o'), all.x=FALSE, all.y = FALSE)
          temp5$value =  temp5$value.x -  temp5$value.y
          
          for (hemis in hemis_param) {
            temp5_la = temp5[temp5$HEM_o == hemis,]
            
            for (medi in c('ON','OFF')) {
              temp5_lat_1 = temp5_la[temp5_la$Medication == medi,]
              
              for (ev in unique(temp5_la$Event)) {
                temp5_lat = temp5_lat_1[temp5_lat_1$Event == ev,]
                if (length(temp5_lat[,1]) != 0) {
                  
                  
                  
                  mask = data.frame(matrix(ncol = 3, nrow = length(unique(temp5_lat$times))*length(unique(temp5_lat$Freq))))
                  indice = 0
                  colnames(mask) = c('Freq','times','value')
                  for (timepoint in unique(temp5_lat$times)){
                    for (freqpoint in unique(temp5_lat$Freq)){
                      indice = indice+1
                      temp6 = subset(temp5_lat, (temp5_lat$times == timepoint))
                      temp6 = subset(temp6,     (temp6$Freq      == freqpoint))
                      test  = t.test(temp6$value.x, temp6$value.y , paired=TRUE)  
                      mask$times[indice] = timepoint
                      mask$Freq[indice] = freqpoint
                      if ( test$p.value < p_lim){
                        mask$value[indice] = 1
                      } else {
                        mask$value[indice] = 0
                      }
                    }
                  }
                  
                  
                  ggplot(temp5_lat, aes(x = times, y = Freq, fill = value)) +
                    geom_raster(interpolate = TRUE) + 
                    scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#FFFFFF") +
                    geom_vline(xintercept = 0, size = .1) +
                    geom_contour(data = mask,mapping = aes(x = times, y = Freq, z = value),colour = "black", bins = 1, linewidth=1.2) +
                    theme_classic() + # scale_y_log10() +
                    # facet_grid(Chan_o ~ Event, drop = TRUE,scales = "free_x") +
                    ggtitle(paste("NoGO-GOi-all", l, ev, cond, medi, hemis, nor,  "median" , sep = "_")) +
                    theme(plot.title = element_text(hjust = 0.5))
                  
                  ## sauvegarde des graphes
                  nameplot = paste("NoGO-GOi-all", l, ev, cond, medi, hemis, nor, 'tBlock', tBlock, 'fqStart', fqStart, "median" , sep = "_")
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
        
        
        } 
        }
        
      }
    }       
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
