
batch_fitter = function(params) {
  if (!dir.exists(params[["pq_path"]]))   {dir.create(params[["pq_path"]])}
  if (!dir.exists(params[["save_path"]])) {dir.create(params[["save_path"]])}
  
  freqs_to_fit    = params[["freqs_to_fit"]]
  time_window     = params[["time_window"]]
  locs_to_include = params[["locs_to_include"]]
  FOG_to_include  = params[["FOG_to_include"]]
  GNG_to_include  = params[["GNG_to_include"]]
  DOPA_to_include = params[["DOPA_to_include"]]
  remove_artifacts<- params[["remove_artifacts"]]
  param_sets      = params[["param_sets"]]
  keep_RT = ifelse(((params[["Project"]] == "GNG_STN") | (params[["Project"]] == "GNG_PPN")), TRUE, FALSE)
  
  tfdata  = arrow::open_dataset(params[["pq_path"]])
  df_gait = read_gait_data(params[["gait_data_file"]], params[["Project"]], drop_missing = T, keep_RT = keep_RT)
  df_gait = augment_gait_w_pca(df_gait, keep_RT = keep_RT)
  if (!is.null(params[["EMG_file"]])) EMG_data = read_emg_data(params[["EMG_file"]], zscore = T)
  
  # timebins are in wide format, with names indicating bin centers
  # create a vector of names to drop when loading data
  cnames = tfdata$schema$names
  time_col_names = cnames[str_ends(cnames, "0")]
  times = time_col_names %>% as.numeric()
  ind = times < time_window[1] | times > time_window[2]
  times_to_drop = time_col_names[ind]
  
  if (FOG_to_include[1]  == "all") FOG_to_include  = tfdata %>% distinct(Meta_FOG)  %>% collect() %>% pull(.)
  if (locs_to_include[1] == "all") locs_to_include = tfdata %>% distinct(Loc)       %>% collect() %>% pull(.) 
  if (GNG_to_include[1]  == "all") GNG_to_include  = tfdata %>% distinct(GoNogo)    %>% collect() %>% pull(.)
  if (DOPA_to_include[1] == "all") DOPA_to_include = tfdata %>% distinct(Condition) %>% collect() %>% pull(.)
  
  DF = NULL
  for (f in freqs_to_fit) {
    MeanFreq = ifelse(params[["Bands_Averaging"]],(params[["maxFreq_Bands"]][f] + params[["minFreq_Bands"]][f]) / 2, f ) 
    
    alert = 0 ; max25 = 0
    for (p in param_sets) {
      if (!params[["Replace_if_already_existing"]] & file.exists(paste0(params[["save_path"]], "model_", p["model_id"], "_", p["pc"],"_Freq_", MeanFreq, ".qs"))) alert = alert+1
      if (grepl("max25", p["model_id"])) max25 = max25+1
    }
    if ((max25 != length(param_sets)) & max25 != 0) ErrorCanNotHandlePartialMax25
    MaxTrial = ifelse(max25 == length(param_sets), 25, 9999)
    
    if ((params[["Replace_if_already_existing"]] == TRUE ) || (alert != length(param_sets))) {
      
      if (params[["Bands_Averaging"]]) {
        minFreq = params[["minFreq_Bands"]][f] 
        maxFreq = params[["maxFreq_Bands"]][f]
        query = tfdata %>% 
          select(-all_of(times_to_drop)) %>%
          filter(Freq >= minFreq & Freq <= maxFreq) %>%
          filter(GoNogo %in% GNG_to_include) %>%
          filter(Loc %in% locs_to_include) %>%
          filter(Meta_FOG %in% FOG_to_include) %>%
          filter(Condition %in% DOPA_to_include) %>%
          filter(TrialNum <= MaxTrial) %>%
          collect() 
      } else {
        query = tfdata %>% 
          select(-all_of(times_to_drop)) %>%
          filter(Freq == f) %>%
          filter(GoNogo %in% GNG_to_include) %>%
          filter(Loc %in% locs_to_include) %>%
          filter(Meta_FOG %in% FOG_to_include) %>%
          filter(Condition %in% DOPA_to_include) %>%
          filter(TrialNum <= MaxTrial) %>%
          collect()
      }
      query %<>% 
        mutate(Side_channel = ifelse(stringr::str_detect(Channel, "D"), "R", "L")) %>%
        mutate(Side_firststep_ipsi_contra = ifelse(Side_channel==Side_firststep, "ipsi", "contra")) %>%
        mutate(Loc = as.factor(Loc),
               Condition = as.factor(Condition),
               GoNogo = as.factor(GoNogo),
               Side_channel = as.factor(Side_channel),
               Side_firststep_ipsi_contra = as.factor(Side_firststep_ipsi_contra),
               Meta_FOG = as.factor(Meta_FOG))
      
      if (query$Loc[1] == query$Channel[1]) { # PPN study                                 # Quick look up
        if (all(query$Loc == query$Channel)) {                                            # Complete verif
          query$Loc = as.numeric(substr(as.character(query$Loc), 1, 1))
        } else print("Error in channel determination, unexpected behavior")
      }
      
      query %<>% 
        pivot_longer(
          cols = ends_with("0"),
          names_to = "Time",
          values_to = "Power"
        ) %>% 
        filter(!is.na(Power)) %>%
        mutate(Time = as.numeric(Time))
      
      if (params[["Bands_Averaging"]]) {
        query %<>% 
          group_by(Loc, Protocol, Condition, GoNogo, TrialNum, Meta_FOG, Channel, Side_firststep, Subject, Side_channel, Side_firststep_ipsi_contra, Time) %>%
          summarise(Power = median(Power))
        query$Freq = mean(c(minFreq, maxFreq))
      }
      
      if (remove_artifacts)
        query = global_remove_artifacts(query, verbose = F)
      
      if ((param_sets[[1]]["pc"] != "Null") | (length(param_sets) > 1)) {
        query = join_tf_and_gait(query, df_gait, keep_RT = keep_RT)
        if (!is.null(params[["EMG_file"]])) {
          query %<>% left_join(EMG_data, by = c("Subject", "Condition", "TrialNum", "Time", "Side_channel"))
          query %<>% mutate(across(contains("Tibialis"), ~ if_else(Side_firststep_ipsi_contra == "ipsi", NA, .))) # Contralateral STN to the muscle !
          print("Only ipsilateral muscle kept for Tibialis") # Contralateral STN !!!
        }
      }
      
      query %<>%
        group_by(Time) %>%
        nest(data = -c(Freq, Time)) %>%
        ungroup()
      
      print(unique(query$Freq))
      
      for (p in param_sets) {
        if ((params[["Replace_if_already_existing"]] == TRUE ) | !((p["pc"] == "RT") & ("NoGO" %in% GNG_to_include)) | (!file.exists(paste0(params[["save_path"]], "model_", p["model_id"], "_", p["pc"],"_Freq_", unique(query$Freq), ".qs")))) {
          
          print(paste0(p["model_id"], "_", p["pc"],"_Freq_", unique(query$Freq)))
          
          query %<>% mutate(fit = future_map(data, fitfunc, p, verbose=F, .progress = T))
          df_save = query %>% select(-data)
          
          fname = paste0(params[["save_path"]], "model_", p["model_id"], "_", p["pc"],"_Freq_", unique(query$Freq))
          qs::qsave(df_save, paste0(fname, ".qs"))
          if (params[["Export_in_RData"]] == TRUE) {
            save(df_save, file = paste0(fname, ".RData"))
          }
          
          rm("df_save")
        }
      }
    }
    
    rm("query")
  }
  return("Done")
}

fitfunc = function(df, 
                    p,
                   verbose = T
) {
  model_id = p["model_id"]
  pc =  p["pc"] # pass in empty string "" to ignore PC
  fe =  p["fe"]
  re =  p["re"]
  
  control = lmerControl(
    calc.derivs = T,
    optimizer="nloptwrap", 
    optCtrl = list(algorithm = "NLOPT_LN_BOBYQA")
  )
  
  if (model_id %in% c("1", 1)) {
    fe = "Power ~ Loc*Condition*Meta_FOG*"
    re = "+ (1|Subject/Channel)"
  } else if (model_id %in% c("2", 2)) {
    fe = "Power ~ Loc*Condition*Meta_FOG*"
    re = "+ (1|Subject/Channel) + (1|Subject:Condition)"
    # re = "+ (1|Subject) + (1|Subject:Side_channel) + (1|Subject:Side:Channel)
    #https://ourcodingclub.github.io/tutorials/mixed-models/#types
    #https://stats.stackexchange.com/questions/486832/lmer-model-syntax-for-a-combination-of-crossed-and-nested-random-effects
    #https://errickson.net/stats-notes/vizrandomeffects.html
    #https://www.muscardinus.be/statistics/nested.html
    #https://yury-zablotski.netlify.app/post/mixed-effects-models-2/#crossed-and-nested-at-the-same-time
    #https://stats.stackexchange.com/questions/272377/nested-crossed-random-effects-for-repeated-measures-data
    #https://www.muscardinus.be/statistics/levels.html
  } else if (model_id %in% c("3", 3)) {
    fe = "Power ~ GoNogo + Side_channel*Side_firststep_ipsi_contra + Loc*Condition*Meta_FOG*"
    re = "+ (1|Subject/Channel)"
  }
  if (!is.null(pc) & pc != "" & pc != "Null") {
    f = paste0(fe, pc, re)
  } else {
    if (stringr::str_ends(fe, "\\*$")) {fe = stringr::str_sub(fe, end = -2)}
    f = paste0(fe,     re)
    pc = NULL
  }
  
  if (!is.null(pc)) df %<>% drop_na(!!sym(pc))
  df %<>% drop_na(Power)
  df %<>% filter(!is.infinite(abs(Power)))
  
  
  if (verbose) m = lmer(f, data = df, control = control) else m = suppressMessages(lmer(f, data = df, control = control))
  # formula(fit) will extract formula
  return(m)
}

