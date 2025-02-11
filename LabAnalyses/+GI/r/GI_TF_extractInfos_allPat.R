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
DataDir   = 'F:/IR-IHU-ICM/Donnees/Analyses/DBS/DBStmp_Matthieu/data/analyses'
OutputDir = "F:/IR-IHU-ICM/Donnees/Analyses/DBS/DBStmp_Matthieu/TF"

# PRECISE nomarlization types
# normtype = c('RAW', 'zNOR', 'sNOR', 'dNOR', 'ldNOR')

segType  = 'step' #'trial'   'step' 
normtype = c('dNOR')
datatype = 'TF' #meanTF' #'PE' # TF
tBlock   = '05'
fqStart  = '1'
# PRECISE GROUPS
groups   = c('PPN')
# groups   = c('PPN')
#SELECT EVENTS
events  = c('T0', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E')
#events  = c('BSL')
funType = 'mean' #  c('median', 'mean')


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
    
    #############################################################################################
    ###### Chargement du fichier
    
    ##LOAD DATA
    listname = matrix(NaN, nrow = 1, ncol = 15)
    iname = 1
    
    s_count = 0
    
    for (s in subjects) {
      # s=subjects
      s_count = s_count + 1
      
      # Chemin
      RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
      setwd(paste(RecDir, '/POSTOP', sep = ""))
      
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
        if (datatype == 'TF') {
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', segType, '_TF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
          }
        else if (datatype == 'PE') {
          temp <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_PE_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
        }
        else if (datatype == 'meanTF') {
          temp     <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_', segType, '_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))
          temp$TOI = 'EVT' # Time Of Interest
          if (segType == '') {
            temp_bsl <- read.delim(paste(outputname, '_', protocol, '_POSTOP_GI_SPON_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_BSL.csv', sep = ""))
            temp_bsl$TOI   = 'BSL' # Time Of Interest
            temp_bsl$Event = ev # Time Of Interest
            temp_bsl$Condition = temp$Condition[1]
            temp <- rbind(temp, temp_bsl)
            remove(temp_bsl)
          }
          else if (segType == 'trial' & nor == 'RAW') {
            temp_bsl <- read.delim(paste(outputname, '_', protocol, '_POSTOP_BLEO_STAND_', segType, '_meanTF_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_BSL.csv', sep = ""))
            temp_bsl$TOI   = 'BSL' # Time Of Interest
            temp_bsl$Event = ev # Time Of Interest
            #temp_bsl$Condition = temp_bsl$Condition[1]
            temp_bsl$nStep[is.na(temp_bsl$nStep)] = ''
            temp_bsl$side[is.na(temp_bsl$side)] = ''
            temp <- rbind(temp, temp_bsl)
            remove(temp_bsl)
          }
        }
          
        
        temp$grouping[is.na(temp$grouping)] = ''
        temp$nStep[is.na(temp$nStep)] = ''
        temp$side[is.na(temp$side)] = ''
        
      
        # aggregate duplicates
        if (segType == 'trial') {
        temp <- aggregate(x0 ~ Patient + Medication + Condition + Channel + grouping + Run + nTrial + Event + isValid + quality,
          temp, FUN = mean, na.rm = F, na.action = NULL)
        temp <- aggregate(x0 ~ Patient + Medication + Condition + Channel + grouping + Event + isValid + quality,
                           temp, FUN = length)
        }
        else if (segType == 'step') {
          temp <- aggregate(x_0_75 ~ Patient + Medication + Condition + Channel + grouping + Run + nTrial + Event + isValid + quality,
                            temp, FUN = mean, na.rm = F, na.action = NULL)
          temp <- aggregate(x_0_75 ~ Patient + Medication + Condition + Channel + grouping + Event + isValid + quality,
                            temp, FUN = length)
        }
        
        # On compile les données de tous les patients
        if (exists('DAT_LFP')) {
          DAT_LFP <- rbind(DAT_LFP, temp)
        } else {
          DAT_LFP <- temp
        }
        
        rm('temp')
        gc(verbose = FALSE)
        
      }
      iname = iname + 1
    }
    
    
    #############################################################################################
    ###### Mise en forme du fichier
 
 
    setwd(OutputDir)
    
    if (datatype == 'TF') {
      write.table(DAT_LFP, paste('GI_infos_TF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'PE') {
      write.table(DAT_LFP, paste('GI_infos_PE', '_', gp, '_', funType, '.csv', sep = ""))
    }
    else if (datatype == 'meanTF') {
      write.table(DAT_LFP, paste('GI_infos_meanTF', '_', segType, '_', gp, '_', nor, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', funType, '.csv', sep = ""))
    }

  }
}



