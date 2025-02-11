# Rapid overview of specific events
Type_of_trial = "neon"
  if (Type_of_trial == "freeforced") {
  filename = 'C:/Users/mathieu.yeche/Desktop/PERCEPT/P05/LFP/Report_Json_Session_Report_20231213T122757.json'  
  WindowStart = -3
  WindowEnd = 2
  LittleBaseline = TRUE
  freeforced = TRUE
  if (LittleBaseline) {
    BSLStart = 0
    BSLEnd   = 0
  }
} else if (Type_of_trial == "Catwalk") {
  filename = 'C:/Users/mathieu.yeche/Desktop/PERCEPT/P05/LFP/Report_Json_Session_Report_20231213T122659.json'  
  WindowStart = -0.5
  WindowEnd = 3
  LittleBaseline = TRUE
  freeforced = FALSE
  if (LittleBaseline) {
    BSLStart = -0.6
    BSLEnd   = -1.6
  }
} else if (Type_of_trial == "neon")  {
  filename = 'C:/Users/mathieu.yeche/Desktop/PERCEPT/P05/LFP/Report_Json_Session_Report_20231213T122826.json'  
  WindowStart = 0
  WindowEnd = 0
  LittleBaseline = TRUE
  if (LittleBaseline) {
    BSLStart = -0.6
    BSLEnd   = -1.6
  }
}


# Load the data
LFP_name = str_replace(filename, '.json', '_LFP_transformed.parquet')
tim_name = str_replace(filename, '.json', '_LFP_timing.csv');
VRt_name = str_replace(filename, '.json', '_helmet.xlsx');

LFP = arrow::read_parquet(LFP_name)
tim = vroom::vroom(tim_name, delim = ';', col_names = c('time'))
VRt = readxl::read_xlsx(VRt_name)

# Chop the TF
p_1 = list()
p_0 = list()
df_0 = list()
df_1 = list()
if(Type_of_trial != "neon") {
  for (i in 1:nrow(VRt)) {
    # found in the tim the value closest to VRt$time[i]
    windows_start = which.min(abs(tim$time - VRt$time[i] - WindowStart))
    windows_end   = ifelse(freeforced,windows_start+178, which.min(abs(tim$time - VRt$time[i] - WindowEnd)))
    data_local    = LFP[windows_start:windows_end,] %>% 
      mutate(Time = (seq(from = WindowStart, to = WindowEnd, by = 0.028))) %>% 
      pivot_longer(cols = -Time, names_to = 'Freq', values_to = 'Value') %>%
      mutate(Freq = readr::parse_number(Freq))

    if (LittleBaseline) {
      bsl_start = ifelse(freeforced,1000,  which.min(abs(tim$time - VRt$time[i] - BSLStart)))
      bsl_end   = ifelse(freeforced,19500, which.min(abs(tim$time - VRt$time[i] - BSLEnd)))
      data_bsl      = LFP[bsl_start:bsl_end,] %>% 
        mutate(Time = 1) %>%
        summarize_all(mean) %>%
        pivot_longer(cols = -Time, names_to = 'Freq', values_to = 'Value') %>%
        mutate(Freq = readr::parse_number(Freq))
      
      data_local %<>% left_join(data_bsl, by = 'Freq') %>%
        mutate(Value = 10*log10(Value.x / Value.y)) %>%
        select(-Value.x, -Value.y, -Time.y) %>%
        rename(Time = Time.x)
    }

  plotlocal = plottf2(data_local, "Value", limits = c(-12,12), palette = 'pals::jet') + geom_vline(xintercept = 0, linetype = 'dashed') + ggtitle(paste('TF ', VRt$sceneName[i],' trial:', VRt$trial[i])) + theme_minimal()
  
  if (VRt$sceneName[i] == "catwalk" || VRt$sceneName[i] == "free") {
    p_1[[length(p_1)+1]] = plotlocal
    df_1[[length(df_1)+1]] = data_local
  } else {
    p_0[[length(p_0)+1]] = plotlocal
    df_0[[length(df_0)+1]] = data_local
  }
} 
} else {
  # Neon
  for (i in 1:((nrow(VRt)-3)/2)) {
    if (i == 1 & filename == 'C:/Users/mathieu.yeche/Desktop/PERCEPT/P05/LFP/Report_Json_Session_Report_20231213T122826.json') next
    WindowStart   = VRt$time[2*i+1]
    WindowEnd     = VRt$time[2*i+2]
    windows_start = which.min(abs(tim$time - WindowStart))
    windows_end   = which.min(abs(tim$time - WindowEnd))
    data_local    = LFP[windows_start:windows_end,] %>% 
        mutate(Time = (seq(from = 0, to = ((windows_end-windows_start) * 0.028), by = 0.028))) %>% 
        pivot_longer(cols = -Time, names_to = 'Freq', values_to = 'Value') %>%
        mutate(Freq = readr::parse_number(Freq))

      if (LittleBaseline) {
        bsl_start = which.min(abs(tim$time - VRt$time[2*i+1] - BSLStart))
        bsl_end   = which.min(abs(tim$time - VRt$time[2*i+1] - BSLEnd))
      # classic - as above from here
        data_bsl      = LFP[bsl_start:bsl_end,] %>% 
          mutate(Time = 1) %>%
          summarize_all(mean) %>%
          pivot_longer(cols = -Time, names_to = 'Freq', values_to = 'Value') %>%
          mutate(Freq = readr::parse_number(Freq))
        
        data_local %<>% left_join(data_bsl, by = 'Freq') %>%
          mutate(Value = 10*log10(Value.x / Value.y)) %>%
          select(-Value.x, -Value.y, -Time.y) %>%
          rename(Time = Time.x)
      }
    
    # Change here
    if (LittleBaseline) limitsplot = c(-12,12) else limitsplot = c(-0.2,2)
    plotlocal = plottf2(data_local, "Value", limits = limitsplot, palette = 'pals::jet') + geom_vline(xintercept = 0, linetype = 'dashed') + ggtitle(paste('TF trial: ', VRt$Trial[2*i+1])) + theme_minimal()
    
    p_0[[length(p_0)+1]]   = plotlocal
    df_0[[length(df_0)+1]] = data_local
  }
}