batch_emm = function(params
) {
  freqs_to_fit = params[["freqs_to_fit"]]
  emm_params = params[["emm_params"]]
  model_dir = params[["save_path"]]
  tag = params[["emm_params"]][["tag"]]
  
  DF = NULL
  
  for (f in freqs_to_fit) {
    # Load model
    fname = paste0(model_dir, "model_", emm_params[["model_id"]], "_", emm_params[["pc"]],"_Freq_", f, ".qs")
    # fname = paste0("model_fits/model_", emm_params["model_id"], "_", emm_params["pc"],"_Freq_", f, ".qs")
    df_fits = qread(fname, nthreads = 4)
    
    # EMMs
    df_fits %<>% mutate(emm = future_map(fit, emmfunc, emm_params, .progress = T))
    
    print(f)
    DF[[f]] = df_fits %>% select(-fit) %>% unnest(cols = emm)
  }
  
  if (is.null(emm_params[["at"]])) {
    fname = paste0(params[["save_path"]], "model_", 
                    emm_params[["model_id"]], "_", 
                    emm_params[["pc"]],
                    "_emm", tag, ".qs")
  } else {
    fname = paste0(params[["save_path"]], "model_", 
                    emm_params[["model_id"]], "_", 
                    emm_params[["pc"]], "_",
                    "at_", emm_params[["at"]],
                    "_emm", tag, ".qs")
  }
  
  qs::qsave(bind_rows(DF), fname)
  return(fname)

}

emmfunc = function(m,
                    params
) {
  specs = params[["specs"]]
  if (!is_formula(specs))
    specs = as.formula(specs)
  pc = params[["pc"]]
  at = params[["at"]]
  
  emm_options(lmer.df = "asymp")
  
  if (!is.null(at)) {
    l = list(var = at)
    names(l) = pc
    emm = suppressMessages(emmeans(m, specs, at = l))
  } else {
    emm = suppressMessages(emmeans(m, specs))
  }
  
  #https://aosmith.rbind.io/2019/04/15/custom-contrasts-emmeans/#using-at-for-simple-comparisons
  a = emm %>% 
    summary(infer = c(T,T), adjust = "none") %>% as_tibble()
  b = emm %>% pairs %>%
    summary(infer = c(T,T), adjust = "none") %>% as_tibble() %>%
    rename(emmean = estimate)
  
  if ((!is.null(pc)) & (pc != "") & (pc != "Null")) {
    emt = emtrends(m, specs, var = pc)
    c = emt %>% 
      summary(infer = c(T,T), adjust = "none") %>% as_tibble() %>%
      rename(emslope = paste0(pc, ".trend"))
    d = emt %>% pairs %>%
      summary(infer = c(T,T), adjust = "none") %>% as_tibble() %>%
      rename(emslope = estimate)
    
    df = a %>% bind_rows(b) %>% bind_rows(c) %>% bind_rows(d)
  } else {
    df = a %>% bind_rows(b)
  }
  
  return(df)
}

augment_gait_w_pca = function(df,
                              ncp = 5,
                              keep_RT = FALSE
) {
  if (keep_RT) {
    dfsave = df %>% dplyr::select(c(TrialName,real_t_reac))
    colnames(dfsave)[2] = "RT"
    df %<>% dplyr::select(-real_t_reac)
  }
  
  # Complete cases only
  df %<>% tidyr::drop_na()
  
  # Let's adjust the remaining temporal variable that differs between groups.
  df %<>%
    group_by(Group) %>%
    mutate(across(c("t_Vm"), ~scale(.x, scale = F))) %>%
    #mutate(across(quantvar_names, ~scale(.x, scale = F))) %>%
    ungroup()
  
  if (is.null(df$Indices)) {
    IndActive = which(!df$is_FOG)
    IndSup    = which( df$is_FOG)
  } else {
    df$Indices[which(df$is_FOG)] = FALSE
    IndActive  = which( df$Indices)
    IndSup     = which(!df$Indices)
    df %<>% select(-Indices)
  }
  
  qualvar_names = df %>% dplyr::select(Group:TrialName) %>% names()
  quantvar_names = df %>% dplyr::select(-all_of(qualvar_names)) %>% names()
  
  # Don't need to index active rows here since IndSup is passed to PCA
  df_pca = df %>% select(-TrialNum, -GoNogo, -Cote, -is_FOG, -Meta_FOG, -TrialName, -Subject2)
  res.pca = FactoMineR::PCA(df_pca, graph = F, scale.unit = T, ncp = ncp,
                             quali.sup = 1:4, ind.sup = IndSup)
  
  # Rotated scores
  # https://stackoverflow.com/questions/22761733/rotation-in-factominer-package
  # https://stats.stackexchange.com/questions/612/is-pca-followed-by-a-rotation-such-as-varimax-still-pca
  # https://gist.github.com/martinctc/6c46fbec5288e642fb47e9e5fa767722
  # https://stats.stackexchange.com/questions/59213/how-to-compute-varimax-rotated-principal-components-in-r
  rawLoadings     = res.pca$var$cor
  rotatedLoadings = varimax(rawLoadings)$loadings
  invLoadings     = t(pracma::pinv(rotatedLoadings))
  
  meanLocal = df[IndActive,] %>% select(quantvar_names) %>% summarise_all(mean, na.rm = T) 
  sd__Local = df[IndActive,] %>% select(quantvar_names) %>% summarise_all(sd, na.rm = T)
  for (var in quantvar_names) df[, var] = (df[, var] - as.numeric(meanLocal[var])) / as.numeric(sd__Local[var])
  
  scores           <- df[IndActive,] %>% select(quantvar_names) %>% as.matrix() %*% invLoadings
  colnames(scores) <- c("RPC.1", "RPC.2", "RPC.3", "RPC.4", "RPC.5")
  df1 <- df[IndActive,] %>% bind_cols(as_tibble(scores))
  
  scores           <- df[IndSup,] %>% select(quantvar_names) %>% as.matrix() %*% invLoadings
  colnames(scores) <- c("RPC.1", "RPC.2", "RPC.3", "RPC.4", "RPC.5")
  df2 <- df[IndSup,] %>% bind_cols(as_tibble(scores))
  
  df_ind = df1 %>% bind_rows(df2) %>%
    mutate(Factor = interaction(Condition, Pat_Foggeur, is_FOG))
  
  # Unrotated scores
  df_ind2 = (df[IndActive,] %>% bind_cols(res.pca$ind$coord %>% as_tibble())) %>%
    bind_rows(df[IndSup,] %>% bind_cols(res.pca$ind.sup$coord %>% as_tibble())) %>%
    select(TrialName, Dim.1:Dim.5) %>%
    rename(PC.1 = Dim.1, PC.2 = Dim.2, PC.3 = Dim.3, PC.4 = Dim.4, PC.5 = Dim.5)
  
  df_scores = df_ind %>% left_join(df_ind2, by = "TrialName")
  df_scores$RPC.5 = -df_scores$RPC.5
  print("RPC.5 is -RPC.5")
  
  if (keep_RT) df_scores = df_scores %>% left_join(dfsave, by = "TrialName")
  
  return(df_scores)
}

join_tf_and_gait = function(df_tf,
                            df_gait, 
                            keep_RT = FALSE,
                            forClassif = FALSE
) {
  df_gait %<>% mutate(
    Task = ifelse(
      GoNogo == "R", "fast",
      ifelse(
        GoNogo == "S", "spon",
        ifelse(
          GoNogo == "C", "GOc", 
          ifelse(
            GoNogo == "I", "GOi" , "NoGO"
          )
        )
      )
    )
  )
  df_gait %<>% mutate(
    index = 
      paste0(Subject2,
             Condition,
             TrialNum,
             "_",
             Task)
  )
  
  if (keep_RT) {
    df_gait %<>% select(index, starts_with("PC."), starts_with("RPC."), RT)
  } else if (forClassif) {
    df_gait %<>% select(index, t_APA, APA_antpost, APA_lateral, StepWidth, t_swing1, t_DA, t_swing2, Longueur_pas, V_swing1, Vy_FO1, Vm, t_Vm, VML_absolue, Cadence, VZmin_APA, V2, Diff_V)
  } else {
    df_gait %<>% select(index, starts_with("PC."), starts_with("RPC."))
  }
  
  df_tf %<>% mutate(index = 
                      paste0(sub(".*_", "", Subject),
                             Condition,
                             TrialNum,
                             '_',
                             GoNogo)
  )
  
  df_tf %<>% left_join(df_gait, by = "index")
  if (keep_RT & (sum(unique(df_tf$GoNogo == "NoGO")) > 0)) df_tf %<>% ImputeRTforNoGO()
  
  return(df_tf)
}


read_emg_data = function(EMG_file, verbose = T, zscore = F) {
  
  EMG_data = suppressMessages(suppressWarnings(vroom::vroom(EMG_file))) 
  
  if(verbose) print("Trial's numbers must be unique regardless of task (magic compatible, not gbmov or percept)")
  
  EMG_data %<>% 
    pivot_longer(
      cols = ends_with("0"),
      names_to = "Time",
      values_to = "Enveloppe"
    ) %>% 
    filter(!is.na(Enveloppe)) %>%
    mutate(Time = as.numeric(Time))
  
  EMG_data %<>% pivot_wider(names_from = Muscle, 
                            values_from = c(AlphaEMG, BetaEMG, Enveloppe),
                            id_cols = c(Patient, Condition, TrialNum, Time, EMG_Side))
  
  EMG_data$Side_channel = ifelse(EMG_data$EMG_Side == "R", "L", "R") # Décussation
  EMG_data$TrialNum     = as.numeric(EMG_data$TrialNum)
  
  EMG_data %<>% mutate(Subject = ifelse(nchar(Patient) == 3,
                                   paste0(substr(Patient,1,2), tolower(substr(Patient,3,3))),
                                   paste0(substr(Patient,1,2), tolower(substr(Patient,4,4)))),
                 .after = Patient) %>% 
    select(-EMG_Side) %>% select(-Patient)
  
  if (zscore) {
    EMG_loc_mean = EMG_data %>%
      select(c(AlphaEMG_Vastus, AlphaEMG_Tibialis, AlphaEMG_Soleus, BetaEMG_Vastus, BetaEMG_Tibialis, BetaEMG_Soleus, Enveloppe_Vastus, Enveloppe_Tibialis, Enveloppe_Soleus)) %>%
      summarise(across(everything(), ~mean(.x, na.rm = TRUE)))
    EMG_loc_sd = cbind(
      EMG_data %>%
        filter(Time == -0.98) %>%
        select(c(AlphaEMG_Vastus, AlphaEMG_Tibialis, AlphaEMG_Soleus, BetaEMG_Vastus, BetaEMG_Tibialis, BetaEMG_Soleus)) %>%
        summarise(across(everything(), ~sd(.x, na.rm = TRUE))),
      EMG_data %>%
        select(c(Enveloppe_Vastus, Enveloppe_Tibialis, Enveloppe_Soleus)) %>%
        summarise(across(everything(), ~sd(.x, na.rm = TRUE)))
    )
    EMG_data %<>% mutate(across(c(AlphaEMG_Vastus, AlphaEMG_Tibialis, AlphaEMG_Soleus, BetaEMG_Vastus, BetaEMG_Tibialis, BetaEMG_Soleus, Enveloppe_Vastus, Enveloppe_Tibialis, Enveloppe_Soleus), 
                    ~ (.x - EMG_loc_mean[[cur_column()]]) / EMG_loc_sd[[cur_column()]]))
  }
  
  return(EMG_data)
}

