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
DataDir   = '//lexport/iss01.dbs/data/analyses/'
InputDir  = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheVirtuelle/04_Traitement"
# InputDir  = "F:/DBStmp/TF"
OutputDir = "//lexport/iss01.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheVirtuelle/04_Traitement/03_CartesTF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR')
normtype = c('zNOR')
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('STN')
# SELECT EVENTS
events = c('GAIT', 'DOOR', 'END')
# events = c('DOOR', 'END')

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
    
    ### Chemin
    setwd(InputDir)
    OutputPath = paste(OutputDir, gp, nor, sep = "/")
    
    #### Lecture fichier
    # tempp <- read.table('temp_PPN.csv')
    # tempp <- read.table('temp_STN.csv')
    tempp <-
      read.table(paste('temp', '_', gp, '_', nor, '.csv', sep = ""))
    
    ### Patients
    # subjects <-  c('AVl_0444',  'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
    # listname = c('PPNPitie_2018_07_05_AVl','PPNPitie_2016_11_17_CHd','PPNPitie_2018_04_26_DEm','PPNPitie_2017_11_09_HAg','PPNPitie_2017_06_08_LEn','PPNPitie_2017_03_09_SOd')
    # subjects <-  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
    # listname = c("ParkPitie_2016_10_13_AUa", "ParkPitie_2018_03_08_BEe", "ParkPitie_2017_09_14_BEv", "ParkPitie_2017_01_26_GUa", "ParkPitie_2017_09_28_GUd",
    #             "ParkPitie_2018_01_18_MAn", "ParkPitie_2018_02_08_OGb", "ParkPitie_2016_12_15_PHj", "ParkPitie_2018_03_22_RUm", "ParkPitie_2018_02_01_VEm")
    
    ### Protocole
    # protocol <- 'GAITPARK'
    # if (s == 'AUa_0342' | s == 'PHj_0351') {protocol = 'GBMOV'} else {protocol = 'GBxxx'}
    
    
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
    
    
    ### Pb de donn�es pour le run 2 � supprimer
    # temp_ver = tempp[tempp$Patient == 'ParkPitie_2018_02_01_VEm' ,]
    # temp_ver = temp_ver[temp_ver$Run == 1,]
    #
    # temp2 = subset(tempp, tempp$Patient != 'ParkPitie_2018_02_01_VEm')
    # temp2 = rbind(temp2,temp_ver)
    # remove(temp_ver)
    
    
    for (ev in events) {
      temp2 <- subset(tempp, tempp$Event == ev)
      
      
      ### Mise en forme des donn�es des colonnes Channels et Hemisphere
      temp2$Chan_o <- as.character(temp2$Chan_o)
      temp2$Chan_o[temp2$Chan_o %in% c("1")] <- "01"
      temp2$Chan_o <- as.factor(temp2$Chan_o)
      levels(temp2$Chan_o)
      
      temp2$HEM_o <- as.factor(temp2$HEM_o)
      levels(temp2$HEM_o)
      
      #ORDER (on veut 01 en bas)
      if (gp == 'STN') {
        temp2$Chan_o <-
          factor(temp2$Chan_o, levels = levels(temp2$Chan_o)[c(3, 2, 1)]) # STN
      }
      else if (gp == 'PPN') {
        temp2$Chan_o <-
          factor(temp2$Chan_o, levels = levels(temp2$Chan_o)[c(7, 6, 5, 4, 3, 2, 1)]) # PPN
      }
      temp2$HEM_o <-
        factor(temp2$HEM_o, levels = levels(temp2$HEM_o)[c(2, 1)]) # On inverse l'ordre des facteurs pour pr�senter gauche � gauche et droite � droite sur les graphes
      
      
      ############################################################################################
      #############################################################################################
      ### TAPIS + Marche - Pas Porte ----
      ############################################################################################
      #############################################################################################
      if (ev != 'DOOR') {
        #############################################################################################
        ##INDIV
        temp_NoPorte <- subset(temp2, temp2$IsDoor == 0)
        temp_NoPorte = temp_NoPorte[, c(
          "Patient",
          "Medication",
          "Condition",
          "IsDoor",
          "Freq",
          "value",
          "times",
          "Chan_o",
          "HEM_o"
        )]
        temp_NoPorte = aggregate(
          value ~ Patient + Medication + Freq + times + Chan_o + HEM_o,
          temp_NoPorte,
          FUN = 'median',
          na.rm = T,
          na.action = NULL
        )
        
        
        
        limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
        colnames(limlist) = c('ON_D_NoPorte',
                              'ON_G_NoPorte',
                              'OFF_D_NoPorte',
                              'OFF_G_NoPorte')
        
        # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
        # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
        rownames(limlist) = subjects
        
        iname = 1
        ivar = 1
        
        ### PLOTS
        for (s in listnameSubj) {
          # s="ParkPitie_2016_10_13_AUa"
          temp_NoPorte2 <-
            temp_NoPorte[temp_NoPorte$Patient == s,]
          
          ## Selection de la MedCondition
          if (s == "PPNPitie_2018_04_26_DEm") {
            medCond = 'ON'
          } else{
            medCond = c('ON', 'OFF')
          }
          for (medcondi in medCond) {
            # medcondi = 'OFF'
            temp_NoPorte3 <-
              temp_NoPorte2[temp_NoPorte2$Medication == medcondi, ]
            
            ## Sélection del'hémisphère
            hem = c('D', 'G')
            for (h in hem) {
              # h = 'G'
              temp_NoPorte4 <-
                temp_NoPorte3[temp_NoPorte3$HEM == h,]
              
              if (exists('Delta_M')) {
                Delta_M <- rbind(Delta_M, temp_NoPorte4)
              } else {
                Delta_M <- temp_NoPorte4
              }
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp_NoPorte4$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
              ## GRAPH
              ggplot(temp_NoPorte4,
                     aes(
                       x = times,
                       y = Freq,
                       fill = Re(value)
                     )) +
                geom_tile() +
                scale_fill_gradientn(
                  colours = myPalette(100),
                  lim = c(-lim, lim),
                  na.value = "#7F0000"
                ) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() +
                facet_grid(Chan_o ~ HEM_o + Medication,
                           drop = TRUE,
                           scales = "free_x") + #~ Medication + Event
                ggtitle(
                  paste(
                    gp,
                    nor,
                    substr(subjects[iname], 0, 3),
                    temp_NoPorte4$Medication[1],
                    temp_NoPorte4$HEM[1],
                    ev,
                    'NoPorte_median' ,
                    sep = "_"
                  )
                ) + #, temp_NoPorte4$Medication[1], temp_NoPorte4$HEM[1]
                theme(plot.title = element_text(hjust = 0.5))
              
              # sauvegarde des graphes
              ggsave(
                paste(
                  OutputPath,
                  '/',
                  paste(
                    gp,
                    'TF',
                    nor,
                    subjects[iname],
                    medcondi,
                    h,
                    ev,
                    'NoPorte_median.png',
                    sep = "_"
                  ),
                  sep = ""
                ),
                width = 6,
                height = 8
              ) #'_', medcondi,'_',h,
              ivar = ivar + 1
            }
          }
          ivar = 1
          iname = iname + 1
        }
        
        # Write table des lim
        setwd(InputDir)
        write.table(limlist,
                    paste("limites_",
                          gp,
                          "_",
                          nor,
                          "_NoPorte_median.csv",
                          sep = ""))
        
        #############################################################################################
        ## all patients
        Delta_M_Tot <-
          aggregate(
            value ~ Medication + Freq + times + Chan_o + HEM_o ,
            Delta_M,
            FUN = "median",
            na.rm = T,
            na.action = NULL
          )
        
        
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          Delta_M_Tot1 <-
            Delta_M_Tot[Delta_M_Tot$Medication == medcondi, ]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            Delta_M_Tot2 <- Delta_M_Tot1[Delta_M_Tot1$HEM == h,]
            
            ## GRAPH
            lim  <-
              max(abs(Delta_M_Tot2$value)) # limites différentes pour chaque patient
            ggplot(Delta_M_Tot2, aes(
              x = times,
              y = Freq,
              fill = Re(value)
            )) +
              geom_tile() +
              scale_fill_gradientn(
                colours = myPalette(100),
                lim = c(-lim, lim),
                na.value = "#7F0000"
              ) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ HEM_o + Medication,
                         drop = TRUE,
                         scales = "free_x") + #~ Medication + Event
              ggtitle(
                paste(
                  gp,
                  nor,
                  Delta_M_Tot2$Medication[1],
                  Delta_M_Tot2$HEM[1],
                  ev,
                  "NoPorte_median" ,
                  sep = "_"
                )
              ) + #, temp_NoPorte4$Medication[1], temp_NoPorte4$HEM[1]
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(
              paste(
                OutputPath,
                '/',
                paste(
                  gp,
                  'TF',
                  nor,
                  medcondi,
                  h,
                  ev,
                  'NoPorte_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            
          }
        }
        
        remove(temp_NoPorte)
        remove(Delta_M_Tot)
        remove(Delta_M)
        remove(Delta_M_Tot1)
        remove(Delta_M_Tot2)
        remove(temp_NoPorte2)
        remove(temp_NoPorte3)
        remove(temp_NoPorte4)
      }
      ############################################################################################
      #############################################################################################
      ### TAPIS + Marche - Porte ----
      ############################################################################################
      #############################################################################################
      
      #############################################################################################
      ##INDIV
      temp_Porte <- subset(temp2, temp2$IsDoor == 1)
      temp_Porte = temp_Porte[, c(
        "Patient",
        "Medication",
        "Condition",
        "IsDoor",
        "Freq",
        "value",
        "times",
        "Chan_o",
        "HEM_o"
      )]
      temp_Porte = aggregate(
        value ~ Patient + Medication + Freq + times + Chan_o + HEM_o,
        temp_Porte,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )

      
      limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
      colnames(limlist) = c('ON_D_Porte',
                            'ON_G_Porte',
                            'OFF_D_Porte',
                            'OFF_G_Porte')
      # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367','SOd_0363')
      # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
      rownames(limlist) = subjects
      
      iname = 1
      ivar = 1
      
      ### PLOTS
      for (s in listnameSubj) {
        # s="ParkPitie_2016_10_13_AUa"
        temp_Porte2 <-
          temp_Porte[temp_Porte$Patient == s, ]
        
        ## Selection de la MedCondition
        if (s == "PPNPitie_2018_04_26_DEm") {
          medCond = 'ON'
        } else{
          medCond = c('ON', 'OFF')
        }
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          temp_Porte3 <-
            temp_Porte2[temp_Porte2$Medication == medcondi,]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            temp_Porte4 <-
              temp_Porte3[temp_Porte3$HEM == h, ]
            
            if (exists('Delta_M')) {
              Delta_M <- rbind(Delta_M, temp_Porte4)
            } else {
              Delta_M <- temp_Porte4
            }
            
            ## Sélection des limites du graphe
            lim  <-
              max(abs(temp_Porte4$value)) # limites différentes pour chaque patient
            limlist[iname, ivar] = lim
            
            ## GRAPH
            ggplot(temp_Porte4, aes(
              x = times,
              y = Freq,
              fill = Re(value)
            )) +
              geom_tile() +
              scale_fill_gradientn(
                colours = myPalette(100),
                lim = c(-lim, lim),
                na.value = "#7F0000"
              ) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ HEM_o + Medication,
                         drop = TRUE,
                         scales = "free_x") + #~ Medication + Event
              ggtitle(
                paste(
                  gp,
                  nor,
                  substr(subjects[iname], 0, 3),
                  temp_Porte4$Medication[1],
                  temp_Porte4$HEM[1],
                  ev,
                  'Porte_median' ,
                  sep = "_"
                )
              ) + #, temp_Porte4$Medication[1], temp_Porte4$HEM[1]
              theme(plot.title = element_text(hjust = 0.5))
            
            # sauvegarde des graphes
            ggsave(
              paste(
                OutputPath,
                '/',
                paste(
                  gp,
                  'TF',
                  nor,
                  subjects[iname],
                  medcondi,
                  h,
                  ev,
                  'Porte_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            ivar = ivar + 1
          }
        }
        ivar = 1
        iname = iname + 1
      }
      
      # Write table des lim
      setwd(InputDir)
      # write.table(limlist, "limites_Porte_PPN_median.csv")
      write.table(limlist,
                  paste("limites_",
                        gp,
                        "_",
                        nor,
                        "_Porte_median.csv",
                        sep = ""))
      
      #############################################################################################
      ## all patients
      Delta_M_Tot <-
        aggregate(
          value ~ Medication + Freq + times + Chan_o + HEM_o ,
          Delta_M,
          FUN = "median",
          na.rm = T,
          na.action = NULL
        )
      
      
      for (medcondi in medCond) {
        # medcondi = 'OFF'
        Delta_M_Tot1 <-
          Delta_M_Tot[Delta_M_Tot$Medication == medcondi,]
        
        ## Sélection del'hémisphère
        hem = c('D', 'G')
        for (h in hem) {
          # h = 'G'
          Delta_M_Tot2 <- Delta_M_Tot1[Delta_M_Tot1$HEM == h, ]
          
          ## GRAPH
          lim  <-
            max(abs(Delta_M_Tot2$value)) # limites différentes pour chaque patient
          ggplot(Delta_M_Tot2, aes(
            x = times,
            y = Freq,
            fill = Re(value)
          )) +
            geom_tile() +
            scale_fill_gradientn(
              colours = myPalette(100),
              lim = c(-lim, lim),
              na.value = "#7F0000"
            ) +
            geom_vline(xintercept = 0, size = .1) +
            theme_classic() +
            facet_grid(Chan_o ~ HEM_o + Medication,
                       drop = TRUE,
                       scales = "free_x") + #~ Medication + Event
            ggtitle(
              paste(
                gp,
                nor,
                Delta_M_Tot2$Medication[1],
                Delta_M_Tot2$HEM[1],
                ev,
                "Porte_median" ,
                sep = "_"
              )
            ) + #, temp_Porte4$Medication[1], temp_Porte4$HEM[1]
            theme(plot.title = element_text(hjust = 0.5))
          
          ## sauvegarde des graphes
          ggsave(
            paste(
              OutputPath,
              '/',
              paste(
                gp,
                'TF',
                nor,
                medcondi,
                h,
                ev,
                'Porte_median.png',
                sep = "_"
              ),
              sep = ""
            ),
            width = 6,
            height = 8
          ) #'_', medcondi,'_',h,
          
        }
      }
      
      
      remove(temp_Porte)
      remove(Delta_M_Tot)
      remove(Delta_M)
      remove(Delta_M_Tot1)
      remove(Delta_M_Tot2)
      remove(temp_Porte2)
      remove(temp_Porte3)
      remove(temp_Porte4)
      
      ############################################################################################
      #############################################################################################
      ### PORTE + NoPORTE - MARCHE ----
      ############################################################################################
      #############################################################################################
      #############################################################################################
      ### indiv
      temp_Marche <- subset(temp2, temp2$Condition == 'marche')
      temp_Marche = temp_Marche[, c(
        "Patient",
        "Medication",
        "Condition",
        "IsDoor",
        "Freq",
        "value",
        "times",
        "Chan_o",
        "HEM_o"
      )]
      temp_Marche = aggregate(
        value ~ Patient + Medication + Freq + times + Chan_o + HEM_o,
        temp_Marche,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      iname = 1
      ivar = 1
      
      
      limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
      colnames(limlist) = c('ON_D_Marche',
                            'ON_G_Marche',
                            'OFF_D_Marche',
                            'OFF_G_Marche')
      # rownames(limlist) = c('AVl_0444','CHd_0343','DEm_0423','HAg_0372','LEn_0367','SOd_0363')
      # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
      rownames(limlist) = subjects
      
      ### PLOTS
      for (s in listnameSubj) {
        # s="ParkPitie_2016_10_13_AUa"
        temp_Marche2 <-
          temp_Marche[temp_Marche$Patient == s, ]
        
        ## Selection de la MedCondition
        if (s == "PPNPitie_2018_04_26_DEm") {
          medCond = 'ON'
        } else{
          medCond = c('ON', 'OFF')
        }
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          temp_Marche3 <-
            temp_Marche2[temp_Marche2$Medication == medcondi,]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            temp_Marche4 <-
              temp_Marche3[temp_Marche3$HEM == h, ]
            
            if (exists('Delta_P')) {
              Delta_P <- rbind(Delta_P, temp_Marche4)
            } else {
              Delta_P <- temp_Marche4
            }
            
            ## Sélection des limites du graphe
            lim  <-
              max(abs(temp_Marche4$value)) # limites différentes pour chaque patient
            limlist[iname, ivar] = lim
            
            ## GRAPH
            ggplot(temp_Marche4,
                   aes(
                     x = times,
                     y = Freq,
                     fill = Re(value)
                   )) +
              geom_tile() +
              scale_fill_gradientn(
                colours = myPalette(100),
                lim = c(-lim, lim),
                na.value = "#7F0000"
              ) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ HEM_o + Medication,
                         drop = TRUE,
                         scales = "free_x") + #~ Medication + Event
              ggtitle(
                paste(
                  gp,
                  nor,
                  substr(subjects[iname], 0, 3),
                  temp_Marche4$Medication[1],
                  temp_Marche4$HEM[1],
                  ev,
                  'Marche_median' ,
                  sep = "_"
                )
              ) + #, temp_Marche4$Medication[1], temp_Marche4$HEM[1]
              theme(plot.title = element_text(hjust = 0.5))
            
            # sauvegarde des graphes
            ggsave(
              paste(
                OutputPath,
                '/',
                paste(
                  gp,
                  'TF',
                  nor,
                  subjects[iname],
                  medcondi,
                  h,
                  ev,
                  'Marche_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            ivar = ivar + 1
          }
        }
        ivar = 1
        iname = iname + 1
      }
      
      # Write table des lim
      setwd(InputDir)
      # write.table(limlist, "limites_Marche_PPN_median.csv")
      write.table(limlist,
                  paste("limites_",
                        gp,
                        "_",
                        nor,
                        "_Marche_median.csv",
                        sep = ""))
      
      
      #############################################################################################
      ## indiv
      Delta_P_Tot <-
        aggregate(
          value ~ Medication + Freq + times + Chan_o + HEM_o ,
          Delta_P,
          FUN = "median",
          na.rm = T,
          na.action = NULL
        )
      
      
      for (medcondi in medCond) {
        # medcondi = 'OFF'
        Delta_P_Tot1 <-
          Delta_P_Tot[Delta_P_Tot$Medication == medcondi,]
        
        ## Sélection del'hémisphère
        hem = c('D', 'G')
        for (h in hem) {
          # h = 'G'
          Delta_P_Tot2 <- Delta_P_Tot1[Delta_P_Tot1$HEM == h, ]
          
          ## GRAPH
          lim  <-
            max(abs(Delta_P_Tot2$value)) # limites différentes pour chaque patient
          ggplot(Delta_P_Tot2, aes(
            x = times,
            y = Freq,
            fill = Re(value)
          )) +
            geom_tile() +
            scale_fill_gradientn(
              colours = myPalette(100),
              lim = c(-lim, lim),
              na.value = "#7F0000"
            ) +
            geom_vline(xintercept = 0, size = .1) +
            theme_classic() +
            facet_grid(Chan_o ~ HEM_o + Medication,
                       drop = TRUE,
                       scales = "free_x") + #~ Medication + Event
            ggtitle(
              paste(
                gp,
                nor,
                Delta_P_Tot2$Medication[1],
                Delta_P_Tot2$HEM[1],
                ev,
                "Marche_median" ,
                sep = "_"
              )
            ) + #, temp_Marche4$Medication[1], temp_Marche4$HEM[1]
            theme(plot.title = element_text(hjust = 0.5))
          
          ## sauvegarde des graphes
          ggsave(
            paste(
              OutputPath,
              '/',
              paste(
                gp,
                'TF',
                nor,
                medcondi,
                h,
                ev,
                'Marche_median.png',
                sep = '_'
              ),
              sep = ""
            ),
            width = 6,
            height = 8
          ) #'_', medcondi,'_',h,
          
        }
      }
      
      remove(temp_Marche)
      remove(Delta_P_Tot)
      remove(Delta_P)
      remove(Delta_P_Tot1)
      remove(Delta_P_Tot2)
      remove(temp_Marche2)
      remove(temp_Marche3)
      remove(temp_Marche4)
      
      ############################################################################################
      #############################################################################################
      ### PORTE / NoPORTE  - MARCHE ----
      ############################################################################################
      #############################################################################################
      #############################################################################################
      ### indiv
      temp_Marche <- subset(temp2, temp2$Condition == 'marche')
      temp_Marche = temp_Marche[, c(
        "Patient",
        "Medication",
        "Condition",
        "IsDoor",
        "Freq",
        "value",
        "times",
        "Chan_o",
        "HEM_o"
      )]
      temp_Marche = aggregate(
        value ~ Patient + Medication + IsDoor + Freq + times + Chan_o + HEM_o,
        temp_Marche,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      iname = 1
      ivar = 1
      
      
      limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
      colnames(limlist) = c('ON_D_Marche',
                            'ON_G_Marche',
                            'OFF_D_Marche',
                            'OFF_G_Marche')
      # rownames(limlist) = c('AVl_0444','CHd_0343','DEm_0423','HAg_0372','LEn_0367','SOd_0363')
      # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
      rownames(limlist) = subjects
      
      ### PLOTS
      for (s in listnameSubj) {
        # s="ParkPitie_2016_10_13_AUa"
        temp_Marche2 <-
          temp_Marche[temp_Marche$Patient == s, ]
        
        ## Selection de la MedCondition
        if (s == "PPNPitie_2018_04_26_DEm") {
          medCond = 'ON'
        } else{
          medCond = c('ON', 'OFF')
        }
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          temp_Marche3 <-
            temp_Marche2[temp_Marche2$Medication == medcondi,]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            temp_Marche4 <-
              temp_Marche3[temp_Marche3$HEM == h, ]
            
            ## Loop on Door
            door = c(0, 1)
            for (d in door) {
              if (ev == 'DOOR' & d == 0) {
                next }
              if (d == 0) {
                figName = 'NoPorte'
              }
              else {
                figName = 'Porte'
              }
              
              # temp_Marche5 = temp_Marche4[temp_Marche4$IsDoor == d, c('Patient',
              #                                                         'IsDoor',
              #                                                         'Medication',
              #                                                         'Freq',
              #                                                         'times',
              #                                                         'Chan_o',
              #                                                         'HEM_o')]
              
              temp_Marche5 = subset(temp_Marche4, temp_Marche4$IsDoor == d)
              
              if (exists('Delta_P')) {
                Delta_P <- rbind(Delta_P, temp_Marche5)
              } else {
                Delta_P <- temp_Marche5
              }
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp_Marche5$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
              ## GRAPH
              ggplot(temp_Marche5,
                     aes(
                       x = times,
                       y = Freq,
                       fill = Re(value)
                     )) +
                geom_tile() +
                scale_fill_gradientn(
                  colours = myPalette(100),
                  lim = c(-lim, lim),
                  na.value = "#7F0000"
                ) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() +
                facet_grid(Chan_o ~ HEM_o + Medication,
                           drop = TRUE,
                           scales = "free_x") + #~ Medication + Event
                ggtitle(
                  paste(
                    gp,
                    nor,
                    substr(subjects[iname], 0, 3),
                    temp_Marche5$Medication[1],
                    temp_Marche5$HEM[1],
                    ev,
                    figName,
                    'Marche_median' ,
                    sep = "_"
                  )
                ) + #, temp_Marche5$Medication[1], temp_Marche5$HEM[1]
                theme(plot.title = element_text(hjust = 0.5))
              
              # sauvegarde des graphes
              ggsave(
                paste(
                  OutputPath,
                  '/',
                  paste(
                    gp,
                    'TF',
                    nor,
                    subjects[iname],
                    medcondi,
                    h,
                    ev,
                    figName,
                    'Marche_median.png',
                    sep = "_"
                  ),
                  sep = ""
                ),
                width = 6,
                height = 8
              ) #'_', medcondi,'_',h,
            }
            ivar = ivar + 1
          }
        }
        ivar = 1
        iname = iname + 1
      }
      
      # # Write table des lim
      # setwd(InputDir)
      # # write.table(limlist, "limites_Marche_PPN_median.csv")
      # write.table(
      #   limlist,
      #   paste(
      #     "limites_",
      #     gp,
      #     "_",
      #     nor,
      #     "_Porte_Marche_median.csv",
      #     sep = ""
      #   )
      # )
      #
      
      #############################################################################################
      ## indiv
      Delta_P_Tot <-
        aggregate(
          value ~ Medication + IsDoor + Freq + times + Chan_o + HEM_o ,
          Delta_P,
          FUN = "median",
          na.rm = T,
          na.action = NULL
        )
      
      
      for (medcondi in medCond) {
        # medcondi = 'OFF'
        Delta_P_Tot1 <-
          Delta_P_Tot[Delta_P_Tot$Medication == medcondi,]
        
        ## Sélection del'hémisphère
        hem = c('D', 'G')
        for (h in hem) {
          # h = 'G'
          Delta_P_Tot2 <- Delta_P_Tot1[Delta_P_Tot1$HEM == h, ]
          
          # loop on Door
          door = c(0, 1)
          for (d in door) {
            if (ev == 'DOOR' & d == 0) {
              next }
            if (d == 0) {
              figName = 'NoPorte'
            }
            else {
              figName = 'Porte'
            }
            # Delta_P_Tot3 = Delta_P_Tot2[Delta_P_Tot2$IsDoor == d, c('Patient',
            #                                                         'IsDoor',
            #                                                         'Medication',
            #                                                         'Freq',
            #                                                         'times',
            #                                                         'Chan_o',
            #                                                         'HEM_o')]
            
            Delta_P_Tot3 = subset(Delta_P_Tot2, Delta_P_Tot2$IsDoor == d)
            
            ## GRAPH
            lim  <-
              max(abs(Delta_P_Tot3$value)) # limites différentes pour chaque patient
            ggplot(Delta_P_Tot3, aes(
              x = times,
              y = Freq,
              fill = Re(value)
            )) +
              geom_tile() +
              scale_fill_gradientn(
                colours = myPalette(100),
                lim = c(-lim, lim),
                na.value = "#7F0000"
              ) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ HEM_o + Medication,
                         drop = TRUE,
                         scales = "free_x") + #~ Medication + Event
              ggtitle(
                paste(
                  gp,
                  nor,
                  Delta_P_Tot3$Medication[1],
                  Delta_P_Tot3$HEM[1],
                  ev,
                  figName,
                  "Marche_median" ,
                  sep = "_"
                )
              ) + #, temp_Marche5$Medication[1], temp_Marche5$HEM[1]
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(
              paste(
                OutputPath,
                '/',
                paste(
                  gp,
                  'TF',
                  nor,
                  medcondi,
                  h,
                  ev,
                  figName,
                  'Marche_median.png',
                  sep = '_'
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
          }
        }
      }
      
      remove(temp_Marche)
      remove(Delta_P_Tot)
      remove(Delta_P)
      remove(Delta_P_Tot1)
      remove(Delta_P_Tot2)
      remove(Delta_P_Tot3)
      remove(temp_Marche2)
      remove(temp_Marche3)
      remove(temp_Marche4)
      remove(temp_Marche5)
      
      
      ############################################################################################
      #############################################################################################
      ### PORTE + NoPORTE - TAPIS ----
      ############################################################################################
      #############################################################################################
      
      #############################################################################################
      ### indiv
      temp_Tapis <- subset(temp2, temp2$Condition == 'tapis')
      temp_Tapis = temp_Tapis[, c(
        "Patient",
        "Medication",
        "Condition",
        "IsDoor",
        "Freq",
        "value",
        "times",
        "Chan_o",
        "HEM_o"
      )]
      temp_Tapis = aggregate(
        value ~ Patient + Medication + Freq + times + Chan_o + HEM_o,
        temp_Tapis,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      iname = 1
      ivar = 1
      
      
      limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
      colnames(limlist) = c('ON_D_Tapis',
                            'ON_G_Tapis',
                            'OFF_D_Tapis',
                            'OFF_G_Tapis')
      # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
      # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
      rownames(limlist) = subjects
      
      ### PLOTS
      for (s in listnameSubj) {
        # s="ParkPitie_2016_10_13_AUa"
        temp_Tapis2 <-
          temp_Tapis[temp_Tapis$Patient == s, ]
        
        ## Selection de la MedCondition
        if (s == "PPNPitie_2018_04_26_DEm") {
          medCond = 'ON'
        } else{
          medCond = c('ON', 'OFF')
        }
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          temp_Tapis3 <-
            temp_Tapis2[temp_Tapis2$Medication == medcondi,]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            temp_Tapis4 <-
              temp_Tapis3[temp_Tapis3$HEM == h, ]
            
            
            if (exists('Delta_P')) {
              Delta_P <- rbind(Delta_P, temp_Tapis4)
            } else {
              Delta_P <- temp_Tapis4
            }
            
            ## Sélection des limites du graphe
            lim  <-
              max(abs(temp_Tapis4$value)) # limites différentes pour chaque patient
            limlist[iname, ivar] = lim
            
            ## GRAPH
            ggplot(temp_Tapis4,
                   aes(
                     x = times,
                     y = Freq,
                     fill = Re(value)
                   )) +
              geom_tile() +
              scale_fill_gradientn(
                colours = myPalette(100),
                lim = c(-lim, lim),
                na.value = "#7F0000"
              ) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ HEM_o + Medication,
                         drop = TRUE,
                         scales = "free_x") + #~ Medication + Event
              ggtitle(
                paste(
                  gp,
                  nor,
                  substr(subjects[iname], 0, 3),
                  temp_Tapis4$Medication[1],
                  temp_Tapis4$HEM[1],
                  ev,
                  'Tapis_median' ,
                  sep = "_"
                )
              ) + #, temp_Tapis4$Medication[1], temp_Tapis4$HEM[1]
              theme(plot.title = element_text(hjust = 0.5))
            
            # sauvegarde des graphes
            ggsave(
              paste(
                OutputPath,
                '/',
                paste(
                  gp,
                  'TF',
                  nor,
                  subjects[iname],
                  medcondi,
                  h,
                  ev,
                  'Tapis_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            ivar = ivar + 1
          }
        }
        ivar = 1
        iname = iname + 1
      }
      
      # Write table des lim
      setwd(InputDir)
      # write.table(limlist, "limites_Tapis_PPN_median.csv")
      write.table(
        limlist,
        paste(
          "limites_",
          gp,
          "_",
          nor,
          "Porte_Tapis_median.csv",
          sep = ""
        )
      )
      
      
      #############################################################################################
      ## indiv
      Delta_P_Tot <-
        aggregate(
          value ~ Medication + Freq + times + Chan_o + HEM_o ,
          Delta_P,
          FUN = "median",
          na.rm = T,
          na.action = NULL
        )
      
      
      for (medcondi in medCond) {
        # medcondi = 'OFF'
        Delta_P_Tot1 <-
          Delta_P_Tot[Delta_P_Tot$Medication == medcondi,]
        
        ## Sélection del'hémisphère
        hem = c('D', 'G')
        for (h in hem) {
          # h = 'G'
          Delta_P_Tot2 <- Delta_P_Tot1[Delta_P_Tot1$HEM == h, ]
          
          ## GRAPH
          lim  <-
            max(abs(Delta_P_Tot2$value)) # limites différentes pour chaque patient
          ggplot(Delta_P_Tot2, aes(
            x = times,
            y = Freq,
            fill = Re(value)
          )) +
            geom_tile() +
            scale_fill_gradientn(
              colours = myPalette(100),
              lim = c(-lim, lim),
              na.value = "#7F0000"
            ) +
            geom_vline(xintercept = 0, size = .1) +
            theme_classic() +
            facet_grid(Chan_o ~ HEM_o + Medication,
                       drop = TRUE,
                       scales = "free_x") + #~ Medication + Event
            ggtitle(
              paste(
                gp,
                nor,
                Delta_P_Tot2$Medication[1],
                Delta_P_Tot2$HEM[1],
                ev,
                "Tapis_median" ,
                sep = "_"
              )
            ) + #, temp_Tapis4$Medication[1], temp_Tapis4$HEM[1]
            theme(plot.title = element_text(hjust = 0.5))
          
          ## sauvegarde des graphes
          ggsave(
            paste(
              OutputPath,
              '/',
              paste(
                gp,
                'TF',
                nor,
                medcondi,
                h,
                ev,
                'Tapis_median.png',
                sep = "_"
              ),
              sep = ""
            ),
            width = 6,
            height = 8
          ) #'_', medcondi,'_',h,
          
        }
      }
      
      
      remove(temp_Tapis)
      remove(Delta_P_Tot)
      remove(Delta_P)
      remove(Delta_P_Tot1)
      remove(Delta_P_Tot2)
      remove(temp_Tapis2)
      remove(temp_Tapis3)
      remove(temp_Tapis4)
      
      ############################################################################################
      #############################################################################################
      ### PORTE / NoPORTE - TAPIS ----
      ############################################################################################
      #############################################################################################
      
      #############################################################################################
      ### indiv
      temp_Tapis <- subset(temp2, temp2$Condition == 'tapis')
      temp_Tapis = temp_Tapis[, c(
        "Patient",
        "Medication",
        "Condition",
        "IsDoor",
        "Freq",
        "value",
        "times",
        "Chan_o",
        "HEM_o"
      )]
      temp_Tapis = aggregate(
        value ~ Patient + Medication + IsDoor + Freq + times + Chan_o + HEM_o,
        temp_Tapis,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      iname = 1
      ivar = 1
      
      
      limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
      colnames(limlist) = c('ON_D_Tapis',
                            'ON_G_Tapis',
                            'OFF_D_Tapis',
                            'OFF_G_Tapis')
      # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
      # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
      rownames(limlist) = subjects
      
      ### PLOTS
      for (s in listnameSubj) {
        # s="ParkPitie_2016_10_13_AUa"
        temp_Tapis2 <-
          temp_Tapis[temp_Tapis$Patient == s, ]
        
        ## Selection de la MedCondition
        if (s == "PPNPitie_2018_04_26_DEm") {
          medCond = 'ON'
        } else{
          medCond = c('ON', 'OFF')
        }
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          temp_Tapis3 <-
            temp_Tapis2[temp_Tapis2$Medication == medcondi,]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            temp_Tapis4 <-
              temp_Tapis3[temp_Tapis3$HEM == h, ]
            
            ## Loop on Door
            door = c(0, 1)
            for (d in door) {
              if (ev == 'DOOR' & d == 0) {
                next }
              if (d == 0) {
                figName = 'NoPorte'
              }
              else {
                figName = 'Porte'
              }
              # temp_Tapis5 = temp_Tapis4[temp_Tapis4$IsDoor == d, c('Patient',
              #                                                         'IsDoor',
              #                                                         'Medication',
              #                                                         'Freq',
              #                                                         'times',
              #                                                         'Chan_o',
              #                                                         'HEM_o')]
              
              temp_Tapis5 = subset(temp_Tapis4, temp_Tapis4$IsDoor == d)
              
              if (exists('Delta_P')) {
                Delta_P <- rbind(Delta_P, temp_Tapis5)
              } else {
                Delta_P <- temp_Tapis5
              }
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp_Tapis5$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
              ## GRAPH
              ggplot(temp_Tapis5,
                     aes(
                       x = times,
                       y = Freq,
                       fill = Re(value)
                     )) +
                geom_tile() +
                scale_fill_gradientn(
                  colours = myPalette(100),
                  lim = c(-lim, lim),
                  na.value = "#7F0000"
                ) +
                geom_vline(xintercept = 0, size = .1) +
                theme_classic() +
                facet_grid(Chan_o ~ HEM_o + Medication,
                           drop = TRUE,
                           scales = "free_x") + #~ Medication + Event
                ggtitle(
                  paste(
                    gp,
                    nor,
                    substr(subjects[iname], 0, 3),
                    temp_Tapis5$Medication[1],
                    temp_Tapis5$HEM[1],
                    ev,
                    figName,
                    'Tapis_median' ,
                    sep = "_"
                  )
                ) + #, temp_Tapis5$Medication[1], temp_Tapis5$HEM[1]
                theme(plot.title = element_text(hjust = 0.5))
              
              # sauvegarde des graphes
              ggsave(
                paste(
                  OutputPath,
                  '/',
                  paste(
                    gp,
                    'TF',
                    nor,
                    subjects[iname],
                    medcondi,
                    h,
                    ev,
                    figName,
                    'Tapis_median.png',
                    sep = "_"
                  ),
                  sep = ""
                ),
                width = 6,
                height = 8
              ) #'_', medcondi,'_',h,
            }
            ivar = ivar + 1
          }
        }
        ivar = 1
        iname = iname + 1
      }
      
      
      
      #############################################################################################
      ## indiv
      Delta_P_Tot <-
        aggregate(
          value ~ Medication +  IsDoor + Freq + times + Chan_o + HEM_o ,
          Delta_P,
          FUN = "median",
          na.rm = T,
          na.action = NULL
        )
      
      
      for (medcondi in medCond) {
        # medcondi = 'OFF'
        Delta_P_Tot1 <-
          Delta_P_Tot[Delta_P_Tot$Medication == medcondi,]
        
        ## Sélection del'hémisphère
        hem = c('D', 'G')
        for (h in hem) {
          # h = 'G'
          Delta_P_Tot2 <- Delta_P_Tot1[Delta_P_Tot1$HEM == h, ]
          
          # loop on Door
          door = c(0, 1)
          for (d in door) {
            if (ev == 'DOOR' & d == 0) {
              next }
            if (d == 0) {
              figName = 'NoPorte'
            }
            else {
              figName = 'Porte'
            }
            # Delta_P_Tot3 = Delta_P_Tot2[Delta_P_Tot2$IsDoor == d, c('Patient',
            #                                                         'IsDoor',
            #                                                         'Medication',
            #                                                         'Freq',
            #                                                         'times',
            #                                                         'Chan_o',
            #                                                         'HEM_o')]
            
            Delta_P_Tot3 = subset(Delta_P_Tot2, Delta_P_Tot2$IsDoor == d)
                                        
            ## GRAPH
            lim  <-
              max(abs(Delta_P_Tot3$value)) # limites différentes pour chaque patient
            ggplot(Delta_P_Tot3, aes(
              x = times,
              y = Freq,
              fill = Re(value)
            )) +
              geom_tile() +
              scale_fill_gradientn(
                colours = myPalette(100),
                lim = c(-lim, lim),
                na.value = "#7F0000"
              ) +
              geom_vline(xintercept = 0, size = .1) +
              theme_classic() +
              facet_grid(Chan_o ~ HEM_o + Medication,
                         drop = TRUE,
                         scales = "free_x") + #~ Medication + Event
              ggtitle(
                paste(
                  gp,
                  nor,
                  Delta_P_Tot3$Medication[1],
                  Delta_P_Tot3$HEM[1],
                  ev,
                  figName,
                  "Tapis_median" ,
                  sep = "_"
                )
              ) + #, temp_Tapis5$Medication[1], temp_Tapis5$HEM[1]
              theme(plot.title = element_text(hjust = 0.5))
            
            ## sauvegarde des graphes
            ggsave(
              paste(
                OutputPath,
                '/',
                paste(
                  gp,
                  'TF',
                  nor,
                  medcondi,
                  h,
                  ev,
                  figName,
                  'Tapis_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
          }
        }
      }
      
      remove(temp_Tapis)
      remove(Delta_P_Tot)
      remove(Delta_P)
      remove(Delta_P_Tot1)
      remove(Delta_P_Tot2)
      remove(temp_Tapis2)
      remove(temp_Tapis3)
      remove(temp_Tapis4)
      remove(temp_Tapis5)
      ########################################################
    }
  }
}