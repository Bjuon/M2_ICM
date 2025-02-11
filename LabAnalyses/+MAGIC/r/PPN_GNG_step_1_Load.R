#############################################################################################
##                                                                                         ##
##                         Step 1 : Loading from Matlab CSV to R pq                        ##
##                                                                                         ##
#############################################################################################
                                                                                                        rm(list = ls()) ; gc()
#############################################################################################
print("This code is modified from MY's MAGIC_GNG_step_1 as of August 2024")

# Event(s) to treat independently :
events  = c("T0") # "CUE", "FIX", "FO1", "FC1", "T0", "T0_EMG", "FO", "FC", "FOG_S", "FOG_E", "TURN_S", "TURN_E"

# Contacts that will be fusionned into the exit parquet dataset
Contacts_of_interest = c("AllPerChan") 
GroupingMode         = "PPN"

# Paths
DataDir      = '//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
OutputDir    = paste0("Z:/PPN/", Contacts_of_interest)
MY_PatPCA    = "//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/00_notes/ResAPA_PPN.xlsx"
LocTablePath = "//iss/pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/00_notes/PPN_loc_electrodes.xlsx"
pq_folder    = "pq_wide"

SauvegardeDirecte = TRUE

# Parameters
gp       = 'PPN'             # 'MAGIC_Only' 'STN'
segType  = 'step'            #'trial'   'step' 
normtype = 'ldNOR'           # RAW or ldNOR
datatype = 'TF'              #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'

additional_nor_to_do = 'none'  # 'none', "fooof_perpat" ou "multip_par_freq"

####

Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()

print(Sys.time())