# Display the results per trial
plot0 = p_0 %>% patchwork::wrap_plots() + plot_layout(guides = "collect") 
plot1 = p_1 %>% patchwork::wrap_plots() + plot_layout(guides = "collect") 
plot1
plot0

# Display the global results 
if (Type_of_trial == "Catwalk") df_0[[9]] = NULL # (artefact)
dfg_0 = df_0 %>% bind_rows() %>% group_by(Time, Freq) %>% summarize(Value = mean(Value))
dfg_1 = df_1 %>% bind_rows() %>% group_by(Time, Freq) %>% summarize(Value = mean(Value))

  ## Global model
# dfg_both = df_0 %>% bind_rows() %>% mutate(Condition = 0) %>% bind_rows(df_1 %>% bind_rows() %>% mutate(Condition = 1))
# dfg_both = mutate(dfg_both, Condition = as.factor(Condition), Freq = as.factor(Freq), Time = as.factor(Time))
# model = lm(Value ~ Condition:Freq:Time, data = dfg_both)
# pairwise = emmeans::emmeans(model, ~ Condition | Freq:Time)
plot0_global = plottf2(dfg_0, "Value", limits = c(-3,3), palette = 'pals::jet') + geom_vline(xintercept = 0, linetype = 'dashed') + ggtitle(ifelse(freeforced,'TF global free','TF global catwalk')) + theme_Publication()
plot1_global = plottf2(dfg_1, "Value", limits = c(-3,3), palette = 'pals::jet') + geom_vline(xintercept = 0, linetype = 'dashed') + ggtitle(ifelse(freeforced,'TF global forced','TF global patio')) + theme_Publication()

dfg_diff = dfg_1 %>% left_join(dfg_0, by = c('Time', 'Freq')) %>% mutate(Value = Value.x - Value.y) %>% select(-Value.x, -Value.y)
plot_diff = plottf2(dfg_diff, "Value", limits = c(-3,3), palette = 'pals::kovesi.diverging_linear_bjy_30_90_c45') + geom_vline(xintercept = 0, linetype = 'dashed') + ggtitle('TF diff') + theme_Publication()

# Display the results
plot_g = plot0_global + plot1_global + plot_diff + plot_layout(guides = "collect") 
plot_g

# End