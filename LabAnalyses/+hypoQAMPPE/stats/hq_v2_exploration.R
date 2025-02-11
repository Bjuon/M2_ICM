#############################################################################################
##                                                                                         ##
##                                  hQ - v2 : Exploration                                  ##
##                                                                                         ##
#############################################################################################

## Libraries

Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()


# Load
Type_of_Spectrum = 'detail' # 'detail' or 'raw'
PlotSaveFolder = 'C:/LustreSync/hypoQAMPPE/Figures/Article/'
CoordRepere = "STN_boite" # ACPC_YeB or STN_boite
Normalisation = 'brut' # 'AUC100' or 'brut'

spcdata = arrow::read_parquet(paste0(PlotSaveFolder, "SpectrumDatabase_AllPat_AllCond_", Normalisation, ".parquet"))
clinicd = readxl::read_excel("C:/LustreSync/hypoQAMPPE/PatientInfo3.xlsx")
locdata = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesInterPlots_juillet2018.xlsx", sheet = CoordRepere)
locid   = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesInterPlots_juillet2018.xlsx", sheet = "MatchingId")
locplot = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesPlots_oct2017.xlsx", sheet = CoordRepere)
locThera= readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesPlots_oct2017.xlsx", sheet = "ClinicalContacts")
pathSTN_VTK =                "C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/VTK_STN/"

## 1) Localisation des signaux

query = spcdata %>% 
    filter(Freq < 100) %>%
    filter(Preproccess == "detail") %>%
    collect()
q1 = query
query = q1

query$Freq = ifelse(query$Freq > 81, "N", 
                    ifelse(query$Freq > 61, "gamma", 
                           ifelse(query$Freq > 35, "N", 
                                  ifelse(query$Freq > 20, "highBeta", 
                                         ifelse(query$Freq > 12, "lowBeta", 
                                                ifelse(query$Freq > 7.99, "alpha", 
                                                       ifelse(query$Freq > 2.99, "theta", "N")))))))
query %<>% filter(Freq != "N") 
query = rbind(query, query %>% filter(Freq %in% c("highBeta", "lowBeta")) %>% mutate(Freq = "beta"))%>%
  mutate(Freq = factor(Freq, levels = c("theta", "alpha", "beta", "lowBeta", "highBeta", "gamma")))

query %<>% dplyr::group_by(Patient, Treatment, Preproccess, ChanelLabel, Side, Freq) %>%
  dplyr::summarise(PSD = median(PSD), .groups = "drop")
query %<>% mutate(Patient = as.factor(Patient), Treatment = as.factor(Treatment), Preproccess = as.factor(Preproccess), Side = as.factor(Side), ChanelLabel = as.factor(ChanelLabel)) 
query$Side_Freq = as.factor(paste0(query$Side, ".", query$Treatment, ".", query$Freq))

q11 = query
query %<>% join_spectrum_loc(locdata) %>% mutate(Patient = as.factor(Patient)) 

## 1.1) 1 model all freqband

model = mgcv::bam(PSD ~ s(ML, AP, DV, by = Side_Freq, k = 73) + s(Patient, bs = "re"), data = query, cluster = parallel::makeCluster(16), nthreads = 16)
m1 = model
# check_model(model)  # long+++

# p = gratia::draw(model) # long+++
# ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMv2_PSDperLoc_freqband", ".png"), p, limitsize = FALSE, width = 50, height = 50)

mviz = mgcViz::getViz(model)
AP_range = seq(ceiling(min(query$AP)), floor(max(query$AP)), by = 1)
for (sf in seq_along(unique(query$Side_Freq))) {
  p = mgcViz::plotSlice(x = mgcViz::sm(mviz, sf), 
                    fix = list("AP" = AP_range), a.facet = list(ncol = 1)) + 
    mgcViz::l_fitRaster() + mgcViz::l_fitContour() + mgcViz::l_points() + mgcViz::l_rug() +
    scale_fill_gradientn(colours = pals::jet(100))
  
  ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMv2_PSDperLoc_freqband_", levels(query$Side_Freq)[sf], ".png"), p$ggObj, width = 10, height = 10)
}

