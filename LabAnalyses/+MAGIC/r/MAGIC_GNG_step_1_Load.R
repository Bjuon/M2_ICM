#############################################################################################
##                                                                                         ##
##                         Step 1 : Loading from Matlab CSV to R pq                        ##
##                                                                                         ##
#############################################################################################
                                                                                                        rm(list = ls()) ; gc()
#############################################################################################


# Event(s) to treat independently :
events  = c( "WrCUE", "WrFIX") # "CUE", "FIX", "FO1", "FC1", "T0", "T0_EMG", "FO", "FC", "FOG_S", "FOG_E", "TURN_S", "TURN_E"

# Contacts that will be fusionned into the exit parquet dataset
Contacts_of_interest = c("STN-SM-exclusif", "STN-AS-exclusif", "inSTN-elargi") # Region + "HotspotFOG","Motor" or grouping + "HighestBeta" or "other" + "All"
GroupingMode         = "other"

# Paths
DataDir      = 'Z:/TMP/analyses'
OutputDir    = "Z:/Stats"
MY_PatPCA    = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
LocTablePath = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/MAGIC+GI_loc_electrodes.xlsx"
pq_folder    = "pq_wide"

SauvegardeDirecte = TRUE

# Parameters
gp       = 'GNGMagicGoGait'             # 'MAGIC_Only' 'STN'
segType  = 'step'            #'trial'   'step' 
normtype = 'ldNOR'           # RAW or ldNOR
datatype = 'TF'              #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'
Montage  = 'extended'        # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'TF'              # 'TraceBrut' , 'TF',  'none'

additional_nor_to_do = 'none'  # 'none', "fooof_perpat" ou "multip_par_freq"

####

Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()

print(Sys.time())
print("This code is modified from MY's MAGIC Stats GI and BL's pq wide")

