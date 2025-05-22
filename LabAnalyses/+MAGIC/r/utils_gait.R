read_gait_data <- function(filename
) {
  df = readxl::read_xlsx(filename, sheet = 1,
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
                         ))
  
  df %<>% dplyr::select(-c(real_t_reac:t_Reaction)) %>%
    dplyr::relocate(c(Subject, Pat_Foggeur, Condition, TrialNum, GoNogo, Cote, 
                      is_FOG, Meta_FOG, TrialName))
  
  # Previously, longer subject Ids were reduced to three letters, keep this as a 
  # separate variable, but note that this reduction confounds two patients into DEm
  df %<>% mutate(Subject2 = ifelse(nchar(Subject) == 3,
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,3,3))),
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,4,4)))),
                 .after = Subject)
  
  # Two subjects with same 3-letter code, recode one of them
  df %<>% mutate(Subject2 = ifelse(Subject2 == "DESPI05", "DEp2", Subject2))
  
  df %<>% mutate(Pat_Foggeur = ifelse(as.character(Pat_Foggeur)=="FALSE", "NF", "F")) %>%
    mutate(Group = forcats::as_factor(ifelse(GoNogo %in% c("C", "I"), "M", "A")), .before = Subject)
  
  df %<>% mutate(
    across(c(Subject, Pat_Foggeur, Condition, GoNogo, Cote, TrialName), ~forcats::as_factor(.x))
  )
  
  df %<>% dplyr::select(-Freq_InitiationPas) # same as cadence?
  #df %<>% select(-TrialNum)
}

# This reads the magic data from Saoussen that includes a FOG code
read_gait_data_magic2 <- function(filename
) {
  df = readr::read_delim(filename, delim = ";",
                         col_types = cols(
                           TrialName = col_character(),
                           TrialNum = col_integer(),
                           Subject = col_character(),
                           Condition = col_character(),
                           GoNogo = col_character(),
                           Session = col_character(),
                           Cote = col_character(),
                           CueTime = col_double(),
                           real_t_reac = col_double(),
                           TR = col_double(),
                           T0 = col_double(),
                           FO1 = col_double(),
                           FC1 = col_double(),
                           FO2 = col_double(),
                           FC2 = col_double(),
                           stime_time = col_double(),
                           real_t_Reaction = col_double(),
                           t_Reaction = col_double(),
                           t_APA = col_double(),
                           APA_antpost = col_double(),
                           APA_lateral = col_double(),
                           StepWidth = col_double(),
                           t_swing1 = col_double(),
                           t_DA = col_double(),
                           t_swing2 = col_double(),
                           t_cycle_marche = col_double(),
                           Longueur_pas = col_double(),
                           V_swing1 = col_double(),
                           Vy_FO1 = col_double(),
                           t_VyFO1 = col_double(),
                           Vm = col_double(),
                           t_Vm = col_double(),
                           VML_absolue = col_double(),
                           Freq_InitiationPas = col_double(),
                           Cadence = col_double(),
                           VZmin_APA = col_double(),
                           V1 = col_double(),
                           V2 = col_double(),
                           Diff_V = col_double(),
                           Freinage = col_double(),
                           t_chute = col_double(),
                           t_freinage = col_double(),
                           t_V1 = col_double(),
                           t_V2 = col_double(),
                           is_FOG = col_character(),
                           Pat_Foggeur = col_double(),
                           Meta_FOG = col_double()
                         )
  )
  
  df %<>% dplyr::select(-c(real_t_reac:t_Reaction)) %>%
    dplyr::relocate(c(Subject, Pat_Foggeur, Condition, TrialNum, GoNogo, Cote, 
                      is_FOG, Meta_FOG, TrialName))
  
  # Previously, longer subject Ids were reduced to three letters, keep this as a 
  # separate variable, but note that this reduction confounds two patients into DEm
  df %<>% mutate(Subject2 = ifelse(nchar(Subject) == 3,
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,3,3))),
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,4,4)))),
                 .after = Subject)
  
  df %<>% mutate(Subject = Subject2)
  
  # is_FOG has Na
  df %<>% mutate(is_FOG = ifelse(is_FOG == "Na", NA, is_FOG)) %>%
    mutate(is_FOG = as.numeric(is_FOG))
  
  # Split Condition into Condition (OFF/ON) and Treatment (Dopa, DBS site)
  df %<>% mutate(Condition2 = Condition, .after = Condition) %>%
    mutate(Condition = ifelse(Condition2 == "OFF", "OFF", "ON")) %>%
    mutate(Condition = ifelse(Condition2 == "OFF_Stim", "OFF", Condition)) %>%
    mutate(Treatment = Condition2, .after = Condition) %>%
    mutate(Treatment = ifelse(Condition2 == "Hot spot FOG", "Hotspot", NA)) %>%
    mutate(Treatment = ifelse(Condition2 == "Motor STN", "Motor", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "OFF_Stim", "Stim", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "Outside STN", "Outside", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "Single ring", "Ring", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "Ventral STN", "Ventral", Treatment)) %>%
    mutate(Treatment = ifelse(is.na(Treatment), "Dopa", Treatment))
  
  df %>% group_by(Condition2, Condition, Treatment) %>% summarise(n = n())
  df %<>% select(-Condition2)
  
  df %<>% mutate(Pat_Foggeur = ifelse(as.character(Pat_Foggeur)=="FALSE", "NF", "F")) %>%
    mutate(Group = forcats::as_factor(ifelse(GoNogo %in% c("C", "I"), "M", "A")), .before = Subject)
  
  df %<>% mutate(
    across(c(Subject, Pat_Foggeur, Condition, GoNogo, Cote, TrialName), ~forcats::as_factor(.x))
  )
  
  df %<>% dplyr::select(-Freq_InitiationPas) # same as cadence?
  df %<>% select(-CueTime)
}

