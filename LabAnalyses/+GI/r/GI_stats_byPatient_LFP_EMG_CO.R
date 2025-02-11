#############################################################################################
##                                                                                         ##
##                       Marche Reelle  -  stats                                           ##
##                                                                                         ##
#############################################################################################

#############################################################################################
###### Initialisation
# DEFINE PATHS
DataDir   = 'D:/01_IR-ICM/donnees/Analyses/DBS/DBStmp_Matthieu/data/analyses' #'//lexport/iss01.dbs/data/analyses/'
OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/04_Traitement/03_CartesTF"
ScriptDir = 'D:/01_IR-ICM/donnees/git_for_github/LabAnalyses/+GI'
ElecGroup  = 0 # 1 if electrodes averaged by region

# PRECISE nomarlization types
# segType  = 'step' #'trial'   'step' 
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')
normtype = c('sNOR')
datatype = 'TF' #meanTF' #'PE' # TF
CO_meth  = c('MVcoh')
tBlock   = '0375'
# fqStart  = '1'
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('PPN')
#SELECT EVENTS
events  = c('T0_EMG')
conditions = c('APA')
funType   = c('median') # 'median'
FqBdesLim  = c(1, 4, 8, 13, 21, 36, 61, 81)

todo.stats = 0
todo.figs  = 1
todo.test  = 'emmeans_cont' # 'joint_test' #   'emmeans_pairs' 'emmeans_cont'

if (datatype == 'FqBdes') {
  freqs   = c("1-3", "4-7", "8-12", "13-20", "21-35", "36-60", "61-80")
} else if (datatype == 'TF') {
  freqs   = 1:100
  # freqs   = 10:11
} 


