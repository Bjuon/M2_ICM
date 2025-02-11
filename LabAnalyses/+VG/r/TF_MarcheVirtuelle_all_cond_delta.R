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
normtype = c('RAW')
# PRECISE GROUPS
# groups   = c('STN', 'PPN')
groups   = c('PPN')
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
      ### TAPIS Vs Marche - Pas Porte ----
      ############################################################################################
      #############################################################################################
      if (ev != 'DOOR') {
        #############################################################################################
        ##INDIV
        temp_DeltaMarche <- subset(temp2, temp2$IsDoor == 0)
        temp_DeltaMarche = temp_DeltaMarche[, c(
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
        temp_DeltaMarche = aggregate(
          value ~ Patient + Medication + Condition + Freq + times + Chan_o + HEM_o,
          temp_DeltaMarche,
          FUN = 'median',
          na.rm = T,
          na.action = NULL
        )
        
        iname = 1
        ivar = 1
        
        
        limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
        colnames(limlist) = c(
          'ON_D_DeltaMarche',
          'ON_G_DeltaMarche',
          'OFF_D_DeltaMarche',
          'OFF_G_DeltaMarche'
        )
        
        # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
        # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
        rownames(limlist) = subjects
        
        ### PLOTS
        for (s in listnameSubj) {
          # s="ParkPitie_2016_10_13_AUa"
          temp_DeltaMarche2 <-
            temp_DeltaMarche[temp_DeltaMarche$Patient == s, ]
          
          ## Selection de la MedCondition
          if (s == "PPNPitie_2018_04_26_DEm") {
            medCond = 'ON'
          } else{
            medCond = c('ON', 'OFF')
          }
          for (medcondi in medCond) {
            # medcondi = 'OFF'
            temp_DeltaMarche3 <-
              temp_DeltaMarche2[temp_DeltaMarche2$Medication == medcondi,]
            
            ## Sélection del'hémisphère
            hem = c('D', 'G')
            for (h in hem) {
              # h = 'G'
              temp_DeltaMarche4 <-
                temp_DeltaMarche3[temp_DeltaMarche3$HEM == h, ]
              
              ## Delta
              temp_DeltaMarche5 = temp_DeltaMarche4[temp_DeltaMarche4$Condition == 'tapis', c('Patient',
                                                                                              'Medication',
                                                                                              'Freq',
                                                                                              'times',
                                                                                              'Chan_o',
                                                                                              'HEM_o')]
              temp_DeltaMarche5$value = temp_DeltaMarche4[temp_DeltaMarche4$Condition == 'marche', c('value')] - temp_DeltaMarche4[temp_DeltaMarche4$Condition == 'tapis', c('value')]
              
              if (exists('Delta_M')) {
                Delta_M <- rbind(Delta_M, temp_DeltaMarche5)
              } else {
                Delta_M <- temp_DeltaMarche5
              }
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp_DeltaMarche5$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
              ## GRAPH
              ggplot(temp_DeltaMarche5,
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
                    temp_DeltaMarche5$Medication[1],
                    temp_DeltaMarche5$HEM[1],
                    ev,
                    'DeltaMarche_NoPorte_median' ,
                    sep = "_"
                  )
                ) + #, temp_DeltaMarche5$Medication[1], temp_DeltaMarche5$HEM[1]
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
                    'DeltaMarche_NoPorte_median.png',
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
        write.table(
          limlist,
          paste(
            "limites_",
            gp,
            "_",
            nor,
            "_DeltaMarche_NoPorte_median.csv",
            sep = ""
          )
        )
        
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
                  "DeltaMarche_NoPorte_median" ,
                  sep = "_"
                )
              ) + #, temp_DeltaMarche5$Medication[1], temp_DeltaMarche5$HEM[1]
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
                  'DeltaMarche_NoPorte_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            
          }
        }
        
        remove(temp_DeltaMarche)
        remove(Delta_M_Tot)
        remove(Delta_M)
        remove(Delta_M_Tot1)
        remove(Delta_M_Tot2)
        remove(temp_DeltaMarche2)
        remove(temp_DeltaMarche3)
        remove(temp_DeltaMarche4)
        remove(temp_DeltaMarche5)
      }
      ############################################################################################
      #############################################################################################
      ### TAPIS Vs Marche - Porte ----
      ############################################################################################
      #############################################################################################
      
      #############################################################################################
      ##INDIV
      temp_DeltaMarche <- subset(temp2, temp2$IsDoor == 1)
      temp_DeltaMarche = temp_DeltaMarche[, c(
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
      temp_DeltaMarche = aggregate(
        value ~ Patient + Medication + Condition + Freq + times + Chan_o + HEM_o,
        temp_DeltaMarche,
        FUN = 'median',
        na.rm = T,
        na.action = NULL
      )
      
      iname = 1
      ivar = 1
      
      
      limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
      colnames(limlist) = c(
        'ON_D_DeltaMarche',
        'ON_G_DeltaMarche',
        'OFF_D_DeltaMarche',
        'OFF_G_DeltaMarche'
      )
      # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367','SOd_0363')
      # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
      rownames(limlist) = subjects
      
      ### PLOTS
      for (s in listnameSubj) {
        # s="ParkPitie_2016_10_13_AUa"
        temp_DeltaMarche2 <-
          temp_DeltaMarche[temp_DeltaMarche$Patient == s,]
        
        ## Selection de la MedCondition
        if (s == "PPNPitie_2018_04_26_DEm") {
          medCond = 'ON'
        } else{
          medCond = c('ON', 'OFF')
        }
        for (medcondi in medCond) {
          # medcondi = 'OFF'
          temp_DeltaMarche3 <-
            temp_DeltaMarche2[temp_DeltaMarche2$Medication == medcondi, ]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            temp_DeltaMarche4 <-
              temp_DeltaMarche3[temp_DeltaMarche3$HEM == h,]
            
            ## Delta
            temp_DeltaMarche5 = temp_DeltaMarche4[temp_DeltaMarche4$Condition == 'tapis', c('Patient',
                                                                                            'Medication',
                                                                                            'Freq',
                                                                                            'times',
                                                                                            'Chan_o',
                                                                                            'HEM_o')]
            temp_DeltaMarche5$value = temp_DeltaMarche4[temp_DeltaMarche4$Condition == 'marche', c('value')] - temp_DeltaMarche4[temp_DeltaMarche4$Condition == 'tapis', c('value')]
            
            if (exists('Delta_M')) {
              Delta_M <- rbind(Delta_M, temp_DeltaMarche5)
            } else {
              Delta_M <- temp_DeltaMarche5
            }
            
            ## Sélection des limites du graphe
            lim  <-
              max(abs(temp_DeltaMarche5$value)) # limites différentes pour chaque patient
            limlist[iname, ivar] = lim
            
            ## GRAPH
            ggplot(temp_DeltaMarche5, aes(
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
                  temp_DeltaMarche5$Medication[1],
                  temp_DeltaMarche5$HEM[1],
                  ev,
                  'DeltaMarche_Porte_median' ,
                  sep = "_"
                )
              ) + #, temp_DeltaMarche5$Medication[1], temp_DeltaMarche5$HEM[1]
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
                  'DeltaMarche_Porte_median.png',
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
      # write.table(limlist, "limites_DeltaMarche_Porte_PPN_median.csv")
      write.table(
        limlist,
        paste(
          "limites_",
          gp,
          "_",
          nor,
          "_DeltaMarche_Porte_median.csv",
          sep = ""
        )
      )
      
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
                "DeltaMarche_Porte_median" ,
                sep = "_"
              )
            ) + #, temp_DeltaMarche5$Medication[1], temp_DeltaMarche5$HEM[1]
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
                'DeltaMarche_Porte_median.png',
                sep = "_"
              ),
              sep = ""
            ),
            width = 6,
            height = 8
          ) #'_', medcondi,'_',h,
          
        }
      }
      
      
      remove(temp_DeltaMarche)
      remove(Delta_M_Tot)
      remove(Delta_M)
      remove(Delta_M_Tot1)
      remove(Delta_M_Tot2)
      remove(temp_DeltaMarche2)
      remove(temp_DeltaMarche3)
      remove(temp_DeltaMarche4)
      remove(temp_DeltaMarche5)
      
      ############################################################################################
      #############################################################################################
      ### PORTE Vs NoPORTE - MARCHE ----
      ############################################################################################
      #############################################################################################
      if (ev != 'DOOR') {
        #############################################################################################
        ### indiv
        temp_DeltaPorte <- subset(temp2, temp2$Condition == 'marche')
        temp_DeltaPorte = temp_DeltaPorte[, c(
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
        temp_DeltaPorte = aggregate(
          value ~ Patient + Medication + IsDoor + Freq + times + Chan_o + HEM_o,
          temp_DeltaPorte,
          FUN = 'median',
          na.rm = T,
          na.action = NULL
        )
        
        iname = 1
        ivar = 1
        
        
        limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
        colnames(limlist) = c(
          'ON_D_DeltaPorte',
          'ON_G_DeltaPorte',
          'OFF_D_DeltaPorte',
          'OFF_G_DeltaPorte'
        )
        # rownames(limlist) = c('AVl_0444','CHd_0343','DEm_0423','HAg_0372','LEn_0367','SOd_0363')
        # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
        rownames(limlist) = subjects
        
        ### PLOTS
        for (s in listnameSubj) {
          # s="ParkPitie_2016_10_13_AUa"
          temp_DeltaPorte2 <-
            temp_DeltaPorte[temp_DeltaPorte$Patient == s,]
          
          ## Selection de la MedCondition
          if (s == "PPNPitie_2018_04_26_DEm") {
            medCond = 'ON'
          } else{
            medCond = c('ON', 'OFF')
          }
          for (medcondi in medCond) {
            # medcondi = 'OFF'
            temp_DeltaPorte3 <-
              temp_DeltaPorte2[temp_DeltaPorte2$Medication == medcondi, ]
            
            ## Sélection del'hémisphère
            hem = c('D', 'G')
            for (h in hem) {
              # h = 'G'
              temp_DeltaPorte4 <-
                temp_DeltaPorte3[temp_DeltaPorte3$HEM == h,]
              
              ## Delta
              temp_DeltaPorte5 = temp_DeltaPorte4[temp_DeltaPorte4$IsDoor == 0, c('Patient',
                                                                                  'Medication',
                                                                                  'Freq',
                                                                                  'times',
                                                                                  'Chan_o',
                                                                                  'HEM_o')]
              temp_DeltaPorte5$value = temp_DeltaPorte4[temp_DeltaPorte4$IsDoor == 1, c('value')] - temp_DeltaPorte4[temp_DeltaPorte4$IsDoor == 0, c('value')]
              
              if (exists('Delta_P')) {
                Delta_P <- rbind(Delta_P, temp_DeltaPorte5)
              } else {
                Delta_P <- temp_DeltaPorte5
              }
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp_DeltaPorte5$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
              ## GRAPH
              ggplot(temp_DeltaPorte5,
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
                    temp_DeltaPorte5$Medication[1],
                    temp_DeltaPorte5$HEM[1],
                    ev,
                    'DeltaPorte_Marche_median' ,
                    sep = "_"
                  )
                ) + #, temp_DeltaPorte5$Medication[1], temp_DeltaPorte5$HEM[1]
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
                    'DeltaPorte_Marche_median.png',
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
        # write.table(limlist, "limites_DeltaPorte_Marche_PPN_median.csv")
        write.table(
          limlist,
          paste(
            "limites_",
            gp,
            "_",
            nor,
            "_DeltaMarche_Porte_Marche_median.csv",
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
            Delta_P_Tot[Delta_P_Tot$Medication == medcondi, ]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            Delta_P_Tot2 <- Delta_P_Tot1[Delta_P_Tot1$HEM == h,]
            
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
                  "DeltaPorte_Marche_median" ,
                  sep = "_"
                )
              ) + #, temp_DeltaPorte5$Medication[1], temp_DeltaPorte5$HEM[1]
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
                  'DeltaPorte_Marche_median.png',
                  sep = '_'
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            
          }
        }
        
        remove(temp_DeltaPorte)
        remove(Delta_P_Tot)
        remove(Delta_P)
        remove(Delta_P_Tot1)
        remove(Delta_P_Tot2)
        remove(temp_DeltaPorte2)
        remove(temp_DeltaPorte3)
        remove(temp_DeltaPorte4)
        remove(temp_DeltaPorte5)
        
        ############################################################################################
        #############################################################################################
        ### PORTE Vs NoPORTE - TAPIS ----
        ############################################################################################
        #############################################################################################
        
        #############################################################################################
        ### indiv
        temp_DeltaPorte <- subset(temp2, temp2$Condition == 'tapis')
        temp_DeltaPorte = temp_DeltaPorte[, c(
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
        temp_DeltaPorte = aggregate(
          value ~ Patient + Medication + IsDoor + Freq + times + Chan_o + HEM_o,
          temp_DeltaPorte,
          FUN = 'median',
          na.rm = T,
          na.action = NULL
        )
        
        
        limlist = matrix(NaN, nrow = length(subjects), ncol = 4) #6 #10
        colnames(limlist) = c(
          'ON_D_DeltaPorte',
          'ON_G_DeltaPorte',
          'OFF_D_DeltaPorte',
          'OFF_G_DeltaPorte'
        )
        # rownames(limlist) = c('AVl_0444', 'CHd_0343', 'DEm_0423', 'HAg_0372', 'LEn_0367', 'SOd_0363')
        # rownames(limlist) =  c('AUa_0342', 'BEe_0412', 'BEv_0474', 'GUa_0357', 'GUd_0327', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'VEm_0402')
        rownames(limlist) = subjects
        
        iname = 1
        ivar = 1

        ### PLOTS
        for (s in listnameSubj) {
          # s="ParkPitie_2016_10_13_AUa"
          temp_DeltaPorte2 <-
            temp_DeltaPorte[temp_DeltaPorte$Patient == s,]
          
          ## Selection de la MedCondition
          if (s == "PPNPitie_2018_04_26_DEm") {
            medCond = 'ON'
          } else{
            medCond = c('ON', 'OFF')
          }
          for (medcondi in medCond) {
            # medcondi = 'OFF'
            temp_DeltaPorte3 <-
              temp_DeltaPorte2[temp_DeltaPorte2$Medication == medcondi, ]
            
            ## Sélection del'hémisphère
            hem = c('D', 'G')
            for (h in hem) {
              # h = 'G'
              temp_DeltaPorte4 <-
                temp_DeltaPorte3[temp_DeltaPorte3$HEM == h,]
              
              ## Delta
              temp_DeltaPorte5 = temp_DeltaPorte4[temp_DeltaPorte4$IsDoor == 0, c('Patient',
                                                                                  'Medication',
                                                                                  'Freq',
                                                                                  'times',
                                                                                  'Chan_o',
                                                                                  'HEM_o')]
              temp_DeltaPorte5$value = temp_DeltaPorte4[temp_DeltaPorte4$IsDoor == 1, c('value')] - temp_DeltaPorte4[temp_DeltaPorte4$IsDoor == 0, c('value')]
              
              if (exists('Delta_P')) {
                Delta_P <- rbind(Delta_P, temp_DeltaPorte5)
              } else {
                Delta_P <- temp_DeltaPorte5
              }
              
              ## Sélection des limites du graphe
              lim  <-
                max(abs(temp_DeltaPorte5$value)) # limites différentes pour chaque patient
              limlist[iname, ivar] = lim
              
              ## GRAPH
              ggplot(temp_DeltaPorte5,
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
                    temp_DeltaPorte5$Medication[1],
                    temp_DeltaPorte5$HEM[1],
                    ev,
                    'DeltaPorte_Tapis_median' ,
                    sep = "_"
                  )
                ) + #, temp_DeltaPorte5$Medication[1], temp_DeltaPorte5$HEM[1]
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
                    'DeltaPorte_Tapis_median.png',
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
        # write.table(limlist, "limites_DeltaPorte_Tapis_PPN_median.csv")
        write.table(
          limlist,
          paste(
            "limites_",
            gp,
            "_",
            nor,
            "DeltaMarche_Porte_Tapis_median.csv",
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
            Delta_P_Tot[Delta_P_Tot$Medication == medcondi, ]
          
          ## Sélection del'hémisphère
          hem = c('D', 'G')
          for (h in hem) {
            # h = 'G'
            Delta_P_Tot2 <- Delta_P_Tot1[Delta_P_Tot1$HEM == h,]
            
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
                  "DeltaPorte_Tapis_median" ,
                  sep = "_"
                )
              ) + #, temp_DeltaPorte5$Medication[1], temp_DeltaPorte5$HEM[1]
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
                  'DeltaPorte_Tapis_median.png',
                  sep = "_"
                ),
                sep = ""
              ),
              width = 6,
              height = 8
            ) #'_', medcondi,'_',h,
            
          }
        }
        
        remove(temp_DeltaPorte)
        remove(Delta_P_Tot)
        remove(Delta_P)
        remove(Delta_P_Tot1)
        remove(Delta_P_Tot2)
        remove(temp_DeltaPorte2)
        remove(temp_DeltaPorte3)
        remove(temp_DeltaPorte4)
        remove(temp_DeltaPorte5)
      }
    }
  }
}