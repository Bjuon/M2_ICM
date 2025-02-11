#############################################################################################
##                                                                                         ##
##                          Step 3bit - Plot the timecourses                               ##
##                                                                                         ##
#############################################################################################
print("This code is modified from MY's PPN_GNG_step_3 as of September 2024")

## Input Parameters ########
DataDir    = 'Z:/PPN/Depth/'
Project    = "PPN_GI"
BandsNames = c("alpha", "lowBeta")
BandsVals  = c( 10   ,   16.0    )

## Cosmetic Parameters ########
time_window = c(-1, 1.5)
save_to_svg = F
Palette1    = "pals::jet"     # "pals::parula" or "jet"
Palette2    = "pals::kovesi.diverging_linear_bjy_30_90_c45"
DarkMode    = F
PlotSizeWidth  = 60
PlotSizeHeight = 60

#############################################################################################
## Plot Parameters ##########################################################################

#  ATTENTION : BIEN REMPLIR ICI TOUS LES PARAMETRES
#              Dupliquer au besoin les params plots

params_plot = NULL ; j = 1



if (grepl("/Regions/" , DataDir)) {
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_Null_Freq_5.5",
                          title           = "region_off_null",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_Null_emm",
                          title           = "region_on_null",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.1_at_0_emm",
                          title           = "region_off_RPC1",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.1_at_0_emm",
                          title           = "region_on_RPC1",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.2_at_0_emm",
                          title           = "region_off_RPC2",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.2_at_0_emm",
                          title           = "region_on_RPC2",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.3_at_0_emm",
                          title           = "region_off_RPC3",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.3_at_0_emm",
                          title           = "region_on_RPC3",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.4_at_0_emm",
                          title           = "region_off_RPC4",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.4_at_0_emm",
                          title           = "region_on_RPC4",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.5_at_0_emm",
                          title           = "region_off_RPC5",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.5_at_0_emm",
                          title           = "region_on_RPC5",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPNb", "PPNc", "CuN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  
} else if (grepl("/Regions1PPN/" , DataDir)) {
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_Null_emm",
                          title           = "region_off_null",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_Null_emm",
                          title           = "region_on_null",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.1_at_0_emm",
                          title           = "region_off_RPC1",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.1_at_0_emm",
                          title           = "region_on_RPC1",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.2_at_0_emm",
                          title           = "region_off_RPC2",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.2_at_0_emm",
                          title           = "region_on_RPC2",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.3_at_0_emm",
                          title           = "region_off_RPC3",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.3_at_0_emm",
                          title           = "region_on_RPC3",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.4_at_0_emm",
                          title           = "region_off_RPC4",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.4_at_0_emm",
                          title           = "region_on_RPC4",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.5_at_0_emm",
                          title           = "region_off_RPC5",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.5_at_0_emm",
                          title           = "region_on_RPC5",
                          Var1_name       = "Meta_FOG",
                          Var2_levels     = c("PPN", "CuN"),
                          Var2_name       = "Loc",
                          Var1_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  
} else if (grepl("/Grouping/" , DataDir)) { 
  
  
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_Null_emm",
                          title           = "grouping_off_null",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_Null_emm",
                          title           = "grouping_on_null",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.1_at_0_emm",
                          title           = "grouping_off_RPC1",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.1_at_0_emm",
                          title           = "grouping_on_RPC1",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.2_at_0_emm",
                          title           = "grouping_off_RPC2",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.2_at_0_emm",
                          title           = "grouping_on_RPC2",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.3_at_0_emm",
                          title           = "grouping_off_RPC3",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.3_at_0_emm",
                          title           = "grouping_on_RPC3",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.4_at_0_emm",
                          title           = "grouping_off_RPC4",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.4_at_0_emm",
                          title           = "grouping_on_RPC4",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.5_at_0_emm",
                          title           = "grouping_off_RPC5",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  params_plot[[j]] = list(Event           = "T0",
                          norm            = "ldNOR",
                          FileName        = "model_PPN_RPC.5_at_0_emm",
                          title           = "grouping_on_RPC5",
                          Var1_name       = "Loc",
                          Var1_levels     = c("PPN", "CuN-LM", "SN"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(1,2),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
}





#############################################################################################
#############################################################################################
#############################################################################################

## Running      ########
# Shouldn't be modified below

Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()

if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) PlotSizeWidth  = 1.6*PlotSizeWidth ; PlotSizeHeight = 1.7*PlotSizeHeight

if (todo_avg) query = list()

for (i in seq_along(params_plot)) {
  
  for (band in seq_along(BandsNames)) {
    
    AVANT
    spec = as.formula("~ Meta_FOG | Loc + Condition + Subject")
    # spec = as.formula("~ Meta_FOG*Loc*Condition*Subject")
    RPC
    
    params_plot[[i]]$FileName = 'model_PPN_Null_Freq_'
    
    
    
    modelpath = paste0(DataDir, 'model_fits/', Project, "_", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "/",params_plot[[i]]$FileName, BandsVals[band],".Rdata")
    load(modelpath)
     
    emGlobal = data.frame()
    for (time in seq_along(df_save$fit)) {
      if(todo_trend & !(grepl("Null", params_plot[[i]]$FileName))) {
        emmeanS = suppressMessages(emtrends(df_save$fit[time][[1]], spec, at = list(Loc = c(1, 2, 3, 4, 5, 6, 7)), var = RPC))
      } else {
        emmeanS = suppressMessages(emmeans (df_save$fit[time][[1]], spec, at = list(Loc = c(1, 2, 3, 4, 5, 6, 7)) ))
      }
      emmean = emmeanS %>% contrast() %>% as.data.frame() # %>% filter(!!sym(params_plot[[i]]$Selection_name) == params_plot[[i]]$Selection_level)
      emmean %<>% mutate(Time = df_save$Time[time]) %>% relocate(Time, .before = 1)
      if (todo_trend & !(grepl("Null", params_plot[[i]]$FileName))) emmean %<>% rename(estimate = !!sym(paste0(RPC, ".trend")))
      emGlobal = rbind(emGlobal, emmean)
    }
    
    emGlobal$side = ifelse(grepl("G", emGlobal$Loc), "Left", "Right")
    emGlobal$pval = p.adjust(emGlobal$p.value, method = "fdr")
    
    emGlobal$emmean = (emGlobal$estimate - min(emGlobal$estimate) ) / (max(emGlobal$estimate) - min(emGlobal$estimate))
    emGlobal$SE     = emGlobal$SE / (max(emGlobal$estimate) - min(emGlobal$estimate))
    emGlobal$emmean = emGlobal$emmean - 0.5 + as.numeric(substr(emGlobal$Loc, 1, 1))
    
    ggplot2::ggplot(emGlobal, aes(x = Time, y = emmean, group = Loc)) +
      geom_ribbon(aes(ymin = emmean - SE, ymax = emmean + SE), alpha = 0.2) +
      geom_line(size = 0.1) +
      geom_line(size = 1, data = emGlobal %>% filter(pval < 0.05)) +
      theme() + 
      xlab("Time (s)") + ylab("Depth") +
      facet_wrap(~ paste(Condition, side, contrast)) +
      
      ggtitle(paste0("Trend of ", RPC, " in ", params_plot[[i]]$Selection_level, " around " , BandsNames[band])) +
      theme(legend.position = "top") +
      geom_ribbon(data = emGlobal %>% filter(pval < 0.05), aes(x = Time, ymin = max(emGlobal$emmean + emGlobal$SE), ymax = max(emGlobal$emmean + emGlobal$SE) + 0.03), fill = "black", color = "black", show.legend = FALSE) +
      theme_Publication()
    
    
    height = max(dfRes$List0 + dfRes$List0SE)
    ceiling= min(dfRes$List0 - dfRes$List0SE)
    # plot
    ggplot2::ggplot(dfRes, aes(x = Listt, y = List0, color = G0)) +
      geom_ribbon(aes(ymin = List0 - List0SE, ymax = List0 + List0SE, fill = G0), alpha = 0.2) +
      geom_line() +
      theme() + 
      xlab("Time (s)") + ylab("Regression Estimate") +
      ggtitle(paste0("Trend of ", RPC, " in ", LocSTN, " - ", Cond, " around " , Freq, "Hz")) +
      theme(legend.position = "top") +
      # if Listp < 0.05 then add a black point at 0.2
      geom_ribbon(data = dfRes %>% filter(Listp < 0.05), aes(x = Listt, ymin = height, ymax = height+0.03*(height-ceiling)), fill = "black", color = "black", show.legend = FALSE) +
      theme_Publication() 
    
    
    
  function(modelpath, RPC, LocSTN = "", Cond = "OFF")
    modelpath = paste0(DataDir, 'model_fits/', Project, "_", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "/",params_plot[[i]]$FileName,".Rdata")
  # load Rdata model
  load(modelpath)
  spec = as.formula(ifelse(LocSTN == "", "~ Meta_FOG + Condition", "~ Meta_FOG | Loc + Condition"))
  Freq = str_extract_all(modelpath, "[0-9]+", )[[1]]
  Freq = as.numeric(Freq[length(Freq)])
  
  # extract emmean
  List0 = c() ; List1 = c() ; Listp = c() ; List0SE = c() ; List1SE = c()
  Listt = df_save$Time
  for (time in seq_along(df_save$fit)) {
    emmeanS = suppressMessages(emtrends(df_save$fit[time][[1]], spec, var = RPC) )
    emmean  = emmeanS %>% as.data.frame() %>% filter(Loc == LocSTN, Condition == Cond) %>% rename(trend = !!sym(paste0(RPC, ".trend"))) %>% as.data.frame()
    List0   = c(List0,   emmean$trend[1])
    List1   = c(List1,   emmean$trend[2])
    List0SE = c(List0SE, emmean$SE[1])
    List1SE = c(List1SE, emmean$SE[2])
    pval    = emmeanS %>% pairs() %>% as.data.frame() %>% filter(Loc == LocSTN, Condition == Cond) %>% pull(p.value)
    Listp   = c(Listp, pval)
  }
  
  Listp  = p.adjust(Listp, method = "fdr")
  dfRes0 = data.frame(Listt, Listp, List0, List0SE)
  dfRes0$G0    = "F-/-"
  dfRes1 = data.frame(Listt, Listp)
  dfRes1$List0 = List1
  dfRes1$List0SE = List1SE
  dfRes1$G0    = "F+/-"
  dfRes = rbind(dfRes0, dfRes1)
  
  height = max(dfRes$List0 + dfRes$List0SE)
  ceiling= min(dfRes$List0 - dfRes$List0SE)
  # plot
  ggplot2::ggplot(dfRes, aes(x = Listt, y = List0, color = G0)) +
    geom_ribbon(aes(ymin = List0 - List0SE, ymax = List0 + List0SE, fill = G0), alpha = 0.2) +
    geom_line() +
    theme() + 
    xlab("Time (s)") + ylab("Regression Estimate") +
    ggtitle(paste0("Trend of ", RPC, " in ", LocSTN, " - ", Cond, " around " , Freq, "Hz")) +
    theme(legend.position = "top") +
    # if Listp < 0.05 then add a black point at 0.2
    geom_ribbon(data = dfRes %>% filter(Listp < 0.05), aes(x = Listt, ymin = height, ymax = height+0.03*(height-ceiling)), fill = "black", color = "black", show.legend = FALSE) +
    theme_Publication() 
  
  
  
  
  
  Grid_Size_local = 9
  if (is.null(params_plot[[i]]$Var2_name)) Grid_Size_local = 3
  if (length(params_plot[[i]]$Var1_levels) == 3) Grid_Size_local = 15
  if (!dir.exists(paste0(DataDir, 'Figures/'         ))) dir.create(paste0(DataDir, 'Figures/'         ))
  if (!dir.exists(paste0(DataDir, 'Figures/', Project))) dir.create(paste0(DataDir, 'Figures/', Project))
  
  if (todo_emean | todo_trend) {
    df = qs::qread(paste0(DataDir, 'model_fits/', Project, "_", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "/",params_plot[[i]]$FileName,".qs"))
    df %<>% mutate(p.value.a = p.adjust(p.value,method="fdr"))
  }
  
  if (todo_emean) {
    ## Emmean      ########
    estimator = "emmean"
    p = suppressMessages(plot_tf_Variable(df,
                                          est = estimator,
                                          pval_col = "p.value.a",
                                          title = paste0(Project, " - ", params_plot[[i]]$Event, " " , params_plot[[i]]$norm, " : ", params_plot[[i]]$title, " - ", estimator),
                                          Var1_name   = params_plot[[i]]$Var1_name,
                                          Var1_levels = params_plot[[i]]$Var1_levels,
                                          Var2_name   = params_plot[[i]]$Var2_name,
                                          Var2_levels = params_plot[[i]]$Var2_levels,
                                          Selection_name  = params_plot[[i]]$Selection_name,
                                          Selection_level = params_plot[[i]]$Selection_level,
                                          Tag = NULL,
                                          Grid_Size = Grid_Size_local,
                                          PaletteMain = PaletteMain,
                                          PaletteDiff = PaletteDiff,
                                          norm = params_plot[[i]]$norm
    ))
    
    if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) p = p + theme_dark_dark_classiclegend() 
    
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_emmeans.png"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
    if (save_to_svg) {
      if (!dir.exists(paste0(DataDir, 'Figures/', Project, '/SVG/'))) dir.create(paste0(DataDir, 'Figures/', Project, '/SVG/'))
      cowplot::ggsave2(filename = paste0(DataDir, 'Figures/', Project, "/SVG/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_emmeans.svg"), 
                       plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
    }
  }
  
  if (todo_trend & !(grepl("Null", params_plot[[i]]$FileName))) {
    ## Emtrend      ########
    estimator = "emslope"
    p = suppressMessages(plot_tf_Variable(df,
                                          est = estimator,
                                          pval_col = "p.value.a",
                                          title = paste0(Project, " - ", params_plot[[i]]$Event, " " , params_plot[[i]]$norm, " : ", params_plot[[i]]$title, " - ", estimator),
                                          Var1_name   = params_plot[[i]]$Var1_name,
                                          Var1_levels = params_plot[[i]]$Var1_levels,
                                          Var2_name   = params_plot[[i]]$Var2_name,
                                          Var2_levels = params_plot[[i]]$Var2_levels,
                                          Selection_name  = params_plot[[i]]$Selection_name,
                                          Selection_level = params_plot[[i]]$Selection_level,
                                          Tag = NULL,
                                          Grid_Size = Grid_Size_local,
                                          PaletteMain = PaletteMain,
                                          PaletteDiff = PaletteDiff,
                                          norm = params_plot[[i]]$norm
    ))
    
    if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) p = p + theme_dark_dark_classiclegend()
    
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_emtrends.png"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
    if (save_to_svg) {
      if (!dir.exists(paste0(DataDir, 'Figures/', Project, '/SVG/'))) dir.create(paste0(DataDir, 'Figures/', Project, '/SVG/'))
      cowplot::ggsave2(filename = paste0(DataDir, 'Figures/', Project, "/SVG/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_emtrends.svg"), 
                       plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
    }
  }
  
  if (todo_avg) {
    ## Average      ########
    ev   = params_plot[[i]]$Event
    norm = params_plot[[i]]$norm
    if (!is.null(query[[ev]])) {
      if (!is.null(query[[ev]][[norm]])) {
        df = query[[ev]][[norm]]
      } else df = NULL
    } else {query[[ev]] = list() ; df = NULL}
    
    if (is.null(df)) {
      if (is.null(params_plot[[i]]$pq_path)) {
        pq_path = paste0(DataDir, 'pq_wide/', ev, "_" , norm, "/")
        print("pq_path not provided for average, using default")
      } else pq_path = params_plot[[i]]$pq_path
      tfdata = arrow::open_dataset(pq_path)
      
      # timebins
      cnames = tfdata$schema$names
      time_col_names = cnames[str_ends(cnames, "0")]
      times = time_col_names %>% as.numeric()
      ind = times < -1.0 | times > 1.0
      times_to_drop = time_col_names[ind]
      
      # Collect
      df = tfdata %>%
        select(-all_of(times_to_drop)) %>%
        to_duckdb() %>%
        pivot_longer(
          cols = ends_with("0"),
          names_to = "Time",
          values_to = "Power"
        ) %>% 
        filter(!is.na(Power)) %>%
        mutate(Time = as.numeric(Time)) %>%
        collect()
      
      query[[ev]][[norm]] = df
    }
    
    df %<>% filter(!!sym(params_plot[[i]]$Var1_name) %in% params_plot[[i]]$Var1_levels)
    if (!is.null(params_plot[[i]]$Var2_name)) df %<>% filter(!!sym(params_plot[[i]]$Var2_name) %in% params_plot[[i]]$Var2_levels)
    if (!is.null(params_plot[[i]]$Selection_name)) df %<>% filter(!!sym(params_plot[[i]]$Selection_name) %in% params_plot[[i]]$Selection_level)
    df %<>% group_by(Subject, Time, Freq, !!sym(params_plot[[i]]$Selection_name), !!sym(params_plot[[i]]$Var2_name), !!sym(params_plot[[i]]$Var1_name)) %>%
      summarise(meanPower = mean((Power), na.rm = T), .groups = "drop")
    
    df %<>% group_by(Time, Freq, !!sym(params_plot[[i]]$Selection_name), !!sym(params_plot[[i]]$Var2_name), !!sym(params_plot[[i]]$Var1_name)) %>%
      summarise(meanPower = mean(meanPower), .groups = "drop")
    
    
    estimator = "meanPower"
    p = suppressMessages(plot_tf_Variable(df,
                                          est = estimator,
                                          pval_col = NULL,
                                          title = paste0(Project, " - ", params_plot[[i]]$Event, " " , params_plot[[i]]$norm, " : ", params_plot[[i]]$title, " - ", estimator),
                                          Var1_name   = params_plot[[i]]$Var1_name,
                                          Var1_levels = params_plot[[i]]$Var1_levels,
                                          Var2_name   = params_plot[[i]]$Var2_name,
                                          Var2_levels = params_plot[[i]]$Var2_levels,
                                          Selection_name  = params_plot[[i]]$Selection_name,
                                          Selection_level = params_plot[[i]]$Selection_level,
                                          Tag = NULL,
                                          Grid_Size = Grid_Size_local,
                                          PaletteMain = PaletteMain,
                                          PaletteDiff = PaletteDiff,
                                          norm = params_plot[[i]]$norm
    ))
    
    if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) p = p + theme_dark_dark_classiclegend()
    
    if (!dir.exists(paste0(DataDir, 'Figures/', Project))) dir.create(paste0(DataDir, 'Figures/', Project))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_", estimator, ".png"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
    if (save_to_svg) {
      if (!dir.exists(paste0(DataDir, 'Figures/', Project, '/SVG/'))) dir.create(paste0(DataDir, 'Figures/', Project, '/SVG/'))
      cowplot::ggsave2(filename = paste0(DataDir, 'Figures/', Project, "/SVG/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_", estimator, ".svg"), 
                       plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
    }
    gc()
  }
  print(paste0("Figure ", i, " / ", length(params_plot)))
}

## Sortie           ########

if (todo_avg) print("It is highly recommended to run : rm(query);gc()    ")

print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")







BIS


DataDir    = 'C:/LustreSync/PPN/AllPerChan/'
Project    = "PPN_GI"
Event      = "T0"
norm       = "ldNOR"

tfdata  = arrow::open_dataset(paste0(DataDir, "pq_wide/", Event , "_", norm, "/"))
query   = tfdata %>% collect() 

query %<>% 
  pivot_longer(
    cols = ends_with("0"),
    names_to = "Time",
    values_to = "Power"
  ) %>% 
  filter(!is.na(Power)) %>%
  mutate(Time = as.numeric(Time))

query$Freq = ifelse(query$Freq > 81, "N", 
                    ifelse(query$Freq > 61, "gamma", 
                           ifelse(query$Freq > 36, "N", 
                                  ifelse(query$Freq > 20, "highBeta", 
                                         ifelse(query$Freq > 12, "lowBeta", 
                                                ifelse(query$Freq > 7, "alpha", 
                                                       ifelse(query$Freq > 2, "theta", "N")))))))

query = rbind(query, query %>% filter(Freq %in% c("highBeta", "lowBeta")) %>% mutate(Freq = "beta"))
query %<>% filter(Freq != "N") 

qaverage = query %>% group_by(Subject, Loc, Condition, Meta_FOG, Freq, Time) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaverage$side = ifelse(grepl("G", qaverage$Loc), "Left", "Right")

for (band in seq_along(BandsNames)) {
  qaveBand = qaverage %>% filter(Freq == BandsNames[band])
  qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*3   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
  qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *3
  
  p = ggplot(qaveBand, aes(x = Time, y = Mean, group = Loc)) +
    geom_ribbon(aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2) +
    geom_line(size = 0.3) +
    # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
    # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
    theme() + 
    xlab("Time (s)") + ylab("Power") +
    facet_wrap(~ paste(Condition, side, Subject, Meta_FOG)) +
    ggtitle(paste0("Average Power in ", BandsNames[band])) +
    theme_Publication()
  
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/', BandsNames[band], "_average.png"), 
                   plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  if (save_to_svg) {
    if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/', BandsNames[band], "_average.svg"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  }
}

   # Per subject
for(subj in unique(qaverage$Subject)) {
  qaveBand = qaverage %>% filter(Subject == subj)
  qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*3   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
  qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *3
  
  p = ggplot(qaveBand, aes(x = Time, y = Mean, group = Loc)) +
    geom_ribbon(aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2) +
    geom_line(size = 0.3) +
    # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
    # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
    theme() + 
    xlab("Time (s)") + ylab("Power") +
    facet_wrap(~ paste(Freq, side, Condition, Meta_FOG)) +
    ggtitle(paste0("Average Power for ", subj)) +
    theme_Publication()
  
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/', subj, "_average.png"), 
                   plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  if (save_to_svg) {
    if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/', subj, "_average.svg"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  }
}



# No Condition

qaverage = query %>% group_by(Subject, Loc, Meta_FOG, Freq, Time) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaverage$side = ifelse(grepl("G", qaverage$Loc), "Left", "Right")

for (band in seq_along(BandsNames)) {
  qaveBand = qaverage %>% filter(Freq == BandsNames[band])
  qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*3   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
  qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *3
  
  p = ggplot(qaveBand, aes(x = Time, y = Mean, group = Loc)) +
    geom_ribbon(aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2) +
    geom_line(size = 0.3) +
    # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
    # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
    theme() + 
    xlab("Time (s)") + ylab("Power") +
    facet_wrap(~ paste(Subject, side, Meta_FOG)) +
    ggtitle(paste0("Average Power in ", BandsNames[band], " - No Cond")) +
    theme_Publication()
  
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/', BandsNames[band], "_average_nocond.png"), 
                   plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  if (save_to_svg) {
    if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/', BandsNames[band], "_average_nocond.svg"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  }
  
}

   # Per subject

for (subj in unique(qaverage$Subject)) {
  qaveBand = qaverage %>% filter(Subject == subj)
  qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*3   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
  qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *3
  
  p = ggplot(qaveBand, aes(x = Time, y = Mean, group = Loc)) +
    geom_ribbon(aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2) +
    geom_line(size = 0.3) +
    # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
    # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
    theme() + 
    xlab("Time (s)") + ylab("Power") +
    facet_wrap(~ paste(Freq, side, Meta_FOG)) +
    ggtitle(paste0("Average Power for ", subj, " - No Cond")) +
    theme_Publication()
  
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/', subj, "_average_nocond.png"), 
                   plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  if (save_to_svg) {
    if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/', subj, "_average_nocond.svg"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  }
}




# No FOG No Cond

qaverage = query %>% group_by(Subject, Loc, Freq, Time) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaverage$side = ifelse(grepl("G", qaverage$Loc), "Left", "Right")

for (band in seq_along(BandsNames)) {
  qaveBand = qaverage %>% filter(Freq == BandsNames[band])
  qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*3   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
  qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *3
  
  p = ggplot(qaveBand, aes(x = Time, y = Mean, group = Loc)) +
    geom_ribbon(aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2) +
    geom_line(size = 0.3) +
    # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
    # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
    theme() + 
    xlab("Time (s)") + ylab("Power") +
    facet_wrap(~ paste(Subject, side)) +
    ggtitle(paste0("Average Power in ", BandsNames[band], " - No Cond No FoG")) +
    theme_Publication()
  
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/', BandsNames[band], "_average_nocondorfog.png"), 
                   plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  if (save_to_svg) {
    if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/', BandsNames[band], "_average_nocondorfog.svg"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  }
  
}


  # Per Subject

for (subj in unique(qaverage$Subject)) {
  qaveBand = qaverage %>% filter(Subject == subj)
  qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*3   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
  qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *3
  
  p = ggplot(qaveBand, aes(x = Time, y = Mean, group = Loc)) +
    geom_ribbon(aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2) +
    geom_line(size = 0.3) +
    # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
    # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
    theme() + 
    xlab("Time (s)") + ylab("Power") +
    facet_wrap(~ paste(Freq, side)) +
    ggtitle(paste0("Average Power for ", subj, " - No Cond No FoG")) +
    theme_Publication()
  
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/', subj, "_average_nocondorfog.png"), 
                   plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  if (save_to_svg) {
    if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
    cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/', subj, "_average_nocondorfog.svg"), 
                     plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
  }
}




# Nothing AllAverage

qaverage = query %>% mutate(Loc = substr(Loc, 1, 2)) %>%
  group_by( Loc, Freq, Time) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaveBand = qaverage %>% filter(Freq %in% c("alpha", "lowBeta"))
qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*2   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *2
qaveAlph       = qaveBand %>% filter(Freq == "alpha"   & Time <= 1 & Time > -1)
qaveBeta       = qaveBand %>% filter(Freq == "lowBeta" & Time <= 1 & Time > -1)

p = ggplot(qaveAlph, aes(x = Time, y = Mean, group = Loc)) + 
  theme_dark_black_classiclegend() +
  geom_hline(yintercept = 1:7, linetype = "33", color = "grey50" ) +
  geom_ribbon(                 aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::darken("blue", .2, space = "HLS") ) +
  geom_ribbon(data = qaveBeta, aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::darken("red" , .3, space = "HLS")) +
  geom_line(                 size = 0.3, color = "blue") +
  geom_line(data = qaveBeta, size = 0.3, color = "red") +
  # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
  # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
  theme() + 
  xlab("Time (s)") + ylab("Power") +
  #theme_Publication()
  ggtitle(paste0("Grand Average Power in Alpha and Beta")) 

cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/Grand_average.png'), 
                 plot = p, width = 21, height = 29.7, units = "cm")
if (save_to_svg) {
  if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/Grand_average.svg'), 
                   plot = p, width = 21, height = 29.7, units = "cm")
}
  




# Just Meta_FOG AllAverage

qaverage = query %>% mutate(Loc = substr(Loc, 1, 2)) %>%
  group_by( Loc, Freq, Time, Meta_FOG) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaveBand = qaverage %>% filter(Freq %in% c("alpha", "lowBeta"))
qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*2   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *2
qaveBand$Meta_FOG %<>% recode_factor("1" = "Sans FOG", "2" = "Avec FOG")
qaveAlph       = qaveBand %>% filter(Freq == "alpha"   & Time <= 1 & Time > -1)
qaveBeta       = qaveBand %>% filter(Freq == "lowBeta" & Time <= 1 & Time > -1)

p = ggplot(qaveAlph, aes(x = Time, y = Mean, group = Loc)) +
  geom_hline(yintercept = 1:7, linetype = "33", color = "grey50" ) +
  geom_ribbon(                 aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2, fill = "blue") +
  geom_ribbon(data = qaveBeta, aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2, fill = "red") +
  geom_line(                 size = 0.3, color = "blue") +
  geom_line(data = qaveBeta, size = 0.3, color = "red") +
  # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
  # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
  theme() + 
  facet_wrap(~ Meta_FOG) +
  xlab("Time (s)") + ylab("Power") +
  ggtitle(paste0("Grand Average Power in Alpha and Beta")) +
  theme_Publication()


pdark = ggplot(qaveAlph, aes(x = Time, y = Mean, group = Loc)) +
  theme_dark_black_classiclegend() +
  geom_hline(yintercept = 1:7, linetype = "33", color = "grey50" ) +
  geom_ribbon(                 aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::darken("blue", .2, space = "HLS") ) +
  geom_ribbon(data = qaveBeta, aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::darken("red" , .3, space = "HLS")) +
  geom_line(                 size = 0.3, color = "blue") +
  geom_line(data = qaveBeta, size = 0.3, color = "red") +
  # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
  # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
  theme() + 
  facet_wrap(~ Meta_FOG) +
  xlab("Time (s)") + ylab("Power") +
  ggtitle(paste0("Grand Average Power in Alpha and Beta"))

cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/Grand_average_Meta_FOG.png'), 
                 plot = p, width = 21, height = 29.7, units = "cm")
if (save_to_svg) {
  if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/Grand_average_Meta_FOG.svg'), 
                   plot = p, width = 21, height = 29.7, units = "cm")
}






# Just Condition AllAverage

qaverage = query %>% mutate(Loc = substr(Loc, 1, 2)) %>%
  group_by( Loc, Freq, Time, Condition) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaveBand = qaverage %>% filter(Freq %in% c("alpha", "lowBeta"))
qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*2   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *2
qaveAlph       = qaveBand %>% filter(Freq == "alpha"   & Time <= 1 & Time > -1)
qaveBeta       = qaveBand %>% filter(Freq == "lowBeta" & Time <= 1 & Time > -1)

p = ggplot(qaveAlph, aes(x = Time, y = Mean, group = Loc)) +
  geom_hline(yintercept = 1:7, linetype = "33", color = "grey50" ) +
  geom_ribbon(                 aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2, fill = "blue") +
  geom_ribbon(data = qaveBeta, aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.2, fill = "red") +
  geom_line(                 size = 0.3, color = "blue") +
  geom_line(data = qaveBeta, size = 0.3, color = "red") +
  # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
  # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
  theme() + 
  facet_wrap(~ Condition) +
  xlab("Time (s)") + ylab("Power") +
  ggtitle(paste0("Grand Average Power in Alpha and Beta")) +
  theme_Publication()

cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/Grand_average_Condition.png'), 
                 plot = p, width = 21, height = 29.7, units = "cm")
if (save_to_svg) {
  if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/Grand_average_Condition.svg'), 
                   plot = p, width = 21, height = 29.7, units = "cm")
}




# Nothing AllAverage + stat

qaverage = query %>% mutate(Loc = substr(Loc, 1, 2)) %>%
  group_by( Loc, Freq, Time) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaveBand = qaverage %>% filter(Freq %in% c("alpha", "lowBeta"))
qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*2   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *2
qaveAlph       = qaveBand %>% filter(Freq == "alpha"   & Time <= 1 & Time > -1)
qaveBeta       = qaveBand %>% filter(Freq == "lowBeta" & Time <= 1 & Time > -1)

p = ggplot(qaveAlph, aes(x = Time, y = Mean, group = Loc)) + 
  theme_dark_black_classiclegend() +
  geom_hline(yintercept = 1:7, linetype = "33", color = "grey50" ) +
  geom_ribbon(                 aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::darken("blue", .2, space = "HLS") ) +
  geom_ribbon(data = qaveBeta, aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::darken("red" , .3, space = "HLS")) +
  geom_line(                 size = 0.3, color = "blue") +
  geom_line(data = qaveBeta, size = 0.3, color = "red") +
  # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
  # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
  theme() + 
  xlab("Time (s)") + ylab("Power") +
  #theme_Publication()
  ggtitle(paste0("Grand Average Power in Alpha and Beta")) 

cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/Grand_average.png'), 
                 plot = p, width = 21, height = 29.7, units = "cm")
