#############################################################################################
##                                                                                         ##
##                        Step 2 - Run Model fit and Extract emmeans                       ##
##                                                                                         ##
#############################################################################################
print("This code is modified from MY's MAGIC_GNG_step_2 as of August 2024")

## General Parameters ########
DataDir    = ifelse((Sys.info()["sysname"]=="Windows"),'Z:/PPN/Regions1PPN/', '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/PPN/Grouping/')
Project    = "PPN_GI"
Event      = "T0"
norm       = "ldNOR"
todo_model = F
todo_emm   = TRUE
todo_Bands = F
if (grepl("/AllPerChan/", DataDir))  todo_Bands = T
if (grepl("/Regions/" ,   DataDir))  LocsIncl = c("PPNb", "PPNc", "CuN")       # or "all"
if (grepl("/Grouping/",   DataDir))  LocsIncl = c("PPN", "CuN-LM", "SN")
if (grepl("/Regions1PPN/",DataDir))  LocsIncl = c("PPN", "CuN")
if (grepl("/AllPerChan/", DataDir))  LocsIncl = "all"
FoGIncl    = c(1, 2)              # pas de 0 chez les patients PPN
GNGIncl    = c("spon")      
DopaIncl   = c("OFF", "ON")      

ModelToUse     = "PPN_nocond" # either numeric or a specific name. Formula must be set as input
FixedEffect    = "Power ~ Loc*Meta_FOG*" # or NULL if model numeric
# if (ModelToUse == "PPNxEMG") FixedEffect    = "Power ~ Loc*Condition*Meta_FOG*Side_firststep_ipsi_contra*" # or NULL if model numeric
if (grepl("/AllPerChan/", DataDir)) FixedEffect    = "Power ~ Subject*Side_channel*Loc*Meta_FOG*" # or NULL if model numeric
RandmEffect    = "+ (1|Subject/Channel)"           # or NULL if model numeric
gait_data_file = c(
  "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx",
  "U:/MarcheReelle/00_notes/ResAPA_PPN.xlsx"
)
EMG_file = NULL
#EMG_file       = "Z:/DATA/EMG_Enveloppes_PPN_spon.csv"
Correl         = c("Null", "RPC.1", "RPC.2", "RPC.3", "RPC.4", "RPC.5") # , "PC.1", "PC.2", "PC.3", "PC.4", "PC.5")
if (ModelToUse == "PPNxEMG") Correl = c("Null", "AlphaEMG_Tibialis",  "AlphaEMG_Soleus", "BetaEMG_Tibialis", "BetaEMG_Soleus", "Enveloppe_Tibialis", "Enveloppe_Soleus") # , "PC.1", "PC.2", "PC.3", "PC.4", "PC.5")

Emm_Tag    = NULL # or _marg_FOG or "_marg_Loc_FOG"
Emm_Spec   = "~Meta_FOG*Loc"
# if (ModelToUse == "PPNxEMG") Emm_Spec = "~Meta_FOG*Loc*Condition*Side_firststep_ipsi_contra"
  
## Regular Parameters ########
Freq2fit    = 1:50
time_window = c(-1, 1)
Export_in_RData = FALSE

## BANDS Parameters   ########
if (todo_Bands) {
  Freq2fit    = 1:6
  time_window = c(-1, 1.51)
  Export_in_RData = TRUE
  minFreq_Bands = c( 4,  8, 12, 12, 21, 60)
  maxFreq_Bands = c( 7, 12, 35, 20, 35, 80)
}


## Modeles a faire    ########
# Parameters for GNG study
# compare GOi vs. NG & GOc vs. GOi
# Marche lancee ou Initiation
# per event
# UPDRS correl => non car trop 
# faire les 2 norms

#############################################################################################
#############################################################################################
#############################################################################################

## Model running      ########
# Shouldn't be modified below

Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()

if (Sys.info()["nodename"] == "UMR-LAU-WP011" && as.numeric(format(Sys.time(), "%H")) < 18) {
  plan(list(multisession, multisession), workers = availableCores() - 4)
} else {
  plan(list(multisession, multisession), workers = availableCores())
}