# This reads the simplified dataset used by Saoussen
read_gait_data_magic <- function(filename
) {
  df = readr::read_delim(filename, delim = ";",
                         col_types = cols(
                           TrialName = col_character(),
                           TrialNum = col_integer(),
                           Subject = col_character(),
                           Condition = col_character(),
                           GoNogo = col_character(),
                           Session = col_character(),
                           Cote = col_character(),
                           CueTime = col_double(),
                           real_t_reac = col_double(),
                           TR = col_double(),
                           T0 = col_double(),
                           FO1 = col_double(),
                           FC1 = col_double(),
                           FO2 = col_double(),
                           FC2 = col_double(),
                           stime_time = col_double(),
                           real_t_Reaction = col_double(),
                           t_Reaction = col_double(),
                           t_APA = col_double(),
                           APA_antpost = col_double(),
                           APA_lateral = col_double(),
                           StepWidth = col_double(),
                           t_swing1 = col_double(),
                           t_DA = col_double(),
                           t_swing2 = col_double(),
                           t_cycle_marche = col_double(),
                           Longueur_pas = col_double(),
                           V_swing1 = col_double(),
                           Vy_FO1 = col_double(),
                           t_VyFO1 = col_double(),
                           Vm = col_double(),
                           t_Vm = col_double(),
                           VML_absolue = col_double(),
                           Freq_InitiationPas = col_double(),
                           Cadence = col_double(),
                           VZmin_APA = col_double(),
                           V1 = col_double(),
                           V2 = col_double(),
                           Diff_V = col_double(),
                           Freinage = col_double(),
                           t_chute = col_double(),
                           t_freinage = col_double(),
                           t_V1 = col_double(),
                           t_V2 = col_double()
                         )
  )
  
  df %<>% #dplyr::select(-c(real_t_reac:t_Reaction)) %>%
    dplyr::relocate(c(Session, Subject, Condition, TrialNum, GoNogo, Cote, 
                      TrialName))
  
  # Previously, longer subject Ids were reduced to three letters, keep this as a 
  # separate variable, but note that this reduction confounds two patients into DEm
  df %<>% mutate(Subject2 = ifelse(nchar(Subject) == 3,
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,3,3))),
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,4,4)))),
                 .after = Subject)
  
  df %<>% mutate(Subject = Subject2)
  
  # Split Condition into Condition (OFF/ON) and Treatment (Dopa, DBS site)
  df %<>% mutate(Condition2 = Condition, .after = Condition) %>%
    mutate(Condition = ifelse(Condition2 == "OFF", "OFF", "ON")) %>%
    mutate(Condition = ifelse(Condition2 == "OFF_Stim", "OFF", Condition)) %>%
    mutate(Treatment = Condition2, .after = Condition) %>%
    mutate(Treatment = ifelse(Condition2 == "Hot spot FOG", "Hotspot", NA)) %>%
    mutate(Treatment = ifelse(Condition2 == "Motor STN", "Motor", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "OFF_Stim", "Stim", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "Outside STN", "Outside", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "Single ring", "Ring", Treatment)) %>%
    mutate(Treatment = ifelse(Condition2 == "Ventral STN", "Ventral", Treatment)) %>%
    mutate(Treatment = ifelse(is.na(Treatment), "Dopa", Treatment))
  
  df %>% group_by(Condition2, Condition, Treatment) %>% summarise(n = n())
  df %<>% select(-Condition2)
  
  df %<>% #mutate(Pat_Foggeur = ifelse(as.character(Pat_Foggeur)=="FALSE", "NF", "F")) %>%
    mutate(Group = forcats::as_factor(ifelse(GoNogo %in% c("C", "I"), "M", "A")), .before = Subject)
  
  df %<>% mutate(Condition = factor(Condition, levels = c("OFF", "ON")))
  
  df %<>% mutate(
    across(c(Session, Subject, Subject2, GoNogo, Cote, TrialName), ~forcats::as_factor(.x))
  )
  
  df %<>% dplyr::select(-Freq_InitiationPas) # same as cadence?
  #df %<>% select(-TrialNum)
  
  df %<>% select(-c(CueTime:t_Reaction))
  
  # Some NaNs
  #df %<>% mutate_all(~ifelse(is.nan(.), NA, .))
  df %<>% mutate(across(everything(), ~replace(.x, is.nan(.x), NA)))
}

