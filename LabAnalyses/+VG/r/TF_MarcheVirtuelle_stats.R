#############################################################################################
##                                                                                         ##
##                       Marche Virtuelle  -  cartes TF individuelles                      ##
##                                                                                         ##
#############################################################################################

# test analyse 1 fichier 02/10/19



#############################################################################################
###### Initialisation
# DEFINE PATHS
# DataDir   = '//lexport/iss01.dbs/data/analyses/'
# OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheVirtuelle/04_Traitement/03_CartesTF"
ScriptDir = 'D:/01_IR-ICM/donnees/git_for_github/LabAnalyses/+VG'
DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_protocoles_data/MarcheVirtuelle/02_electrophy'
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_protocoles_data/MarcheVirtuelle/03_outputs/02_TFmaps"

# OutputDir = "F:/DBStmp/TF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('ldNOR')
datatype = 'TF'# 'TF' # 'FqBdes'
# PRECISE GROUPS
groups   = c('STN') #, ('STN', 'PPN')
# groups   = c('PPN')
#SELECT EVENTS
events  = c('GAIT', 'DOOR', 'END')
freqs   = 1:100
todo.descr = 0
todo.stats = 0
todo.count = 0
todo.figs  = 1
todo.test  = 'emmeans_cont' # 'joint_test' #   'emmeans_pairs' 'emmeans_cont'


# define frequency bandes
if (datatype == 'FqBdes'){
  fqBdes = c("1-3", "4-7", "8-12", "13-20", "21-35", "36-60", "61-80")
  FqBdesLim  = c(1, 4, 8, 13, 21, 36, 61, 81)
  freqs   = fqBdes
}