## Step 1.1 : Generate the CSV with the data to keep #########################################################
nor = normtype 
Contact = Contacts_of_interest[1]
for (Contact in Contacts_of_interest) { 
  # SET SUBJECTS
  
  #ToAdaptForPPN
  if (gp == 'MAGIC_Only') {
    subjects = c(
        'ALb_000a',
        'FEp_0536',   
        'VIj_000a',
        'DEp_0535',
        'GAl_000a',
        'SOh_0555',
        'GUg_0634',
        # "FRa_000a",
        "SAs_000a",
        'FRj_0610'
      )
    
    listnameSubj = c(
        "ParkPitie_2020_06_25_ALb",
        "ParkPitie_2020_02_20_FEp",
        "ParkPitie_2021_04_01_VIj",
        "ParkPitie_2020_01_16_DEp",
        "ParkPitie_2020_09_17_GAl",
        "ParkPitie_2020_10_08_SOh",
        "ParkRouen_2020_11_30_GUg",
        # "ParkRouen_2021_10_04_FRa",
        "ParkPitie_2021_10_21_SAs",
        "ParkRouen_2021_02_08_FRj"
      )
  }
  
  if (gp == 'STN') {
    subjects = c(
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
      'LOp_000a',
      'ParkPitie_2013_03_21_ROe',
      'ParkPitie_2013_04_04_REs',
      'ParkPitie_2013_06_06_SOj',
      'ParkPitie_2013_10_10_COd',
      'ParkPitie_2013_10_17_FRl',
      'ParkPitie_2013_10_24_CLn',
      'ParkPitie_2014_04_18_MAd',
      'ParkPitie_2014_06_19_LEc',
      'ParkPitie_2015_01_15_MEp',
      'ParkPitie_2015_03_05_RAt',
      'ParkPitie_2015_04_30_VAp',
      'ParkPitie_2015_05_07_ALg',
      'ParkPitie_2015_05_28_DEm',
      'ParkPitie_2015_10_01_SAj'
    )
    
    listnameSubj = c(
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
      "ParkPitie_2019_11_28_LOp",
      'ParkPitie_2013_03_21_ROe',
      'ParkPitie_2013_04_04_REs',
      'ParkPitie_2013_06_06_SOj',
      'ParkPitie_2013_10_10_COd',
      'ParkPitie_2013_10_17_FRl',
      'ParkPitie_2013_10_24_CLn',
      'ParkPitie_2014_04_18_MAd',
      'ParkPitie_2014_06_19_LEc',
      'ParkPitie_2015_01_15_MEp',
      'ParkPitie_2015_03_05_RAt',
      'ParkPitie_2015_04_30_VAp',
      'ParkPitie_2015_05_07_ALg',
      'ParkPitie_2015_05_28_DEm',
      'ParkPitie_2015_10_01_SAj'
    )
    
  }
  if (gp == 'GNGMagicGoGait') {
    subjects = c(
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
    
    listnameSubj = c(
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
  
  ev = events[1]
  
  for (ev in events) {
    
    print(paste0('########## ', ev, ' ######', nor, ' ######', Contact, ' ##########' ))
    if (ev ==  "FOG_S" ||  ev ==  "FOG_E") {
        subjects = c(
            'ALb_000a',
            'VIj_000a',
            'DEj_000a',
            'GAl_000a',
            'SAs_000a',
            #'FRa_000a',
            'GUg_0634',
            'GIs_0550'
          )
        
        listnameSubj = c(
            "ParkPitie_2020_06_25_ALb",
            "ParkPitie_2021_04_01_VIj",
            "ParkPitie_2019_04_25_DEj",
            "ParkPitie_2020_09_17_GAl",
            "ParkPitie_2021_10_21_SAs",
            #  "ParkRouen_2021_10_04_FRa",
            "ParkRouen_2020_11_30_GUg",
            "ParkPitie_2020_07_02_GIs"
          )
        if (gp == 'STN') {
          subjects = c(subjects,
              'ParkPitie_2015_10_01_SAj',
              'ParkPitie_2013_03_21_ROe',
              'ParkPitie_2013_10_24_CLn'
            )
          
          listnameSubj = c(listnameSubj,
              "ParkPitie_2015_10_01_SAj",
              "ParkPitie_2013_03_21_ROe",
              "ParkPitie_2013_10_24_CLn"
            )
        }
    }
    
      print(Sys.time())
      print(cat ('Nombre de sujets inclus : ', length(subjects), ' / Verifier que cela correspond au nombre attendu '))
      
      if (!dir.exists(paste0(OutputDir))) {
           dir.create(paste0(OutputDir))
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
          if (s == 'ParkPitie_2013_03_21_ROe' || s == 'ParkPitie_2013_04_04_REs' || s == 'ParkPitie_2013_06_06_SOj' || s == 'ParkPitie_2013_10_10_COd' || s == 'ParkPitie_2013_10_17_FRl'|| s == 'ParkPitie_2013_10_24_CLn' 
              || s == 'ParkPitie_2014_04_18_MAd' || s == 'ParkPitie_2014_06_19_LEc' || s == 'ParkPitie_2015_01_15_MEp' || s == 'ParkPitie_2015_03_05_RAt' || s ==  'ParkPitie_2015_04_30_VAp' 
              || s ==  'ParkPitie_2015_05_07_ALg' || s == 'ParkPitie_2015_05_28_DEm' || s == 'ParkPitie_2015_10_01_SAj') { 
            task_name = 'GI' 
            suff_name = ''
          } else { 
            task_name = 'GNG_GAIT'  
            suff_name = paste('_', Montage,'_', Artefact, sep="")
          }
          
          ### CHARGEMENT #########################################################################################
          
          s_count = s_count + 1
          print(paste0('########## Patient ', s_count, ' of ', length(subjects), ' /// ', s, ' ', ev, ' ##########' ))
          
          
          # define recdir depending on protocol group
          if (task_name == 'GI'){
            WorkDir = paste(DataDir , s, sep = "/")
          } else {
            RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
            WorkDir = paste(RecDir, '/POSTOP', sep = "") 
          }
          
          #ToAdaptForPPN
          if (task_name == 'GI' || s == 'DEj_000a' || s == 'DRc_000a'|| s == 'BEm_000a' || s == 'BAg_0496' || s == 'LOp_000a'|| s == 'GIs_0550' || s == 'COm_000a'|| s == 'REa_0526' ) { 
            protocol = 'GBMOV' 
          } else { 
            protocol = 'MAGIC'  
          }
          outputname = listnameSubj[s_count]
          
          if (ev == "WrCUE" ||  ev == "WrFIX") {
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
          
          #ToAdaptForPPN
          if (task_name == 'GI') {
            TF1Pat$Task = TF1Pat$Condition
            TF1Pat$Condition = TF1Pat$Segment
            TF1Pat$Segment = NULL
          }
          
          
          ### SELECTION #########################################################################################
          
          if (GroupingMode == "other"  ) {
            if ("All" == Contact) {  #Keep All electrodes
              ;
              
            } else if (grepl("STN", Contact)) {
              
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
          
          if (GroupingMode == "Region"  ) {TF1Pat = subset(TF1Pat, TF1Pat$Region   == Contact)}  #Keep Only 1 electrode
          if (GroupingMode == "grouping") {
            if ("HighestBeta" == Contact) {
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
          TF1Pat = subset(TF1Pat, TF1Pat$quality == 1)
          
          
          # Blacklisted trials (due to bad baseline mainly)
          if (s == 'COm_000a') {
            TF1Pat = subset(TF1Pat, 
                            !((TF1Pat$Channel == '25D' && TF1Pat$Medication == 'ON') | 
                                (TF1Pat$Channel == '23D' && TF1Pat$Medication == 'ON') | 
                                (TF1Pat$Channel == '36D' && TF1Pat$Medication == 'ON')))
          }
          
          if (s == 'VIj_000a') {
            TF1Pat = subset(TF1Pat, 
                            !((TF1Pat$Channel == '75D' && TF1Pat$Medication == 'OFF') | 
                                (TF1Pat$Channel == '67D' && TF1Pat$Medication == 'OFF') | 
                                (TF1Pat$Channel == '47D' && TF1Pat$Medication == 'OFF')))
          }
          
          if (s == 'GAl_000a') {
            TF1Pat = subset(TF1Pat, 
                            !((TF1Pat$Channel == '25D' && TF1Pat$Medication == 'ON') | 
                                (TF1Pat$Channel == '23D' && TF1Pat$Medication == 'ON') | 
                                (TF1Pat$Channel == '47G' && TF1Pat$Medication == 'ON') | 
                                (TF1Pat$Channel == '75G' && TF1Pat$Medication == 'ON') | 
                                (TF1Pat$Channel == '42D' && TF1Pat$Medication == 'ON')))
          }
          
          
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
        
        ### PCA #########################################################################################
        
        
        if (TRUE==TRUE) {            
          
          MY_APA = readxl::read_excel(MY_PatPCA, sheet = 1)
          MY_APA = MY_APA %>%
            mutate( across(c(15:35),~as.numeric(as.character(.x))))
          
          MY_APA$is_FOG = as.factor(MY_APA$is_FOG)
          MY_APA$Meta_FOG = as.factor(MY_APA$Meta_FOG)
          
          
          # Si Subject a 3 lettres alors le copier dans le champ PatID, else 
          MY_APA$PatID = NA
          for (rownumAPA in 1:nrow(MY_APA)) { # nolint: seq_linter.
            if (nchar(MY_APA$Subject[rownumAPA]) == 3) {
              MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 3, 3)))
            } else {
              MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 4, 4)))
            }
          }
          MY_APA$Subject = MY_APA$PatID
          
          MY_APA$Groupe = ifelse((MY_APA$GoNogo == 'R' | MY_APA$GoNogo == 'S') , 'GI', 'MY')
          MY_APA$Groupe = as.factor(MY_APA$Groupe)
          MY_APA$GoNogo = as.factor(MY_APA$GoNogo)
          MY_APA$Subject = as.factor(MY_APA$Subject)
          
          
          IncludedValuesInPCA = c(1,2, 3,4,5,15:29, 31:35, 43) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
          QualitativeValuesInPCA = c(1, 2, 3, 4, 5, 43-17)
          ToNormalize = c(15, 19:22, 26, 28, 30:32)
          
          MY_APA_norm = MY_APA
          for (varnum in ToNormalize) {
            MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] = 
              (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] - 
                 mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE) ) /
              sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE)
            
            MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] = 
              (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] - 
                 mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE) ) /
              sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE)
          }
          
          
          All_APA_fitted = missMDA::imputePCA(MY_APA_norm[,IncludedValuesInPCA], 
                                              quali.sup = QualitativeValuesInPCA , 
                                              ncp = 5)$
            completeObs
          res_pca   = FactoMineR::PCA(All_APA_fitted, 
                                      quali.sup = QualitativeValuesInPCA , 
                                      ncp=9, 
                                      scale.unit=TRUE, graph=FALSE)
          pca = res_pca
          vecTF = paste0(sub(".*_", "", TFbySubject$Patient) , TFbySubject$Medication, TFbySubject$nTrial,'_', TFbySubject$Task)
          vecCA = paste0(pca$call$quali.sup$quali.sup$Subject, pca$call$quali.sup$quali.sup$Condition, pca$call$quali.sup$quali.sup$TrialNum, pca$call$quali.sup$quali.sup$GoNogo)
          vecTF = gsub("_fast", "R", vecTF)
          vecTF = gsub("_spon", "S", vecTF)
          vecTF = gsub("_GOc",  "C", vecTF)
          vecTF = gsub("_GOi",  "I", vecTF)
          indices_communs = match(vecTF, vecCA)
          
          TFbySubject$dimension1 = factoextra::get_pca_ind(pca)$coord[indices_communs, 1]
          TFbySubject$dimension2 = factoextra::get_pca_ind(pca)$coord[indices_communs, 2]
          TFbySubject$dimension3 = factoextra::get_pca_ind(pca)$coord[indices_communs, 3]
          TFbySubject$FOG        = pca$call$quali.sup$quali.sup$Meta_FOG[indices_communs]
          
        }
        
        
        # Ajustement Meta FOG pour patients dont les données comportementales sont manquantes
        TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2015_05_07_ALg" | TFbySubject$Patient == "ParkPitie_2015_05_28_DEm" | TFbySubject$Patient == "ParkPitie_2020_10_08_SOh" | TFbySubject$Patient == "ParkPitie_2015_03_05_RAt" | TFbySubject$Patient == "ParkPitie_2013_06_06_SOj" | TFbySubject$Patient == "ParkPitie_2015_04_30_VAp"] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Patient == "ParkPitie_2015_10_01_SAj")] = "Meta_FOG_1"
        # ROYO E.
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Patient == "ParkPitie_2013_03_21_ROe")] = "Meta_FOG_1"
        TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2013_03_21_ROe" & TFbySubject$Medication == "OFF"  & TFbySubject$Task == "spon" & (TFbySubject$nTrial == 1 | TFbySubject$nTrial == 3 | TFbySubject$nTrial == 4 | TFbySubject$nTrial == 6 | TFbySubject$nTrial == 7 | TFbySubject$nTrial == 8 | TFbySubject$nTrial == 9 | TFbySubject$nTrial == 10 | TFbySubject$nTrial == 11 | TFbySubject$nTrial == 12 | TFbySubject$nTrial == 13 | TFbySubject$nTrial == 14 | TFbySubject$nTrial == 15 | TFbySubject$nTrial == 19 | TFbySubject$nTrial == 20)] = "Meta_FOG_2"
        # Claivaz N.
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Patient == "ParkPitie_2013_10_24_CLn")] = "Meta_FOG_1"
        TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2013_10_24_CLn" & TFbySubject$Medication == "OFF"  & TFbySubject$Task == "spon" & (TFbySubject$nTrial == 19 )] = "Meta_FOG_2"
        TFbySubject$FOG[TFbySubject$Patient == "ParkPitie_2013_10_24_CLn" & TFbySubject$Medication == "OFF"  & TFbySubject$Task == "fast" & (TFbySubject$nTrial == 6 | TFbySubject$nTrial == 7 )] = "Meta_FOG_2" 
        
        TFbySubject %<>% filter(quality == 1)
        
        # Ajustement Meta FOG pour les NoGO
        if (length(unique(TFbySubject$Patient)) > 17) for (s in 1:100) print('Attention, il n y a pas 17 patients dans le dataframe')
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2019_04_25_DEj")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_06_25_ALb")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_02_20_FEp")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2021_04_01_VIj")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_01_16_DEp")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_09_17_GAl")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_10_08_SOh")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkRouen_2020_11_30_GUg")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkRouen_2021_02_08_FRj")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2019_02_21_BAg")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2019_03_14_DRc")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2019_10_24_COm")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2019_10_03_BEm")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_01_09_REa")] = "Meta_FOG_0"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2021_10_21_SAs")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2020_07_02_GIs")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkRouen_2021_10_04_FRa")] = "Meta_FOG_1"
        TFbySubject$FOG[is.na(TFbySubject$FOG) & (TFbySubject$Task == "NoGO") & (TFbySubject$Patient == "ParkPitie_2019_11_28_LOp")] = "Meta_FOG_0"
        
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
cat("FIN step 1 : ", nor, " ", GroupingMode, " ", segType, " ", tBlock, " ", fqStart, " ", Montage, " ", Artefact, " ", nor, " ", events, " ", sep = "")

      
      
      
      
      