## 1.2) 1 model per frequency
query_freqnum = q1 %>% mutate(Freq = round(as.numeric(Freq))) %>%
  dplyr::group_by(Patient, Treatment, Preproccess, ChanelLabel, Side, Freq) %>%
  dplyr::summarise(PSD = median(PSD), .groups = "drop") %>% 
  mutate(Patient = as.factor(Patient), Treatment = as.factor(Treatment), Preproccess = as.factor(Preproccess), Side = as.factor(Side), ChanelLabel = as.factor(ChanelLabel)) %>%
  mutate(Side_TTT = as.factor(paste0(Side, ".", Treatment)))
q21 = query_freqnum
query_freqnum %<>%
  join_spectrum_loc(locdata) %>%
  mutate(Patient = as.factor(Patient))
model = mgcv::bam(PSD ~ s(ML,AP,DV, Freq, by = Side_TTT) + s(Patient,bs="re"), data = query_freqnum)
m2 = model
print(summary(model))

mviz = mgcViz::getViz(model)
AP_range = seq(ceiling(min(query$AP)), floor(max(query$AP)), by = 1)
Freq_range = c(seq(1,35, by = 2), seq(40, 100, by = 5))

for (st in 1:length(unique(query$Side_TTT))) {
    p = mgcViz::plotSlice(x = mgcViz::sm(mviz, st), 
                        fix = list("AP" = AP_range, "Freq" = Freq_range)) + 
    mgcViz::l_fitRaster() + mgcViz::l_fitContour() + mgcViz::l_points() + mgcViz::l_rug() +
    scale_fill_gradientn(colours = pals::jet(100))

    ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMv2_PSDperLoc_allfreq_", levels(query$Side_TTT)[st], ".png"), p2$ggObj, limitsize = FALSE, width = 50, height = 10)
}

## 1.3) same as model 1 but YeB atlas coordinates
loctemp = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesInterPlots_juillet2018.xlsx", sheet = "ACPC_YeB")
loctemp %<>% mutate(Patient = locid$IdLFP[match(Patient_code, locid$IdLOC)]) %>% select(-Patient_code)

query = q11 %>% join_spectrum_loc(loctemp) %>% mutate(Patient = as.factor(Patient))
model = mgcv::bam(PSD ~ s(ML, AP, DV, by = Side_Freq) + s(Patient, bs = "re"), data = query)
m3 = model
summary(model)

## 1.4) 1 model per frequency but YeB atlas coordinates
query_freqnum = q21 %>% join_spectrum_loc(loctemp) %>% mutate(Patient = as.factor(Patient))
model = mgcv::bam(PSD ~ s(ML,AP,DV, Freq, by = Side_TTT) + s(Patient,bs="re"), data = query_freqnum)
m4 = model

"print('m1')
summary(m1)
R-sq.(adj) =  0.398   Deviance explained = 47.9%
fREML = -14816  Scale est. = 8.9636e-10  n = 1800
print('m2')
summary(m2)
R-sq.(adj) =  0.242   Deviance explained = 24.8%
fREML = -2.5982e+05  Scale est. = 1.9989e-09  n = 30300
print('m3')
summary(m3)
R-sq.(adj) =  0.356   Deviance explained = 42.7%
fREML = -14889  Scale est. = 9.5883e-10  n = 1800
print('m4')
summary(m4)
R-sq.(adj) =   0.26   Deviance explained = 26.5%
fREML = -2.599e+05  Scale est. = 1.9513e-09  n = 30300

anova(m1, m3, test = 'Chisq')
anova(m2, m4, test = 'Chisq')

===> Mieux vaut utiliser les coordonnées de la boite
"