if (save_to_svg) {
  if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/Grand_average.svg'), 
                   plot = p, width = 21, height = 29.7, units = "cm")
}
















StartPath = "C:/LustreSync/PPN/Depth/model_fits/PPN_GI_T0_ldNOR/model_PPN_FOG+Depth"
EndPath   = "D_Null_Freq_"

df_plot = data.frame() 

#alpha
for (i in c(1,2,3,4,5,6,7)) {
  load(paste0(StartPath, i, i+1, EndPath, 10, ".RData"))
  df_save$Depth = i  ; df_save$Freq = "Alpha"
  df_save$valNF = NA ; df_save$valF = NA ; df_save$pval = NA
  for (j in 1:nrow(df_save)) {
    emm = df_save$fit[[j]] %>% emmeans(pairwise ~ Meta_FOG)
    df_save$valNF[j] = emm$emmeans[1] %>% as.data.frame() %>% pull(emmean)
    df_save$valF[j]  = emm$emmeans[2] %>% as.data.frame() %>% pull(emmean)
    df_save$pval[j]  = emm$contrasts  %>% as.data.frame() %>% pull(p.value)
  }
  df_plot = rbind(df_plot, df_save %>% select(-fit))
  load(paste0(StartPath, i, i+1, EndPath, 16, ".RData"))
  df_save$Depth = i  ; df_save$Freq = "LowBeta"
  df_save$valNF = NA ; df_save$valF = NA ; df_save$pval = NA
  for (j in 1:nrow(df_save)) {
    emm = df_save$fit[[j]] %>% emmeans(pairwise ~ Meta_FOG)
    df_save$valNF[j] = emm$emmeans[1] %>% as.data.frame() %>% pull(emmean)
    df_save$valF[j]  = emm$emmeans[2] %>% as.data.frame() %>% pull(emmean)
    df_save$pval[j]  = emm$contrasts  %>% as.data.frame() %>% pull(p.value)
  }
  df_plot = rbind(df_plot, df_save %>% select(-fit))
}
df_plot_save = df_plot
df_plot %>% write.csv("C:/LustreSync/PPN/Depth/model_fits/PPN_GI_T0_ldNOR/AllDepth.csv", row.names = FALSE)

