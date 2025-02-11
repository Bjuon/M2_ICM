#############################################################################################
##                                                                                         ##
##                               Step 3 - Plots the TF Maps                                ##
##                                                                                         ##
#############################################################################################

## Input Parameters ########
DataDir    = 'Z:/Stats/'
Project    = "GNG_STN"
todo_avg   = F 
todo_emean = TRUE
todo_trend = TRUE

## Cosmetic Parameters ########
Freq2fit    = 1:100
time_window = c(-1, 1)
save_to_svg = TRUE
PaletteMain = "pals::jet"     # "pals::parula" or "jet"
PaletteDiff = "pals::kovesi.diverging_linear_bjy_30_90_c45"
DarkMode    = TRUE
PlotSizeWidth  = 20
PlotSizeHeight = 20

#############################################################################################
## Plot Parameters ##########################################################################

#  ATTENTION : BIEN REMPLIR ICI TOUS LES PARAMETRES
#              Dupliquer au besoin les params plots

params_plot = NULL ; j = 1




params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_CI_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "off_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-AS.SM_Null_at_0_emm_marg_FOG",
                        title           = "on_IN_loc",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "off_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "on_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "off_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "on_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "off_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "on_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "off_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGi.n-STN_Null_at_0_emm_marg_loc",
                        title           = "on_IN_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOi", "NoGO"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1




params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_Null_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



if (todo_trend) {
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "ldNOR",
                          FileName        = "model_GNGi.n-AS.SM_RT_at_0_emm_marg_FOG",
                          title           = "off_IN_loc_RT",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOi", "NoGO"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "ldNOR",
                          FileName        = "model_GNGi.n-AS.SM_RT_at_0_emm_marg_FOG",
                          title           = "off_IN_loc_RT",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOi", "NoGO"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "off_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "on_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "off_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "on_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "off_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "on_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "off_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-AS.SM_RPC.1_at_0_emm_marg_FOG",
                          title           = "on_CI_loc_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Loc",
                          Var2_levels     = c("AS","SM"),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "off_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "on_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "off_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "FIX",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "on_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "off_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "ldNOR",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "on_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  
  params_plot[[j]] = list(Event           = "CUE",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "off_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("OFF")
  ) ; j = j + 1
  
  
  
params_plot[[j]] = list(Event           = "CUE",
                          norm            = "RAW",
                          FileName        = "model_GNGc.i-STN_RPC.1_at_0_emm_marg_loc",
                          title           = "on_CI_allSTN_RPC.1",
                          Var1_name       = "GoNogo",
                          Var1_levels     = c("GOc", "GOi"),
                          Var2_name       = "Meta_FOG",
                          Var2_levels     = c(0,1),
                          Selection_name  = "Condition",
                          Selection_level = c("ON")
  ) ; j = j + 1
  
  



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.2_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.2_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.2",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1

  
  
  


params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.3_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.3_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.3",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1





params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.4_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.4_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.4",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1




params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RPC.5_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RPC.5_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RPC.5",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1




params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "off_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-AS.SM_RT_at_0_emm_marg_FOG",
                        title           = "on_CI_loc_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Loc",
                        Var2_levels     = c("AS","SM"),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "FIX",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "ldNOR",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("ON")
) ; j = j + 1


params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "off_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
                        Selection_name  = "Condition",
                        Selection_level = c("OFF")
) ; j = j + 1



params_plot[[j]] = list(Event           = "CUE",
                        norm            = "RAW",
                        FileName        = "model_GNGc.i-STN_RT_at_0_emm_marg_loc",
                        title           = "on_CI_allSTN_RT",
                        Var1_name       = "GoNogo",
                        Var1_levels     = c("GOc", "GOi"),
                        Var2_name       = "Meta_FOG",
                        Var2_levels     = c(0,1),
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
  if (is.null(params_plot[[i]]$Var2_name)) Grid_Size_local = 3
  
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
    
    if (!dir.exists(paste0(DataDir, 'Figures/', Project))) dir.create(paste0(DataDir, 'Figures/', Project))
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
    
    if (!dir.exists(paste0(DataDir, 'Figures/', Project))) dir.create(paste0(DataDir, 'Figures/', Project))
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