# load coordinate file
# coordinates <- read.csv(paste(ScriptDir, '/', '+load/VG_loc_electrodes.csv', sep = ""), header = TRUE, sep = ";") 

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
    } else if (gp == 'PPN') {
      subjects <-
        c(
          'AVl_0444'# ,
          # 'CHd_0343',
          # 'LEn_0367',
          # 'SOd_0363'
        )
      listnameSubj =
        c(
          'PPNPitie_2018_07_05_AVl'# ,
          # 'PPNPitie_2016_11_17_CHd',
          # 'PPNPitie_2017_06_08_LEn',
          # 'PPNPitie_2017_03_09_SOd'
        )
    }
    
    ### Definition des couleurs
    myPalette  <- colorRampPalette(
      c("#00007F", "#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", 
        "yellow", "#FF7F00", "red", "#7F0000", "#7F0000" ))
    
    ## LIBRARY
    library(reshape2)
    library(RColorBrewer)
    library(ggplot2)
    library(lme4)
    library(lmerTest)
    library(emmeans)
    
    ## path
    dir.create(paste(OutputDir, gp, nor, sep = "/"))
    OutputPathAll = paste(OutputDir, gp, nor, 'stats', sep = "/")
    dir.create(OutputPathAll)
    
    OutputPathAll = paste(OutputPathAll, conditions, sep = "/")
    dir.create(OutputPathAll)
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    
    s_count = 0
    for (s in subjects) {
      s
      s_count = s_count + 1
      
      # path
      RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
      setwd(paste(RecDir, '/POSTOP', sep = ""))
      
      #SET PROTOCOL
      if (gp == 'STN') {
        if (s == 'AUa_0342' | s == 'PHj_0351') {
          protocol = 'GBMOV'
        } else {
          protocol = 'GBxxx'
        }
      } else if (gp == 'PPN') {
        protocol = 'GAITPARK'
      }
      
      outputname <- listnameSubj[s_count]
      
      
      if (todo.stats == 1) {
        for (ev in events) {
          # Lecture du fichier
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', 'LFP_EMG_', CO_meth, '_', 'tBlock', tBlock, '_', ev, '.csv', sep = ""))
          
          temp <- temp[, c("Protocol", "Patient", "Medication", "Condition", "Channel", "Freq", "Run", "nTrial", "side","Event", "isValid",
                           colnames(temp)[16:length(colnames(temp))])]
          temp <- melt(temp, id = c("Protocol", "Patient", "Medication", "Condition", "Freq", "Channel", "Run", "nTrial", "side", "Event", "isValid"))
          
          
          
          if (nor == 'ldNOR' | nor == 'sNOR') {
            temp_BSL <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', 'LFP_EMG_', CO_meth, '_', 'tBlock', tBlock, '_', 'BSL', '.csv', sep = ""))
            
            temp_BSL <- temp_BSL[, c("Protocol", "Patient", "Medication", "Condition", "Channel", "Freq", "Run", "nTrial", "side","Event", "isValid",
                             colnames(temp_BSL)[16:length(colnames(temp_BSL))])]
            temp_BSL <- melt(temp_BSL, id = c("Protocol", "Patient", "Medication", "Condition", "Freq", "Channel", "Run", "nTrial", "side", "Event", "isValid"))
            
            temp <- rbind(temp, temp_BSL)
            remove(temp_BSL)
          }

          # temp$grouping[is.na(temp$grouping)] = ''
          # temp$nStep[is.na(temp$nStep)] = ''
          temp$side[is.na(temp$side)] = ''
          
          # keep only quality == 1 (reject events rejected by visual inspection)
          # if (ev != 'FOG_S' & ev != 'FOG_E') {
          #   temp <- subset(temp, temp$quality == 1)
          # }
          # 
           # transform to log if dNOR before averaging
          if (nor == 'ldNOR' | nor == 'RAW') {
            temp$value = 10*log10(Re(temp$value))
          }
          
          # average frequency bands if FqBdes
          if (datatype == 'FqBdes') {
            temp$FqBde = 'FqBde'
            for (ifq in 1:(length(FqBdesLim)-1)) {
              temp$FqBde[temp$Freq >= FqBdesLim[ifq] & temp$Freq < FqBdesLim[ifq+1]] = paste(FqBdesLim[ifq], FqBdesLim[ifq+1]-1, sep = '-')
            }
            temp <- subset(temp, temp$FqBde != 'FqBde')
            temp$Freq = temp$FqBde
          }
          
          

          # # add coordinates: loop on channel
          # channel_name = unique(temp$Channel)
          # temp$x = NaN
          # temp$y = NaN
          # temp$z = NaN
          # for (ch in channel_name) {
          #   temp$x[which(temp$Channel == ch)] = coordinates$x[which(coordinates$ChName == ch & coordinates$Patient == s)]
          #   temp$y[which(temp$Channel == ch)] = coordinates$y[which(coordinates$ChName == ch & coordinates$Patient == s)]
          #   temp$z[which(temp$Channel == ch)] = coordinates$z[which(coordinates$ChName == ch & coordinates$Patient == s)]
          # }
          # 
          # On compile les donnÃ©es de tous les patients
          if (exists('DAT_LFP')) {DAT_LFP <- rbind(DAT_LFP, temp)
          } else {
            DAT_LFP <- temp
          }
          
          rm('temp')
          gc(verbose = FALSE)
          
          
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
          DAT_LFP <- DAT_LFP[DAT_LFP$times > -0.7 & DAT_LFP$times < 1, ] #0.5
          
          #HEM
          DAT_LFP$HEM   <- factor(substr(DAT_LFP$Channel, 3, 3))         
          DAT_LFP$chan  <- factor(substr(DAT_LFP$Channel, 1, 2))        
          DAT_LFP$EMG   <- factor(substr(DAT_LFP$Channel, 5, 7))
          
          
          # get time values
          times = unique(DAT_LFP$times[which(DAT_LFP$Event == ev)])
          
          
          for (fq in freqs) { 
            print(fq)
            temp_fq <- DAT_LFP[which(DAT_LFP$Freq == fq), ]
            
            if (nor == 'ldNOR' | nor == 'sNOR') {
              temp_BSL_fq = temp_fq[which(temp_fq$Event == 'BSL'), ]
              
              # select time to keep for step
              temp_BSL_fq = temp_BSL_fq[temp_BSL_fq$times >= 0 & temp_BSL_fq$times <= 0.5, ]
              # average
              temp_BSL_fq = aggregate( value ~ Protocol + Patient + Medication + Condition + Freq + Channel + Run + 
                                          nTrial + Event + HEM + chan,
                                        temp_BSL_fq,
                                        FUN = funType,
                                        na.rm = T,
                                        na.action = NULL)
              
            }
            
            # stats: loop on times
            for (tps in times) { 
              print(tps)
              # get data at tps time
              temp_tps <- temp_fq[which(temp_fq$times == tps), ]
              
              temp_tps$Medication <- as.factor(temp_tps$Medication)
              temp_tps$Patient    <- as.factor(temp_tps$Patient)
              temp_tps$HEM        <- as.factor(temp_tps$HEM)
              
              temp_tps$value = Re(temp_tps$value)
              
              # if (ElecGroup == 1) {
              #   regions = unique(temp_tps$grouping)
              # } else {
              regions = unique(temp_tps$Channel)
              # }
              
              for (rg in regions) {
                #print(rg)
                if (ElecGroup == 1) {
                  temp <- temp_tps[which(temp_tps$grouping == rg), ]
                  if (nor == 'ldNOR' | nor == 'sNOR') {
                    temp_BSL <- temp_BSL_fq[which(temp_BSL_fq$grouping == rg), ]
                  }
                } else {
                  temp <- temp_tps[which(temp_tps$Channel == rg), ]
                  if (nor == 'ldNOR' | nor == 'sNOR') {
                    temp_BSL <- temp_BSL_fq[which(temp_BSL_fq$Channel == rg), ]
                  }
                }
                # temp = temp[, c("Patient", "Medication", "Condition", "IsDoor", "value", "HEM", "x", "y", "z")]

                if (nor == 'ldNOR' | nor == 'sNOR') {
                  # temp      = temp[which(temp$isValid == 1), ]
                  # temp_step = temp[which(temp$Event == 'FO'), ]
                  temp      = temp[which(temp$Event == ev), ]
                  trial_num = unique(temp$nTrial)
                  trial_med = unique(temp$Medication)
                  # temp_step = temp_step[which(temp_step$nTrial == trial_num), ]

                  # select time to keep for step
                  # temp_step = temp_step[which(is.numeric(temp_step$times) >= 0 & temp_step$times <= 0.2), ]
                  # average
                  # temp_step = aggregate( value ~ Protocol + Patient + Medication + Condition + Freq + Channel + Region + grouping + Run + 
                  #                   nTrial + Event + isValid + variable + times + HEM + chan,
                  #                   temp_step,
                  #                   FUN = funType,
                  #                   na.rm = T,
                  #                   na.action = NULL)
                  
                  
                  for (med in trial_med) {
                    for (n_trial in trial_num) {
                      temp$value[which(temp$nTrial == n_trial & temp$Medication == med)] = 
                        temp$value[which(temp$nTrial == n_trial & temp$Medication == med)] - temp_BSL$value[which(temp_BSL$nTrial == n_trial & temp_BSL$Medication == med)]
                    }
                  }
                  remove(temp_BSL)
                }
                
                
                if (gp == 'STN') {
                  # model.lmer        = lmer(value ~ Medication*Condition*IsDoor + HEM + x + y + z + (1|Patient), data=temp)
                } else if (gp == 'PPN') {
                  # model.lmer        = lmer(value ~ Medication*Condition*IsDoor + HEM + (1|Patient), data=temp)
                  # model.lmer        = lmer(value ~ Medication + HEM + (1|Patient), data=temp)
                  # model.lmer        = lm(value ~ Medication + HEM , data=temp)
                  if (ev == 'FOG_S' | ev == 'FOG_E') {
                    model.lmer        = lm(value ~ Medication + isValid, data=temp) 
                    }
                    else {
                      model.lmer        = lm(value ~ Medication, data=temp)
                    }
                }
                
                
                # descriptive values of conditions
                # Descr_tmp  = summary(emmeans(model.lmer, ~ Condition*IsDoor |Medication))
                # Descr_tmp  = summary(emmeans(model.lmer, ~ (1|Medication) + (1|HEM)))
                Descr_tmp  = summary(emmeans(model.lmer, ~ (1|Medication)))
                
                # pour faires des constrates https://aosmith.rbind.io/2019/04/15/custom-contrasts-emmeans/#reasons-for-custom-comparisons
                
                if (todo.test  == 'joint_test') {
                  # pour afficher les interactions des facteurs
                  # stats_tmp          = joint_tests(model.lmer, by = "Medication")
                } else if (todo.test  == 'emmeans_pairs') {
                  # # pour afficher toutes les comparaisons 2 à 2
                  # model.lmer.emm.s  <- emmeans(model.lmer, ~ Medication*Condition*IsDoor)
                  # par medication: fonctionne !!
                  # model.lmer.emm.s  <- emmeans(model.lmer, ~ Condition*IsDoor |Medication)
                  
                  # stats_tmp  = print(pairs(model.lmer.emm.s, adjust = "none"))
                  
                } else if (todo.test  == 'emmeans_cont') {
                  # model.lmer.emm.s  <- emmeans(model.lmer, ~ Condition*IsDoor |Medication)
                  # model.lmer.emm.s  <- emmeans(model.lmer, ~ Medication + HEM)
                  model.lmer.emm.s  <- emmeans(model.lmer, ~ Medication)
                  
                  # get contrast  
                  OFF = c(1,0)
                  ON  = c(0,1)
 
                  stats_tmp = summary(contrast(model.lmer.emm.s, method = list("OFF" = OFF, "ON" = ON)))
                  # 
                  # # get contrast  
                  # OFF_D = c(1,0,0,0)
                  # ON_D  = c(0,1,0,0)
                  # OFF_G = c(0,0,1,0)
                  # ON_G  = c(0,0,0,1)
                  # OFF   = (OFF_D + OFF_G)/2
                  # ON    = (ON_D + ON_G)/2
                  # D     = (OFF_D + ON_D)/2
                  # G     = (OFF_G + ON_G)/2
                  # 
                  # stats_tmp = summary(contrast(model.lmer.emm.s, method = list("OFF_D" = OFF_D, "ON_D" = ON_D, "OFF_G" = OFF_G, "ON_G" = ON_G,
                  #                                                              "OFF" = OFF, "ON" = ON, "D" = D, "G" = G)))
                }
                
                # 
                stats_tmp$Event      <- ev
                stats_tmp$Freq       <- fq
                stats_tmp$times      <- tps 
                stats_tmp$grouping   <- factor(substr(rg, 1, 2)) 
                stats_tmp$HEM        <- factor(substr(rg, 3, 3)) 
                stats_tmp$EMG        <- factor(substr(rg, 5, 7))  
                stats_tmp$Medication <- stats_tmp$contrast
                # stats_tmp$HEM        <- NA 
                # stats_tmp$Medication <- NA 
                # stats_tmp$HEM[stats_tmp$contrast == "OFF_D" | stats_tmp$contrast == "ON_D"] = "D" 
                # stats_tmp$HEM[stats_tmp$contrast == "OFF_G" | stats_tmp$contrast == "ON_G"] = "G" 
                # stats_tmp$Medication[stats_tmp$contrast == "OFF_D" | stats_tmp$contrast == "OFF_G"] = "OFF" 
                # stats_tmp$Medication[stats_tmp$contrast == "ON_D" | stats_tmp$contrast == "ON_G"] = "ON" 
                
                Descr_tmp$Event    <- ev
                Descr_tmp$Freq     <- fq
                Descr_tmp$times    <- tps 
                # stats_tmp$grouping <- factor(substr(rg, 1, 2)) 
                # stats_tmp$HEM      <- factor(substr(rg, 3, 3)) 
                # stats_tmp$EMG      <- factor(substr(rg, 5, 7)) 

                # compile data
                if (exists('stats_out')) {stats_out <- rbind(stats_out, stats_tmp)
                } else {
                  stats_out <- stats_tmp
                }
                
                if (exists('Descr_out')) {Descr_out <- rbind(Descr_out, Descr_tmp)
                } else {
                  Descr_out <- Descr_tmp
                }

                rm('temp')
                rm('model.lmer')
                rm('stats_tmp') 
                rm('Descr_tmp') 
              }
              rm('temp_tps')
            }
            rm('temp_fq')
            rm('temp_BSL_fq')
          }
          
          rm('DAT_LFP')
          gc(verbose = FALSE)
          # save table
          write.table(stats_out, paste(OutputPathAll, '/', 'stats_out_', todo.test, '_', s, '_', nor, CO_meth, '.csv', sep = ""))
          write.table(Descr_out, paste(OutputPathAll, '/', 'descr_out_', todo.test, '_', s, '_', nor, CO_meth, '.csv', sep = ""))
        }
      }
      
      gc(verbose = FALSE)
      rm('stats_out')
      rm('Descr_out')
      
      
      if (todo.figs == 1){
        
        # stats
        stats_mat = c('stats_out') 
        # load stat file
        stats_out <- read.csv(paste(OutputPathAll, '/', 'stats_out', '_', todo.test, '_', s, '_', nor, CO_meth, '.csv', sep = ""), header = TRUE, sep = " ")

        
        # change names for statsAno
        if (todo.test  == 'joint_test') {
          stats_out$estimate <- stats_out$`F.ratio`
          stats_out$contrast <- stats_out$model.term
        }
        
        # loop on contrasts to create figure
        contrast_names = unique(stats_out$contrast)
        # stats_out = stats_out[stats_out$contrast == "OFF_D" | stats_out$contrast == "OFF_G" | stats_out$contrast == "ON_D" | stats_out$contrast == "ON_G",]
        
        
        # order events
        stats_out$Event <- as.factor(stats_out$Event)
        # stats_out$Event <-
        #   factor(stats_out$Event, levels = levels(stats_out$Event)[c("T0", "FO1", "FC1")]) # On inverse l'ordre des events pour avoir gait-door-end
        # levels(stats_out$Event)
        
        if (conditions == 'FOG') {
          stats_out$Event <- factor(stats_out$Event, levels = levels(stats_out$Event)[c("FOG_S", "FOG_E")]) # On inverse l'ordre des events pour avoir gait-door-end
        }
        
        
        stats_out$HEM <- as.factor(stats_out$HEM)
        stats_out$HEM <- factor(stats_out$HEM, levels = levels(stats_out$HEM)[c(2, 1)]) # On inverse l'ordre des facteurs pour présenter gauche à gauche et droite à droite sur les graphes
        
        stats_out$grouping <- as.factor(stats_out$grouping)
        
        #Chan
        if (ElecGroup == 1) {
        } else {
          #stats_out$grouping <- factor(substr(stats_out$grouping, 1, 2))
          stats_out$grouping <- factor(stats_out$grouping, levels = levels(stats_out$grouping)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
        }

        
        # mask non significant pvalues
        stats_out$estimate_p05 <- stats_out$estimate
        stats_out$estimate_p05[which(stats_out$p.value > 0.05)]<- 0
        
        stats_out$estimate_p001 <- stats_out$estimate
        stats_out$estimate_p001[which(stats_out$p.value > 0.001)]<- 0
        
        # fdr correction
        stats_out$p.fdr = p.adjust(stats_out$p.value, method = 'fdr')
        stats_out$estimate_pfdr <- stats_out$estimate
        stats_out$estimate_pfdr[which(stats_out$p.fdr > 0.05)]<- 0
        
        lim = 1
        
        
        
        myvars <- c("estimate", "estimate_p001", "estimate_p05", "estimate_pfdr","p.value", "Event", "Freq", "times", "grouping", "Medication", "HEM", "EMG")
        temp <- stats_out[myvars]
        
        temp <- melt(temp, id = c("p.value", "Event", "Freq", "times", "grouping", "Medication", "HEM", "EMG"))
        
        thresh = levels(unique(temp$variable))
        
        for (th in thresh ){
          temp2 <- subset(temp, temp$variable == th)
          
          for (EMGch in unique(temp$EMG)) {
            temp3 <- subset(temp2, temp2$EMG == EMGch)
            
            # facet_grid(variable ~ Medication + Event,
            ggplot(temp3, aes(x = times, y = 100-Freq, fill = value)) + geom_raster(interpolate = F) + 
              scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#7F0000") +
              geom_vline(xintercept = 0, size = .1) + theme_classic() +
              facet_grid(grouping ~ Medication + HEM +  Event , drop = TRUE, scales = "free_x") +
              ggtitle(paste('stats_out', todo.test, s, nor, EMGch, CO_meth, th, sep = "_")) +
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(paste(OutputPathAll, '/', paste('stats_out', todo.test, s, nor, EMGch, CO_meth, th, sep = "_"), '.png', sep = ""),
                   width = 6,
                   height = 8)
          }
        }
        
        
       
        rm('stats_out')
        
        
        # 
        # # descr
        # descr_out <- read.csv(paste(OutputPathAll, '/', 'descr_out_', todo.test, '_', gp, '_', nor, '.csv', sep = ""), header = TRUE, sep = " ")
        # conditions = c('allcond', 'marche', 'tapis')
        # doorCond   = c('alldoor', 'Door', 'noDoor')
        # 
        # # order events
        # descr_out$Event <- as.factor(descr_out$Event)
        # descr_out$Event <-
        #   factor(descr_out$Event, levels = levels(descr_out$Event)[c(3, 1, 2)]) # On inverse l'ordre des events pour avoir gait-door-end
        # levels(descr_out$Event)
        # 
        # 
        # 
        # for (cond in conditions) {
        #   
        #   if (cond == 'allcond') {
        #     temp <- descr_out
        #   } else {
        #     temp <- subset(descr_out, descr_out$Condition == cond)
        #   }
        #   
        #   for (d in doorCond) {
        #     if (d == 'noDoor') {
        #       temp2 <- subset(temp, temp$IsDoor == 0)
        #     } else if (d == 'Door') {
        #       temp2 <- subset(temp, temp$IsDoor == 1)
        #     } else if (d == 'alldoor') {
        #       temp2 = temp
        #     }
        #     
        #     
        #     ## graph
        #     ggplot(temp2, aes(x = times, y = Freq, fill = emmean)) +
        #       geom_raster(interpolate = F) + 
        #       scale_fill_gradientn(colours = myPalette(100), lim = c(-lim, lim), na.value = "#7F0000") +
        #       geom_vline(xintercept = 0, size = .1) +
        #       theme_classic() +
        #       facet_grid(grouping ~ Medication + Event, drop = TRUE, scales = "free_x") +
        #       ggtitle(paste('descr_out', todo.test, nor, cond, d, sep = "_")) +
        #       theme(plot.title = element_text(hjust = 0.5))
        #     
        #     
        #     
        #     
        #     ## sauvegarde des graphes
        #     ggsave(paste(OutputPathAll, '/', paste('descr_out', todo.test, nor, cond, d, sep = "_"), '.png',sep = ""),
        #            width = 6, height = 8)
        #     
        #     
        #     remove(temp2)
        #     
        #   }
        #   remove(temp)
        # }
        # rm('descr_out')
      }
    }
  }
}