df_plot$pvalcor[df_plot$Freq == "Alpha"] = p.adjust(df_plot$pval[df_plot$Freq == "Alpha"], method = "fdr")
df_plot$pvalcor[df_plot$Freq == "LowBeta"] = p.adjust(df_plot$pval[df_plot$Freq == "LowBeta"], method = "fdr")
max_p   = max(max(df_plot$valNF),max(df_plot$valF))
df_plot %<>% mutate(valNF = valNF/max_p + Depth - 1, valF = valF/max_p + Depth - 1)
df_plot %<>% pivot_longer(cols = c("valNF", "valF"), names_to = "MFog", values_to = "val") %>% mutate(mgpc = paste(Depth, MFog))


ggplot2::ggplot(df_plot, aes(x = Time, group = mgpc, color = MFog)) +
  geom_line(aes(y = val)) +
  facet_wrap(~ Freq) +
  geom_ribbon(data = df_plot %>% filter(pvalcor < 0.05), aes(ymin = 7.8, ymax = 8), fill = "black", color = "black", show.legend = FALSE) +
  geom_ribbon(data = df_plot %>% filter(pval < 0.05), aes(ymin = 7.3, ymax = 7.5), fill = "black", color = "black", show.legend = FALSE) +
  theme_Publication() 


# Nothing AllAverage

