########################################
#           Localisation               #
########################################

## Commencer par charger Query 

### MAGIC + GOGAIT !!!sans!!! GBMOV
# pq_path        = 
# gait_data_file = 
# Project        =  # Must be
# 
# locs_to_include = c("AS", "SM")
# tfdata  = arrow::open_dataset(pq_path)
# df_gait = read_gait_data(gait_data_file, params[["Project"]], drop_missing = T, keep_RT = T)
# df_gait = augment_gait_w_pca(df_gait, keep_RT = keep_RT)
# cnames = tfdata$schema$names ; time_col_names = cnames[str_ends(cnames, "0")] ; times = time_col_names %>% as.numeric() ; ind = times < -1 | times > -0.97 ; times_to_drop = time_col_names[ind]
# 
# query = tfdata %>% 
#   select(-all_of(times_to_drop)) %>%
#   filter(Freq == 1) %>%
#   filter(Loc %in% locs_to_include) %>%
#   collect()
# query %<>% 
#   mutate(Side_channel = ifelse(stringr::str_detect(Channel, "D"), "R", "L")) %>%
#   mutate(Side_firststep_ipsi_contra = ifelse(Side_channel==Side_firststep, "ipsi", "contra")) %>%
#   mutate(Loc = as.factor(Loc),
#          Condition = as.factor(Condition),
#          GoNogo = as.factor(GoNogo),
#          Side_channel = as.factor(Side_channel),
#          Side_firststep_ipsi_contra = as.factor(Side_firststep_ipsi_contra),
#          Meta_FOG = as.factor(Meta_FOG)) %>%
#   global_remove_artifacts(verbose = F) %>%
#   join_tf_and_gait(df_gait, keep_RT = keep_RT)

### MAGIC + GOGAIT + GBMOV
if(T){
setwd('C:/LustreSync/LAU Brian - 2024_GBMOV/Data/') 
source("../Codes/utils.R")
params <- NULL
params[["pq_path"]] <- "pq_wide/T0/"
params[["save_path"]] <- "model_fits/pro-ra/"
params[["gait_data_file"]] <- "ResAPA_32Pat_forPCA.xlsx"
params[["freqs_to_fit"]] <- 1:1
params[["time_window"]] <- c(-1, -0.975)
params[["locs_to_include"]] <- c("AS", "SM") # AS/SM/OUT
params[["FOG_to_include"]] <- c(0, 1,2) # 0/1/2
params[["DOPA_to_include"]] <- c("OFF", "ON")
params[["Replace_if_already_existing"]] = TRUE
params[["remove_artifacts"]] <- TRUE
params[["Bands_Averaging"]] = FALSE
params[["Export_in_RData"]] = FALSE

param_sets <- NULL
param_sets[[1]] <- c(model_id = 1, pc = "RPC.1")
param_sets[[2]] <- c(model_id = 1, pc = "RPC.2")
param_sets[[3]] <- c(model_id = 1, pc = "RPC.5")
params[["param_sets"]] <- param_sets
if (!dir.exists(params[["pq_path"]]))   {dir.create(params[["pq_path"]])}
if (!dir.exists(params[["save_path"]])) {dir.create(params[["save_path"]])}
## End part new MY
tfdata  <- arrow::open_dataset(params[["pq_path"]])
df_gait <- read_gait_data(params[["gait_data_file"]], drop_missing = T)
df_gait <- augment_gait_w_pca(df_gait)

freqs_to_fit    <- params[["freqs_to_fit"]]
time_window     <- params[["time_window"]]
locs_to_include <- params[["locs_to_include"]]
FOG_to_include  <- params[["FOG_to_include"]]
DOPA_to_include <- params[["DOPA_to_include"]]
param_sets      <- params[["param_sets"]]
params_remove_artifacts <- params[["remove_artifacts"]]

# timebins are in wide format, with names indicating bin centers
# create a vector of names to drop when loading data
cnames <- tfdata$schema$names
time_col_names <- cnames[str_ends(cnames, "0")]
times <- time_col_names %>% as.numeric()
ind <- times < time_window[1] | times > time_window[2]
times_to_drop <- time_col_names[ind]

if (FOG_to_include[1]  == "all") {FOG_to_include  = unique(tfdata$Meta_FOG)}
if (locs_to_include[1] == "all") {locs_to_include = unique(tfdata$Loc)}
if (DOPA_to_include[1] == "all") {DOPA_to_include = unique(tfdata$Condition)}
f=1
query <- tfdata %>% 
  select(-all_of(times_to_drop)) %>%
  filter(Freq == f) %>%
  filter(Loc %in% locs_to_include) %>%
  #    filter(Meta_FOG %in% FOG_to_include) %>%
  filter(Condition %in% DOPA_to_include) %>%
  collect()
query$Meta_FOG[query$TrialNum == 27 & query$Condition == "OFF" & query$Subject == "GIs"] = 2
query$Meta_FOG[query$TrialNum == 39 & query$Condition == "OFF" & query$Subject == "GIs"] = 2
query$Meta_FOG[query$TrialNum == 51 & query$Condition == "OFF" & query$Subject == "GIs"] = 2
query$Meta_FOG[query$TrialNum == 27 & query$Condition == "ON"  & query$Subject == "GIs"] = 1
query$Meta_FOG[query$TrialNum == 43 & query$Condition == "ON"  & query$Subject == "GAl"] = 1

query %<>% 
  mutate(Side_channel = ifelse(stringr::str_detect(Channel, "D"), "R", "L")) %>%
  mutate(Side_firststep_ipsi_contra = ifelse(Side_channel==Side_firststep, "ipsi", "contra")) %>%
  mutate(Loc = factor(Loc, levels = locs_to_include),
         Condition = factor(Condition, levels = c("OFF", "ON")),
         GoNogo = as.factor(GoNogo),
         Side_channel = as.factor(Side_channel),
         Side_firststep_ipsi_contra = as.factor(Side_firststep_ipsi_contra),
         Meta_FOG = as.factor(Meta_FOG))

query <- remove_artifacts(query)

query <- join_tf_and_gait(query, df_gait)
}