read_gait_data_gogait_control <- function(filename
) {
  df = readr::read_csv2(filename,
                         col_types = cols(
                           TrialName = col_character(),
                           TrialNum = col_double(),
                           Subject = col_character(),
                           Condition = col_character(),
                           GoNogo = col_character(),
                           Session = col_character(),
                           t_APA = col_double(),
                           APA_antpost = col_double(),
                           APA_lateral = col_double(),
                           StepWidth = col_double(),
                           t_swing1 = col_double(),
                           t_DA = col_double(),
                           Longueur_pas = col_double(),
                           V1 = col_double(),
                           V2 = col_double(),
                           Diff_V = col_double(),
                           Vm = col_double()
                         )
  )
  
  df %<>% #rename(Session = `Session `) %>%
    dplyr::relocate(c(Session, Subject, Condition, TrialNum, GoNogo,
                      TrialName))
  
  # Previously, longer subject Ids were reduced to three letters, keep this as a 
  # separate variable, but note that this reduction confounds two patients into DEm
  df %<>% mutate(Subject2 = ifelse(nchar(Subject) == 3,
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,3,3))),
                                   paste0(substr(Subject,1,2), tolower(substr(Subject,4,4)))),
                 .after = Subject)
  
  df %<>% mutate(Subject = paste0(Subject2, '_CTL'))
  
  df %<>% 
    mutate(Group = "S", .before = Subject)
  
  #df %<>% mutate(Condition = factor(Condition, levels = c("OFF", "ON")))
  
  df %<>% mutate(
    across(c(Session, Subject, Subject2, GoNogo, TrialName), ~forcats::as_factor(.x))
  )
  
  # Some NaNs
  #df %<>% mutate_all(~ifelse(is.nan(.), NA, .))
  df %<>% mutate(across(everything(), ~replace(.x, is.nan(.x), NA)))
}

read_gait_data_merged <- function(filename, 
                                  filename_magic
) {
  df1 <- read_gait_data(filename)
  df1 %<>% mutate(Treatment = "Dopa", .after = Condition)
  df2 <-read_gait_data_magic2(filename_magic)
  
  return(df1 %>% bind_rows(df2) %>% relocate(Session))
}