## vis_gam_custom



## OLD visu

model = m1 
query = q11 %>% join_spectrum_loc(locdata) %>% mutate(Patient = as.factor(Patient))

rangeML_left  = grDevices::extendrange(query %>% filter(Side == "left")  %>% pull(ML), f = 0.1)
rangeDV_left  = grDevices::extendrange(query %>% filter(Side == "left")  %>% pull(DV), f = 0.1)
rangeML_right = grDevices::extendrange(query %>% filter(Side == "right") %>% pull(ML), f = 0.1)
rangeDV_right = grDevices::extendrange(query %>% filter(Side == "right") %>% pull(DV), f = 0.1)
rangeAP       = seq(ceiling(min(query$AP)), floor(max(query$AP)), by = 1)

for (sf in unique(query$Side_Freq)) {
  PSDlim_SF = range(predict(model, newdata = query %>% filter(Side_Freq == sf), type = "response"))
  if(grepl("left", sf)) {
    rangeML_local = rangeML_left
    rangeDV_local = rangeDV_left
    } else {
    rangeML_local = rangeML_right
    rangeDV_local = rangeDV_right
    }
  plot_list <- list()
  for (ap in rangeAP) {
    p = vis_gam_custom(model, view = c("ML", "DV"), cond = list(Side_Freq = sf, AP = ap), 
                 plot.type = "contour", color = "jet", too.far = 0.1, n.grid = 100, 
                 rangeML = rangeML_local, rangeDV = rangeDV_local, PSDlim_SF = PSDlim_SF, localtitle = paste("AP =", ap), lastAP = (rangeAP[length(rangeAP)] == ap))

   # p = p + geom_point(data = query %>% filter(Side_Freq == sf, AP < ap+1, AP > ap-1), aes(x = ML, y = DV), color = "black", size = 1)
    plot_list[[length(plot_list) + 1]] = p
  }
  combined_plot = wrap_plots(plot_list) + plot_annotation(sf)
  
  ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMv2_PSDperLoc_vis.gam_", sf, ".png"), combined_plot, width = 10, height = 10)
}


## 1.5) New Model post Brian
# changements : gamma/mean/logtransform/
todo_logtransform = T
query = spcdata %>% 
    filter(Freq < 100) %>%
    filter(Preproccess == "detail") %>%
    collect()
q1 = query
query = q1

query$Freq = ifelse(query$Freq > 61, "gamma", 
                           ifelse(query$Freq > 35, "N", 
                                  ifelse(query$Freq > 20, "highBeta", 
                                         ifelse(query$Freq > 12, "lowBeta", 
                                                ifelse(query$Freq > 7.99, "alpha", 
                                                       ifelse(query$Freq > 2.99, "theta", "N"))))))
query %<>% filter(Freq != "N") 
query = rbind(query, query %>% filter(Freq %in% c("highBeta", "lowBeta")) %>% mutate(Freq = "beta"))%>%
  mutate(Freq = factor(Freq, levels = c("theta", "alpha", "beta", "lowBeta", "highBeta", "gamma")))

if (todo_logtransform) query$PSD = log(query$PSD)

query %<>% dplyr::group_by(Patient, Treatment, Preproccess, ChanelLabel, Side, Freq) %>%
  dplyr::summarise(PSD = mean(PSD), .groups = "drop")
query %<>% mutate(Patient = as.factor(Patient), Treatment = as.factor(Treatment), Preproccess = as.factor(Preproccess), Side = as.factor(Side), ChanelLabel = as.factor(ChanelLabel)) 
query$Side_Freq = interaction(query$Treatment, query$Freq)

q51 = query
query %<>% join_spectrum_loc(locdata) %>% mutate(Patient = as.factor(Patient)) 