query %<>% select(Loc, Protocol, Channel, Subject) %>% 
  unique() %>%
  mutate(Elec = ifelse(Protocol == "MAGIC", "Cartesia", 
                       ifelse(Subject %in% c("BEm", "BAg", "COm", "DEj", "DRc", "GIs", "LOp", "REa"), 
                              "Cartesia", "3389"))) %>%
  select(-Protocol)


# Load necessary libraries
library(xml2)

# Load the XML file
xml_Cartesia_Pl_left  = read_xml("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/localisationsYeche2023/CARTESIA/XML/LH_Plots.xml")
xml_Cartesia_Pl_right = read_xml("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/localisationsYeche2023/CARTESIA/XML/RH_Plots.xml")

xml_3389_IP_left  = read_xml("C:/Users\\mathieu.yeche\\Desktop\\Imagerie_GoGait\\localisationsYeche2023\\3389\\XML\\LH_InterPlots.xml")
xml_3389_IP_right = read_xml("C:/Users\\mathieu.yeche\\Desktop\\Imagerie_GoGait\\localisationsYeche2023\\3389\\XML\\RH_InterPlots.xml")

# Electrodes 
#tableau_excel = readxl::read_xlsx("C:\\Users\\mathieu.yeche\\OneDrive - ICM\\TMP\\Fig24.07\\LocPlotsACPC\\Plots inclus par region.xlsx")