ImputeRTforNoGO = function(df_tf, BlocPseudoRandom = TRUE) {
  
  if (!BlocPseudoRandom) ErreurAImplementerdanslefutur
  
  cat("\n Imputing RT for NoGO")
  MinTime = min(df_tf$Time)
  MinFreq = min(df_tf$Freq)
  
  unique_combinations = df_tf %>%
    select(GoNogo, TrialNum, Condition, Subject, RT) %>%
    distinct()
  
  for (rownum in 1:length(df_tf$GoNogo)) {
    if (df_tf$GoNogo[rownum] == "NoGO" & df_tf$Time[rownum] == MinTime & df_tf$Freq[rownum] == MinFreq & is.na(df_tf$RT[rownum])) {
      LocCondition = df_tf$Condition[rownum]
      LocSubject   = df_tf$Subject[rownum]
      nT           = df_tf$TrialNum[rownum]
      RTGo  = c()
      
      if        (nT < 19) {GoIdx = c(11:18)
      } else if (nT < 27) {GoIdx = c(19:26)
      } else if (nT < 35) {GoIdx = c(27:34)
      } else if (nT < 43) {GoIdx = c(35:42)
      } else if (nT < 51) {GoIdx = c(43:50)
      } else {GoIdx = c(0)}
      
      for (i in GoIdx) {
        value = unique_combinations %>% filter(GoNogo == "GOi" & TrialNum == i & Condition == LocCondition & Subject == LocSubject) %>% pull(RT)
        RTGo  = c(RTGo, value)
      } 
      df_tf$RT[df_tf$TrialNum == nT & df_tf$Condition == LocCondition & df_tf$Subject == LocSubject] = mean(RTGo, na.rm = T)
      cat(".")
    }  
  }
  cat("\n\n")
  return(df_tf)
}

global_remove_artifacts = function(df_tf, verbose = T, mode = "pro") {
  
  if (mode == "std") {
    # ParkRouen_2020_11_30_GUg_ON_ All trials _75D
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "ON" & Channel == "75D"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkRouen_2020_11_30_GUg_ON_ All trials _75D"))
    
    # ParkRouen_2020_11_30_GUg_OFF_GOi_15_23G
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "OFF" & GoNogo == "GOi" & TrialNum == 15 & Channel == "23G"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkRouen_2020_11_30_GUg_OFF_GOi_15_23G"))
    
    # ParkPitie_2020_09_17_GAl_OFF_GOc_10_56D
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & GoNogo == "GOc" & TrialNum == 10 & Channel == "56D"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkPitie_2020_09_17_GAl_OFF_GOc_10_56D"))
    
    #ParkPitie_2020_09_17_GAl_OFF_GOc_10_25D
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & GoNogo == "GOc" & TrialNum == 10 & Channel == "25D"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkPitie_2020_09_17_GAl_OFF_GOc_10_25D"))
    
    # ParkPitie_2020_09_17_GAl_ON_GOi_35_75G
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & GoNogo == "GOi" & TrialNum == 35 & Channel == "75G"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkPitie_2020_09_17_GAl_ON_GOi_35_75G"))
    
    # ParkPitie_2020_09_17_GAl_ON_GOi_41_25D
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & GoNogo == "GOi" & TrialNum == 41 & Channel == "25D"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkPitie_2020_09_17_GAl_ON_GOi_41_25D"))
    
    # ParkPitie_2020_09_17_GAl_ON_GOi_41_25G
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & GoNogo == "GOi" & TrialNum == 41 & Channel == "25G"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkPitie_2020_09_17_GAl_ON_GOi_41_25G"))
    
    # ParkPitie_2020_09_17_GAl_ON_GOi_41_75G
    n_in = nrow(df_tf)
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & GoNogo == "GOi" & TrialNum == 41 & Channel == "75G"))
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. ParkPitie_2020_09_17_GAl_ON_GOi_41_75G"))
  
  } else if (mode == "pro") {
    
    n_in = nrow(df_tf)
    
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & TrialNum == 8 & Channel == "25D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & TrialNum == 9 & Channel == "25D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & TrialNum == 10& Channel == "25D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & TrialNum == 8 & Channel == "56D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & TrialNum == 9 & Channel == "56D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "OFF" & TrialNum == 10& Channel == "56D"))
    
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum %in% c(52, 60) & Channel == "25G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum %in% c(52, 53, 54, 59, 60) & Channel == "25D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum %in% c(52, 53, 54) & Channel == "56D"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum %in% c(53, 54, 56, 59, 60) & Channel == "75G"))
    
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum == 46 & Channel == "25G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum == 46 & Channel == "25D"))
    
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "OFF" & TrialNum == 15 & Channel == "23G"))
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "OFF" & TrialNum == 15 & Channel == "56G"))
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "OFF" & TrialNum == 15 & Channel == "75D"))
    
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "ON" & Channel == "75D"))
    
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "ON" & TrialNum == 60 & Channel == "23G"))
    
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "ON" & TrialNum  %in% c(24, 26, 31, 32, 43, 45, 48) & Channel == "23G"))
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "ON" & TrialNum  %in% c(24, 30, 31, 43, 48) & Channel == "47G"))
    df_tf %<>% filter(!(Subject == "GUg" & Condition == "ON" & TrialNum  %in% c(23, 24, 31, 32, 37, 39, 43) & Channel == "56G"))
    
    # MY ajout à selection MLW ("pro plus")
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 35 & Channel == "75G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 41))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 46 & Channel == "23G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 46 & Channel == "67G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 46 & Channel == "34G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 46 & Channel == "36G"))
    df_tf %<>% filter(!(Subject == "GAl" & Condition == "ON" & TrialNum  == 46 & Channel == "56G"))
    
    ### Max version 
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "23G" & TrialNum %in% c(4,6,7,8,9,13,15,18,19,37,39)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "23G" & TrialNum %in% c(32,31,20,54,53,52)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "23D" & TrialNum %in% c(56,59,53,51)))
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "34G" & TrialNum %in% c(3,4,59,6,9,11,12,13,16,18,24,30,31,32)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "34G" & TrialNum %in% c(31,54,52,53)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "34D" & TrialNum %in% c(10,3,51,53,54,56,59,60,15)))
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "42G" & TrialNum %in% c(4,54,56,59,6,60,7,8,9,11,12,13,15,16,18,19,23,24,31,32,37,43,45,48)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "42G" & TrialNum %in% c(46,1)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "42D" & TrialNum %in% c(4,51,53,54,56,59,60,15,32,46)))
    
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "56G" & TrialNum %in% c(4,54,9,12,13,26,45)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "56G" & TrialNum %in% c(53,54,59)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "56D" & TrialNum %in% c(3,4,54,6,60,7,8,9,12,13,15,16,18,19,23,24,26,31,32,39,45,48)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "56D" & TrialNum %in% c(15,31,32)))
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "67G" & TrialNum %in% c(3,4,54,6,7,8,9,12,13,16,18,19,24,26,31,32,37,43,45)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "67G" & TrialNum %in% c(1,4,53,54,59,20,32)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "67D" & TrialNum %in% c(4,12,43)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "67D" & TrialNum %in% c(2,4,54,32)))
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "75G" & TrialNum == 43))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "75G" & TrialNum %in% c(1,2,4,51,15)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "75D" & TrialNum %in% c(51,54,6)))
    
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "25G" & TrialNum %in% c(6,13,32,48)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "25D" & TrialNum %in% c(4,51,15,32,34)))
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "36G" & TrialNum %in% c(4,7,9,11,13,18,26,31,37)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "36G" & TrialNum %in% c(52,53,54,59)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "36D" & TrialNum %in% c(6,15,32)))
    
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GUg" & Channel == "47G" & TrialNum %in% c(3,6,60,9,11)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "47G" & TrialNum %in% c(1,54,15,46)))
    df_tf %<>% filter(!(Condition == "ON" & Subject == "GAl" & Channel == "47D" & TrialNum %in% c(2,54,60,15)))
    
    n_out = nrow(df_tf)
    
    if (verbose & (n_in - n_out > 0)) print("Removing artifacts - pro max")
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. May 7th, 2024 MLW selection + MY and MLW reselection"))
    
  } else if (mode == "ultra") {
    
    print("Removing artifacts - ultra")
    
    n_in = nrow(df_tf)
    df_tf %<>% 
      filter(!(Subject == "GUg" & Condition == "ON"))
    df_tf %<>% 
      filter(!(Subject == "GAl" & Condition == "ON"))
    
    n_out = nrow(df_tf)
    if (verbose & (n_in - n_out > 0)) print(paste0(n_in - n_out, " rows removed. All GAl & GUg"))
    
  } else if (mode == "None" | mode == "none" | mode == "null" | mode == "Null" | mode == "NULL" | mode == "no" | mode == "No" | mode == "NO" | mode == "n" | mode == "N" | mode == "0" | mode == 0 | mode == FALSE | mode == "false" | mode == "False") {
    print("Not removing artifacts")
  } else  {
    print("Not removing artifacts, mode not recognized")
  }
  
  return(df_tf)
}