tictoc::tic()
model = mgcv::bam(PSD ~ s(ML, AP, DV, by = Side_Freq) + s(ML, AP, DV, by = Side) + s(Patient, bs = "re"), data = query, cluster = parallel::makeCluster(16), nthreads = 16)
m5 = model
tictoc::toc()
# save model 
dir.create(paste0(PlotSaveFolder,"/model"), showWarnings = F)
save(model, file = paste0(PlotSaveFolder,"/model/m5.RData"))

query$Side_Freq = interaction(query$Side, query$Treatment, query$Freq)
tictoc::tic()
model = mgcv::bam(PSD ~ s(ML, AP, DV, by = Side_Freq, k = 74) + s(Patient, bs = "re"), data = query, cluster = parallel::makeCluster(16), nthreads = 16)
m1meanlog = model
tictoc::toc()
save(model, file = paste0(PlotSaveFolder,"/model/m1meanlog.RData"))

## 2) Localisation des dipoles highest beta et comparaison avec les contacts cliniques

## 2.1) Raw spectrum


ACPClocdata = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesInterPlots_juillet2018.xlsx", sheet = "ACPC_YeB")
ACPClocplot = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesPlots_oct2017.xlsx", sheet = "ACPC_YeB")
ACPClocdata %<>% match_patient_names(locid)
ACPClocplot %<>% match_patient_names(locid)

queryLoc = spcdata %>% 
    filter(Freq < 35, Freq > 12.99) %>%
    filter(Preproccess == "base") %>% # raw or detailed ??? raw semble plus adapté pour le 
    collect() 
queryLoc %<>% dplyr::group_by(Patient, Treatment, Side) %>% 
    filter(PSD == max(PSD, na.rm = TRUE)) %>% 
    join_spectrum_loc(ACPClocdata) %>%
    pivot_longer(cols = c(ML, AP, DV), names_to = "Axe", values_to = "LocValue") %>%
    mutate(signalorclinic = "Highest Beta Dipole")
qlocB = queryLoc

ACPClocplot %<>% select_clinical_contacts(locThera, filter_contact = T) %>% 
    select(-Therapeutic) %>% 
    dplyr::group_by(Patient, Hemisphere) %>%
    dplyr::summarise(ML = mean(ML), AP = mean(AP), DV = mean(DV))
ACPClocplot %<>% match_patient_names(locid) %>%
    mutate(Side = ifelse(Hemisphere == "RH", "right", "left")) %>%
    pivot_longer(cols = c(ML, AP, DV), names_to = "Axe", values_to = "LocValue") %>%
    mutate(signalorclinic = "Therapeutical Contact", Treatment = NA) %>%
    select(Patient, Treatment, Side, Axe, LocValue, signalorclinic)

dfLoc = rbind(queryLoc %>% select(Patient, Treatment, Side, Axe, LocValue, signalorclinic), 
              ACPClocplot %>% mutate(Treatment = "OFF"),
              ACPClocplot %>% mutate(Treatment = "ON" ))
dfLoc %<>% mutate(LocValue = ifelse(Axe == "ML", abs(LocValue), LocValue))
dfLoc$signalorclinicsmall = ifelse(dfLoc$signalorclinic == "Highest Beta Dipole", "Beta", "Clinic")

ggplot(dfLoc, aes(x = interaction(signalorclinicsmall,Axe), y = LocValue, color = signalorclinic, group = interaction(Patient,Axe))) + 
    geom_line(aes(color = NULL), color = "gray70") + 
    ggbeeswarm::geom_beeswarm(alpha = 0.2, size = 2) + 
    theme_bw() +
    facet_wrap(~interaction(Treatment, Side)) + 
    ggtitle("Highest Beta - Raw Spectrum")


## 2.2) Detailed spectrum 

queryLoc = spcdata %>% 
    filter(Freq < 35, Freq > 12.99) %>%
    filter(Preproccess == "detail") %>% # raw or detailed ??? raw semble plus adapté pour le 
    collect()