## Step 1.1 : Generate the CSV with the data to keep #########################################################
nor = normtype 
Contact = Contacts_of_interest[1]
for (Contact in Contacts_of_interest) { 
  # SET SUBJECTS
  
  #ToAdaptForPPN
  if (gp == 'PPN') {
    subjects = c(
        'PPNPitie_2018_07_05_AVl',
        'PPNPitie_2017_06_08_LEn',   
        'PPNPitie_2017_03_09_SOd',
        'PPNPitie_2016_11_17_CHd'
      )
    
    listnameSubj = c(
      'PPNPitie_2018_07_05_AVl',
      'PPNPitie_2017_06_08_LEn',   
      'PPNPitie_2017_03_09_SOd',
      'PPNPitie_2016_11_17_CHd'
      )
  }
  
  ev = events[1]
  
  for (ev in events) {
    
    print(paste0('########## ', ev, ' ######', nor, ' ######', Contact, ' ##########' ))
    if (ev ==  "FOG_S" ||  ev ==  "FOG_E") {
        # No need for PPN as the 4 patients are freezers
    }
    
      print(Sys.time())
      print(cat ('Nombre de sujets inclus : ', length(subjects), ' / Verifier que cela correspond au nombre attendu '))
      
      if (!dir.exists(paste0(OutputDir))) {
           dir.create(paste0(OutputDir))
      } 
      if (!dir.exists(paste0(OutputDir, '/model_fits/'))) {
           dir.create(paste0(OutputDir, '/model_fits/'))
      } 
      if (!dir.exists(paste0(OutputDir, '/',pq_folder,'/'))) {
           dir.create(paste0(OutputDir, '/',pq_folder,'/'))
      } 
      if (!dir.exists(paste0(OutputDir, '/',pq_folder,'/', ev, '_', nor, '/'))) {
           dir.create(paste0(OutputDir, '/',pq_folder,'/', ev, '_', nor, '/'))
      }  
      if (!dir.exists(paste0(OutputDir, '/',pq_folder,'/csv/'))) {
           dir.create(paste0(OutputDir, '/',pq_folder,'/csv/'))
      }  
      if (!dir.exists(paste0(OutputDir, '/',pq_folder,'/csv/', ev, '/'))) {
           dir.create(paste0(OutputDir, '/',pq_folder,'/csv/', ev, '/'))
      } 
      
      
      if (GroupingMode == "other"  ) {
        if ("All" != Contact) { #ToAdaptForPPN
          LocTable = readxl::read_excel(LocTablePath, sheet = 'LocSara')
        }
      }
      
      # Initialisationde la liste par Sujet
      TFbySubject = tibble()
      s_count = 0
      
      
        for (s in subjects) {
          # precise groupe of protocol : GI or GNG
          #ToAdaptForPPN
          task_name = 'GI' 
          suff_name = ''
          WorkDir = paste(DataDir , s, sep = "/")
          protocol = 'GAITPARK' 
          
          ### CHARGEMENT #########################################################################################
          
          s_count = s_count + 1
          print(paste0('########## Patient ', s_count, ' of ', length(subjects), ' /// ', s, ' ', ev, ' ##########' ))
          
          outputname = listnameSubj[s_count]
          
          if (ev == "WrCUE" ||  ev == "WrFIX") {
            WIP_PPN
            alert = 1
            if (file.exists(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_', 'dNOR', suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))) alert = 0
            if (file.exists(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_',   nor , suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""))) alert = 0
            if (alert == 1) next
          }
          if ((nor == 'ldNOR') && segType  == 'step') {
            TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_', 'dNOR', suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
          } else {
            TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_',   nor , suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
          }
          
            TF1Pat$Task = TF1Pat$Condition
            TF1Pat$Condition = TF1Pat$Segment
            TF1Pat$Segment = NULL
          
          
          ### SELECTION #########################################################################################
          
          if (GroupingMode == "PPN"  ) {
            if ("All" == Contact | Contact == "AllPerChan") {  #Keep All electrodes
              ;
            } else if (grepl("Regions1PPN", Contact)) {
              TF1Pat$Region   = ifelse(grepl("PPN", TF1Pat$Region), "PPN", TF1Pat$Region)
              TF1Pat$grouping = TF1Pat$Region
              TF1Pat %<>% drop_na(Region)
            } else if (grepl("Regions", Contact)) {
              TF1Pat$grouping = TF1Pat$Region
              TF1Pat %<>% drop_na(Region)
            } else if (grepl("Grouping", Contact)) {
              TF1Pat$Region = TF1Pat$grouping
              TF1Pat %<>% drop_na(grouping)
            } else if (grepl("MY_choice", Contact)) {
              
              # Select which contacts to keep
              pat_row = which(LocTable$Pat == s)    
              if (is.na(LocTable$D0[pat_row])) {
                print(paste0('Patient ', s, ' not found in LocTable'))
                TF1Pat = tibble()
                next
              }
              
              rm(StrToSearch)
              if (grepl("inSTN", Contact)) {
                StrToSearch = "STN"
              } else if (grepl("STN-AS", Contact)) {
                StrToSearch = "AS"
              } else if (grepl("STN-SM", Contact)) {
                StrToSearch = "SM"
              } else if (grepl("STNversus-exclusif", Contact)) { #exclusif needed below
                StrToSearch = "STN"
              } else if (grepl("ZonaIncerta", Contact)) { #exclusif needed below
                StrToSearch = "ZI"
              }
              
              if (grepl("exclusif", Contact)) {
                e01D = (grepl(StrToSearch, LocTable$D0[pat_row]) & grepl(StrToSearch, LocTable$D1[pat_row]))
                e01G = (grepl(StrToSearch, LocTable$G0[pat_row]) & grepl(StrToSearch, LocTable$G1[pat_row]))
                e12D = (grepl(StrToSearch, LocTable$D1[pat_row]) & grepl(StrToSearch, LocTable$D2[pat_row]))
                e12G = (grepl(StrToSearch, LocTable$G1[pat_row]) & grepl(StrToSearch, LocTable$G2[pat_row]))
                e23D = (grepl(StrToSearch, LocTable$D2[pat_row]) & grepl(StrToSearch, LocTable$D3[pat_row]))
                e23G = (grepl(StrToSearch, LocTable$G2[pat_row]) & grepl(StrToSearch, LocTable$G3[pat_row]))
              } else if (grepl("elargi", Contact)) {
                e01D = (grepl(StrToSearch, LocTable$D0[pat_row]) | grepl(StrToSearch, LocTable$D1[pat_row]))
                e01G = (grepl(StrToSearch, LocTable$G0[pat_row]) | grepl(StrToSearch, LocTable$G1[pat_row]))
                e12D = (grepl(StrToSearch, LocTable$D1[pat_row]) | grepl(StrToSearch, LocTable$D2[pat_row]))
                e12G = (grepl(StrToSearch, LocTable$G1[pat_row]) | grepl(StrToSearch, LocTable$G2[pat_row]))
                e23D = (grepl(StrToSearch, LocTable$D2[pat_row]) | grepl(StrToSearch, LocTable$D3[pat_row]))
                e23G = (grepl(StrToSearch, LocTable$G2[pat_row]) | grepl(StrToSearch, LocTable$G3[pat_row]))
              } 
              
              # Keep only the selected contacts
              
              #ToAdaptForPPN
              if (task_name == 'GI') {
                if (grepl("ANTI", Contact)) {
                  e01D = !e01D ; e01G = !e01G ; e12D = !e12D ; e12G = !e12G ; e23D = !e23D ; e23G = !e23G
                }
                if (!e01D) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "01D")}
                if (!e01G) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "01G")}
                if (!e12D) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "12D")}
                if (!e12G) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "12G")}
                if (!e23D) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "23D")}
                if (!e23G) {TF1Pat = subset(TF1Pat, TF1Pat$Channel != "23G")}
                
              } else if (task_name == 'GNG_GAIT') {
                listChan = unique(TF1Pat$Channel)
                listChan = listChan[nchar(listChan) == 3]
                
                realChan = listChan
                listChan = gsub("1", "0", listChan)
                listChan = gsub("[2-4]", "1", listChan)
                listChan = gsub("[5-7]", "2", listChan)
                listChan = gsub("8", "3", listChan)
                
                listToExclude = realChan[!(listChan %in% c("01D", "11D", "12D", "22D", "23D", "01G", "11G", "12G", "22G", "23G"))]
                realChan = realChan[grep("^(01|12|23|11|22)", listChan)]
                listChan = listChan[grep("^(01|12|23|11|22)", listChan)]
                
                if (!e01D) {realChan = realChan[listChan != "01D"] ; listChan = listChan[listChan != "01D"]}
                if (!e01G) {realChan = realChan[listChan != "01G"] ; listChan = listChan[listChan != "01G"]}
                if (!e12D) {realChan = realChan[listChan != "12D"] ; listChan = listChan[listChan != "12D"]}
                if (!e12G) {realChan = realChan[listChan != "12G"] ; listChan = listChan[listChan != "12G"]}
                if (!e23D) {realChan = realChan[listChan != "23D"] ; listChan = listChan[listChan != "23D"]}
                if (!e23G) {realChan = realChan[listChan != "23G"] ; listChan = listChan[listChan != "23G"]}
                
                # Ajout de la possibilité d'avoir un montage 42, 23, 56, ...
                if (!grepl(StrToSearch, LocTable$D1[pat_row])) {
                  realChan = realChan[listChan != "11D"] ; listChan = listChan[listChan != "11D"]
                }
                if (!grepl(StrToSearch, LocTable$G1[pat_row])) {
                  realChan = realChan[listChan != "11G"] ; listChan = listChan[listChan != "11G"]
                }
                if (!grepl(StrToSearch, LocTable$D2[pat_row])) {
                  realChan = realChan[listChan != "22D"] ; listChan = listChan[listChan != "22D"]
                }
                if (!grepl(StrToSearch, LocTable$G2[pat_row])) {
                  realChan = realChan[listChan != "22G"] ; listChan = listChan[listChan != "22G"]
                }
                
                if (grepl("ANTI", Contact)) {
                  TF1Pat = subset(TF1Pat,!(TF1Pat$Channel %in% realChan))
                  TF1Pat = subset(TF1Pat,!(TF1Pat$Channel %in% listToExclude))
                } else {
                  TF1Pat = subset(TF1Pat,  TF1Pat$Channel %in% realChan)
                }
                
              }
              
              if (grepl("STNversus", Contact) & !grepl("ANTI", Contact )) {
                
                TF1Pat$Region = 0
                for (RegToSearch in c("AS", "SM")) { #bien dans cet ordre
                  StrToSearch = RegToSearch
                  e01D = (grepl(StrToSearch, LocTable$D0[pat_row]) & grepl(StrToSearch, LocTable$D1[pat_row]))
                  e01G = (grepl(StrToSearch, LocTable$G0[pat_row]) & grepl(StrToSearch, LocTable$G1[pat_row]))
                  e12D = (grepl(StrToSearch, LocTable$D1[pat_row]) & grepl(StrToSearch, LocTable$D2[pat_row]))
                  e12G = (grepl(StrToSearch, LocTable$G1[pat_row]) & grepl(StrToSearch, LocTable$G2[pat_row]))
                  e23D = (grepl(StrToSearch, LocTable$D2[pat_row]) & grepl(StrToSearch, LocTable$D3[pat_row]))
                  e23G = (grepl(StrToSearch, LocTable$G2[pat_row]) & grepl(StrToSearch, LocTable$G3[pat_row]))
                  
                  listChan = unique(TF1Pat$Channel)
                  realChan = listChan
                  if (task_name == 'GNG_GAIT') {
                    listChan = gsub("1", "0", listChan)
                    listChan = gsub("[2-4]", "1", listChan)
                    listChan = gsub("[5-7]", "2", listChan)
                    listChan = gsub("8", "3", listChan)
                  }
                  
                  if (!e01D) {realChan = realChan[listChan != "01D"] ; listChan = listChan[listChan != "01D"]}
                  if (!e01G) {realChan = realChan[listChan != "01G"] ; listChan = listChan[listChan != "01G"]}
                  if (!e12D) {realChan = realChan[listChan != "12D"] ; listChan = listChan[listChan != "12D"]}
                  if (!e12G) {realChan = realChan[listChan != "12G"] ; listChan = listChan[listChan != "12G"]}
                  if (!e23D) {realChan = realChan[listChan != "23D"] ; listChan = listChan[listChan != "23D"]}
                  if (!e23G) {realChan = realChan[listChan != "23G"] ; listChan = listChan[listChan != "23G"]}
                  
                  if (!grepl(StrToSearch, LocTable$D1[pat_row])) {
                    realChan = realChan[listChan != "11D"] ; listChan = listChan[listChan != "11D"]
                  }
                  if (!grepl(StrToSearch, LocTable$G1[pat_row])) {
                    realChan = realChan[listChan != "11G"] ; listChan = listChan[listChan != "11G"]
                  }
                  if (!grepl(StrToSearch, LocTable$D2[pat_row])) {
                    realChan = realChan[listChan != "22D"] ; listChan = listChan[listChan != "22D"]
                  }
                  if (!grepl(StrToSearch, LocTable$G2[pat_row])) {
                    realChan = realChan[listChan != "22G"] ; listChan = listChan[listChan != "22G"]
                  }
                  
                  if (RegToSearch == "AS") {
                    TF1Pat$Region = ifelse(TF1Pat$Channel %in% realChan, 1+TF1Pat$Region, TF1Pat$Region)
                  } else if (RegToSearch == "SM") {
                    TF1Pat$Region = ifelse(TF1Pat$Channel %in% realChan, 3-TF1Pat$Region, TF1Pat$Region)
                  }
                  
                } # End for RegToSearch
                
                # petit checkpoint
                if (nrow(filter(TF1Pat, Region == 0)) != 0) {
                  print(paste0(unique(TF1Pat$Channel[TF1Pat$Region == 0]) , ' contacts ne sont pas exclusivement dans une region du STN (regime exclusif)'))
                }
                
                TF1Pat = subset(TF1Pat, TF1Pat$Region != 0)
                TF1Pat$Region = ifelse(TF1Pat$Region == 1, "AS", ifelse(TF1Pat$Region == 2, "MidSTN", "SM"))
                
              }
            } 
          }
          
          if (GroupingMode == "Region"  ) {TF1Pat = subset(TF1Pat, TF1Pat$Region == Contact)}  #Keep Only 1 electrode
          if (GroupingMode == "grouping") {
            if ("HighestBeta" == Contact) {
              NonRevuPourLesPPN
              if (1 == sum(unique(TF1Pat$Region) == "HotspotFOG", na.rm = TRUE)) {
                TF1Pat = subset(TF1Pat, TF1Pat$Region   == "HotspotFOG")
              } else {
                # Implementation de l'HighestBeta
                TFPat2 = subset(TF1Pat, TF1Pat$Freq > 13 & TF1Pat$Freq < 30)
                TFPat2 = subset(TFPat2, TFPat2$quality == 1)
                
                startTimeBeta = 18 + 0.5*ncol(TFPat2)
                endTimeBeta   = ncol(TFPat2) - 0.25*ncol(TFPat2)
                
                # Gauche
                TFPat3 = subset(TFPat2, grepl('G', TFPat2$Channel))
                TFPat3 = TFPat3[nchar(TFPat3$Channel) == 3,]
                valuelist = c()
                for (ch in unique(TFPat3$Channel)){
                  TFPat4 = subset(TFPat3, TFPat3$Channel == ch)
                  valuelist[ch] = sum(sum(TFPat4[, startTimeBeta:endTimeBeta], na.rm = TRUE), na.rm = TRUE)
                }
                ChOfInterestG = names(which.max(valuelist))
                
                # Droite
                TFPat3 = subset(TFPat2, grepl('D', TFPat2$Channel))
                TFPat3 = TFPat3[nchar(TFPat3$Channel) == 3,]
                valuelist = c()
                for (ch in unique(TFPat3$Channel)){
                  TFPat4 = subset(TFPat3, TFPat3$Channel == ch)
                  valuelist[ch] = sum(sum(TFPat4[, startTimeBeta:endTimeBeta], na.rm = TRUE), na.rm = TRUE)
                }
                ChOfInterestD = names(which.max(valuelist))
                
                print(paste0(s, " BestBeta : ", ChOfInterestG, ' et ', ChOfInterestD))
                TF1Pat = subset(TF1Pat, TF1Pat$Channel == ChOfInterestG | TF1Pat$Channel == ChOfInterestD)
              }
            } else {
              TF1Pat = subset(TF1Pat, TF1Pat$grouping == Contact)
            }  #Keep Only 1 electrode
          }
          TF1Pat %<>% filter(quality == 1)
          
          if (nrow(TF1Pat) == 0) {
            print(paste0('No electrodes kept for patient ', s, ' ', ev))
            next
          }
          
          # Normalisation du 1/f
          if (nor == 'RAW') {
            TF1Pat = LFP_normalization(TF1Pat, additional_nor_to_do)
          }
          
          TFbySubject = bind_rows(TFbySubject, TF1Pat)
          rm(TF1Pat)
          gc()
          
        } #  End for all subjects : chargement global
        
        timepoints_number      = ncol(TFbySubject) - 17
        
        print(paste0('Nombre de patients : ', length(unique(TFbySubject$Patient)), ' pour une combinaison de ', 
                     length(unique(paste0(TFbySubject$Patient , TFbySubject$Channel))), ' canaux / patients '))
        
        ### MetaFOG #########################################################################################
        
        
        if (MY_PatPCA != "") {            
          
          MY_APA = readxl::read_excel(MY_PatPCA, sheet = 1)
          MY_APA %<>% filter(Session == "POSTOP")
          
          vecTF = paste0(sub(".*_", "", TFbySubject$Patient) , TFbySubject$Medication, TFbySubject$nTrial,'_', TFbySubject$Task)
          vecCA = paste0(MY_APA$Subject, MY_APA$Condition, MY_APA$TrialNum, MY_APA$GoNogo)
          vecTF = gsub("_fast", "R", vecTF)
          vecTF = gsub("_spon", "S", vecTF)
          vecTF = gsub("_GOc",  "C", vecTF)
          vecTF = gsub("_GOi",  "I", vecTF)
          vecCA = gsub("LESNE03",  "LEn", vecCA)
          vecCA = gsub("AVALA08",  "AVl", vecCA)
          vecCA = gsub("CHADO01",  "CHd", vecCA)
          vecCA = gsub("SOUDA02",  "SOd", vecCA)
          indices_communs = match(vecTF, vecCA)
          
          TFbySubject$FOG        = MY_APA$Meta_FOG[indices_communs]
        }
        
        # Save the LFP dataframe
        vroom::vroom_write(TFbySubject, file = paste0(OutputDir, '/',pq_folder,'/csv/', ev, '/TF_', ev, '_', nor, '_', Contact, '.csv'), delim = ";")
        
      }
      
}
      
      



## Step 1.2 : Convert to parquet #########################################################

ev = events[1]
for (ev in events) {  
      
    ##### data to parquet format
    
    timefreq_file = c()
    for (Contact in Contacts_of_interest) { 
      timefreq_file = c(timefreq_file, paste0(OutputDir, '/',pq_folder,'/csv/', ev, '/TF_', ev, '_', nor, '_', Contact, '.csv'))
    }
    
    tic();
    df <- read_timefreq_data(timefreq_file, timestep = 0.03, format_long = F, ev = ev, nor = nor);
    toc()
    tic()
    df %>%
      group_by(Subject) %>%
      arrow::write_dataset(path = paste0(OutputDir, '/',pq_folder,'/', ev, '_', nor, '/'), format = "parquet", compression = "zstd")
    toc()
    
}

cat("###########################################################################################")
print(Sys.time())
cat("FIN step 1 : ", nor, " ", GroupingMode, " ", segType, " ", tBlock, " ", fqStart, " ", nor, " ", events, " ", sep = "")

      
      
      
      
      