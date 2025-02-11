#############################################################################################
##                                                                                         ##
##                       GI  -  cartes TF individuelles                      ##
##                                                                                         ##
#############################################################################################



#############################################################################################
###### Initialisation
# DEFINE PATHS

# DataDir   = '//lexport/iss01.dbs/data/analyses/'
# OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/DIVINE/04_Traitement"
DataDir   = 'F:/DBStmp_Matthieu/data/analyses'
OutputDir = '//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/04_Traitement/03_CartesTF'
ElecGroup = 0 # 1 if electrodes averaged by region
TimeLim   = 0.5
FreqLim   = 1
ColLim    = 20


# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('dNOR')
tBlock   = '05'
fqStart  = '1'
# PRECISE GROUPS
groups   = c('PPN')
# groups   = c('PPN')
#SELECT EVENTS
#events  = c('T0', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E')
events  = c('T0', 'FO1', 'FC1')
conditions = c('APA')
funType = 'median' #  c('median', 'mean')

OutPutFold = paste('Lim_Time', TimeLim, 's', '_Freq', FreqLim, 'Hz', 'Hz_Col', ColLim, sep='')


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
          'AVl_0444' ,
          'CHd_0343',
          'LEn_0367',
          'SOd_0363')
      listnameSubj =
        c(
          'PPNPitie_2018_07_05_AVl',
          'PPNPitie_2016_11_17_CHd',
          'PPNPitie_2017_06_08_LEn',
          'PPNPitie_2017_03_09_SOd'
        )
    }
    
    ## LIBRARY
    library(reshape2)
    library(RColorBrewer)
    library(ggplot2)
    library(FedData)
    
    
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
    
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    
    s_count = 0
    
    for (s in subjects) {
      # create outputdir
      dir.create(paste(OutputDir, gp,'ArtCheck', sep = "/"))
      dir.create(paste(OutputDir, gp,'ArtCheck', nor, sep = "/")) 
      dir.create(paste(OutputDir, gp,'ArtCheck', nor, OutPutFold, sep = "/")) 
      dir.create(paste(OutputDir, gp,'ArtCheck', nor, OutPutFold, s, sep = "/"))
      OutputPathInd = paste(OutputDir, gp,'ArtCheck', nor, OutPutFold, s, sep = "/")
      
      # s=subjects
      s_count = s_count + 1
      
      # Chemin
      RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)

      #SET PROTOCOL
      if (gp == 'STN') {
        if (s == 'AUa_0342' |
            s == 'PHj_0351') {
          protocol = 'GBMOV'
        }
        else {
          protocol = 'GBxxx'
        }
      }
      else if (gp == 'PPN') {
        protocol = 'GAITPARK'
      }
      
      outputname <- listnameSubj[s_count]
      
      for (ev in events) {
        # Lecture du fichier
        temp <- read.delim(paste(RecDir, '/POSTOP/', outputname, '_', protocol, '_POSTOP_GI_SPON_TF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))

        temp$grouping[is.na(temp$grouping)] = ''
        temp$nStep[is.na(temp$nStep)] = ''
        temp$side[is.na(temp$side)] = ''

        temp <- temp[, c("Protocol", "Patient", "Medication", "Condition", "Channel", "Freq", "Region", "grouping", "Event", "nTrial",
                         colnames(temp)[16:length(colnames(temp))]
        )]
        temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Condition", "Freq", "Channel", "Region", "grouping", "Event", "nTrial"))
        temp <- aggregate(
          value  ~ Protocol + Patient + Medication + Condition + variable + Freq + Channel + Region + grouping + Event + nTrial ,
          temp,
          FUN = funType, # 'mean',
          na.rm = T,
          na.action = NULL
        )
        
        # On compile les donnÃ©es de tous les patients
        if (exists('DAT_LFP')) {
          DAT_LFP <- rbind(DAT_LFP, temp)
        } else {
          DAT_LFP <- temp
        }
        
        rm('temp')
        gc(verbose = FALSE)
        
      }

      ###### Mise en forme du fichier
      
      #TIMES
      # vÃ©rifier fenÃªtre de temps sÃ©lectionnÃ©e
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

      #ORDER
      if (protocol == 'GBMOV' | protocol == 'GBxxx') {
        DAT_LFP$Chan_o <-
          factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(3, 2, 1)]) # STN
      } else {
        DAT_LFP$Chan_o <-
          factor(DAT_LFP$Chan, levels = levels(DAT_LFP$Chan)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
      }
      
      DAT_LFP$HEM_o <- factor(DAT_LFP$HEM, levels = levels(DAT_LFP$HEM)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
      
      #event
      #DAT_LFP$Event <- as.factor(DAT_LFP$Event)
      #DAT_LFP$Event <- factor(DAT_LFP$Event, levels = levels(DAT_LFP$Event)[c(5, 4, 2, 3, 1)])
      
      if (nor == 'RAW' | nor == 'dNOR') {
        DAT_LFP$value = 10*log10(Re(DAT_LFP$value))
      } else {
        DAT_LFP$value = Re(DAT_LFP$value)
      }
      
      
      
      ############################################################################################
      #############################################################################################
      ### 1 plot per condition and trial
      ############################################################################################
      #############################################################################################
      
      for (cond in conditions) {
        temp3 <- subset(DAT_LFP, DAT_LFP$Condition == cond)
        if (ElecGroup == 1) {
          temp3 = aggregate( value ~ Patient + Medication + Event + Freq + times + nTrial + grouping + HEM_o, temp3,
                             FUN = funType,
                             na.rm = T,
                             na.action = NULL)
        } # else if (ElecGroup == 0) {
          # temp3 = aggregate( value ~ Patient + Medication + Event + Freq + times + nTrial + Chan_o + HEM_o, temp3,
          #                    FUN = funType,
          #                    na.rm = T,
          #                    na.action = NULL)
        # }
        


        temp3 <- temp3[temp3$Freq >= FreqLim,]
        
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
        
        trials = unique(temp3$nTrial)
        
        
        for (nTrial in trials) {
          remove(temp4)
          temp4 <- temp3[temp3$nTrial == nTrial,]
          
          temp4 <- temp4[temp4$times >= (-1 * TimeLim) & temp4$times <= TimeLim, ] #0.5
          
          # lim  <- max(abs(temp4_ind$value))
          lim = ColLim # 10
          
          ## GRAPH
          
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
            ggplot(temp4, aes(x = times, y = Freq, fill = value)) +
              geom_raster(interpolate = F) + 
              scale_fill_gradientn(colours = myPalette(100),lim = c(-lim, lim), na.value = "#7F0000") +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ Medication + HEM_o + Event, drop = TRUE,scales = "free_x") +
              ggtitle(paste(s, nor, cond, 'nTrial', nTrial , sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
          }
          ## sauvegarde des graphes
          ggsave(paste(OutputPathInd, '/', paste(s, nor, 'tBlock', tBlock, 'fqStart', fqStart, cond, 'nTrial', nTrial, sep = "_"), '.png', sep = ""),
                 width = 32, height =18, units = "cm")
        }
        
        
        remove(temp3)
      }
      
      
      rm(DAT_LFP)
      
    }
    
  }
}