if (Sys.info()["sysname"]!="Windows") {error ; toimplement ; gait_data_file = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/00_notes/ResAPA_PPN.xlsx'; print("GAIT DATA NON LOCAL")}


params = NULL
params[["pq_path"]]         = paste0(DataDir, "pq_wide/", Event , "_", norm, "/")
params[["save_path"]]       = paste0(DataDir, "model_fits/", Project, "_", Event, "_", norm, "/")
params[["gait_data_file"]]  = gait_data_file
params[["freqs_to_fit"]]    = Freq2fit
params[["time_window"]]     = time_window
params[["locs_to_include"]] = LocsIncl 
params[["GNG_to_include"]]  = GNGIncl 
params[["FOG_to_include"]]  = FoGIncl # 0/1/2
params[["DOPA_to_include"]] = DopaIncl
params[["remove_artifacts"]]= TRUE
params[["Bands_Averaging"]] = todo_Bands
params[["Export_in_RData"]] = Export_in_RData
params[["Project"]]         = Project
params[["Replace_if_already_existing"]] = TRUE
if (!is.null(EMG_file)) params[["EMG_file"]] = EMG_file

if (todo_Bands) {
  params[["minFreq_Bands"]] = minFreq_Bands
  params[["maxFreq_Bands"]] = maxFreq_Bands
}


param_sets = NULL
if (is.null(Correl)) {
  param_sets[["Null"]] = c(model_id = ModelToUse, pc = "Null", fe = FixedEffect, re = RandmEffect)
} else {
  for(pc in seq_along(Correl)) {
    param_sets[[pc]] = c(model_id = ModelToUse, pc = Correl[[pc]], fe = FixedEffect, re = RandmEffect)
  }
}
params[["param_sets"]] = param_sets

if(todo_model & (Sys.info()["sysname"]=="Windows")) { tictoc::tic() ; batch_fitter(params) ; tictoc::toc()}
if(todo_model & (Sys.info()["sysname"]!="Windows")) { 
  ResPar = list()
  for (i in 1:10) {
    fit = list()
    params[["freqs_to_fit"]] = ((i-1)*10 + 1):(i*10)
    ResPar[[i]] = future(batch_fitter(params))
  }
  cat("\nWaiting for all models to finish... \n\n")
  tictoc::tic()
  ResPar = future::value(ResPar) ; print("All models finished")
  params[["freqs_to_fit"]]    = Freq2fit
  tictoc::toc()
}

if(todo_emm) { 
  params[["emm_params"]] = list(model_id = ModelToUse, specs = Emm_Spec, pc = "Null", at = 0)
  params[["emm_params"]][["tag"]] = Emm_Tag
  
  result = list()
  params[["emm_params"]][["at"]] = NULL  ; result[["Null"]] = future(batch_emm(params)) ; gc()
  for(pc in Correl) {
    if (pc != "Null" & pc != "") {
      params[["emm_params"]][["pc"]] = pc  
      params[["emm_params"]][["at"]] = 0   
      result[[pc]] = future(batch_emm(params)) ; gc()
    }
  }
  
  print(format(Sys.time(), "%F_%H-%M-%S"))				           
  cat("\nWaiting for all emmeans to finish... \n\n")
  tictoc::tic() ; result = future::value(result) ; print("All emm finished") ; tictoc::toc()
}

gc()
#plan(sequential)


## Sortie           ########

print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")

WhatDone          = ifelse((todo_model & todo_emm), "ModelEmm", ifelse((todo_model), "Model", "Emm"))
IdForNotification = paste(Event, '-', norm , ' - ', WhatDone, '-', ModelToUse, collapse ="_")
Timing            = format(Sys.time(), "%F_%H-%M-%S")
LogDir            = ifelse((Sys.info()["sysname"]=="Windows"),'//l2export/iss02.home/mathieu.yeche/Cluster/outputs/', '/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/')
fileSuccess       = file(paste(LogDir, Timing, "-R_Stats" , IdForNotification , "SUCCESS", ".txt",sep = "")) ; writeLines("Hello", fileSuccess) ; close(fileSuccess)

if (Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006") {
  system(paste0('matlab -nodisplay -nosplash -nodesktop -r \" addpath(\'\\\\l2export\\iss02.home\\mathieu.yeche\\Cluster\\Matlab\\\') ; SMS_Mathieu(\'R_BatchFit , ' , IdForNotification, ' : Fin du script\');exit\"'))
}




### Model depth

if (F) {
  DataDir    = ifelse((Sys.info()["sysname"]=="Windows"),'Z:/PPN/Depth/', '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/PPN/Grouping/')
  Project    = "PPN_GI"
  Event      = "T0"
  norm       = "ldNOR"
  todo_model = T
  todo_emm   = F
  todo_Bands = T
  FoGIncl    = c(1, 2)              # pas de 0 chez les patients PPN
  GNGIncl    = c("spon")      
  DopaIncl   = c("OFF", "ON")      
  
  ModelToUse     = "PPN_FOG+Depth" # either numeric or a specific name. Formula must be set as input
  FixedEffect    = "Power ~ Meta_FOG" # or NULL if model numeric
  RandmEffect    = "+ (1|Subject/Channel)"           # or NULL if model numeric
  gait_data_file = c(
    "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx",
    "U:/MarcheReelle/00_notes/ResAPA_PPN.xlsx"
  )
  EMG_file = NULL
  Correl         = c("Null") # , "PC.1", "PC.2", "PC.3", "PC.4", "PC.5")
  if (ModelToUse == "PPNxEMG") Correl = c("Null", "AlphaEMG_Tibialis",  "AlphaEMG_Soleus", "BetaEMG_Tibialis", "BetaEMG_Soleus", "Enveloppe_Tibialis", "Enveloppe_Soleus") # , "PC.1", "PC.2", "PC.3", "PC.4", "PC.5")
  
  ## Regular Parameters ########
  Freq2fit    = 1:2
  time_window = c(-1, 1.51)
  Export_in_RData = TRUE
  minFreq_Bands = c(  8, 12)
  maxFreq_Bands = c( 12, 20)
  
  Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
  if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
  LoadLibraries()
  
  if (Sys.info()["nodename"] == "UMR-LAU-WP011" && as.numeric(format(Sys.time(), "%H")) < 18) {
    plan(list(multisession, multisession), workers = availableCores() - 4)
  } else {
    plan(list(multisession, multisession), workers = availableCores())
  }

  for (i in 1:7) {
    LocsIncl = switch(i,
                     "1" = c("12D", "12G"),
                     "2" = c("23D", "23G"),
                     "3" = c("34D", "34G"),
                     "4" = c("45D", "45G"),
                     "5" = c("56D", "56G"),
                     "6" = c("67D", "67G"),
                     "7" = c("78D", "78G"))
    
    if (Sys.info()["sysname"]!="Windows") {error ; toimplement ; gait_data_file = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/00_notes/ResAPA_PPN.xlsx'; print("GAIT DATA NON LOCAL")}
    
    params = NULL
    params[["pq_path"]]         = paste0(DataDir, "pq_wide/", Event , "_", norm, "/")
    params[["save_path"]]       = paste0(DataDir, "model_fits/", Project, "_", Event, "_", norm, "/")
    params[["gait_data_file"]]  = gait_data_file
    params[["freqs_to_fit"]]    = Freq2fit
    params[["time_window"]]     = time_window
    params[["locs_to_include"]] = LocsIncl 
    params[["GNG_to_include"]]  = GNGIncl 
    params[["FOG_to_include"]]  = FoGIncl # 0/1/2
    params[["DOPA_to_include"]] = DopaIncl
    params[["remove_artifacts"]]= TRUE
    params[["Bands_Averaging"]] = todo_Bands
    params[["Export_in_RData"]] = Export_in_RData
    params[["Project"]]         = Project
    params[["Replace_if_already_existing"]] = TRUE
    if (!is.null(EMG_file)) params[["EMG_file"]] = EMG_file
    
    if (todo_Bands) {
      params[["minFreq_Bands"]] = minFreq_Bands
      params[["maxFreq_Bands"]] = maxFreq_Bands
    }
    
    param_sets = NULL
    if (is.null(Correl)) {
      param_sets[["Null"]] = c(model_id = paste0(ModelToUse, LocsIncl), pc = "Null", fe = FixedEffect, re = RandmEffect)
    } else {
      for(pc in seq_along(Correl)) {
        param_sets[[pc]] = c(model_id = paste0(ModelToUse, LocsIncl), pc = Correl[[pc]], fe = FixedEffect, re = RandmEffect)
      }
    }
    params[["param_sets"]] = param_sets
    
    if(todo_model & (Sys.info()["sysname"]=="Windows")) { tictoc::tic() ; batch_fitter(params) ; tictoc::toc()}
    
    }
}
  
  