queryLoc %<>% dplyr::group_by(Patient, Treatment, Side) %>%
    filter(PSD == max(PSD, na.rm = TRUE)) %>% 
    join_spectrum_loc(ACPClocdata) %>%
    pivot_longer(cols = c(ML, AP, DV), names_to = "Axe", values_to = "LocValue") %>%
    mutate(signalorclinic = "Highest Beta Dipole")
qlocD = queryLoc

dfLoc = rbind(queryLoc %>% select(Patient, Treatment, Side, Axe, LocValue, signalorclinic), 
              ACPClocplot %>% mutate(Treatment = "OFF"),
              ACPClocplot %>% mutate(Treatment = "ON" ))
dfLoc %<>% mutate(LocValue = ifelse(Axe == "ML", abs(LocValue), LocValue))
dfLoc$signalorclinicsmall = ifelse(dfLoc$signalorclinic == "Highest Beta Dipole", "Beta", "Clinic")

ggplot(dfLoc, aes(x = interaction(signalorclinicsmall,Axe), y = LocValue, color = signalorclinic, group = interaction(Patient,Axe))) + 
    geom_line(aes(color = NULL), color = "gray70") + 
    ggbeeswarm::geom_beeswarm(alpha = 0.2, size = 2) + 
    theme_bw() +
    facet_wrap(~interaction(Treatment, Side)) + 
    ggtitle("Highest Beta - Detailed Spectrum")

## 2.3) Non-highest

ACPClocdata = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesInterPlots_juillet2018.xlsx", sheet = "ACPC_YeB")
ACPClocplot = readxl::read_excel("C:/users/mathieu.yeche/Desktop/Imagerie_GoGait/hQ_coordinatesPlots_oct2017.xlsx", sheet = "ACPC_YeB")
ACPClocdata %<>% match_patient_names(locid)
ACPClocplot %<>% match_patient_names(locid)

queryLoc = spcdata %>% 
    filter(Freq < 35, Freq > 12.99) %>%
    filter(Preproccess == "base") %>% # raw or detailed ??? raw semble plus adapté pour le 
    collect() 
queryLoc %<>% dplyr::group_by(Patient, Treatment, Side, ChanelLabel) %>%
    filter(PSD == max(PSD, na.rm = TRUE)) %>%
    dplyr::group_by(Patient, Treatment, Side) %>%
    mutate(signalorclinic = ifelse(PSD == max(PSD, na.rm = TRUE),"Highest Beta Dipole","other dipole")) %>% 
    join_spectrum_loc(ACPClocdata) %>%
    pivot_longer(cols = c(ML, AP, DV), names_to = "Axe", values_to = "LocValue")

ACPClocplot %<>% select_clinical_contacts(locThera, filter_contact = F)
ACPClocplot %<>% match_patient_names(locid) %>%
    mutate(Side = ifelse(Hemisphere == "RH", "right", "left")) %>%
    pivot_longer(cols = c(ML, AP, DV), names_to = "Axe", values_to = "LocValue") %>%
    mutate(signalorclinic = ifelse(Therapeutic, "Therapeutical Contact", "clasic contact"), Treatment = NA) %>%
    mutate(ChanelLabel = "NA") %>%
    select(Patient, Treatment, Side, Axe, LocValue, signalorclinic, ChanelLabel)

dfLoc = rbind(queryLoc %>% select(Patient, Treatment, Side, Axe, LocValue, signalorclinic, ChanelLabel), 
              ACPClocplot %>% mutate(Treatment = "OFF"),
              ACPClocplot %>% mutate(Treatment = "ON" ))
dfLoc %<>% mutate(LocValue = ifelse(Axe == "ML", abs(LocValue), LocValue))
dfLoc$signalorclinicsmall = ifelse(dfLoc$signalorclinic == "Highest Beta Dipole", "Beta", 
                                   ifelse(dfLoc$signalorclinic == "Therapeutical Contact", "Clinic",
                                   ifelse(dfLoc$signalorclinic == "other dipole", "ip", "p")))