# Function to extract coordinates for a specific patient and contact
extract_coordinates <- function(patient_code, contact_code, hemisphere_code, Elec, xml_3389_IP_right, xml_3389_IP_left, xml_Cartesia_Pl_right, xml_Cartesia_Pl_left) {
  
  if (grepl("3389", Elec) | grepl("GBMOV", Elec)) {
    xml_file <- switch(hemisphere_code, 
                       "D" = xml_3389_IP_right, # Right hemisphere contact (D)
                       "G" = xml_3389_IP_left) # Left hemisphere contact (G)
    contact_code = paste0(substr(contact_code, 1, 1), '-', substr(contact_code, 2, 2))
    if (patient_code == "ROe") patient_code = "Roe"
    
    coord = find_plot(patient_code, contact_code, xml_file)
    
  } else {
    # if (contact_code %in% c("25D", "25G", "12D" "12G", "58D" "58G")) {
    #   xml_file <- switch(hemisphere_code, 
    #                      "D" = xml_Cartesia_IP_right, # Right hemisphere contact (D)
    #                      "G" = xml_Cartesia_IP_left) # Left hemisphere contact (G)
    #   contact_code = gsub("1", "0", contact_code)
    #   contact_code = gsub("[2-4]", "1", contact_code)
    #   contact_code = gsub("[5-7]", "2", contact_code)
    #   contact_code = gsub("8", "3", contact_code)
    #   contact_code = paste0(substr(contact_code, 1, 1), '-', substr(contact_code, 2, 2))
    # } else {
    xml_file <- switch(hemisphere_code, 
                       "D" = xml_Cartesia_Pl_right, # Right hemisphere contact (D)
                       "G" = xml_Cartesia_Pl_left) # Left hemisphere contact (G)
    
    contact_code1 = substr(contact_code, 1, 1) # get first character
    contact_code1 = as.numeric(contact_code1) - 1
    coord1 = find_plot(patient_code, contact_code1, xml_file)
    
    contact_code2 = substr(contact_code, 2, 2)
    contact_code2 = as.numeric(contact_code2) - 1
    coord2 = find_plot(patient_code, contact_code2, xml_file)
    
    coord = (coord1 + coord2)/2
  }
  return(coord)
}

find_plot <- function(patient_code, contact_code, xml_file) {
  
  # Find the matching subjectId in XML
  subject_node <- xml_find_first(xml_file, paste0("//locations[contains(@subjectId, '", patient_code, "')]"))
  
  # If no matching subject found, return NA for the coordinates
  if (is.na(subject_node)) {
    print(patient_code)
    #errrrrrrrrrrrr_pat
    return(data.frame(X = NA, Y = NA, Z = NA))
  }
  
  # Find the matching location in the XML for the contact number and hemisphere
  location_node <- xml_find_first(subject_node, paste0(".//location[@contactNumber='", contact_code, "']"))
  
  if (is.na(location_node)) {
    print(patient_code)
    #errrrrrrrrrrrr_loc
    return(data.frame(X = NA, Y = NA, Z = NA))
  }
  
  # Extract coordinates in "acpc.fantomas.NiftiWorld"
  coord_node <- xml_find_first(location_node, paste0(".//coordinates[@referential='", Coordinates_system, "']"))
  
  if (is.na(coord_node)) {
    print(patient_code)
    #errrrrrrrrrrrr_coord
    return(data.frame(X = NA, Y = NA, Z = NA))
  }
  
  # Extract X, Y, Z values
  x_val <- xml_attr(coord_node, "x")
  y_val <- xml_attr(coord_node, "y")
  z_val <- xml_attr(coord_node, "z")
  
  return(data.frame(X = as.numeric(x_val), Y = as.numeric(y_val), Z = as.numeric(z_val)))
}

# Add new columns to the table with extracted coordinates
# table_data_with_coordinates <- tableau_excel %>%
#   rowwise() %>%
#   mutate(Coordinates = list(extract_coordinates(Patient, Contact, substr(Contact, 3, 3), Elec, xml_3389_IP_right, xml_3389_IP_left, xml_Cartesia_Pl_right, xml_Cartesia_Pl_left))) %>%
#   unnest_wider(Coordinates)

Coordinates_system = "fantomas.NiftiWorld"
Locs = query %>%
  rowwise() %>%
  mutate(Coordinates = list(extract_coordinates(Subject, Channel, substr(Channel, 3, 3), Elec, xml_3389_IP_right, xml_3389_IP_left, xml_Cartesia_Pl_right, xml_Cartesia_Pl_left))) %>%
  unnest_wider(Coordinates) %>%
  rename(Patient = Subject, Contact = Channel, X.Fant = X, Y.Fant = Y, Z.Fant = Z) %>%
  mutate(Weight = 1) %>%
  select(Patient, Contact, Loc, Weight, Elec, X.Fant, Y.Fant, Z.Fant)

# Save
write.csv(Locs, paste0("C:/Users\\mathieu.yeche\\Desktop\\Imagerie_GoGait\\localisationsYeche2023\\Locs_papierMagic_", Coordinates_system,".csv"))