read_gait_data = function(filename,
                           Projet = "GNG_STN",
                           drop_missing = TRUE,
                           drop_vars = "brian",
                           keep_RT = FALSE
) {
  if (Projet == "PPN_GI") {
    df_supp = suppressMessages(
      readxl::read_xlsx(filename[2], sheet = 1,
                        col_types = c("text", "numeric", "text",                                      "text", "text", "text", "text",                                    "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                      "numeric", "numeric", "numeric",                                     "numeric", "numeric", "numeric",                                      "logical", "logical", "numeric"
                        )
      )
    )
    filename = filename[1]
  }
  df = suppressMessages(
    readxl::read_xlsx(filename, sheet = 1,
                      col_types = c("text", "numeric", "text",
                                    "text", "text", "text", "text",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "numeric", "numeric", "numeric",
                                    "logical", "logical", "numeric"
                      )
    )
  )
  
  if (Projet == "PPN_GI") {
    df$Indices = TRUE
    df_supp$Indices = FALSE
    df = rbind(df, df_supp)
  }
  if (keep_RT) dfsave = df %>% select(c(TrialName:real_t_reac))
  df %<>% dplyr::select(-Session, -c(real_t_reac:t_Reaction)) %>%
    dplyr::relocate(c(Subject, Pat_Foggeur, Condition, TrialNum, GoNogo, Cote, 
                      is_FOG, Meta_FOG, TrialName))
  
  # Previously, longer subject Ids were reduced to three letters, keep this as a 
  # separate variable, but note that this reduction confounds two patients into DEp (DEp et DESPI)
  df %<>% mutate(Subject2 = ifelse(nchar(Subject) == 3,
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,3,3))),
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,4,4)))),
                 .after = Subject)
  
  df %<>% mutate(Pat_Foggeur = ifelse(as.character(Pat_Foggeur)=="FALSE", "NF", "F")) %>%
    mutate(Group = forcats::as_factor(ifelse(GoNogo %in% c("C", "I"), "M", "A")), .before = Subject)
  
  df %<>% mutate(
    across(c(Subject, Pat_Foggeur, Condition, GoNogo, Cote, TrialName), ~forcats::as_factor(.x))
  )
  
  df %<>% dplyr::select(-Freq_InitiationPas) # same as cadence?
  
  if (drop_vars == "ACC_MY") {
    # Antoine & Mathieu selection
    df %<>% dplyr::select(-Freinage, -t_chute, -t_freinage, -t_V1, -t_V2)
  } else {
    # Brian selection
    df %<>% dplyr::select(-Freinage, -t_chute, -t_freinage, -t_V1, -t_V2, -t_VyFO1, 
                          -t_cycle_marche, -V1)
  }
  
  if (drop_missing)
    df %<>% tidyr::drop_na()
  
  if (keep_RT) df$real_t_reac = dfsave$real_t_reac[match(df$TrialName, dfsave$TrialName)]
  
  return(df)
}






read_timefreq_data = function(filename,
                               timestep = NULL,
                               digits = 2,
                               format_long = T,
                               ev = NULL,
                               nor = "ldNOR"
) {
  col_types = coltypes_per_event(ev)
  
  df = vroom::vroom(filename,
                     delim = ";",
                     col_types = col_types,
                     id = "Loc"
  )
  
  df = transform_timefreq_data(df, timestep = timestep,  digits = digits,  format_long = format_long,  ev = ev,  nor = nor)
  
  return(df)
}

prepare_timefreq_data = function(input_df_list_ev,
                                 timestep = NULL,
                                 digits = 2,
                                 format_long = T,
                                 ev = NULL,
                                 nor = "ldNOR"
) {
  if (is.list(input_df_list_ev)) {
    input_df_list_ev[[1]]$Loc = names(input_df_list_ev)[1]
    df = input_df_list_ev[[1]]
    if (length(input_df_list_ev) > 1) {
      for (i in 2:length(input_df_list_ev)) { input_df_list_ev[[i]]$Loc = names(input_df_list_ev)[i] ; df = rbind(df, input_df_list_ev[[i]]) }
    } 
  } else if (is.dataframe(input_df_list_ev)) df = input_df_list_ev
  
  
  # integrate columns as in read_timefreq_data
  col_types = coltypes_per_event(ev)
  df %<>% select(-all_of(col_types$to_drop)) %>% 
    mutate(Loc = names(input_df_list_ev)[1])
  
  
  # todo : Order column + rename columns + check + implement{ boucle dans step 1 et skip in step 1}
  WIP
  input_df_list[[ev]][[Contact]] 
  df = transform_timefreq_data(df, timestep = timestep,  digits = digits,  format_long = format_long,  ev = ev,  nor = nor)
  return(df)
}

transform_timefreq_data = function(df,
                                    timestep = NULL,
                                    digits = 2,
                                    format_long = T,
                                    ev = NULL,
                                    nor = "ldNOR"
) {
  col_types = coltypes_per_event(ev)
  
  df %<>% mutate(Patient = sub(".*_", "", Patient)) %>%
    dplyr::rename(Subject = Patient,
                  Condition = Medication,
                  GoNogo = Task,
                  Meta_FOG = FOG,
                  TrialNum = nTrial,
                  Side_firststep = side) %>%
    dplyr::relocate(Meta_FOG, .after = TrialNum)
  
  # Decode time variables
  cnames = names(df)
  ind = which(stringr::str_starts(cnames, "x"))
  timepoint = gsub("x_", "-", cnames[ind], fixed = TRUE)
  timepoint = gsub("_" , ".", timepoint)
  timepoint = gsub("x" , "" , timepoint)
  
  if (nor == "ldNOR") {
    for (i in 1:length(ind)) {
      df[[cnames[ind[i]]]][df[,cnames[ind[i]]] <= 0] = NA
      df[,cnames[ind[i]]] = 10*log10(df[,cnames[ind[i]]])
    }
  }
  
  if (!is.null(timestep)) {
    # construct time vector using fixed timestep
    # assume first time is accurate
    timepoint = seq(from = as.numeric(timepoint[1]), 
                     by = timestep, 
                     length.out = length(timepoint))
    if (!is.null(digits)) {
      timepoint = format(timepoint, trim = T, digits = digits)
    } else {
      timepoint = format(timepoint, trim = T)
    }
  }
  cnames[ind] = paste0(timepoint, "0")
  names(df) = cnames
  
  # Decode the location
  df %<>% mutate(
    Loc = ifelse(
      stringr::str_detect(Loc, "-SM-"), 
      "SM", 
      ifelse(
        stringr::str_detect(Loc, "-AS-"), 
        "AS",
        ifelse(
          stringr::str_detect(Loc, "inSTN-elargi"), 
          "STNWide",
          ifelse(
            stringr::str_detect(Loc, "AllPerChan"), 
            "AllPerChan",
            ifelse(
              stringr::str_detect(Loc, "_Regions"), 
              "Region",
              ifelse(
                stringr::str_detect(Loc, "_Grouping"), 
                "Grouping",
                ifelse(
                  stringr::str_detect(Loc, "ANTI-"), 
                  "OUT",
                  ifelse(
                    stringr::str_detect(Loc, "All"), 
                    "All",
                    NA
                  )
                )
              )
            )
          )
        )
      ) 
    )
  )
  
  
  if (df$Loc[1] == "Region" || df$Loc[1] == "Grouping") df$Loc = df$Region
  if (df$Loc[1] == "AllPerChan") df$Loc = df$Channel
  df %<>% select(-Region)
  
  if(sum(is.na(df$Loc)) + sum(is.null(df$Loc)) > 0) {
    print("Warning: Loc is not qualitatively asserted. ChangeHere")
    # export df to global environment
    assign("df_problematique", df, envir = .GlobalEnv)
    error("Loc is not considered. ChangeHere")
  }
  
  df %<>% 
    mutate(Meta_FOG = as.integer(stringr::str_remove(Meta_FOG, "Meta_FOG_")))
  
  if (format_long) {
    df %<>% pivot_longer(
      cols = ends_with("0"),
      names_to = "Time",
      values_to = "Power"
    ) %>%
      mutate(Time = as.numeric(Time)) 
  }
  return(df)
}


plottf = function(df, 
                   thresh=1, 
                   plotcontour=F, 
                   correct=T, 
                   logfreq=F,
                   clim=c(-1,1), 
                   nudge=0, 
                   breaks = c(0.1,0.01,0.001)
){
  if (correct) {
    if("p.value" %in% colnames(df)) {
      df$p.value = p.adjust(df$p.value,method="fdr")
    }
  }
  
  if (thresh<1 & thresh>0) {
    df$estimate[df$p.value > thresh] = NA
  }
  
  # df = df %>% dplyr::arrange(f)
  # if (length(unique(df$tstep))<51) {
  #   t = seq(0.251953125000000,2.740234375,by=0.05078125)-2
  # } else {
  #   t = seq(0.251953125000000,4.720703125000000,by=0.05078125)-1
  # }
  # df$t = t
  # df$tmin = df$t - 0.05078125/2
  # df$tmax = df$t + 0.05078125/2 + nudge
  
  # f = unique(df$f)
  # if (logfreq) {
  #   df = df %>% dplyr::arrange(tstep)
  #   
  #   logf = log10(f)
  #   d = diff(logf,lag=1)/2
  #   logfmin = logf - c(d[1],d)
  #   logfmax = logf + c(d,d[length(d)])
  #   
  #   # Rely on vector expansion
  #   df$logf = logf
  #   df$logfmin = logfmin
  #   df$logfmax = logfmax + nudge
  # }
  
  if (logfreq) {
    p = ggplot(df,aes(x=t,y=logf)) + 
      geom_rect(aes(xmin=tmin,xmax=tmax,ymin=logfmin,ymax=logfmax,fill=estimate),size=NA,color=NA)
    
  } else {
    p = ggplot(df,aes(x=t,y=f)) + 
      geom_raster(aes(fill=estimate),interpolate=F)
  }
  
  p = p + 
    scale_fill_gradientn(colours=pals::parula(100),
                         breaks=c(-1,-.5,0,0.5,1),
                         limits=clim,
                         oob=scales::squish,
                         na.value="gray90")
  
  if (plotcontour) {
    if (!all(df$p.value>max(breaks))) {
      if (logfreq) {
        df2 = getContourLines(df$t,df$logfmin,log10(df$p.value),levels=log10(breaks))
        p = p + new_scale_color() +
          geom_path(data=df2,aes(x,y,group=Group,colour=factor(z)))
      } else {
        p = p + ggnewscale::new_scale_color() +
          geom_contour(aes(z = log10(p.value), color=factor(after_stat(level))),
                       breaks = log10(breaks))
      }
      p = p + colorspace::scale_color_discrete_sequential(palette = "Grays",
                                                          rev=F,
                                                          name="p-value",
                                                          labels=rev(breaks))
    }
  }
  
  if (logfreq) {
    flab = c(2,4,8,16,32,64)
    p = p + scale_y_continuous(limits = c(min(df$logfmin),max(df$logfmax)),
                               breaks = log10(flab),
                               labels = as.character(flab),
                               expand = c(0, 0))
  } else {
    p = p + scale_y_continuous(expand = c(0, 0))
    #p = p + scale_y_continuous(limits = c(min(f),max(f)), expand = c(0, 0))
  }
  
  #p = p + theme_pubr(legend="top") + labs(fill = "dB")
}