qaverage = query %>% mutate(Loc = substr(Loc, 1, 2)) %>%
  group_by( Loc, Freq, Time) %>%
  summarise(sd = sd(Power, na.rm=T), Power = median(Power), count = n(), .groups = "drop")
qaverage$SE = qaverage$sd / sqrt(qaverage$count)

qaveBand = qaverage %>% filter(Freq %in% c("alpha", "lowBeta"))
qaveBand$Mean  = (qaveBand$Power - min(qaveBand$Power) ) / (max(qaveBand$Power) - min(qaveBand$Power))*2   - 0.5 + as.numeric(substr(qaveBand$Loc, 1, 1))
qaveBand$SE    = qaveBand$SE / (max(qaveBand$Power) - min(qaveBand$Power))                            *2
qaveAlph       = qaveBand %>% filter(Freq == "alpha"   & Time <= 1 & Time > -1)
qaveBeta       = qaveBand %>% filter(Freq == "lowBeta" & Time <= 1 & Time > -1)
namemax = round(max(qaveBand$Power)/2, digits = 1)

p = ggplot(qaveAlph, aes(x = Time, y = Mean, group = Loc)) + 
  theme_Publication() +
  geom_hline(yintercept = 1:7, linetype = "33", color = "grey20") +
  geom_vline(xintercept = 0,   color = "grey40", alpha = 0.5) +
  geom_ribbon(data = qaveBeta,aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.65, fill = colorspace::lighten("#4ca5a5", .2, space = "HLS") ) +
  geom_ribbon(                aes(ymin = Mean - SE, ymax = Mean + SE), alpha = 0.25, fill = colorspace::darken("#cc4f00" ,.2, space = "HLS")) +
  geom_line(data = qaveBeta, size = 0.5, color = "#4ca5a5") +
  geom_line(                 size = 0.5, color = "#cc4f00") +
  scale_y_continuous(
    name = "Recording dipole (Depth)",
    # sec.axis = sec_axis(~ . %% 1 * (max(qaveBand$Power)/2), name = "Power (dB)") # Modular transformation
    sec.axis = sec_axis(~., breaks = seq(1,8), labels = c(0,namemax,0,namemax,0,namemax,0,namemax), name = "Power (dB)") 
  ) +
  theme(axis.title.y.right = element_text(angle = 90, vjust = 0.5))
  # geom_line(size = 1, data = qaverage %>% filter(pval < 0.05)) +
  # geom_line(size = 0.3, data = qaveBand %>% filter(abs(Power) > 0.3*(max(qaveBand$Power) - min(qaveBand$Power))), color = "red") +
  xlab("Time (s)") +
  scale_x_continuous(limits = c(-1, 1)) 