# load coordinate file
coordinates <- read.csv(paste(ScriptDir, '/', '+load/VG_loc_electrodes.csv', sep = ""), header = TRUE, sep = ";") 

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
    
    ## LIBRARY
    library(reshape2)
    library(RColorBrewer)
    library(ggplot2)
    library(lme4)
    library(lmerTest)
    library(emmeans)
    
    ## path
    OutputPathAll = paste(OutputDir, gp, nor, 'stats', sep = "/")
    dir.create(paste(OutputDir, gp, nor, 'stats', sep = "/")) 
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    if (todo.stats == 1 | todo.descr == 1 | todo.count == 1) {
      
      for (ev in events) {
        for (s in listnameSubj) {
          s
          
          # path
          # RecDir = list.dirs(paste(DataDir , s, sep = ""), full.names = T, recursive = F)
          # setwd(paste(RecDir, '/POSTOP', sep = ""))
          setwd(paste(DataDir, s, sep = "/"))
          
          #SET PROTOCOL
          if (gp == 'STN') {
            #if (s == 'AUa_0342' | s == 'PHj_0351') {
            if (s == 'ParkPitie_2016_10_13_AUa' |
                s == 'ParkPitie_2016_12_15_PHj') {
              protocol = 'GBMOV'
            }
            else {
              protocol = 'GBxxx'
            }
          }
          else if (gp == 'PPN') {
            protocol = 'GAITPARK'
          }
          
          # Recuperation nom de base du fichier
          name = list.files(
            # path = paste(RecDir, '/POSTOP', sep = ""), 
            path = paste(DataDir, s, sep = "/"),
            pattern = NULL, all.files = FALSE,
            full.names = FALSE, recursive = FALSE, ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
          
          name       <- matrix(unlist(strsplit(name[1], '_', fixed = FALSE, perl = FALSE, useBytes = FALSE)), ncol = 13, nrow = T)
          outputname <- paste(name[1], name[2], name[3], name[4], name[5], sep = "_")
          # listname[iname] = outputname
          
          # Lecture du fichier
          if (nor == 'ldNOR') {
            temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_VG_SIT_TF_', 'dNOR', '_', ev, '.csv', sep = ""))
          } else {
            temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_VG_SIT_TF_', nor, '_', ev, '.csv', sep = ""))
          }
          
          # keep only freq fq
          # temp <- temp[which(temp$Freq == fq), ]
          
          # get time values
          # times = colnames(temp)[14:length(colnames(temp))]
          
          # compile times to check that times are all the same
          # if (exists('times_check')) {times_check <- rbind(DAT_LFP, times)
          # } else {
          #   times_check <- times
          # }
          
          # # aggregate contacts to keep 1 region
          temp <- temp[, c("Protocol", "Patient", "Medication", "Condition", "IsDoor", "Channel", "Freq", "Region", "grouping", "Run", "Event", "nTrial", "DoorCond", "quality",
                           colnames(temp)[16:length(colnames(temp))])]
          temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Condition", "IsDoor", "Freq", "Channel", "Region", "grouping", "Run", "Event", "nTrial", "DoorCond", "quality"))
        
          
         # keep only quality == 1 (reject events rejected by visual inspection)
          temp <- subset(temp, temp$quality == 1)
          
          
          # keep only doors <= P=3
          temp <- subset(temp, temp$DoorCond != "P=4")
          temp <- subset(temp, temp$DoorCond != "P=5")
          
          # transform to log if dNOR before averaging
          if (nor == 'ldNOR') {
            temp$value = 10*log10(Re(temp$value))
          }
          
          # keeps only STN in grouping
          temp <- subset(temp, temp$grouping != "")
          temp <- subset(temp, temp$grouping != "NA")
          if (gp == 'STN') {
          } else if (gp == 'PPN') {
            temp <- subset(temp, temp$grouping != "SN")
          }
          
          
          
          
          # temp <- aggregate(
          #   value  ~ Protocol + Patient + Medication + Condition + IsDoor + variable + Freq + Channel + Region + grouping + Run + Event + nTrial,
          #   temp,
          #   FUN = funType, # 'mean',
          #   na.rm = T,
          #   na.action = NULL
          # )
          # 
          
          # add coordinates: loop on channel
          channel_name = unique(temp$Channel)
          temp$x = NaN
          temp$y = NaN
          temp$z = NaN
          for (ch in channel_name) {
            temp$x[which(temp$Channel == ch)] = coordinates$x[which(coordinates$ChName == ch & coordinates$RecID == s)]
            temp$y[which(temp$Channel == ch)] = coordinates$y[which(coordinates$ChName == ch & coordinates$RecID == s)]
            temp$z[which(temp$Channel == ch)] = coordinates$z[which(coordinates$ChName == ch & coordinates$RecID == s)]
          }
          # 
          # On compile les données de tous les patients
          if (exists('DAT_LFP')) {DAT_LFP <- rbind(DAT_LFP, temp)
          } else {
            DAT_LFP <- temp
          }
          
          rm('temp')
          gc(verbose = FALSE)
        }
        
        #TIMES
        # vérifier fenêtre de temps sélectionnée
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
        
        #HEM
        DAT_LFP$HEM   <- factor(substr(DAT_LFP$Channel, 3, 3))
        
        
        # add frequency bands if FqBdes
        if (datatype == 'FqBdes') {
          DAT_LFP$FqBde = 'FqBde'
          # temp$FqBde[temp$Freq >= FqBdesLim[1] & temp$Freq <= FqBdesLim[1+1]] = paste(FqBdesLim[1], FqBdesLim[1+1], sep = '-')
          for (ifq in 1:(length(FqBdesLim)-1)) {
            DAT_LFP$FqBde[DAT_LFP$Freq >= FqBdesLim[ifq] & DAT_LFP$Freq < FqBdesLim[ifq+1]] = paste(FqBdesLim[ifq], FqBdesLim[ifq+1]-1, sep = '-')
          }
          DAT_LFP <- subset(DAT_LFP, DAT_LFP$FqBde != 'FqBde')
          DAT_LFP$Freq = DAT_LFP$FqBde
         }
         
        # get time values
        times = unique(DAT_LFP$times)
        fq_count = 0
        
        for (fq in freqs) { 
          fq_count = fq_count + 1
          
          temp_fq <- DAT_LFP[which(DAT_LFP$Freq == fq), ]
          
          tps_count = 0
          # stats: loop on times
          for (tps in times) { 
            
            tps_count = tps_count + 1
            
            # get data at tps time
            temp_tps <- temp_fq[which(temp_fq$times == tps), ]
            
            temp_tps$Medication <- as.factor(temp_tps$Medication)
            temp_tps$Condition  <- as.factor(temp_tps$Condition)
            temp_tps$IsDoor     <- as.factor(temp_tps$IsDoor)
            temp_tps$Patient    <- as.factor(temp_tps$Patient)
            temp_tps$HEM        <- as.factor(temp_tps$HEM)
            
            
            temp_tps$value = Re(temp_tps$value)
            
            # # test
            # temp_ON  <- temp[which(temp$Medication == 'ON'), ]
            # temp_OFF <- temp[which(temp$Medication == 'OFF'), ]
            # 
            # model.lmer          = lmer(value ~ Condition*IsDoor + (1|Patient), data=temp_ON)
            # model.lmer.emm.s    <- emmeans(model.lmer, ~ Condition * IsDoor)
            # stats_ON            = print(pairs(model.lmer.emm.s))
            # stats_ON$Medication <- 'ON'
            # rm('model.lmer')
            # rm('model.lmer.emm.s')
            # 
            # model.lmer           = lmer(value ~ Condition*IsDoor + (1|Patient), data=temp_OFF)
            # model.lmer.emm.s     <- emmeans(model.lmer, ~ Condition*IsDoor)
            # test <- print(anova(model.lmer))
            # stats_OFF            = print(pairs(model.lmer.emm.s))
            # stats_OFF$Medication <- 'OFF'
            # rm('model.lmer')
            # rm('model.lmer.emm.s')
            # 
            # stats_tmp <- rbind(stats_ON, stats_OFF)
            
            # do stats and fill output matrix
            # lmer(P ~ DRUG + MarcheTapis*DoorNoDoor + Hem + X + Y + Z + (1|Id), data=dat)
            
            regions = unique(temp_tps$grouping)
            
            for (rg in regions) {
              temp <- temp_tps[which(temp_tps$grouping == rg), ]
              
              # average frequency bands if FqBdes
              if (datatype == 'FqBdes') {
                temp <- aggregate(value ~ Protocol + Patient + Medication + Condition + IsDoor + Freq + Channel + Region + grouping + Run + Event +
                                        + nTrial + DoorCond + quality + variable + value + x + y + z + times + HEM, temp, mean)
              }
              
              # temp = temp[, c("Patient", "Medication", "Condition", "IsDoor", "value", "HEM", "x", "y", "z")]
              if (todo.count == 1 & fq_count == 1 & tps_count == 1) {
                count_out_tmp       = aggregate(value ~ Patient + Medication + Condition + IsDoor + Channel, temp, length)
                count_out_tmp$event = ev
                
                # compile data
                if (exists('count_out')) {count_out <- rbind(count_out, count_out_tmp)
                } else {
                  count_out <- count_out_tmp
                }
                rm('count_out_tmp') 
              }
              
              
              
              if (todo.stats == 1 | todo.descr == 1) {
                if (gp == 'STN') {
                  model.lmer        = lmer(value ~ Medication*Condition*IsDoor + HEM + x + y + z + (1|Patient/Channel), data=temp)
                }
                else if (gp == 'PPN') {
                  # model.lmer        = lmer(value ~ Medication*Condition*IsDoor + HEM + (1|Patient), data=temp)
                  model.lmer        = lmer(value ~ Medication*Condition*IsDoor + (1|Patient), data=temp)
                }
                
                # descriptive values of conditions
                if (todo.descr == 1) {
                  Descr_tmp  = merge(summary(emmeans(model.lmer, ~ Condition*IsDoor |Medication)),
                                     do.call(data.frame,aggregate(value ~ Condition+IsDoor+Medication, data = temp, 
                                     FUN = function(x) c(moy = mean(x), med = median(x), std = sd(x), n=length(x)))))
                  
                  Descr_tmp$Event    <- ev
                  Descr_tmp$Freq     <- fq
                  Descr_tmp$times    <- tps 
                  Descr_tmp$grouping <- rg 
                  
                  if (exists('Descr_out')) {Descr_out <- rbind(Descr_out, Descr_tmp)
                  } else {
                    Descr_out <- Descr_tmp
                  }
                }
                
                # pour faires des constrates https://aosmith.rbind.io/2019/04/15/custom-contrasts-emmeans/#reasons-for-custom-comparisons
                if (todo.stats == 1) {
                  if (todo.test  == 'joint_test') {
                    # pour afficher les interactions des facteurs
                    stats_tmp          = joint_tests(model.lmer, by = "Medication")
                  } else if (todo.test  == 'emmeans_pairs') {
                    # # pour afficher toutes les comparaisons 2 ࠲
                    # model.lmer.emm.s  <- emmeans(model.lmer, ~ Medication*Condition*IsDoor)
                    # par medication: fonctionne !!
                    model.lmer.emm.s  <- emmeans(model.lmer, ~ Condition*IsDoor |Medication)
                    
                    stats_tmp  = print(pairs(model.lmer.emm.s, adjust = "none"))
                    
                  } else if (todo.test  == 'emmeans_cont') {
                    model.lmer.emm.s  <- emmeans(model.lmer, ~ Medication*Condition*IsDoor)
                    
                    # get contrast 
                    # OFF
                    OFF_marche_0 = c(1,0,0,0,0,0,0,0)
                    OFF_tapis_0  = c(0,0,1,0,0,0,0,0)
                    OFF_marche_1 = c(0,0,0,0,1,0,0,0)
                    OFF_tapis_1  = c(0,0,0,0,0,0,1,0)
                    OFF_marche   = (OFF_marche_0 + OFF_marche_1)/2
                    OFF_tapis    = (OFF_tapis_0 + OFF_tapis_1)/2
                    OFF_door     = (OFF_marche_1 + OFF_tapis_1)/2
                    OFF_noDoor   = (OFF_marche_0 + OFF_tapis_0)/2
                    
                    stats_tmp = summary(contrast(model.lmer.emm.s, method = list("OFF_marche_0" = OFF_marche_0, "OFF_tapis_0" = OFF_tapis_0, 
                                                                                 "OFF_marche_1" = OFF_marche_1, "OFF_tapis_1" = OFF_tapis_1,
                                                                                 "OFF_marche" = OFF_marche, "OFF_tapis" = OFF_tapis, "OFF_door" = OFF_door, "OFF_noDoor" = OFF_noDoor,
                                                                                 "OFF_marche-tapis" = OFF_marche - OFF_tapis , "OFF_door-noDoor" = OFF_door - OFF_noDoor,
                                                                                 "OFF_marche1-marche0"= OFF_marche_1 - OFF_marche_0,
                                                                                 "OFF_tapis1-tapis0"  = OFF_tapis_1 - OFF_tapis_0,
                                                                                 "OFF_marche1-tapis1"= OFF_marche_1 - OFF_tapis_1,
                                                                                 "OFF_marche0-tapis0"= OFF_marche_0 - OFF_tapis_0,
                                                                                 "OFF_marche1-tapis1_marche0-tapis0" = (OFF_marche_1 - OFF_tapis_1) - (OFF_marche_0 - OFF_tapis_0),
                                                                                 "OFF_marche1-marche0_tapis1-tapis0" = (OFF_marche_1 - OFF_marche_0) - (OFF_tapis_1 - OFF_tapis_0))))
                    
                    # ON
                    ON_marche_0 = c(0,1,0,0,0,0,0,0)
                    ON_tapis_0  = c(0,0,0,1,0,0,0,0)
                    ON_marche_1 = c(0,0,0,0,0,1,0,0)
                    ON_tapis_1  = c(0,0,0,0,0,0,0,1)
                    ON_marche   = (ON_marche_0 + ON_marche_1)/2
                    ON_tapis    = (ON_tapis_0 + ON_tapis_1)/2
                    ON_door     = (ON_marche_1 + ON_tapis_1)/2
                    ON_noDoor   = (ON_marche_0 + ON_tapis_0)/2
                    
                    stats_tmp_ON = summary(contrast(model.lmer.emm.s, method = list("ON_marche_0" = ON_marche_0, "ON_tapis_0" = ON_tapis_0, 
                                                                                    "ON_marche_1" = ON_marche_1, "ON_tapis_1" = ON_tapis_1,
                                                                                    "ON_marche" = ON_marche, "ON_tapis" = ON_tapis, "ON_door" = ON_door, "ON_noDoor" = ON_noDoor,
                                                                                    "ON_marche-tapis" = ON_marche - ON_tapis , "ON_door-noDoor" = ON_door - ON_noDoor,
                                                                                    "ON_marche1-marche0"= ON_marche_1 - ON_marche_0,
                                                                                    "ON_tapis1-tapis0"  = ON_tapis_1 - ON_tapis_0,
                                                                                    "ON_marche1-tapis1"= ON_marche_1 - ON_tapis_1,
                                                                                    "ON_marche0-tapis0"= ON_marche_0 - ON_tapis_0,
                                                                                    "ON_marche1-tapis1_marche0-tapis0" = (ON_marche_1 - ON_tapis_1) - (ON_marche_0 - ON_tapis_0),
                                                                                    "ON_marche1-marche0_tapis1-tapis0" = (ON_marche_1 - ON_marche_0) - (ON_tapis_1 - ON_tapis_0))))
                    
                    stats_tmp <- rbind(stats_tmp, stats_tmp_ON)
                    rm('stats_tmp_ON')
                    
                    # OFF-ON
                    stats_tmp_OFF_ON = summary(contrast(model.lmer.emm.s, method = list("OFF-ON_marche_0" = OFF_marche_0 - ON_marche_0, "OFF-ON_tapis_0" = OFF_tapis_0 - ON_tapis_0, 
                                                                                        "OFF-ON_marche_1" = OFF_marche_1 - ON_marche_1, "OFF-ON_tapis_1" = OFF_tapis_1 - ON_tapis_1,
                                                                                        "OFF-ON_marche" = OFF_marche - ON_marche, "OFF-ON_tapis" = OFF_tapis - ON_tapis, 
                                                                                        "OFF-ON_door" = OFF_door - ON_door, "OFF-ON_noDoor" = OFF_noDoor - ON_noDoor,
                                                                                        "OFF-ON_marche-tapis" = (OFF_marche - OFF_tapis) - (ON_marche - ON_tapis), 
                                                                                        "OFF-ON_door-noDoor" = (OFF_door - OFF_noDoor) - (ON_door - ON_noDoor),
                                                                                        "OFF-ON_marche1-marche0"= (OFF_marche_1 - OFF_marche_0) - (ON_marche_1 - ON_marche_0),
                                                                                        "OFF-ON_tapis1-tapis0"  = (OFF_tapis_1 - OFF_tapis_0) - (ON_tapis_1 - ON_tapis_0),
                                                                                        "OFF-ON_marche1-tapis1"= (OFF_marche_1 - OFF_tapis_1) - (ON_marche_1 - ON_tapis_1),
                                                                                        "OFF-ON_marche0-tapis0"= (OFF_marche_0 - OFF_tapis_0) - (ON_marche_0 - ON_tapis_0),
                                                                                        "OFF-ON_marche1-marche0_tapis1-tapis0" = ((OFF_marche_1 - OFF_marche_0) - (OFF_tapis_1 - OFF_tapis_0)) - ((ON_marche_1 - ON_marche_0) - (ON_tapis_1 - ON_tapis_0)))))
                    
                    
                    stats_tmp <- rbind(stats_tmp, stats_tmp_OFF_ON)
                    rm('stats_tmp_OFF_ON')
                    
                    # model.lmer.emm.s  <- emmeans(model.lmer, ~ Condition*IsDoor |Medication)
                    # 
                    # # get contrast  
                    # marche_0 = c(1,0,0,0)
                    # tapis_0  = c(0,1,0,0)
                    # marche_1 = c(0,0,1,0)
                    # tapis_1  = c(0,0,0,1)
                    # marche   = (marche_0 + marche_1)/2
                    # tapis    = (tapis_0 + tapis_1)/2
                    # door     = (marche_1 + tapis_1)/2
                    # noDoor   = (marche_0 + tapis_0)/2
                    # 
                    # stats_tmp = summary(contrast(model.lmer.emm.s, method = list("marche_0" = marche_0, "tapis_0" = tapis_0, 
                    #                                                              "marche_1" = marche_1, "tapis_1" = tapis_1,
                    #                                                              "marche" = marche, "tapis" = tapis, "door" = door, "noDoor" = noDoor,
                    #                                                              "marche-tapis" = marche - tapis , "door-noDoor" = door - noDoor,
                    #                                                              "marche1-marche0"= marche_1 - marche_0,
                    #                                                              "tapis1-tapis0"  = tapis_1 - tapis_0,
                    #                                                              "marche1-tapis1"= marche_1 - tapis_1,
                    #                                                              "marche0-tapis0"= marche_0 - tapis_0,
                    #                                                              "marche1-tapis1_marche0-tapis0" = (marche_1 - tapis_1) - (marche_0 - tapis_0),
                    #                                                              "marche1-marche0_tapis1-tapis0" = (marche_1 - marche_0) - (tapis_1 - tapis_0))))
                  }
                  
                  
                  # bleble
                  # 
                  stats_tmp$Event    <- ev
                  stats_tmp$Freq     <- fq
                  stats_tmp$times    <- tps 
                  stats_tmp$grouping <- rg 
                  
                  # # get interaction
                  # statsAno_tmp         <- anova(model.lmer)
                  # statsAno_tmp$contrast = row.names(statsAno_tmp) 
                  # statsAno_tmp$Event    <- ev
                  # statsAno_tmp$Freq     <- fq
                  # statsAno_tmp$times    <- tps 
                  # statsAno_tmp$grouping <- rg 
                  # statsAno_tmp$Medication <- 'OFF_ON' 
                  
                  # compile data
                  if (exists('stats_out')) {stats_out <- rbind(stats_out, stats_tmp)
                  } else {
                    stats_out <- stats_tmp
                  }
                  
                }
                
                # if (exists('statsAno_out')) {statsAno_out <- rbind(statsAno_out, statsAno_tmp)
                # } else {
                #   statsAno_out <- statsAno_tmp
                # }
                
                rm('temp')
                rm('model.lmer')
                rm('stats_tmp') 
                rm('Descr_tmp') 
                #  rm('statsAno_tmp')    
              }
            }
            rm('temp_tps')
          }
          rm('temp_fq')
        }
        
        rm('DAT_LFP')
        gc(verbose = FALSE)
        # save tables
        if (todo.stats == 1) {
          write.table(stats_out, paste(OutputPathAll, '/', 'stats_out_', datatype, '_', todo.test, '_', gp, '_', nor, '.csv', sep = ""))
          # write.table(statsAno_out, paste(OutputPathAll, '/', 'statsAno_out', '_', gp, '_', nor, '.csv', sep = ""))
        }
        
        if (todo.descr == 1) {
          write.table(Descr_out, paste(OutputPathAll, '/', 'descr_out_', datatype, '_', todo.test, '_', gp, '_', nor, '.csv', sep = ""))
        }
        
        if (todo.count == 1) {
          write.table(count_out, paste(OutputPathAll, '/', 'count_out', '_', gp, '_', nor, '.csv', sep = ""))
        }
        
      }
      
      
      #############################################################################################
      #####

 
      # # save tables
      # if (todo.stats == 1) {
      #   write.table(stats_out, paste(OutputPathAll, '/', 'stats_out_', todo.test, '_', gp, '_', nor, '.csv', sep = ""))
      #   write.table(Descr_out, paste(OutputPathAll, '/', 'descr_out_', todo.test, '_', gp, '_', nor, '.csv', sep = ""))
      #   # write.table(statsAno_out, paste(OutputPathAll, '/', 'statsAno_out', '_', gp, '_', nor, '.csv', sep = ""))}
      # }
      # 
      # if (todo.count == 1) {
      #   write.table(count_out, paste(OutputPathAll, '/', 'count_out', todo.test, '_', gp, '_', nor, '.csv', sep = ""))
      # }
      
    }
    gc(verbose = FALSE)
    rm('stats_out')
    rm('Descr_out')
    # rm('statsAno_out')
    
    
    if (todo.figs == 1){
      
      # stats
      stats_mat = c('stats_out') # , 'statsAno_out')
      for (statsName in stats_mat) {
        # load stat file
        stats_out <- read.csv(paste(OutputPathAll, '/', statsName, '_', datatype, '_', todo.test, '_', gp, '_', nor, '.csv', sep = ""), header = TRUE, sep = " ")
        if (statsName == 'statsAno_out'){
          stats_out <- statsAno_out
        }
        
        
        # change names for statsAno
        if (statsName == 'statsAno_out') {
          stats_out$estimate <- stats_out$`F.value`
          stats_out$p.value  <- stats_out$`Pr..F.`
          stats_out$contrast <- stats_out$contrast
        } else if (todo.test  == 'joint_test') {
          stats_out$estimate <- stats_out$`F.ratio`
          stats_out$contrast <- stats_out$model.term
        }
        
        # loop on contrasts to create figure
        contrast_names = unique(stats_out$contrast)
        
        # order events
        stats_out$Event <- as.factor(stats_out$Event)
        stats_out$Event <-
          factor(stats_out$Event, levels = levels(stats_out$Event)[c(3, 1, 2)]) # On inverse l'ordre des events pour avoir gait-door-end
        levels(stats_out$Event)
        
        # mask non significant pvalues
        stats_out$estimate_p05 <- stats_out$estimate
        stats_out$estimate_p05[which(stats_out$p.value > 0.05)]<- 0
        
        stats_out$estimate_p001 <- stats_out$estimate
        stats_out$estimate_p001[which(stats_out$p.value > 0.001)]<- 0
        
        # fdr correction
        stats_out$p.fdr = p.adjust(stats_out$p.value, method = 'fdr')
        stats_out$estimate_pfdr <- stats_out$estimate
        stats_out$estimate_pfdr[which(stats_out$p.fdr > 0.05)]<- 0
        
        for (ct in contrast_names) {
          temp <- subset(stats_out, stats_out$contrast == ct)
          
          myvars <- c("contrast", "estimate", "estimate_p001", "estimate_p05", "estimate_pfdr","p.value", "p.fdr", "Event", "Freq", "times", "grouping") #, "Medication") 
          temp <- temp[myvars]
          
          # temp <- melt(temp, id = c("contrast", "SE", "df", "z.ratio", "p.value", "Event", "Freq", "times"))
          temp <- melt(temp, id = c("contrast", "p.value", "p.fdr", "Event", "Freq", "times", "grouping")) # , "Medication"))
          
          
          # lim  <- max(abs(temp$p.value))
          lim = 3
          
          ## GRAPH
          if (ct == "Medication:Condition") {
            ctName = "MedicationvsCondition"
          }
          else if (ct == "Medication:IsDoor") {
            ctName = "MedicationvsIsDoor"
          }
          else if (ct == "Condition:IsDoor") {
            ctName = "ConditionvsIsDoor"
          }
          else if (ct == "Medication:Condition:IsDoor") {
            ctName = "MedicationvsConditionvsIsDoor"
          }
          
          else {
            ctName = ct
          }
          
          if (datatype == "FqBdes"){
            
            # stats_out$estimate_pfdr[which(stats_out$p.fdr > 0.05)]<- 0
        
            temp$Freq <- factor(temp$Freq, levels = c("1-3", "4-7", "8-12", "13-20", "21-35", "36-60", "61-80"))
            temp_NA = temp
            temp_NA$value[which(temp_NA$value==0)]<- NA
            
            ggplot(subset(temp, temp$variable == "estimate"), aes(x = times, y= value)) + # , color = as.factor(Freq))) +
              geom_line(color="blue") + ylim(-2, 2) +
              geom_vline(xintercept = 0, size = 0.1) +
              theme_classic() + 
              geom_hline(yintercept = 0, size = .1) +
              # geom_line(data=subset(temp, temp$variable == "estimate_pfdr" & temp$value > 0), color = 'red') +
              geom_line(data=subset(temp_NA, temp_NA$variable == "estimate_pfdr"), color = 'red') +

              facet_grid(Freq ~ grouping + Event , drop = TRUE,scales = "free_x") +
              ggtitle(paste('FqBdes', statsName, todo.test, nor, ct, sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))}
          
          else {
          # facet_grid(variable ~ Medication + Event,
            # temp$bin = temp$p.fdr
            # temp$bin[which(temp$p.fdr >= 0.05)]<- 0
            # temp$bin[which(temp$p.fdr < 0.05)]<- 1
          ggplot(temp, aes(x = times, y = Freq, fill = value)) +
            geom_raster(interpolate = F) + 
            scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#7F0000") +
            geom_vline(xintercept = 0, size = .1) +
            theme_classic() +
            #   facet_grid(variable ~ Medication + grouping + Event , drop = TRUE, scales = "free_x") +
            facet_grid(variable ~ grouping + Event , drop = TRUE, scales = "free_x") +
            #  geom_density_2d(data = temp[temp$p.fdr <0.5,], aes(colour = "black"), show.legend = FALSE, bins = 2) +
            geom_density_2d_filled(data = temp[temp$p.fdr < 0.05,], aes(z = p.fdr), show.legend = FALSE, n = 100)
            ggtitle(paste(statsName, todo.test, nor, ct, sep = "_")) +
            theme(plot.title = element_text(hjust = 0.5))+ # center the plot title
              scale_colour_manual("", values = "black")  
            
            # 
            # temp_gait = subset(temp, temp$variable == "estimate")
            # temp_gait = subset(temp_gait, temp_gait$Event == "END")
            # temp_fdr  = subset(temp, temp$variable == "estimate_pfdr")
            # temp_fdr  = subset(temp_fdr, temp_fdr$Event == "GAIT")
            # 
            # ggplot(temp_gait, aes(x = times, y = Freq, fill = value)) +
            #   geom_raster(interpolate = F) + 
            #   scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#7F0000") +
            #   geom_vline(xintercept = 0, size = .1) +
            #   theme_classic() +
            #   geom_density_2d(data = temp_gait[temp_gait$p.fdr < 0.05,], aes(colour = "black"), show.legend = FALSE, bins = 2) +
            #   #   geom_contour() +
            #   #   facet_grid(variable ~ Medication + grouping + Event , drop = TRUE, scales = "free_x") +
            #   #facet_grid(grouping  ~  Event , drop = TRUE, scales = "free_x") +
            #   ggtitle(paste(statsName, todo.test, nor, ct, sep = "_")) +
            #   theme(plot.title = element_text(hjust = 0.5))+ # center the plot title
            #   scale_colour_manual("", values = "black")  
            }
          # 
          # temp$pvalue = temp$p.fdr
          # data = temp_gait
          # data$Time = temp_gait$times
          # data$Power = temp_gait$value
          # data$pvalue = temp_gait$p.fdr
          # ggplot(data, aes(x = Time, y = Freq, fill = Power)) +
          #   # coord_trans(y = Espacement_Freq) +              # scale en log10
          #   geom_raster(interpolate = TRUE) + 
          #   scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value =  "#7F0000") +
          #   geom_vline(xintercept = 0, linewidth = .2) +         # add a vertical line at x = 0
          #   # geom_contour(data = data[data$pvalue < 0.05,], aes(z = pvalue, colour = "black"), show.legend = FALSE, bins=2, size=1) +
          #   theme_classic() + 
          #   geom_density_2d(data = data[data$pvalue < 0.05,], aes(colour = "black"), show.legend = FALSE, bins = 2) +
          #   ggtitle("test") +
          #   geom_hline(yintercept = 12, linetype = "dashed", color = "#000000", size = 0.5) +
          #   geom_hline(yintercept = 35, linetype = "dashed", color = "#000000", size = 0.5) +
          #   theme(plot.title = element_text(hjust = 0.5)) + # center the plot title
          #   scale_colour_manual("", values = "black")       # For the geom contour
          
          
          
          
          
          
          
          
          
          
          
          
          ## sauvegarde des graphes
          ggsave(paste(OutputPathAll, '/', paste(statsName, datatype, todo.test, nor, ctName, sep = "_"), '.png', sep = ""),
                 width = 6,
                 height = 8)
          
          rm('temp')
        }
        rm('stats_out')
        

      }
      # descr
      descr_out <- read.csv(paste(OutputPathAll, '/', 'descr_out_', datatype, '_', todo.test, '_', gp, '_', nor, '.csv', sep = ""), header = TRUE, sep = " ")
      conditions = c('allcond', 'marche', 'tapis')
      doorCond   = c('alldoor', 'Door', 'noDoor')
      
      # order events
      descr_out$Event <- as.factor(descr_out$Event)
      descr_out$Event <-
        factor(descr_out$Event, levels = levels(descr_out$Event)[c(3, 1, 2)]) # On inverse l'ordre des events pour avoir gait-door-end
      levels(descr_out$Event)
      
      
      
      for (cond in conditions) {
        
        if (cond == 'allcond') {
          temp <- descr_out
          # temp = aggregate( cbind(emmean,SE) ~ IsDoor + Medication + Event + Freq + times + grouping , descr_out, FUN = mean, na.rm = T, na.action = NULL)
        } else {
          temp <- subset(descr_out, descr_out$Condition == cond)
        }
        
        for (d in doorCond) {
          if (d == 'noDoor') {
            temp2 <- subset(temp, temp$IsDoor == 0)
          } else if (d == 'Door') {
            temp2 <- subset(temp, temp$IsDoor == 1)
          } else if (d == 'alldoor') {
            # temp2 = aggregate( cbind(emmean,SE) ~ Medication + Event + Freq + times + grouping , temp, FUN = mean,
            #            na.rm = T, na.action = NULL)
            temp2 <- temp
          }
          
          temp2$Condition_IsDoor <-paste(temp2$Condition,temp2$IsDoor,sep="_")
          
          if (datatype == "FqBdes"){
            
            temp2$Freq <- factor(temp2$Freq, levels = c("1-3", "4-7", "8-12", "13-20", "21-35", "36-60", "61-80"))
            
            ggplot(temp2, aes(x = times, y= value.moy, group = Condition_IsDoor, color = as.factor(Condition_IsDoor))) +
              geom_line() + ylim(-2, 2) +
              geom_vline(xintercept = 0, size = .1) +
              geom_hline(yintercept = 0, size = .1) +
              geom_ribbon(aes(ymin=value.moy-value.std/sqrt(value.n), ymax=value.moy+value.std/sqrt(value.n), fill = as.factor(Condition_IsDoor)), alpha = 0.3)+
              theme_classic() + 
              facet_grid(Freq ~  grouping + Medication + Event , drop = TRUE,scales = "free_x") +
              ggtitle(paste('FqBdes', 'descr_out_meanSD', todo.test, nor, cond, d, sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
          
           ## sauvegarde des graphes
            ggsave(paste(OutputPathAll, '/', paste('descr_out', datatype, todo.test, nor, cond, d, "meanSD", sep = "_"), '.png',sep = ""),
                 width = 25, height = 18)
            
            ggplot(temp2, aes(x = times, y=emmean, group = Condition_IsDoor, color = as.factor(Condition_IsDoor))) +
              geom_line() + ylim(-2, 2) +
              geom_vline(xintercept = 0, size = .1) +
              geom_hline(yintercept = 0, size = .1) +
              geom_ribbon(aes(ymin=emmean-SE, ymax=emmean+SE, fill = as.factor(Condition_IsDoor)), alpha = 0.3)+
              theme_classic() + 
              facet_grid(Freq ~  grouping + Medication + Event , drop = TRUE,scales = "free_x") +
              ggtitle(paste('FqBdes', 'descr_out', todo.test, nor, cond, d, sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))}
          
          else {
          ## graph
          ggplot(temp2, aes(x = times, y = Freq, fill = emmean)) +
            geom_raster(interpolate = F) + 
            scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#7F0000") +
            geom_vline(xintercept = 0, size = .1) +
            theme_classic() +
            facet_grid(grouping ~ Medication + Event, drop = TRUE, scales = "free_x") +
            ggtitle(paste('descr_out', todo.test, nor, cond, d, sep = "_")) +
            theme(plot.title = element_text(hjust = 0.5))}
          
          
          
          
          ## sauvegarde des graphes
          ggsave(paste(OutputPathAll, '/', paste('descr_out', datatype, todo.test, nor, cond, d, sep = "_"), '.png',sep = ""),
                 width = 25, height = 18)
          
          
          remove(temp2)
          
        }
        remove(temp)
      }
      rm('descr_out')
    }
  }
}