plottf2 = function(df,
                    column,
                    palette = "pals::parula",
                    limits = NULL,
                    pval_col = NULL,
                    pval_breaks = c(0.05,0.01,0.001),
                    norm = "ldNOR"
) {
  df %<>% tidyr::drop_na(column)
  if (!is.null(pval_col)) {
    if (grepl("TOCORRECT_", pval_col)) {
      print("Correction des pvalues...")
      pval_col = gsub("TOCORRECT_","",pval_col)
      df$p.value.cor = p.adjust(df[[pval_col]], method="fdr")
      pval_col = "p.value.cor"
      if (sum(is.na(df[[pval_col]])) > 0) print("Pval = na !!!!!!!")
      if (is.null(df[[pval_col]])) print("Pval = nullllllll")
      if (sum(df[[pval_col]] < pval_breaks[1]) == 0) print("  non-signif")
    }
  }
  
  transform = "identity"
  if (norm == "RAW") {
    newname = paste0(column, "*Freq")
    df[[newname]] = df[[column]]*df$Freq
    column = newname
  }
  
  if (is.null(limits)) {
    limits = c(-2,2)
    # if more than 15% of the data is above 0.2, then we will use a different scale
    if (sum(abs(df[[column]]) > limits[2]) > 0.15 * nrow(df)) {
      maxL = max((df[[column]]))
      minL  = min((df[[column]]))
      space = maxL - minL
      if (0 > (minL + space/4)) { # valeurs centrees
        lL     = max(abs(MinL),abs(maxL))
        limits = c(-lL,lL)
      } else {
        limits = c(minL,maxL)
      }
    }
  }
  
  p = ggplot(df, aes(Time, Freq)) + 
    geom_raster(aes(fill=!!sym(column)), interpolate = T) +
    scale_fill_paletteer_c(palette,
                           #"ggthemes::Red-Green-White Diverging",
                           #"pals::kovesi.diverging_gwv_55_95_c39",
                           #"scico::roma",
                           limits=limits,
                           oob=scales::squish,
                           na.value="gray90", 
                           transform = transform)

  if (!is.null(pval_col)) {
    if (length(pval_breaks) != 1) {
      p = p + ggnewscale::new_scale_color() +
        geom_contour(aes(z = log10(!!sym(pval_col)), color=factor(after_stat(level))),
                     breaks = log10(pval_breaks), linewidth = .25) +
        colorspace::scale_color_discrete_sequential(palette = "Grays",
                                                    rev=F,
                                                    name="p-value",
                                                    labels=rev(pval_breaks))
    } else {
      p = p + geom_contour(aes(z = log10(!!sym(pval_col)), color = as.character(pval_breaks)),
                     breaks = log10(pval_breaks), linewidth = .25, color = "black") 
    }
  }
  
  p = p + scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0))
  
  return(p)
}

#https://errickson.net/stats-notes/vizrandomeffects.html
rescov = function(model, data) {
  var.d = crossprod(getME(model,"Lambdat"))
  Zt = getME(model,"Zt")
  vr = sigma(model)^2
  var.b = vr*(t(Zt) %*% var.d %*% Zt)
  sI = vr * Diagonal(nrow(data))
  var.y = var.b + sI
  invisible(var.y)
}

# Core wrapping function
wrap.it = function(x, len)
{ 
  sapply(x, function(y) paste(strwrap(y, len), 
                              collapse = "\n"), 
         USE.NAMES = FALSE)
}


# Call this function with a list or vector
wrap.labels = function(x, len)
{
  if (is.list(x))
  {
    lapply(x, wrap.it, len)
  } else {
    wrap.it(x, len)
  }
}

pvalCorr = function(df,pval_col) { 
  # DEPRECATED
  # pval is corrected in plottf2 function instead
  
  # if(grepl("TOCORRECT_", pval_col)) df[[pval_col]] = p.adjust(df[[pval_col]],method="fdr") 
  return(df)
}