#  ggtitle(paste0("Spectral power accross lead depth")) 

cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/Grand_average_color.png'), 
                 plot = p, width = 21, height = 29.7, units = "cm")
if (save_to_svg) {
  if (!dir.exists(paste0(DataDir, 'Figures/Averages/SVG/'))) dir.create(paste0(DataDir, 'Figures/Averages/SVG/'))
  cowplot::ggsave2(filename = paste0(DataDir, 'Figures/Averages/SVG/Grand_average_color.svg'), 
                   plot = p, width = 21, height = 29.7, units = "cm")
}

























##### Figures correlation

DataDir    = 'C:/LustreSync/PPN/Regions1PPN/'
Project    = "PPN_GI"
Event      = "T0"
norm       = "ldNOR"
gaitfilename = c("C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx","C:/LustreSync/DATA/ResAPA_PPN.xlsx")

tfdata  = arrow::open_dataset(paste0(DataDir, "pq_wide/", Event , "_", norm, "/"))
query   = tfdata %>% collect() 

query %<>% 
  pivot_longer(
    cols = ends_with("0"),
    names_to = "Time",
    values_to = "Power"
  ) %>% 
  filter(!is.na(Power)) %>%
  mutate(Time = as.numeric(Time))

df_gait = read_gait_data(gaitfilename, "PPN_GI", drop_missing = T, keep_RT = F)
df_gait = augment_gait_w_pca(df_gait, keep_RT = F)
query %<>% join_tf_and_gait(df_gait, keep_RT = F)