ggplot(dfLoc, aes(x = interaction(signalorclinicsmall,Axe), y = LocValue, color = signalorclinic, group = interaction(Patient,Axe))) + 
    geom_line(aes(color = NULL), color = "gray70") + 
    ggbeeswarm::geom_beeswarm(alpha = 0.2, size = 2) + 
    theme_bw() +
    facet_wrap(~interaction(Treatment, Side)) + 
    ggtitle("Highest Beta - Raw Spectrum")

## Distance analysis

dfLoc_by_patient = dfLoc %>% split(list(.$Patient, .$Side, .$Treatment), drop = TRUE)

distance_results = map_df(dfLoc_by_patient, function(d) {
    # Dipoles of interest
    dipoles = d %>%
        filter(signalorclinic %in% c("Highest Beta Dipole", "other dipole")) %>%
        mutate(signalorclinic = ifelse(signalorclinic == "other dipole", paste0("other dipole", ChanelLabel), signalorclinic)) %>%
        distinct(signalorclinic, Axe, LocValue) %>%
        pivot_wider(names_from = Axe, values_from = LocValue)
    # Therapeutical contact
    clinic = d %>%
        filter(signalorclinic == "Therapeutical Contact") %>%
        group_by(Patient, Treatment, Side , Axe, signalorclinic, ChanelLabel, signalorclinicsmall) %>%
        summarise(LocValue = mean(LocValue)) %>%
        pivot_wider(names_from = Axe, values_from = LocValue)

    # Compute distances for each dipole
    if (nrow(dipoles) > 0 && nrow(clinic) > 0) {
        dipoles <- dipoles %>%
            rowwise() %>%
            mutate(
                dist_to_clinic = sqrt(
                    (ML - clinic$ML)^2 +
                    (AP - clinic$AP)^2 +
                    (DV - clinic$DV)^2
                )
            )

        # Identify closest dipole
        min_dist <- min(dipoles$dist_to_clinic)
        which_closest <- dipoles %>% filter(dist_to_clinic == min_dist)
        
        if (nrow(which_closest) > 1) errrrror2
        data.frame(
            Patient  = unique(d$Patient),
            Side     = unique(d$Side),
            Treatment= unique(d$Treatment),
            ClosestDipole = paste(which_closest$signalorclinic, collapse=", "),
            DistValue = min_dist,
            DiffClosestHighest = min_dist - min(dipoles %>% filter(signalorclinic == "Highest Beta Dipole") %>% pull(dist_to_clinic))
        )
    } else {
        NULL
    }
})

distance_results$HighestClose = ifelse(abs(distance_results$DiffClosestHighest) < 0.1, "Highest Beta Dipole", "non")
print(distance_results)

## 2.4) Detailed vs Raw spectrum
dfLoc = rbind(qlocB %>% mutate(signalorclinic = Preproccess) %>% select(Patient, Treatment, Side, Axe, LocValue, signalorclinic), 
              qlocD %>% mutate(signalorclinic = Preproccess) %>% select(Patient, Treatment, Side, Axe, LocValue, signalorclinic))
dfLoc %<>% mutate(LocValue = ifelse(Axe == "ML", abs(LocValue), LocValue))
dfLoc$signalorclinicsmall = dfLoc$signalorclinic

ggplot(dfLoc, aes(x = interaction(signalorclinicsmall,Axe), y = LocValue, color = signalorclinic, group = interaction(Patient,Axe))) + 
    geom_line(aes(color = NULL), color = "gray70") + 
    ggbeeswarm::geom_beeswarm(alpha = 0.2, size = 2) + 
    theme_bw() +
    facet_wrap(~interaction(Treatment, Side)) + 
    ggtitle("Highest Beta - Raw vs Detailed Spectrum")









## 3) Localisation des dipoles highest beta et comparaison avec les contacts cliniques

## Recuperation des limites du STN