plot_tf_Variable = function(df,
                             est = "emmean",
                             pval_col = "p.value.a",
                             title = "",
                             Var1_name   = "Meta_FOG",
                             Var1_levels = c(0, 1),
                             Var2_name   = "Loc",
                             Var2_levels = c("SM", "AS"),
                             Selection_name   = "Condition",
                             Selection_level = c("OFF"),
                             pval_breaks = c(0.05,0.01,0.001),
                             Tag = NULL,
                             Grid_Size = 9,
                             PaletteMain = "pals::parula",
                             PaletteDiff = "pals::kovesi.diverging_linear_bjy_30_90_c45",
                             limits = NULL,
                             norm = "ldNOR",
                             DarkMode = F
){
  
  if (Grid_Size == 3 & !is.null(Tag)) errorr
    
    dfsave = df
    
    #limits
    if (is.null(limits)) {
      limits = c(-2,2)
      dfest  = df %>% filter(!is.na(!!sym(est)))
      if (sum(abs(dfest[[est]]) > limits[2]) > 0.15 * nrow(dfest)) {
        maxL = max((dfest[[est]]))
        minL  = min((dfest[[est]]))
        space = maxL - minL
        if (0 > (minL + space/4) & 0 < (maxL - space/4)) { # valeurs centrees sur 0
          lL     = max(abs(minL),abs(maxL))
          limits = c(-lL,lL)
        } else {
          limits = c(minL,maxL)
        }
      }
    }
    
    # if (grepl("TOCORRECT_", pval_col)) pval_col %<>% gsub("TOCORRECT_", "", .) 
    # pval_col = 
    if (!is.null(Selection_name) ) df %<>% filter(!!sym(Selection_name) %in% Selection_level)
 
    if (est == "meanPower") pval_col = NULL
    
    if (Grid_Size == 3) {
      df$"i" = ""
      Var2_name = "i"
      Var2_levels = c("","")
    }
    
    if (Grid_Size > 3) a = plottf2(df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[1]) %>% pvalCorr(pval_col),
                 est, limits = limits, pval_breaks = pval_breaks, pval_col = pval_col, palette = PaletteMain, norm = norm) + ggtitle(nice_title_magic(paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[1], " ", Selection_level)))
    b = plottf2(df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[2]) %>% pvalCorr(pval_col),
                 est, limits = limits, pval_breaks = pval_breaks, pval_col = pval_col, palette = PaletteMain, norm = norm) + ggtitle(nice_title_magic(paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[2], " ", Selection_level)))
    
    if (Grid_Size > 3) c = plottf2(df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[1]) %>% pvalCorr(pval_col),
                 est, limits = limits, pval_breaks = pval_breaks, pval_col = pval_col, palette = PaletteMain, norm = norm) + ggtitle(nice_title_magic(paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[1], " ", Selection_level)))
    d = plottf2(df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[2]) %>% pvalCorr(pval_col),
                 est, limits = limits, pval_breaks = pval_breaks, pval_col = pval_col, palette = PaletteMain, norm = norm) + ggtitle(nice_title_magic(paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[2], " ", Selection_level)))
    
    if (Grid_Size >= 13) {
    m = plottf2(df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[1]) %>% pvalCorr(pval_col),
                est, limits = limits, pval_breaks = pval_breaks, pval_col = pval_col, palette = PaletteMain, norm = norm) + ggtitle(nice_title_magic(paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[1], " ", Selection_level)))
    n = plottf2(df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[2]) %>% pvalCorr(pval_col),
                est, limits = limits, pval_breaks = pval_breaks, pval_col = pval_col, palette = PaletteMain, norm = norm) + ggtitle(nice_title_magic(paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[2], " ", Selection_level)))
    }
      
    if (est != "meanPower") {
      df = dfsave
      df$contrast = gsub("Meta_FOG", "FOG", df$contrast)
      ### EMMEANS and EMTRENDS
      
      Var1_levels_save = Var1_levels
      Var2_levels_save = Var2_levels
      Var1_levels = as.character(Var1_levels)
      Var2_levels = as.character(Var2_levels)
      
      if (Grid_Size > 3) {
      dtemp = df %>% filter(str_count(contrast, Var1_levels[1]) == 2, str_count(contrast, Var2_levels[1]) == 1, str_count(contrast, Var2_levels[2]) == 1, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      e = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))

      dtemp = df %>% filter(str_count(contrast, Var1_levels[2]) == 2, str_count(contrast, Var2_levels[1]) == 1, str_count(contrast, Var2_levels[2]) == 1, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      f = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))

      dtemp = df %>% filter(str_count(contrast, Var1_levels[1]) == 1, str_count(contrast, Var1_levels[2]) == 1, str_count(contrast, Var2_levels[1]) == 2, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      g = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      }
      
      dtemp = df %>% filter(str_count(contrast, Var1_levels[1]) == 1, str_count(contrast, Var1_levels[2]) == 1, str_count(contrast, Var2_levels[2]) == 2, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      h = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      
      if (Grid_Size >= 13) {
      dtemp = df %>% filter(str_count(contrast, Var1_levels[3]) == 2, str_count(contrast, Var2_levels[1]) == 1, str_count(contrast, Var2_levels[2]) == 1, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      o = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      
      dtemp = df %>% filter(str_count(contrast, Var1_levels[3]) == 1, str_count(contrast, Var1_levels[2]) == 1, str_count(contrast, Var2_levels[1]) == 2, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      k = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      
      dtemp = df %>% filter(str_count(contrast, Var1_levels[3]) == 1, str_count(contrast, Var1_levels[2]) == 1, str_count(contrast, Var2_levels[2]) == 2, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      l = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      }
      
      if (Grid_Size >= 15) {
      dtemp = df %>% filter(str_count(contrast, Var1_levels[3]) == 1, str_count(contrast, Var1_levels[1]) == 1, str_count(contrast, Var2_levels[2]) == 2, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      r = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      
      dtemp = df %>% filter(str_count(contrast, Var1_levels[3]) == 1, str_count(contrast, Var1_levels[1]) == 1, str_count(contrast, Var2_levels[1]) == 2, (is_null(Selection_name) %||% (str_count(contrast, Selection_level) == 2))) %>% pvalCorr(pval_col)
      s = plottf2(dtemp, est, limits = limits, palette = PaletteDiff, norm = norm, pval_breaks = pval_breaks, pval_col = pval_col) + ggtitle(nice_title_magic(wrap.labels(unique(dtemp$contrast), 20)))
      }
      Var1_levels = Var1_levels_save
      Var2_levels = Var2_levels_save
      
    } else {
      ## AVERAGES and not emmeans
      
      # Meta_FOG0 AS condition - Meta_FOG1 AS condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[2])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[2])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[2]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[2]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      h = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      
      if (Grid_Size > 3) {
      # Meta_FOG0 SM condition - Meta_FOG1 SM condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[1])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[1])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[1]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[1]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      g = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      
      # Meta_FOG0 AS condition - Meta_FOG0 SM condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[2])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[1])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[2]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[1]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      e = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      
      # Meta_FOG1 AS condition - Meta_FOG1 SM condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[2])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[1])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[2]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[1]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      f = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      }
      
      if (Grid_Size >= 13) {
      # Meta_FOG2 AS condition - Meta_FOG2 SM condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[2])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[1])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[2]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[1]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      o = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      
      # Meta_FOG2 AS condition - Meta_FOG1 AS condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[2])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[2])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[2]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[2]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      l = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      
      # Meta_FOG2 SM condition - Meta_FOG1 SM condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[1])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[2], !!sym(Var2_name) == Var2_levels[1])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[1]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[2]," ", Var2_name, Var2_levels[1]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      k = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      }
      
      if (Grid_Size >= 15) {
      # Meta_FOG2 AS condition - Meta_FOG1 AS condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[2])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[2])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[2]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[2]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      r = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      
      # Meta_FOG2 SM condition - Meta_FOG1 SM condition
      df1 = df %>% filter(!!sym(Var1_name) == Var1_levels[3], !!sym(Var2_name) == Var2_levels[1])
      df2 = df %>% filter(!!sym(Var1_name) == Var1_levels[1], !!sym(Var2_name) == Var2_levels[1])
      df_cond = df1 %>% select(Time:meanPower) %>%
        mutate(Condition = paste0(Var1_name,  Var1_levels[3]," ", Var2_name, Var2_levels[1]," ", Selection_level))
      df_cond %<>% bind_rows(df2 %>% select(Time:meanPower) %>%
                               mutate(Condition = paste0(Var1_name,  Var1_levels[1]," ", Var2_name, Var2_levels[1]," ", Selection_level)))
      df_cond %<>% select(Time, Freq, meanPower, Condition)
      df_cond %<>% pivot_wider(values_from = meanPower, names_from = Condition) %>%
        mutate(diffPower = .[[3]] - .[[4]])
      
      s = plottf2(df_cond %>% pvalCorr(pval_col), "diffPower", limits = limits, palette = PaletteDiff, norm = norm) +
        ggtitle(nice_title_magic(wrap.labels(paste0(names(df_cond)[3], ' - ', names(df_cond)[4]), 20)))
      }
      
    }
    
    if (DarkMode & (Sys.info()["nodename"] == "UMR-LAU-WP011")) {
      b = b + theme_dark_dark_classiclegend()
      d = d + theme_dark_dark_classiclegend()
      h = h + theme_dark_dark_classiclegend()
      if (Grid_Size > 3) {
      a = a + theme_dark_dark_classiclegend()
      c = c + theme_dark_dark_classiclegend()
      e = e + theme_dark_dark_classiclegend()
      f = f + theme_dark_dark_classiclegend()
      g = g + theme_dark_dark_classiclegend()
      if (Grid_Size >= 13) {
        m = m + theme_dark_dark_classiclegend()
        n = n + theme_dark_dark_classiclegend()
        o = o + theme_dark_dark_classiclegend()
        k = k + theme_dark_dark_classiclegend()
        l = l + theme_dark_dark_classiclegend()
      if (Grid_Size >= 15) { 
        r = r + theme_dark_dark_classiclegend()
        s = s + theme_dark_dark_classiclegend()
        
        p = b+h+d+l+n+r + a+g+c+k+m+s + e+plot_spacer()+f+plot_spacer()+o+plot_spacer() + plot_layout(guides = "collect", nrow = 3, ncol = 6)
      } else {
        p = b+h+d+l+n   + a+g+c+k+m   + e+plot_spacer()+f+plot_spacer()+o + plot_layout(guides = "collect", nrow = 3, ncol = 5)
      }} else {
        p = b+d+h + a+c+g + e+f + plot_spacer() + plot_layout(guides = "collect", nrow = 3, ncol = 3) 
      }} else {
        p = a + b + c + plot_spacer() + plot_layout(guides = "collect", nrow = 1) 
      }
        
      p = p  + 
        theme_dark_dark_classiclegend() +
        plot_annotation(title = title, theme = theme_dark_dark_classiclegend())  
        # plot_annotation(tag_levels = 'A' ,theme = theme_dark_dark_classiclegend()) +
      
    } else {
      if (Grid_Size == 15) {
        p = b+h+d+l+n+r + a+g+c+k+m+s + e+plot_spacer()+f+plot_spacer()+o+plot_spacer() +
          plot_annotation(title = title) +  
          plot_layout(guides = "collect", nrow = 3, ncol = 6) &
          theme(plot.title = element_text(size=10), legend.position='right')
      } else if (Grid_Size == 13) {
        p = b+h+d+l+n + a+g+c+k+m + e+plot_spacer()+f+plot_spacer()+o +
          plot_annotation(title = title) +  
          plot_layout(guides = "collect", nrow = 3, ncol = 5) &
          theme(plot.title = element_text(size=10), legend.position='right')
      } else if (Grid_Size == 3) {
        p = a + b + c + plot_spacer() + 
          plot_annotation(title = title) + 
          plot_layout(guides = "collect", nrow = 1) &
          theme(plot.title = element_text(size=10), legend.position='right') 
      } else {
      p = b+d+h + a+c+g + e+f + plot_spacer() + 
        plot_annotation(title = title) +  
        plot_layout(guides = "collect", nrow = 3, ncol = 3) &
        theme(plot.title = element_text(size=10), legend.position='right') 
      }
    }
  return(p)
}

nice_title_magic = function(title_name) {
  title_name = gsub("LocSM", "Posterior", title_name)
  title_name = gsub("LocIN", "Intermediary", title_name)
  title_name = gsub("LocAS", "Central", title_name)
  title_name = gsub("Meta_FOG0", "FOG-/-", title_name)
  title_name = gsub("Meta_FOG1", "FOG+/-", title_name)
  title_name = gsub("Meta_FOG2", "FOG+/+", title_name)
  title_name = gsub("FOG0", "FOG-/-", title_name)
  title_name = gsub("FOG1", "FOG+/-", title_name)
  title_name = gsub("FOG2", "FOG+/+", title_name)
  title_name = gsub("SM", "Post.", title_name)
  title_name = gsub("AS", "Ctrl.", title_name)
  title_name = gsub("GoNogo", "", title_name)
  title_name = gsub("spon", "S", title_name)
  title_name = gsub("fast", "R", title_name)
  
  return(title_name)
}

"%||%" = function(x,y) {
  if(x) return(x) else return(y)
}

contrasts_differ_one_factor <- function(contrast) {
  # Split contrast 
  contrast1 = strsplit(contrast, " - ")[[1]][1]
  contrast2 = strsplit(contrast, " - ")[[1]][2]
  # Split contrast strings into components
  split1 = unlist(strsplit(contrast1, " "))
  split2 = unlist(strsplit(contrast2, " "))
  # Return TRUE if exactly one factor differs, else FALSE
  return(sum(split1 != split2) == 1)
}

filter_contrasts <- function(df, contrast) {
  return(df %>% rowwise() %>% filter(contrasts_differ_one_factor(contrast)))
}


LFP_normalization = function(df, nor_to_do) {
  if (nor_to_do == "fooof_perpat") {
    
    local_df = df %>% 
      mutate(Mean = rowMeans(select(., starts_with("x")), na.rm = TRUE))  %>% 
      group_by(Freq) %>% 
      summarise(Mean = mean(Mean, na.rm = TRUE)) 
    localFreq = local_df$Freq
    localSpec = local_df$Mean
    
    library(reticulate)
    
    fooof = import("fooof")
    py_run_string("from fooof import FOOOF")
    py_run_string("from fooof.sim.gen import gen_aperiodic")
    py_run_string("import numpy as np")
    py_run_string("fm = FOOOF()")
    py_run_string("fm.fit(np.array(r.localFreq), np.array(r.localSpec))")
    py_run_string("ap_fit = gen_aperiodic(fm.freqs, fm._robust_ap_fit(fm.freqs, fm.power_spectrum))")
    py_run_string("fm.report(np.array(r.localFreq), np.array(r.localSpec))")
    
    local_df %<>% mutate(ap_fit = py$ap_fit)
    
    df %<>% left_join(local_df, by = "Freq") %>% mutate(across(starts_with("x"), ~ . - ap_fit))
    df %<>% ungroup() %>% select(-ap_fit) %>% select(-Mean)
  } else if(nor_to_do == "multip_par_freq") {
    df %<>% mutate(across(starts_with("x"), ~ . * Freq))
  }
  return(df)
}

ReactionTimeAnalysis = function(path) {
  # path = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
  df = read_gait_data(path, keep_RT = T) %>% filter(Group == "M")
  
  df_per_pat = df %>% group_by(Subject, Condition, GoNogo) %>% 
    summarise(ReactionTime = mean(real_t_reac, na.rm = TRUE))
  
  df_per_pat %<>% mutate(Task = paste0(Condition, ' ', GoNogo))
  df_allmean = df_per_pat %>% group_by(Task) %>% summarise(ReactionTime = mean(ReactionTime, na.rm = TRUE))
  
  ggplot2::ggplot(df_per_pat, aes(x = Task, y = ReactionTime)) +
    geom_text(aes(y = 0, label = paste0(round(ReactionTime * 1000), " ms")), data = df_allmean, color = "white", size = 8) +
    geom_point(aes(color = Subject)) +
    geom_line(aes(group = Subject, color = Subject, alpha = 0.5)) +
    geom_boxplot(color = 'grey90', fill = '#11111111', size = 1) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme_minimal() +
    labs(title = "Reaction Time per Task", x = "Task", y = "Reaction Time (s)") +
    ylim(c(0, .6))  + 
    # sfthemes::theme_sf_dark(size_class = "xxLarge")
    theme_dark_dark()
  
}

RPC_GoNogo_Analysis = function(gait_data_file) {
  # gait_data_file = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
  df_gait = read_gait_data(gait_data_file, drop_missing = T, keep_RT = keep_RT)
  df_gait = augment_gait_w_pca(df_gait, keep_RT = keep_RT)
  
  df_ng = df_gait %>% 
    filter(Group == "M") %>% 
    select(Subject, Condition, GoNogo, RPC.1, RPC.2, RPC.3, RPC.4, RPC.5) %>%
    pivot_longer(cols = starts_with("RPC"), names_to = "RPC", values_to = "Value") 
  
  # ggplot2::ggplot(df_ng, aes(x = GoNogo:Condition, y = Value)) +
  #   geom_boxplot() +
  #   ggbeeswarm::geom_beeswarm(aes(color = Subject), alpha = 0.09) +
  #   facet_wrap(~RPC)

  df_gp = df_ng %>% group_by(Subject, Condition, GoNogo, RPC) %>% 
    summarise(Value = mean(Value, na.rm = TRUE))
  
  mod = lmerTest::lmer(Value ~ Condition*GoNogo*RPC + (1|Subject), data = df_gp)
  df_stat = emmeans::emmeans(mod, pairwise ~ GoNogo | Condition:RPC)$contrasts %>% as.data.frame()
  
  print(df_stat)
  
  ggplot2::ggplot(df_gp, aes(x = Condition:GoNogo, y = Value)) +
    geom_boxplot() +
    ggbeeswarm::geom_beeswarm(aes(color = Subject), data = df_ng, alpha = 0.2, shape = 16) +
    facet_wrap(~RPC) +
    ylim(c(-2.5, 2.5)) +
    theme_light() 
}


Plot_trends_timecourses = function(modelpath, RPC, LocSTN = "", Cond = "OFF") {
# RPC = "RPC.1" ; LocSTN = "AS" ; Cond = "OFF" ; modelpath = "C:/Users/mathieu.yeche/OneDrive - ICM/TMP/Fig24.02/ModelsNew/Data/model_fits/bands_remove_artifacts/model_1_RPC.1_Freq_8.RData"

  # load Rdata model
  load(modelpath)
  spec = as.formula(ifelse(LocSTN == "", "~ Meta_FOG + Condition", "~ Meta_FOG | Loc + Condition"))
  Freq = str_extract_all(modelpath, "[0-9]+", )[[1]]
  Freq = as.numeric(Freq[length(Freq)])
  
  # extract emmean
  List0 = c() ; List1 = c() ; Listp = c() ; List0SE = c() ; List1SE = c()
  Listt = df_save$Time
  for (i in 1:length(df_save$fit)) {
    emmeanS = suppressMessages(emtrends(df_save$fit[i][[1]], spec, var = RPC) )
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
  
  
}


TrialPerTrialPlot = function(
    pq_path    = "C:/LustreSync/LAU Brian - 2024_GBMOV/Data/pq_wide/T0/",
    save_path  = "C:/Users/mathieu.yeche/OneDrive - ICM/TMP/ArtefactON/",
    time_window= c(-1, 1),
    Freq_to_fit= c(1:100),
    LocsIncl   = c("AS", "SM"),
    FoGIncl    = c(0, 1),
    GNGIncl    = c("GOc", "GOi"),
    DopaIncl   = c("OFF", "ON"),
    RemoveArtefactMode = "pro"
){
  
  # Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
  # if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
  # LoadLibraries()
  
  tfdata  = arrow::open_dataset(pq_path)
  
  cnames = tfdata$schema$names
  time_col_names = cnames[str_ends(cnames, "0")]
  times = time_col_names %>% as.numeric()
  ind = times < time_window[1] | times > time_window[2]
  times_to_drop = time_col_names[ind]
  
  query = tfdata %>% 
    select(-all_of(times_to_drop)) %>%
    filter(Freq %in% Freq_to_fit) %>%
    filter(GoNogo %in% GNGIncl) %>%
    filter(Loc %in% LocsIncl) %>%
    filter(Meta_FOG %in% FoGIncl) %>%
    filter(Condition %in% DopaIncl) %>%
    collect()
  
  query$id = paste0( query$Condition, ' ', query$Subject, ' ', query$GoNogo,' ',query$TrialNum, ' ', query$Channel)
  
  query %<>% global_remove_artifacts(verbose = F, mode = RemoveArtefactMode ) %>% 
    pivot_longer(
      cols = ends_with("0"),
      names_to = "Time",
      values_to = "Power"
    ) %>%
    filter(!is.na(Power)) %>%    
    # filter(Power > 0) %>%     # Only old GI dataset
    mutate(Time = as.numeric(Time) 
           #, Power = 10*log10(Power) # Only old GI dataset
    )
  
  for (i in unique(query$id)){
    p = plottf2(data, "Power", limits = c(-25,25), pval_col = NULL) + ggtitle(i)
    cowplot::save_plot(paste0(save_path, i, ".png"), p, base_width = 7, base_height = 9, dpi = 300)
  }
  print("Done")
}


batch_individual_plot = function(params) {
  if (!dir.exists(params[["pq_path"]]))   dir.create(params[["pq_path"]])
  if (!dir.exists(params[["save_path"]])) dir.create(params[["save_path"]])
  if (!dir.exists(paste0(params[["save_path"]],"PlotsIndiv/"))) dir.create(paste0(params[["save_path"]],"PlotsIndiv/"))
  
  freqs_to_fit    = params[["freqs_to_fit"]]
  time_window     = params[["time_window"]]
  locs_to_include = params[["locs_to_include"]]
  FOG_to_include  = params[["FOG_to_include"]]
  GNG_to_include  = params[["GNG_to_include"]]
  DOPA_to_include = params[["DOPA_to_include"]]
  remove_artifacts<- params[["remove_artifacts"]]
  param_sets      = params[["param_sets"]]
  keep_RT = ifelse(((params[["Project"]] == "GNG_STN") | (params[["Project"]] == "GNG_PPN")), TRUE, FALSE)
  
  tfdata  = arrow::open_dataset(params[["pq_path"]])
  df_gait = read_gait_data(params[["gait_data_file"]], params[["Project"]], drop_missing = T, keep_RT = keep_RT)
  df_gait = augment_gait_w_pca(df_gait, keep_RT = keep_RT)
  
  # timebins are in wide format, with names indicating bin centers
  # create a vector of names to drop when loading data
  cnames = tfdata$schema$names
  time_col_names = cnames[str_ends(cnames, "0")]
  times = time_col_names %>% as.numeric()
  ind = times < time_window[1] | times > time_window[2]
  times_to_drop = time_col_names[ind]
  
  if (FOG_to_include[1]  == "all") FOG_to_include  = tfdata %>% distinct(Meta_FOG)  %>% collect() %>% pull(.)
  if (locs_to_include[1] == "all") locs_to_include = tfdata %>% distinct(Loc)       %>% collect() %>% pull(.) 
  if (GNG_to_include[1]  == "all") GNG_to_include  = tfdata %>% distinct(GoNogo)    %>% collect() %>% pull(.)
  if (DOPA_to_include[1] == "all") DOPA_to_include = tfdata %>% distinct(Condition) %>% collect() %>% pull(.)
  MaxTrial = 9999
  
  query = tfdata %>% 
    select(-all_of(times_to_drop)) %>%
    filter(Freq %in% freqs_to_fit) %>%
    filter(GoNogo %in% GNG_to_include) %>%
    filter(Meta_FOG %in% FOG_to_include) %>%
    filter(Condition %in% DOPA_to_include) %>%
    filter(TrialNum <= MaxTrial) %>%
    collect() 
  
  query %<>% 
    mutate(Side_channel = ifelse(stringr::str_detect(Channel, "D"), "R", "L")) %>%
    mutate(Side_firststep_ipsi_contra = ifelse(Side_channel==Side_firststep, "ipsi", "contra")) %>%
    mutate(Loc = as.factor(Loc),
           Condition = as.factor(Condition),
           GoNogo = as.factor(GoNogo),
           Side_channel = as.factor(Side_channel),
           Side_firststep_ipsi_contra = as.factor(Side_firststep_ipsi_contra),
           Meta_FOG = as.factor(Meta_FOG)) %>% 
    pivot_longer(
      cols = ends_with("0"),
      names_to = "Time",
      values_to = "Power"
    ) %>% 
    filter(!is.na(Power)) %>%
    mutate(Time = as.numeric(Time)) %>%
    global_remove_artifacts(verbose = F)
  
  df_gait %<>%  mutate(Task = dplyr::case_when(GoNogo == "R" ~ "fast", GoNogo == "S" ~ "spon", GoNogo == "C" ~ "GOc", GoNogo == "I" ~ "GOi", TRUE ~ "NoGO"),
           index = paste0(Subject2, Condition, TrialNum, "_", Task))
  query   %<>%  mutate(index = paste0(sub(".*_", "", Subject), Condition, TrialNum, '_', GoNogo),
           RPCinornot = ifelse(index %in% df_gait$index, "+Gait", "noGait"))
  
  for (pat in unique(query$Subject)) {
    chanlist = query %>% filter(Subject == pat) %>% pull(Channel) %>% unique()
    for (chan in chanlist) {
      for (cond in query %>% filter(Subject == pat, Channel == chan) %>% pull(Condition) %>% unique()) {
        P = list()
        i = 1
        for (GNGlocal in query %>% filter(Subject == pat, Channel == chan, Condition == cond) %>% pull(GoNogo) %>% unique()) {
          for (trial in query %>% filter(Subject == pat, Channel == chan, Condition == cond, GoNogo == GNGlocal) %>% pull(TrialNum) %>% unique()) {
            TitleSuffix = query %>% filter(Subject == pat, Channel == chan, Condition == cond, GoNogo == GNGlocal, TrialNum == trial) %>% pull(Meta_FOG) %>% unique()
            TitleSuffix = paste0(TitleSuffix, " ", query %>% filter(Subject == pat, Channel == chan, Condition == cond, GoNogo == GNGlocal, TrialNum == trial) %>% pull(Loc) %>% unique())
            TitleSuffix = paste0(TitleSuffix, " ", query %>% filter(Subject == pat, Channel == chan, Condition == cond, GoNogo == GNGlocal, TrialNum == trial) %>% pull(RPCinornot) %>% unique())
            P[[i]]  = plottf2(query %>% filter(Subject == pat, Channel == chan, Condition == cond, GoNogo == GNGlocal, TrialNum == trial), "Power", 
                         limits = c(-10,10), pval_col = NULL) + 
              ggtitle(nice_title_magic(paste0(GNGlocal, trial, ": ", TitleSuffix))) +
              theme(legend.position = "none")
              
            i = i + 1
          }
        }
        p = cowplot::plot_grid(cowplot::ggdraw() + cowplot::draw_label(nice_title_magic(paste0(pat, " ", chan, " ", cond)), fontface = 'bold'), 
                               cowplot::plot_grid(plotlist = P), ncol = 1, rel_heights = c(0.05, 1))
        cowplot::save_plot(paste0(params[["save_path"]], "PlotsIndiv/", pat, "_", chan, "_", cond, ".png"), p, base_width = 29.7, base_height = 21, dpi = 600, units = "cm")
      }
    }
  }
  print("Done")
}


LoadLibraries = function() {
  suppressPackageStartupMessages({
    library(tidyverse)
    library(stringr)
    library(vroom)
    library(reshape2)
    library(magrittr)
    library(tictoc)
    library(arrow)
    library(furrr)
    library(lmerTest)
    library(emmeans)
    library(qs)
    library(patchwork)
    library(paletteer)
    # library(grid)
    # library(ggthemes)
    # library(reticulate) also need python
    if (Sys.info()[['sysname']] == "Windows") source("C:/Users/mathieu.yeche/Documents/Toolbox/ggplot_theme_Publication-2.R") else theme_Publication = theme_minimal
  })
}

`%not_in%` <- Negate(`%in%`)

coltypes_per_event = function(ev = NULL) {
  if (ev == "T0" || ev == "CUE" || ev == "FIX"  || ev == "WrCUE" || ev == "WrFIX" || ev == "FOG_E" || ev == "FO1" || ev == "FC1") {
    col_types = cols_only(
      Protocol = col_character(),
      Patient = col_character(),
      Medication = col_character(),
      Task = col_character(),
      #Condition = col_character(),
      #quality = col_double(), # All == 1 
      #isValid = col_double(), # All == 1
      #isFOG = col_double(), # Has NA values?
      nTrial = col_integer(),
      Channel = col_character(),
      Region = col_character(),
      #grouping = col_character(),
      Freq = col_integer(),
      #Run = col_character(),
      #Event = col_character(),
      #nStep = col_double(),
      side = col_character(), # Side of first step
      x_1_25 = col_double(),
      x_1_2207 = col_double(),
      x_1_1914 = col_double(),
      x_1_1621 = col_double(),
      x_1_1328 = col_double(),
      x_1_1035 = col_double(),
      x_1_0742 = col_double(),
      x_1_0449 = col_double(),
      x_1_0156 = col_double(),
      x_0_98633 = col_double(),
      x_0_95703 = col_double(),
      x_0_92773 = col_double(),
      x_0_89844 = col_double(),
      x_0_86914 = col_double(),
      x_0_83984 = col_double(),
      x_0_81055 = col_double(),
      x_0_78125 = col_double(),
      x_0_75195 = col_double(),
      x_0_72266 = col_double(),
      x_0_69336 = col_double(),
      x_0_66406 = col_double(),
      x_0_63477 = col_double(),
      x_0_60547 = col_double(),
      x_0_57617 = col_double(),
      x_0_54688 = col_double(),
      x_0_51758 = col_double(),
      x_0_48828 = col_double(),
      x_0_45898 = col_double(),
      x_0_42969 = col_double(),
      x_0_40039 = col_double(),
      x_0_37109 = col_double(),
      x_0_3418 = col_double(),
      x_0_3125 = col_double(),
      x_0_2832 = col_double(),
      x_0_25391 = col_double(),
      x_0_22461 = col_double(),
      x_0_19531 = col_double(),
      x_0_16602 = col_double(),
      x_0_13672 = col_double(),
      x_0_10742 = col_double(),
      x_0_078125 = col_double(),
      x_0_048828 = col_double(),
      x_0_019531 = col_double(),
      x0_0097656 = col_double(),
      x0_039062 = col_double(),
      x0_068359 = col_double(),
      x0_097656 = col_double(),
      x0_12695 = col_double(),
      x0_15625 = col_double(),
      x0_18555 = col_double(),
      x0_21484 = col_double(),
      x0_24414 = col_double(),
      x0_27344 = col_double(),
      x0_30273 = col_double(),
      x0_33203 = col_double(),
      x0_36133 = col_double(),
      x0_39062 = col_double(),
      x0_41992 = col_double(),
      x0_44922 = col_double(),
      x0_47852 = col_double(),
      x0_50781 = col_double(),
      x0_53711 = col_double(),
      x0_56641 = col_double(),
      x0_5957 = col_double(),
      x0_625 = col_double(),
      x0_6543 = col_double(),
      x0_68359 = col_double(),
      x0_71289 = col_double(),
      x0_74219 = col_double(),
      x0_77148 = col_double(),
      x0_80078 = col_double(),
      x0_83008 = col_double(),
      x0_85938 = col_double(),
      x0_88867 = col_double(),
      x0_91797 = col_double(),
      x0_94727 = col_double(),
      x0_97656 = col_double(),
      x1_0059 = col_double(),
      x1_0352 = col_double(),
      x1_0645 = col_double(),
      x1_0938 = col_double(),
      x1_123 = col_double(),
      x1_1523 = col_double(),
      x1_1816 = col_double(),
      x1_2109 = col_double(),
      x1_2402 = col_double(),
      x1_2695 = col_double(),
      x1_2988 = col_double(),
      x1_3281 = col_double(),
      x1_3574 = col_double(),
      x1_3867 = col_double(),
      x1_416 = col_double(),
      x1_4453 = col_double(),
      x1_4746 = col_double(),
      x1_5039 = col_double(),
      x1_5332 = col_double(),
      x1_5625 = col_double(),
      x1_5918 = col_double(),
      x1_6211 = col_double(),
      x1_6504 = col_double(),
      x1_6797 = col_double(),
      x1_709 = col_double(),
      x1_7383 = col_double(),
      #dimension1 = col_double(),
      #dimension2 = col_double(),
      #dimension3 = col_double(),
      FOG = col_character(),
      #dU3 = col_double(),
      #dFogQ = col_double(),
      #U3 = col_double()
    )
  } else if (ev == "FOG_S") {
    col_types = cols_only(
      Protocol = col_character(),
      Patient = col_character(),
      Medication = col_character(),
      Task = col_character(),
      #Condition = col_character(),
      #quality = col_double(), # All == 1 
      #isValid = col_double(), # All == 1
      #isFOG = col_double(), # Has NA values?
      nTrial = col_integer(),
      Channel = col_character(),
      #Region = col_character(),
      #grouping = col_character(),
      Freq = col_integer(),
      #Run = col_character(),
      #Event = col_character(),
      #nStep = col_double(),
      side = col_character(), # Side of first step
      x_2_25 = col_double(),
      x_2_2207 = col_double(),
      x_2_1914 = col_double(),
      x_2_1621 = col_double(),
      x_2_1328 = col_double(),
      x_2_1035 = col_double(),
      x_2_0742 = col_double(),
      x_2_0449 = col_double(),
      x_2_0156 = col_double(),
      x_1_9863 = col_double(),
      x_1_957 = col_double(),
      x_1_9277 = col_double(),
      x_1_8984 = col_double(),
      x_1_8691 = col_double(),
      x_1_8398 = col_double(),
      x_1_8105 = col_double(),
      x_1_7812 = col_double(),
      x_1_752 = col_double(),
      x_1_7227 = col_double(),
      x_1_6934 = col_double(),
      x_1_6641 = col_double(),
      x_1_6348 = col_double(),
      x_1_6055 = col_double(),
      x_1_5762 = col_double(),
      x_1_5469 = col_double(),
      x_1_5176 = col_double(),
      x_1_4883 = col_double(),
      x_1_459 = col_double(),
      x_1_4297 = col_double(),
      x_1_4004 = col_double(),
      x_1_3711 = col_double(),
      x_1_3418 = col_double(),
      x_1_3125 = col_double(),
      x_1_2832 = col_double(),
      x_1_2539 = col_double(),
      x_1_2246 = col_double(),
      x_1_1953 = col_double(),
      x_1_166 = col_double(),
      x_1_1367 = col_double(),
      x_1_1074 = col_double(),
      x_1_0781 = col_double(),
      x_1_0488 = col_double(),
      x_1_0195 = col_double(),
      x_0_99023 = col_double(),
      x_0_96094 = col_double(),
      x_0_93164 = col_double(),
      x_0_90234 = col_double(),
      x_0_87305 = col_double(),
      x_0_84375 = col_double(),
      x_0_81445 = col_double(),
      x_0_78516 = col_double(),
      x_0_75586 = col_double(),
      x_0_72656 = col_double(),
      x_0_69727 = col_double(),
      x_0_66797 = col_double(),
      x_0_63867 = col_double(),
      x_0_60938 = col_double(),
      x_0_58008 = col_double(),
      x_0_55078 = col_double(),
      x_0_52148 = col_double(),
      x_0_49219 = col_double(),
      x_0_46289 = col_double(),
      x_0_43359 = col_double(),
      x_0_4043 = col_double(),
      x_0_375 = col_double(),
      x_0_3457 = col_double(),
      x_0_31641 = col_double(),
      x_0_28711 = col_double(),
      x_0_25781 = col_double(),
      x_0_22852 = col_double(),
      x_0_19922 = col_double(),
      x_0_16992 = col_double(),
      x_0_14062 = col_double(),
      x_0_11133 = col_double(),
      x_0_082031 = col_double(),
      x_0_052734 = col_double(),
      x_0_023438 = col_double(),
      x0_0058594 = col_double(),
      x0_035156 = col_double(),
      x0_064453 = col_double(),
      x0_09375 = col_double(),
      x0_12305 = col_double(),
      x0_15234 = col_double(),
      x0_18164 = col_double(),
      x0_21094 = col_double(),
      x0_24023 = col_double(),
      x0_26953 = col_double(),
      x0_29883 = col_double(),
      x0_32812 = col_double(),
      x0_35742 = col_double(),
      x0_38672 = col_double(),
      x0_41602 = col_double(),
      x0_44531 = col_double(),
      x0_47461 = col_double(),
      x0_50391 = col_double(),
      x0_5332 = col_double(),
      x0_5625 = col_double(),
      x0_5918 = col_double(),
      x0_62109 = col_double(),
      x0_65039 = col_double(),
      x0_67969 = col_double(),
      x0_70898 = col_double(),
      x0_73828 = col_double(),
      x0_76758 = col_double(),
      x0_79688 = col_double(),
      x0_82617 = col_double(),
      x0_85547 = col_double(),
      x0_88477 = col_double(),
      x0_91406 = col_double(),
      x0_94336 = col_double(),
      x0_97266 = col_double(),
      x1_002 = col_double(),
      x1_0312 = col_double(),
      x1_0605 = col_double(),
      x1_0898 = col_double(),
      x1_1191 = col_double(),
      x1_1484 = col_double(),
      x1_1777 = col_double(),
      x1_207 = col_double(),
      x1_2363 = col_double(),
      x1_2656 = col_double(),
      x1_2949 = col_double(),
      x1_3242 = col_double(),
      x1_3535 = col_double(),
      x1_3828 = col_double(),
      x1_4121 = col_double(),
      x1_4414 = col_double(),
      x1_4707 = col_double(),
      x1_5 = col_double(),
      x1_5293 = col_double(),
      x1_5586 = col_double(),
      x1_5879 = col_double(),
      x1_6172 = col_double(),
      x1_6465 = col_double(),
      x1_6758 = col_double(),
      x1_7051 = col_double(),
      x1_7344 = col_double(),
      #dimension1 = col_double(),
      #dimension2 = col_double(),
      #dimension3 = col_double(),
      FOG = col_character(),
      #dU3 = col_double(),
      #dFogQ = col_double(),
      #U3 = col_double()
    )
  } else { 
    print("Event not recognized, specify in utils>coltypes_per_event")
    error("Event not recognized, specify in utils>coltypes_per_event")
  }
  return(col_types)
}



