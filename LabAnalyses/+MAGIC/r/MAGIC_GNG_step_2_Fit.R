#############################################################################################
##                                                                                         ##
##                        Step 2 - Run Model fit and Extract emmeans                       ##
##                                                                                         ##
#############################################################################################

## General Parameters ########
DataDir    = ifelse((Sys.info()["sysname"]=="Windows"),'Z:/Stats/', '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/Stats/')
Project    = "GNG_STN"
Event      = "FIX"
norm       = "ldNOR"
todo_model = TRUE
todo_emm   = TRUE
todo_Bands = FALSE
LocsIncl   = c("AS", "SM")        # or "all"
FoGIncl    = c(0, 1)              # or "all"
GNGIncl    = c("GOc", "GOi")      # or "all"
DopaIncl   = c("OFF", "ON")      # or "all"

ModelToUse     = "GNGc.i-AS.SM" # either numeric or a specific name. Formula must be set as input
FixedEffect    = "Power ~ GoNogo*Loc*Condition*Meta_FOG*" # or NULL if model numeric
RandmEffect    = "+ (1|Subject/Channel)"           # or NULL if model numeric
gait_data_file = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
Correl         = c("Null", "RT", "RPC.1", "RPC.2", "RPC.3", "RPC.4", "RPC.5") # , "PC.1", "PC.2", "PC.3", "PC.4", "PC.5")

Emm_Tag    = NULL # or _marg_FOG or "_marg_Loc_FOG"
Emm_Spec   = "~GoNogo*Meta_FOG*Loc*Condition"

## Regular Parameters ########
Freq2fit    = 1:100
time_window = c(-1, 1)
Export_in_RData = FALSE

## BANDS Parameters   ########
if (todo_Bands) {
  Freq2fit    = 1:5
  time_window = c(-1, 1.51)
  Export_in_RData = TRUE
  minFreq_Bands = c( 4, 12, 13, 24, 27)
  maxFreq_Bands = c(12, 35, 23, 26, 35)
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

if (Sys.info()["sysname"]!="Windows") {gait_data_file = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/ResAPA_32Pat_forPCA.xlsx'; print("GAIT DATA NON LOCAL")}


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
	  if (pc != "Null" | pc != "") {
  	  params[["emm_params"]][["pc"]] = pc  
  	  params[["emm_params"]][["at"]] = 0   
  	  result[[pc]] = future(batch_emm(params)) ; gc()
	  }
  }
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