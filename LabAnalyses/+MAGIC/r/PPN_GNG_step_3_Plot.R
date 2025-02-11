#############################################################################################
##                                                                                         ##
##                                Step 3 - Plot the TF Maps                                ##
##                                                                                         ##
#############################################################################################
print("This code is modified from MY's MAGIC_GNG_step_3 as of August 2024")

## Input Parameters ########
DataDir    = 'Z:/PPN/Regions1PPN/'
DataDir    = 'C:/LustreSync/PPN/Regions1PPN/'
Project    = "PPN_GI"
todo_avg   = F 
todo_emean = TRUE
todo_trend = T
todo_auto  = T 

## Cosmetic Parameters ########
Freq2fit    = 1:50
time_window = c(-1, 1)
save_to_svg = F
PaletteMain = "pals::jet"     # "pals::parula" or "jet"
PaletteDiff = "pals::kovesi.diverging_linear_bjy_30_90_c45"
DarkMode    = F
pval_breaks = c(0.05) # c(0.05,0.01,0.001)
PlotSizeWidth  = 40
PlotSizeHeight = 20

#############################################################################################
## Plot Parameters ##########################################################################

#  ATTENTION : BIEN REMPLIR ICI TOUS LES PARAMETRES
#              Dupliquer au besoin les params plots

params_plot = NULL ; j = 1