# Alpha CnF noFOG RPC 2
timewindow = c(-0.15, -0.0)
freqband   = c(8, 8)
qlocal = query %>% filter(Meta_FOG == 1 & Loc == "CuN")
qlocal %<>% filter(Freq >= freqband[1] & Freq <= freqband[2] & Time >= timewindow[1] & Time <= timewindow[2])
qlocme = qlocal %>% group_by(index) %>%
  summarise(sd = sd(Power, na.rm=T), Power = mean(Power), count = n(), RPC.2 = mean(RPC.2), .groups = "drop")
ggscatter(qlocme, x = "Power", y = "RPC.2", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")


# Alpha CnF withFOG RPC 2
timewindow = c(0.4, 0.5)
freqband   = c(9,9)
qlocal = query %>% filter(Meta_FOG == 2 & Loc == "CuN")
qlocal %<>% filter(Freq >= freqband[1] & Freq <= freqband[2] & Time >= timewindow[1] & Time <= timewindow[2])
qlocme = qlocal %>% group_by(index) %>%
  summarise(sd = sd(Power, na.rm=T), Power = mean(Power), count = n(), RPC.2 = mean(RPC.2), .groups = "drop")
ggscatter(qlocme, x = "Power", y = "RPC.2", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")

# Highbeta PPN withFOG RPC 2
timewindow = c(0.8, 0.9)
freqband   = c(27,28)
qlocal = query %>% filter(Meta_FOG == 2 & Loc == "PPN")
qlocal %<>% filter(Freq >= freqband[1] & Freq <= freqband[2] & Time >= timewindow[1] & Time <= timewindow[2])
qlocme = qlocal %>% group_by(index) %>%
  summarise(sd = sd(Power, na.rm=T), Power = mean(Power), count = n(), RPC.2 = mean(RPC.2), .groups = "drop")
ggscatter(qlocme, x = "Power", y = "RPC.2", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")

# Beta PPN withFOG RPC 5
timewindow = c(-0.1, 0.05)
freqband   = c(25,35)
qlocal = query %>% filter(Meta_FOG == 2 & Loc == "PPN")
qlocal %<>% filter(Freq >= freqband[1] & Freq <= freqband[2] & Time >= timewindow[1] & Time <= timewindow[2])
qlocme = qlocal %>% group_by(index) %>%
  summarise(sd = sd(Power, na.rm=T), Power = mean(Power), count = n(), RPC.5 = mean(RPC.5), .groups = "drop")
ggscatter(qlocme, x = "Power", y = "RPC.5", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")


# Beta PPN noFOG RPC 5
timewindow = c(0.1, 0.2)
freqband   = c(18,20)
qlocal = query %>% filter(Meta_FOG == 1 & Loc == "PPN")
qlocal %<>% filter(Freq >= freqband[1] & Freq <= freqband[2] & Time >= timewindow[1] & Time <= timewindow[2])
qlocme = qlocal %>% group_by(index) %>%
  summarise(sd = sd(Power, na.rm=T), Power = mean(Power), count = n(), RPC.5 = mean(RPC.5), .groups = "drop")
ggscatter(qlocme, x = "Power", y = "RPC.5", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")