if (grepl("/Regions/" , DataDir)) {

params_plot[[j]] = list(Event           = "T0",
                        norm            = "ldNOR",
                        FileName        = "model_PPN_Null_emm",
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
  
  todo_vanilla = T
  if (todo_vanilla) {
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
  }
  
  
  
  todo_margcond = T
  if (todo_margcond) { 
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPN_nocond_Null_emm",
                            title           = "region_nomed_null",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = NULL,
                            Selection_level = NULL
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPN_nocond_RPC.1_at_0_emm",
                            title           = "region_nomed_RPC1",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = NULL,
                            Selection_level = NULL
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPN_nocond_RPC.2_at_0_emm",
                            title           = "region_nomed_RPC2",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = NULL,
                            Selection_level = NULL
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPN_nocond_RPC.3_at_0_emm",
                            title           = "region_nomed_RPC3",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = NULL,
                            Selection_level = NULL
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPN_nocond_RPC.4_at_0_emm",
                            title           = "region_nomed_RPC4",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = NULL,
                            Selection_level = NULL
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPN_nocond_RPC.5_at_0_emm",
                            title           = "region_nomed_RPC5",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = NULL,
                            Selection_level = NULL
    ) ; j = j + 1
  
  }
  
  
  
  todo_emg_classic = T
  if (todo_emg_classic) {
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Null_emm",
                            title           = "EMG_off_null",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Null_emm",
                            title           = "EMG_on_null",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Soleus_at_0_emm",
                            title           = "EMG_off_alphaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Soleus_at_0_emm",
                            title           = "EMG_on_alphaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Soleus_at_0_emm",
                            title           = "EMG_off_betaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Soleus_at_0_emm",
                            title           = "EMG_on_betaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Tibialis_at_0_emm",
                            title           = "EMG_off_betaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Tibialis_at_0_emm",
                            title           = "EMG_on_betaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Tibialis_at_0_emm",
                            title           = "EMG_off_alphaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Tibialis_at_0_emm",
                            title           = "EMG_on_alphaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1    
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Soleus_at_0_emm",
                            title           = "EMG_off_envelopSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Soleus_at_0_emm",
                            title           = "EMG_on_envelopSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1    
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Tibialis_at_0_emm",
                            title           = "EMG_off_envelopTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF")
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Tibialis_at_0_emm",
                            title           = "EMG_on_envelopTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON")
    ) ; j = j + 1
    
    
  }
  
  
  todo_emg_per_ipsicontra = T
  if (todo_emg_per_ipsicontra) {
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Null_emm",
                            title           = "EMG_side_off_null",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Null_emm",
                            title           = "EMG_side_on_null",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Soleus_at_0_emm",
                            title           = "EMG_side_off_alphaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Soleus_at_0_emm",
                            title           = "EMG_side_on_alphaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Soleus_at_0_emm",
                            title           = "EMG_side_off_betaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Soleus_at_0_emm",
                            title           = "EMG_side_on_betaSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Tibialis_at_0_emm",
                            title           = "EMG_side_off_betaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_BetaEMG_Tibialis_at_0_emm",
                            title           = "EMG_side_on_betaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Tibialis_at_0_emm",
                            title           = "EMG_side_off_alphaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_AlphaEMG_Tibialis_at_0_emm",
                            title           = "EMG_side_on_alphaTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1    
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Soleus_at_0_emm",
                            title           = "EMG_side_off_envelopSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Soleus_at_0_emm",
                            title           = "EMG_side_on_envelopSoleus",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1    
    
    
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Tibialis_at_0_emm",
                            title           = "EMG_side_off_envelopTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("OFF"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    params_plot[[j]] = list(Event           = "T0",
                            norm            = "ldNOR",
                            FileName        = "model_PPNxEMG_Enveloppe_Tibialis_at_0_emm",
                            title           = "EMG_side_on_envelopTibialis",
                            Var1_name       = "Meta_FOG",
                            Var2_levels     = c("PPN", "CuN"),
                            Var2_name       = "Loc",
                            Var1_levels     = c(1,2),
                            Selection_name  = "Condition",
                            Selection_level = c("ON"),
                            Selection_name2 = "Side_firststep_ipsi_contra"
    ) ; j = j + 1
    
    
  }
  
  
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
  Grid_Size_local = 9
  limits = NULL
  if (is.null(params_plot[[i]]$Var2_name)) Grid_Size_local = 3
  if (length(params_plot[[i]]$Var1_levels) == 3) Grid_Size_local = 15
  if (!dir.exists(paste0(DataDir, 'Figures/'         ))) dir.create(paste0(DataDir, 'Figures/'         ))
  if (!dir.exists(paste0(DataDir, 'Figures/', Project))) dir.create(paste0(DataDir, 'Figures/', Project))
  
  if (todo_emean | todo_trend) {
    df = qs::qread(paste0(DataDir, 'model_fits/', Project, "_", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "/",params_plot[[i]]$FileName,".qs"))
    # df %<>% mutate(p.value.a = p.adjust(p.value,method="fdr"))
    # pval_col = "p.value.a"
    pval_col = "TOCORRECT_p.value"
  }
  
  if (todo_auto & ("emslope" %in% names(df))) todo_emean = F else todo_emean = T
  if (todo_auto & ("emslope" %in% names(df))) todo_trend = T else todo_trend = F
  
  if (todo_emean) {
    ## Emmean      ########
    list.df = list()
    if (!is.null(params_plot[[i]]$Selection_name2)) {
      Selection_name2 = params_plot[[i]]$Selection_name2
      SelectLevels = unique(as.character(df[[Selection_name2]]))
      SelectLevels = SelectLevels[!is.na(SelectLevels)]
      for (subselect in seq_along(SelectLevels)) {
        list.df[[subselect]] = df %>% filter((!!sym(Selection_name2) == SelectLevels[subselect] | str_count(contrast, SelectLevels[subselect]) == 2))
      }
      limits = c(-50,50)
    } else list.df = list(df)
      
    for(subselect in seq_along(list.df)) {
        df_local = list.df[[subselect]]
        estimator = "emmean"
        p = suppressMessages(plot_tf_Variable(df_local,
                                              est = estimator,
                                              pval_col = pval_col,
                                              title = paste0(Project, " - ", params_plot[[i]]$Event, " " , params_plot[[i]]$norm, " : ", params_plot[[i]]$title, " ", ifelse(length(list.df)==1,"", SelectLevels[subselect]), " - ", estimator),
                                              Var1_name   = params_plot[[i]]$Var1_name,
                                              Var1_levels = params_plot[[i]]$Var1_levels,
                                              Var2_name   = params_plot[[i]]$Var2_name,
                                              Var2_levels = params_plot[[i]]$Var2_levels,
                                              Selection_name  = params_plot[[i]]$Selection_name,
                                              Selection_level = params_plot[[i]]$Selection_level,
                                              pval_breaks = pval_breaks,
                                              Tag = NULL,
                                              Grid_Size = Grid_Size_local,
                                              limits = limits,
                                              PaletteMain = PaletteMain,
                                              PaletteDiff = PaletteDiff,
                                              norm = params_plot[[i]]$norm,
                                              DarkMode = (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011"))
        ))
        
        if (length(list.df) == 1) plotname_local = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_emmeans")
        else plotname_local = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_", params_plot[[i]]$Selection_name2, "_", SelectLevels[subselect], "_emmeans")
        
        if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) p = p + theme_dark_dark_classiclegend() 
        if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) plotname_local = paste0(plotname_local, "_dark")
        
        cowplot::ggsave2(filename = paste0(plotname_local, ".png"), 
                         plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
        if (save_to_svg) {
          if (!dir.exists(paste0(DataDir, 'Figures/', Project, '/SVG/'))) dir.create(paste0(DataDir, 'Figures/', Project, '/SVG/'))
          cowplot::ggsave2(filename = paste0(plotname_local, ".svg"), 
                           plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
      }
    }
  }
  
  if (todo_trend & !(grepl("Null", params_plot[[i]]$FileName))) {
    ## Emtrend      ########
    list.df = list()
    if (!is.null(params_plot[[i]]$Selection_name2)) {
      Selection_name2 = params_plot[[i]]$Selection_name2
      SelectLevels = unique(as.character(df[[Selection_name2]]))
      SelectLevels = SelectLevels[!is.na(SelectLevels)]
      for (subselect in seq_along(SelectLevels)) {
        list.df[[subselect]] = df %>% filter((!!sym(Selection_name2) == SelectLevels[subselect] | str_count(contrast, SelectLevels[subselect]) == 2))
      }
      limits = c(-50,50)
    } else list.df = list(df)
    
    for(subselect in seq_along(list.df)) {
      df_local = list.df[[subselect]]
      estimator = "emslope"
      p = suppressMessages(plot_tf_Variable(df_local,
                                            est = estimator,
                                            pval_col = pval_col,
                                            title = paste0(Project, " - ", params_plot[[i]]$Event, " " , params_plot[[i]]$norm, " : ", params_plot[[i]]$title, " ", ifelse(length(list.df)==1,"", SelectLevels[subselect]), " - ", estimator),
                                            Var1_name   = params_plot[[i]]$Var1_name,
                                            Var1_levels = params_plot[[i]]$Var1_levels,
                                            Var2_name   = params_plot[[i]]$Var2_name,
                                            Var2_levels = params_plot[[i]]$Var2_levels,
                                            Selection_name  = params_plot[[i]]$Selection_name,
                                            Selection_level = params_plot[[i]]$Selection_level,
                                            pval_breaks = pval_breaks,
                                            Tag = NULL,
                                            Grid_Size = Grid_Size_local,
                                            limits = limits,
                                            PaletteMain = PaletteMain,
                                            PaletteDiff = PaletteDiff,
                                            norm = params_plot[[i]]$norm,
                                            DarkMode = (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011"))
      ))
      
      if (length(list.df) == 1) plotname_local = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_emtrends")
      else plotname_local = paste0(DataDir, 'Figures/', Project, "/", params_plot[[i]]$Event, "_" , params_plot[[i]]$norm, "_",params_plot[[i]]$title, "_", params_plot[[i]]$Selection_name2, "_", SelectLevels[subselect], "_emtrends")
      
      if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) p = p + theme_dark_dark_classiclegend() 
      if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) plotname_local = paste0(plotname_local, "_dark")
      
      cowplot::ggsave2(filename = paste0(plotname_local, ".png"), 
                       plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
      if (save_to_svg) {
        if (!dir.exists(paste0(DataDir, 'Figures/', Project, '/SVG/'))) dir.create(paste0(DataDir, 'Figures/', Project, '/SVG/'))
        cowplot::ggsave2(filename = paste0(plotname_local, ".svg"), 
                         plot = p, width = PlotSizeWidth, height = PlotSizeHeight, units = "cm")
      }
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
  print(paste0("Figure ", i, " / ", length(params_plot), "  : ", params_plot[[i]]$title))
}

## Sortie           ########

if (todo_avg) print("It is highly recommended to run : rm(query);gc()    ")

print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")
