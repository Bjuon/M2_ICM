#############################################################################################
##                                                                                         ##
##                                 EMG Summary Analysis                                    ##
##                                                                                         ##
#############################################################################################


Load_utils = try(source(paste0(sub("/[^/]*$", "", rstudioapi::getActiveDocumentContext()$path), "/utils.R")), silent = TRUE)
if (inherits(Load_utils, "try-error")) {ifelse((Sys.info()["nodename"] == "UMR-LAU-WP011" || Sys.info()["nodename"] == "ICM-LAU-WF006"), source("C:/Users/mathieu.yeche/Desktop/GitHub/LabAnalyses/+MAGIC/r/utils.R"), source("/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/utils.R")) ; print("Using MAGIC utils.R !!! Be sure to update")}
LoadLibraries()

source("C:/Users/mathieu.yeche/Desktop/GitHub/PhD_Scripts/shared_utils/PCA_utils.R")

EMG_data      = read_emg_data("Z:/DATA/EMG_Enveloppes_PPN_spon.csv")
tfdata        = arrow::open_dataset('Z:/PPN/Regions1PPN/pq_wide/T0_ldNOR/')
df_gait_light = read_gait_data("U:/MarcheReelle/00_notes/ResAPA_PPN.xlsx")

EMG_data$Meta_FOG = df_gait_light$Meta_FOG[match(paste0(EMG_data$Subject, EMG_data$Condition, EMG_data$TrialNum), paste0(df_gait_light$Subject2,df_gait_light$Condition,df_gait_light$TrialNum))] 
print("still not compatible with gbmov and percept")
EMG_data$Meta_FOG[EMG_data$Subject == "AVl" & EMG_data$Condition == "ON" & EMG_data$TrialNum == 25] = 1
EMG_data$AlphaEMG_Vastus[EMG_data$Subject == "SOd"] = NA ; EMG_data$BetaEMG_Vastus[EMG_data$Subject == "SOd"] = NA ; EMG_data$Enveloppe_Vastus[EMG_data$Subject == "SOd"] = NA
EMG_data$Categ = paste0(EMG_data$Condition, ifelse(EMG_data$Meta_FOG==2, " FOG+/+ [avec]", " FOG+/- [sans]"))
EMG_data$indexSide = paste0(EMG_data$Subject, EMG_data$Side_channel, EMG_data$Condition, EMG_data$TrialNum)
EMG_data$index     = paste0(EMG_data$Subject,                        EMG_data$Condition, EMG_data$TrialNum)

# Get Ipsi-Contra
time_col_names = tfdata$schema$names[str_ends(tfdata$schema$names, "0")] ; times = time_col_names %>% as.numeric() ; times_to_drop = time_col_names[times != -0.98]
query = tfdata %>% select(-all_of(times_to_drop)) %>%  filter(Freq == 1) %>%
  collect() %>% #  mutate(Side_channel = ifelse(stringr::str_detect(Channel, "D"), "R", "L")) %>%  mutate(Side_firststep_ipsi_contra = ifelse(Side_channel==Side_firststep, "ipsi", "contra")) %>%
  mutate(index = paste0(Subject, Condition, TrialNum))
EMG_data$Ipsi_Contra = ifelse(EMG_data$Side_channel != query$Side_firststep[match(EMG_data$index, query$index)], "ipsi", "contra")
EMG_data$IC_categ    = paste0(EMG_data$Categ, " - ", EMG_data$Ipsi_Contra)




EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Soleus",  "Subject", title_plot = "Alpha Frequency - EMG Soleus per Patient (no side)",   ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Tibialis","Subject", title_plot = "Alpha Frequency - EMG Tibialis per Patient (no side)", ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Soleus",   "Subject", title_plot = "Beta Frequency - EMG Soleus per Patient (no side)",    ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Tibialis", "Subject", title_plot = "Beta Frequency - EMG Tibialis per Patient (no side)",  ylabel_plot = "EMG (uV)") + theme_Publication()

EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Soleus",  "Categ", title_plot = "Alpha Frequency - EMG Soleus per type of trial (no side)",   ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Tibialis","Categ", title_plot = "Alpha Frequency - EMG Tibialis per type of trial (no side)", ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Soleus",   "Categ", title_plot = "Beta Frequency - EMG Soleus per type of trial (no side)",    ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Tibialis", "Categ", title_plot = "Beta Frequency - EMG Tibialis per type of trial (no side)",  ylabel_plot = "EMG (uV)") + theme_Publication()

m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == -0.98))
emm = emmeans::emmeans(m, pairwise ~ Categ)$contrast %>% as.data.frame() %>% filter(p.value < 0.15) %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "AlphaEMG_Vastus") %>% select(Muscle, contrast, pval_text, everything())
emmean = emm
m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == -0.98))
emm = emmeans::emmeans(m, pairwise ~ Categ)$contrast %>% as.data.frame() %>% filter(p.value < 0.15) %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "AlphaEMG_Tibialis") %>% select(Muscle, contrast, pval_text, everything())
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Vastus ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == -0.98))
emm = emmeans::emmeans(m, pairwise ~ Categ)$contrast %>% as.data.frame() %>% filter(p.value < 0.15) %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "AlphaEMG_Vastus") %>% select(Muscle, contrast, pval_text, everything())
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == -0.98))
emm = emmeans::emmeans(m, pairwise ~ Categ)$contrast %>% as.data.frame() %>% filter(p.value < 0.15) %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "BetaEMG_Soleus") %>% select(Muscle, contrast, pval_text, everything())
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == -0.98))
emm = emmeans::emmeans(m, pairwise ~ Categ)$contrast %>% as.data.frame() %>% filter(p.value < 0.15) %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "BetaEMG_Tibialis") %>% select(Muscle, contrast, pval_text, everything())
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Vastus ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == -0.98))
emm = emmeans::emmeans(m, pairwise ~ Categ)$contrast %>% as.data.frame() %>% filter(p.value < 0.15) %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "BetaEMG_Vastus") %>% select(Muscle, contrast, pval_text, everything())
emmean = rbind(emmean, emm)

emmean %>% knitr::kable()
#   |Muscle            |contrast                              | pval_text|   estimate|        SE|        df|   t.ratio|
#   |------------------|--------------------------------------|----------|-----------|----------|----------|----------|
#   |AlphaEMG_Tibialis |OFF FOG+/- [sans] - OFF FOG+/+ [avec] | 0.1338267| -0.0248199| 0.0113907| 150.20109| -2.178966|
#   |AlphaEMG_Vastus   |OFF FOG+/- [sans] - OFF FOG+/+ [avec] | 0.0209419|  0.8356635| 0.2819056|  72.09172|  2.964339|
#   |AlphaEMG_Vastus   |OFF FOG+/- [sans] - ON FOG+/- [sans]  | 0.0000000|  0.5865217| 0.0933679| 147.23936|  6.281835|
#   |AlphaEMG_Vastus   |OFF FOG+/- [sans] - ON FOG+/+ [avec]  | 0.0000713|  0.6109593| 0.1343172| 130.79614|  4.548630|
#   |BetaEMG_Tibialis  |OFF FOG+/- [sans] - OFF FOG+/+ [avec] | 0.0132810| -0.9172626| 0.2984610| 150.16529| -3.073309|
#   |BetaEMG_Tibialis  |OFF FOG+/+ [avec] - ON FOG+/- [sans]  | 0.0469484|  0.7604054| 0.2899467| 149.80283|  2.622569|
#   |BetaEMG_Tibialis  |OFF FOG+/+ [avec] - ON FOG+/+ [avec]  | 0.0826039|  0.7041823| 0.2941438| 149.76294|  2.394007|
#   |BetaEMG_Vastus    |OFF FOG+/- [sans] - ON FOG+/- [sans]  | 0.0000028|  1.9542346| 0.3707277| 148.93522|  5.271347|
#   |BetaEMG_Vastus    |OFF FOG+/- [sans] - ON FOG+/+ [avec]  | 0.0000729|  2.4942707| 0.5508542| 143.15989|  4.528005|


### EMG Enveloppe
ggplot(EMG_data, aes(y = Enveloppe_Tibialis, x = Time, color = Categ, group = indexSide)) + geom_line() + theme_Publication()
ggplot(EMG_data, aes(y = Enveloppe_Soleus, x = Time, color = Categ, group = indexSide)) + geom_line() + theme_Publication()
ggplot(EMG_data, aes(y = Enveloppe_Tibialis, x = Time, color = Categ, group = indexSide)) + geom_line() + theme_Publication() + facet_wrap(~Subject)
ggplot(EMG_data, aes(y = Enveloppe_Soleus, x = Time, color = Categ, group = indexSide)) + geom_line() + theme_Publication() + facet_wrap(~Subject)

nTrialSide = length(unique(EMG_data$indexSide))
EMG_mean = EMG_data %>% group_by(Categ,Time) %>% summarise(SE_Enveloppe_Tibialis = sd(Enveloppe_Tibialis, na.rm=T)/sqrt(nTrialSide), SE_Enveloppe_Soleus = sd(Enveloppe_Soleus, na.rm=T)/sqrt(nTrialSide), Enveloppe_Tibialis = mean(Enveloppe_Tibialis), Enveloppe_Soleus = mean(Enveloppe_Soleus), .groups = "drop")

# Let's model point by point
emm_Tib = data.frame() ; emm_Sol = data.frame()
for(tp in unique(EMG_data$Time)) {
  m = suppressMessages(lmerTest::lmer("Enveloppe_Tibialis ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == tp)))
  emm = emmeans::emmeans(m, pairwise ~ Categ, adjust = "none")$contrast %>% as.data.frame() %>% mutate(Time = tp)
  emm_Tib = rbind(emm_Tib, emm)
  m = suppressMessages(lmerTest::lmer("Enveloppe_Soleus ~ 1 + Categ + (1|Subject) + (1|Side_channel)", data = EMG_data %>% filter(Time == tp)))
  emm = emmeans::emmeans(m, pairwise ~ Categ, adjust = "none")$contrast %>% as.data.frame() %>% mutate(Time = tp)
  emm_Sol = rbind(emm_Sol, emm)
}

emm_Tib_C1 = emm_Tib %>% filter(contrast == "(OFF FOG+/- [sans]) - (OFF FOG+/+ [avec])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Sol_C1 = emm_Sol %>% filter(contrast == "(OFF FOG+/- [sans]) - (OFF FOG+/+ [avec])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Tib_C2 = emm_Tib %>% filter(contrast == "(OFF FOG+/- [sans]) - (ON FOG+/- [sans])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Sol_C2 = emm_Sol %>% filter(contrast == "(OFF FOG+/- [sans]) - (ON FOG+/- [sans])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Tib_C3 = emm_Tib %>% filter(contrast == "(OFF FOG+/+ [avec]) - (ON FOG+/+ [avec])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Sol_C3 = emm_Sol %>% filter(contrast == "(OFF FOG+/+ [avec]) - (ON FOG+/+ [avec])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Tib_C4 = emm_Tib %>% filter(contrast == "(ON FOG+/- [sans]) - (ON FOG+/+ [avec])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))
emm_Sol_C4 = emm_Sol %>% filter(contrast == "(ON FOG+/- [sans]) - (ON FOG+/+ [avec])") %>% mutate(pval_adjust = p.adjust(p.value, method = "BH"))

height  = max(EMG_mean$Enveloppe_Tibialis + EMG_mean$SE_Enveloppe_Tibialis)
ceiling = min(EMG_mean$Enveloppe_Tibialis - EMG_mean$SE_Enveloppe_Tibialis)
ggplot(EMG_mean, aes(y = Enveloppe_Tibialis, x = Time, color = Categ, fill = Categ)) + 
  geom_ribbon(data = EMG_mean, aes(color = NULL, ymin = Enveloppe_Tibialis - SE_Enveloppe_Tibialis, ymax = Enveloppe_Tibialis + SE_Enveloppe_Tibialis), alpha = 0.2) +
  geom_line() + 
  geom_ribbon(data = emm_Tib_C1, aes(x = Time, y = NULL, ymin = height, ymax = height+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "blue", show.legend = FALSE) +
  geom_ribbon(data = emm_Tib_C2, aes(x = Time, y = NULL, ymin = height+0.02, ymax = height+0.02+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "red", show.legend = FALSE) +
  geom_ribbon(data = emm_Tib_C3, aes(x = Time, y = NULL, ymin = height+0.04, ymax = height+0.04+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "green", show.legend = FALSE) +
  geom_ribbon(data = emm_Tib_C4, aes(x = Time, y = NULL, ymin = height+0.06, ymax = height+0.06+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "purple", show.legend = FALSE) +
  theme_Publication() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Tibialis Enveloppe per type of trial") 

ggplot(EMG_mean, aes(y = Enveloppe_Soleus, x = Time, color = Categ, fill = Categ)) +
  geom_ribbon(aes(color = NULL, ymin = Enveloppe_Soleus - SE_Enveloppe_Soleus, ymax = Enveloppe_Soleus + SE_Enveloppe_Soleus), alpha = 0.2) +
  geom_line() + theme_Publication() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Soleus Enveloppe per type of trial")

ggplot(EMG_mean, aes(y = Enveloppe_Soleus, x = Time, color = Categ, fill = Categ)) +
  geom_ribbon(aes(color = NULL, ymin = Enveloppe_Soleus - SE_Enveloppe_Soleus, ymax = Enveloppe_Soleus + SE_Enveloppe_Soleus), alpha = 0.35) +
  geom_line() + theme_dark_black_classiclegend() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Soleus Enveloppe per type of trial")
ggplot(EMG_mean, aes(y = Enveloppe_Tibialis, x = Time, color = Categ, fill = Categ)) +
  geom_ribbon(aes(color = NULL, ymin = Enveloppe_Tibialis - SE_Enveloppe_Tibialis, ymax = Enveloppe_Tibialis + SE_Enveloppe_Tibialis), alpha = 0.35) +
  geom_line() + theme_dark_black_classiclegend() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Tibialis Enveloppe per type of trial")

height  = max(EMG_mean$Enveloppe_Soleus + EMG_mean$SE_Enveloppe_Soleus)
ceiling = min(EMG_mean$Enveloppe_Soleus - EMG_mean$SE_Enveloppe_Soleus)
ggplot(EMG_mean, aes(y = Enveloppe_Soleus, x = Time, color = Categ, fill = Categ)) +
  geom_ribbon(aes(color = NULL, ymin = Enveloppe_Soleus - SE_Enveloppe_Soleus, ymax = Enveloppe_Soleus + SE_Enveloppe_Soleus), alpha = 0.2) +
  geom_line() +
  geom_ribbon(data = emm_Sol_C1, aes(x = Time, y = NULL, ymin = height, ymax = height+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "blue", show.legend = FALSE) +
  geom_ribbon(data = emm_Sol_C2, aes(x = Time, y = NULL, ymin = height+0.02, ymax = height+0.02+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "red", show.legend = FALSE) +
  geom_ribbon(data = emm_Sol_C3, aes(x = Time, y = NULL, ymin = height+0.04, ymax = height+0.04+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "green", show.legend = FALSE) +
  geom_ribbon(data = emm_Sol_C4, aes(x = Time, y = NULL, ymin = height+0.06, ymax = height+0.06+ifelse(pval_adjust<0.05,0.02,0)*(height-ceiling), color = NULL), fill = "purple", show.legend = FALSE) +
  theme_Publication() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Soleus Enveloppe per type of trial")


## Ipsi-contra analysis
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Soleus",  "Ipsi_Contra", title_plot = "Alpha Frequency - EMG Soleus per side",   ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Soleus",  "IC_categ",    title_plot = "Alpha Frequency - EMG Soleus per side",   ylabel_plot = "EMG (uV)") + theme_dark_black_classiclegend()

EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Tibialis", "Ipsi_Contra", title_plot = "Alpha Frequency - EMG Tibialis per side", ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("AlphaEMG_Tibialis", "IC_categ",    title_plot = "Alpha Frequency - EMG Tibialis per side", ylabel_plot = "EMG (uV)") + theme_dark_black_classiclegend()

EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Soleus",   "Ipsi_Contra", title_plot = "Beta Frequency - EMG Soleus per side",   ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Soleus",   "IC_categ",    title_plot = "Beta Frequency - EMG Soleus per side",   ylabel_plot = "EMG (uV)") + theme_dark_black_classiclegend()

EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Tibialis", "Ipsi_Contra", title_plot = "Beta Frequency - EMG Tibialis per side", ylabel_plot = "EMG (uV)") + theme_Publication()
EMG_data %>% filter(Time == -0.98) %>% RainbowPlot("BetaEMG_Tibialis", "IC_categ",    title_plot = "Beta Frequency - EMG Tibialis per side", ylabel_plot = "EMG (uV)") + theme_dark_black_classiclegend()

m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast) %>% as.data.frame() %>% filter_contrasts() %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "AlphaEMG_Soleus") %>% select(Muscle, contrast, pval_text, everything()) %>% mutate(pval_text = p.adjust(pval_text, method = "fdr"))
emmean = emm
m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast) %>% as.data.frame() %>% filter_contrasts() %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "AlphaEMG_Tibialis") %>% select(Muscle, contrast, pval_text, everything()) %>% mutate(pval_text = p.adjust(pval_text, method = "fdr"))
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Vastus ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast) %>% as.data.frame() %>% filter_contrasts() %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "AlphaEMG_Vastus") %>% select(Muscle, contrast, pval_text, everything()) %>% mutate(pval_text = p.adjust(pval_text, method = "fdr"))
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast) %>% as.data.frame() %>% filter_contrasts() %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "BetaEMG_Soleus") %>% select(Muscle, contrast, pval_text, everything()) %>% mutate(pval_text = p.adjust(pval_text, method = "fdr"))
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast) %>% as.data.frame() %>% filter_contrasts() %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "BetaEMG_Tibialis") %>% select(Muscle, contrast, pval_text, everything()) %>% mutate(pval_text = p.adjust(pval_text, method = "fdr"))
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Vastus ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast) %>% as.data.frame() %>% filter_contrasts() %>% rename(pval_text = p.value) %>% mutate(contrast = str_remove_all(contrast, "[()]")) %>% mutate(Muscle = "BetaEMG_Vastus") %>% select(Muscle, contrast, pval_text, everything()) %>% mutate(pval_text = p.adjust(pval_text, method = "fdr"))
emmean = rbind(emmean, emm)

emmean %>% knitr::kable()
emmean[emmean$pval_text_numeric < 0.15, ] %>% knitr::kable()
# |Muscle            |contrast                                    | pval_text|   estimate|        SE|       df|   t.ratio| pval_text_numeric|
# |:-----------------|:-------------------------------------------|---------:|----------:|---------:|--------:|---------:|-----------------:|
# |AlphaEMG_Soleus   |ipsi OFF Meta_FOG1 - ipsi OFF Meta_FOG2     | 0.0121865| -0.0237814| 0.0093688| 145.9238| -2.538350|         0.0121865|
# |AlphaEMG_Soleus   |contra OFF Meta_FOG2 - ipsi OFF Meta_FOG2   | 0.0774274| -0.0210133| 0.0118158| 145.3541| -1.778408|         0.0774274|
# |AlphaEMG_Soleus   |ipsi OFF Meta_FOG2 - ipsi ON Meta_FOG2      | 0.0178127|  0.0227054| 0.0094754| 147.9993|  2.396248|         0.0178127|
# |AlphaEMG_Tibialis |contra OFF Meta_FOG1 - contra OFF Meta_FOG2 | 0.0493267| -0.0291727| 0.0147185| 147.9041| -1.982051|         0.0493267|
# |AlphaEMG_Tibialis |ipsi OFF Meta_FOG1 - ipsi ON Meta_FOG1      | 0.0013553| -0.0154958| 0.0047432| 145.9408| -3.266941|         0.0013553|
# |AlphaEMG_Tibialis |contra ON Meta_FOG1 - ipsi ON Meta_FOG1     | 0.0006068| -0.0174702| 0.0049838| 145.1342| -3.505409|         0.0006068|
# |AlphaEMG_Tibialis |ipsi ON Meta_FOG1 - ipsi ON Meta_FOG2       | 0.1060143|  0.0110960| 0.0068228| 147.6466|  1.626319|         0.1060143|
# |AlphaEMG_Tibialis |contra OFF Meta_FOG2 - contra ON Meta_FOG2  | 0.0799438|  0.0263415| 0.0149397| 147.2507|  1.763184|         0.0799438|
# |AlphaEMG_Vastus   |contra OFF Meta_FOG1 - ipsi OFF Meta_FOG1   | 0.0193266| -0.2878308| 0.1216713| 144.5057| -2.365643|         0.0193266|
# |AlphaEMG_Vastus   |contra OFF Meta_FOG1 - contra ON Meta_FOG1  | 0.0003423|  0.4838412| 0.1319229| 145.9993|  3.667607|         0.0003423|
# |AlphaEMG_Vastus   |contra OFF Meta_FOG1 - contra OFF Meta_FOG2 | 0.0862825|  0.6753904| 0.3905162| 120.5574|  1.729481|         0.0862825|
# |AlphaEMG_Vastus   |ipsi OFF Meta_FOG1 - ipsi ON Meta_FOG1      | 0.0000006|  0.6892021| 0.1319229| 145.9993|  5.224280|         0.0000006|
# |AlphaEMG_Vastus   |ipsi OFF Meta_FOG1 - ipsi OFF Meta_FOG2     | 0.0120154|  0.9959367| 0.3905162| 120.5574|  2.550308|         0.0120154|
# |BetaEMG_Soleus    |contra ON Meta_FOG2 - ipsi ON Meta_FOG2     | 0.1414379| -0.1194330| 0.0807789| 145.0408| -1.478517|         0.1414379|
# |BetaEMG_Tibialis  |contra OFF Meta_FOG1 - contra OFF Meta_FOG2 | 0.0004425| -1.3302537| 0.3700119| 146.2171| -3.595165|         0.0004425|
# |BetaEMG_Tibialis  |ipsi OFF Meta_FOG1 - ipsi ON Meta_FOG1      | 0.0009382| -0.4038349| 0.1195577| 145.2694| -3.377741|         0.0009382|
# |BetaEMG_Tibialis  |contra ON Meta_FOG1 - ipsi ON Meta_FOG1     | 0.0003807| -0.4573468| 0.1257013| 145.0189| -3.638360|         0.0003807|
# |BetaEMG_Tibialis  |contra OFF Meta_FOG2 - ipsi OFF Meta_FOG2   | 0.0677025|  0.8657606| 0.4703313| 145.0189|  1.840746|         0.0677025|
# |BetaEMG_Tibialis  |contra OFF Meta_FOG2 - contra ON Meta_FOG2  | 0.0001467|  1.4680577| 0.3764952| 145.9144|  3.899273|         0.0001467|
# |BetaEMG_Tibialis  |contra ON Meta_FOG2 - ipsi ON Meta_FOG2     | 0.0012584| -0.6597793| 0.2005500| 145.0189| -3.289850|         0.0012584|
# |BetaEMG_Vastus    |contra OFF Meta_FOG1 - contra ON Meta_FOG1  | 0.0000076|  2.4069660| 0.5183532| 145.6751|  4.643486|         0.0000076|
# |BetaEMG_Vastus    |ipsi OFF Meta_FOG1 - ipsi ON Meta_FOG1      | 0.0043955|  1.4998461| 0.5183532| 145.6751|  2.893483|         0.0043955|


### EMG Enveloppe Ipsi-contra analysis
ggplot(EMG_data, aes(y = Enveloppe_Tibialis, x = Time, color = IC_categ, group = indexSide)) + geom_line() + theme_Publication()
ggplot(EMG_data, aes(y = Enveloppe_Soleus, x = Time, color = IC_categ, group = indexSide)) + geom_line() + theme_Publication()
ggplot(EMG_data, aes(y = Enveloppe_Tibialis, x = Time, color = IC_categ, group = indexSide)) + geom_line() + theme_Publication() + facet_wrap(~Subject)
ggplot(EMG_data, aes(y = Enveloppe_Soleus, x = Time, color = IC_categ, group = indexSide)) + geom_line() + theme_Publication() + facet_wrap(~Subject)

nTrialSide = length(unique(EMG_data$indexSide))
EMG_mean = EMG_data %>% group_by(IC_categ,Time) %>% summarise(SE_Enveloppe_Tibialis = sd(Enveloppe_Tibialis, na.rm=T)/sqrt(nTrialSide), SE_Enveloppe_Soleus = sd(Enveloppe_Soleus, na.rm=T)/sqrt(nTrialSide), Enveloppe_Tibialis = mean(Enveloppe_Tibialis), Enveloppe_Soleus = mean(Enveloppe_Soleus), .groups = "drop")

# Let's model point by point
emm_Tib = data.frame() ; emm_Sol = data.frame()
for(tp in unique(EMG_data$Time)) {
  m = suppressMessages(lmerTest::lmer("Enveloppe_Tibialis ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == tp)))
  emm = emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast %>% as.data.frame() %>% mutate(Time = tp) %>% filter_contrasts()
  emm_Tib = rbind(emm_Tib, emm)
  m = suppressMessages(lmerTest::lmer("Enveloppe_Soleus ~ 1 + Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = EMG_data %>% filter(Time == tp)))
  emm = emmeans::emmeans(m, pairwise ~ Ipsi_Contra*Condition*Meta_FOG, adjust = "none")$contrast %>% as.data.frame() %>% mutate(Time = tp) %>% filter_contrasts()
  emm_Sol = rbind(emm_Sol, emm)
}

emm_Tib$p.adjust = p.adjust(emm_Tib$p.value, method = "BH")
emm_Sol$p.adjust = p.adjust(emm_Sol$p.value, method = "BH")
emm_Tib$signif = NA ; emm_Sol$signif = NA ; i = 0
for (contrast in unique(emm_Tib$contrast)) {
  i = i + 1
  emm_Tib$signif[emm_Tib$contrast == contrast] = ifelse(emm_Tib$p.adjust[emm_Tib$contrast == contrast] < 0.05, i, NA)
  emm_Sol$signif[emm_Sol$contrast == contrast] = ifelse(emm_Sol$p.adjust[emm_Sol$contrast == contrast] < 0.05, i, NA)
}


height  = max(EMG_mean$Enveloppe_Soleus + EMG_mean$SE_Enveloppe_Soleus)
ceiling = min(EMG_mean$Enveloppe_Soleus - EMG_mean$SE_Enveloppe_Soleus)
ggplot(EMG_mean, aes(y = Enveloppe_Soleus, x = Time, color = IC_categ, fill = IC_categ)) +
  geom_ribbon(aes(color = NULL, ymin = Enveloppe_Soleus - SE_Enveloppe_Soleus, ymax = Enveloppe_Soleus + SE_Enveloppe_Soleus), alpha = 0.2) +
  geom_line() +
  geom_point(data = emm_Sol , aes(x = Time, y = height + signif/100, color = NULL, fill = NULL), color = "black", size = 1) +
  theme_Publication() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Soleus Enveloppe per type of trial")


height  = max(EMG_mean$Enveloppe_Tibialis + EMG_mean$SE_Enveloppe_Tibialis)
ceiling = min(EMG_mean$Enveloppe_Tibialis - EMG_mean$SE_Enveloppe_Tibialis)
ggplot(EMG_mean, aes(y = Enveloppe_Tibialis, x = Time, color = IC_categ, fill = IC_categ)) +
  geom_ribbon(aes(color = NULL, ymin = Enveloppe_Tibialis - SE_Enveloppe_Tibialis, ymax = Enveloppe_Tibialis + SE_Enveloppe_Tibialis), alpha = 0.2) +
  geom_line() +
  geom_point(data = emm_Tib , aes(x = Time, y = height + signif/100, color = NULL, fill = NULL), color = "black", size = 1) +
  theme_Publication() + labs(y = "Enveloppe (uV)", x = "Time (s)", title = "Mean Tibialis Enveloppe per type of trial")





######################### RPC * EMG ######################### 

RPC_EMG_data = EMG_data

gait_data_file = c("C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx", "U:/MarcheReelle/00_notes/ResAPA_PPN.xlsx")
df_gait = read_gait_data(gait_data_file, "PPN_GI", drop_missing = T, keep_RT = T)
df_gait = augment_gait_w_pca(df_gait, keep_RT = T)
RPC_EMG_data$RPC.1 = df_gait$RPC.1[match(paste0(RPC_EMG_data$Subject, RPC_EMG_data$Condition, RPC_EMG_data$TrialNum), paste0(df_gait$Subject2,df_gait$Condition,df_gait$TrialNum))] 
RPC_EMG_data$RPC.2 = df_gait$RPC.2[match(paste0(RPC_EMG_data$Subject, RPC_EMG_data$Condition, RPC_EMG_data$TrialNum), paste0(df_gait$Subject2,df_gait$Condition,df_gait$TrialNum))]
RPC_EMG_data$RPC.3 = df_gait$RPC.3[match(paste0(RPC_EMG_data$Subject, RPC_EMG_data$Condition, RPC_EMG_data$TrialNum), paste0(df_gait$Subject2,df_gait$Condition,df_gait$TrialNum))]
RPC_EMG_data$RPC.4 = df_gait$RPC.4[match(paste0(RPC_EMG_data$Subject, RPC_EMG_data$Condition, RPC_EMG_data$TrialNum), paste0(df_gait$Subject2,df_gait$Condition,df_gait$TrialNum))]
RPC_EMG_data$RPC.5 = df_gait$RPC.5[match(paste0(RPC_EMG_data$Subject, RPC_EMG_data$Condition, RPC_EMG_data$TrialNum), paste0(df_gait$Subject2,df_gait$Condition,df_gait$TrialNum))]

RPC_EMG_data %>% filter(Time == -0.98) 



m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + RPC.1*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.1", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.1.trend) %>% mutate(Muscle = "AlphaEMG_Tibialis", RPC = "RPC.1")
emmean = emm
m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + RPC.2*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.2", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.2.trend) %>% mutate(Muscle = "AlphaEMG_Tibialis", RPC = "RPC.2")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + RPC.3*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.3", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.3.trend) %>% mutate(Muscle = "AlphaEMG_Tibialis", RPC = "RPC.3")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + RPC.4*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.4", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.4.trend) %>% mutate(Muscle = "AlphaEMG_Tibialis", RPC = "RPC.4")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Tibialis ~ 1 + RPC.5*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.5", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.5.trend) %>% mutate(Muscle = "AlphaEMG_Tibialis", RPC = "RPC.5")
emmean = rbind(emmean, emm)

emmean %<>% mutate(p.adjust = p.adjust(p.value, method = "fdr"), index = paste(Ipsi_Contra, Condition, ifelse(Meta_FOG == 2, "FOG", "NoFOG"))) 
emmean %>%  knitr::kable() 
emmean$RPC = factor(str_replace_all(emmean$RPC, c("RPC.1" = "Pace", "RPC.2" = "Rhythm", "RPC.3" = "Control", "RPC.4" = "Latency", "RPC.5" = "Balance")), levels = c("Pace", "Rhythm", "Control", "Latency", "Balance"))

ggplot(emmean, aes(x = RPC, y = index, color = emslope, shape = p.adjust < 0.05)) +
  geom_point(size = 10) + 
  scale_color_gradient2(low = "blue", mid = "black", high = "red", midpoint = 0, limits = c(-0.1, 0.1)) +
  geom_point(size = 10, data = emmean %>% filter(emslope > 0.1), color = "red") + 
  geom_point(size = 10, data = emmean %>% filter(emslope < -0.1), color = "blue") +
  scale_shape_manual(values = c(19, 15)) +
  theme_dark_black_classiclegend() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  labs(x = "EMG", y = "Behavior", title = "Alpha Freq in Tibialis", subtitle = "Slope of the regression")


m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + RPC.1*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.1", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.1.trend) %>% mutate(Muscle = "BetaEMG_Tibialis", RPC = "RPC.1")
emmean = emm
m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + RPC.2*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.2", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.2.trend) %>% mutate(Muscle = "BetaEMG_Tibialis", RPC = "RPC.2")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + RPC.3*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.3", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.3.trend) %>% mutate(Muscle = "BetaEMG_Tibialis", RPC = "RPC.3")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + RPC.4*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.4", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.4.trend) %>% mutate(Muscle = "BetaEMG_Tibialis", RPC = "RPC.4")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Tibialis ~ 1 + RPC.5*Ipsi_Contra*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Ipsi_Contra*Condition*Meta_FOG, var = "RPC.5", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.5.trend) %>% mutate(Muscle = "BetaEMG_Tibialis", RPC = "RPC.5")
emmean = rbind(emmean, emm)

emmean %<>% mutate(p.adjust = p.adjust(p.value, method = "fdr"), index = paste(Ipsi_Contra, Condition, ifelse(Meta_FOG == 2, "FOG", "NoFOG")))
emmean %>%  knitr::kable()
emmean$RPC = factor(str_replace_all(emmean$RPC, c("RPC.1" = "Pace", "RPC.2" = "Rhythm", "RPC.3" = "Control", "RPC.4" = "Latency", "RPC.5" = "Balance")), levels = c("Pace", "Rhythm", "Control", "Latency", "Balance"))

ggplot(emmean, aes(x = RPC, y = index, color = emslope, shape = p.adjust < 0.05)) +
  geom_point(size = 10) + 
  scale_color_gradient2(low = "blue", mid = "black", high = "red", midpoint = 0, limits = c(-3, 3)) +
  geom_point(size = 10, data = emmean %>% filter(emslope > 3), color = "red") + 
  geom_point(size = 10, data = emmean %>% filter(emslope < -3), color = "blue") +
  scale_shape_manual(values = c(19, 15)) +
  theme_dark_black_classiclegend() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  labs(x = "Behavior", y = "EMG", title = "Beta Freq in Tibialis", subtitle = "Slope of the regression")





m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + RPC.1*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.1", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.1.trend) %>% mutate(Muscle = "AlphaEMG_Soleus", RPC = "RPC.1")
emmean = emm
m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + RPC.2*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.2", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.2.trend) %>% mutate(Muscle = "AlphaEMG_Soleus", RPC = "RPC.2")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + RPC.3*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.3", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.3.trend) %>% mutate(Muscle = "AlphaEMG_Soleus", RPC = "RPC.3")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + RPC.4*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.4", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.4.trend) %>% mutate(Muscle = "AlphaEMG_Soleus", RPC = "RPC.4")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("AlphaEMG_Soleus ~ 1 + RPC.5*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.5", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.5.trend) %>% mutate(Muscle = "AlphaEMG_Soleus", RPC = "RPC.5")
emmean = rbind(emmean, emm)

emmean %<>% mutate(p.adjust = p.adjust(p.value, method = "fdr"), index = paste(Condition, ifelse(Meta_FOG == 2, "FOG", "NoFOG")))
emmean %>%  knitr::kable()
emmean$RPC = factor(str_replace_all(emmean$RPC, c("RPC.1" = "Pace", "RPC.2" = "Rhythm", "RPC.3" = "Control", "RPC.4" = "Latency", "RPC.5" = "Balance")), levels = c("Pace", "Rhythm", "Control", "Latency", "Balance"))

ggplot(emmean, aes(x = RPC, y = index, color = emslope, shape = p.adjust < 0.05)) +
  geom_point(size = 10) + 
  scale_color_gradient2(low = "blue", mid = "black", high = "red", midpoint = 0, limits = c(-0.07, 0.07)) +
  geom_point(size = 10, data = emmean %>% filter(emslope > 0.07), color = "red") + 
  geom_point(size = 10, data = emmean %>% filter(emslope < -0.07), color = "blue") +
  scale_shape_manual(values = c(19, 15)) +
  theme_dark_black_classiclegend() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  labs(x = "EMG", y = "Behavior", title = "Alpha Freq in Soleus", subtitle = "Slope of the regression")


m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + RPC.1*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.1", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.1.trend) %>% mutate(Muscle = "BetaEMG_Soleus", RPC = "RPC.1")
emmean = emm
m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + RPC.2*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.2", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.2.trend) %>% mutate(Muscle = "BetaEMG_Soleus", RPC = "RPC.2")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + RPC.3*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.3", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.3.trend) %>% mutate(Muscle = "BetaEMG_Soleus", RPC = "RPC.3")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + RPC.4*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.4", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.4.trend) %>% mutate(Muscle = "BetaEMG_Soleus", RPC = "RPC.4")
emmean = rbind(emmean, emm)
m = lmerTest::lmer("BetaEMG_Soleus ~ 1 + RPC.5*Condition*Meta_FOG + (1|Subject)", data = RPC_EMG_data %>% filter(Time == -0.98))
emm = suppressWarnings(emmeans::emtrends(m, ~ Condition*Meta_FOG, var = "RPC.5", adjust = "none"))  %>% test() %>% as.data.frame() %>% rename(emslope = RPC.5.trend) %>% mutate(Muscle = "BetaEMG_Soleus", RPC = "RPC.5")
emmean = rbind(emmean, emm)

emmean %<>% mutate(p.adjust = p.adjust(p.value, method = "fdr"), index = paste(Condition, ifelse(Meta_FOG == 2, "FOG", "NoFOG")))
emmean %>%  knitr::kable()
emmean$RPC = factor(str_replace_all(emmean$RPC, c("RPC.1" = "Pace", "RPC.2" = "Rhythm", "RPC.3" = "Control", "RPC.4" = "Latency", "RPC.5" = "Balance")), levels = c("Pace", "Rhythm", "Control", "Latency", "Balance"))

ggplot(emmean, aes(x = RPC, y = index, color = emslope, shape = p.adjust < 0.05)) +
  geom_point(size = 10) + 
  scale_color_gradient2(low = "blue", mid = "black", high = "red", midpoint = 0, limits = c(-0.15, 0.15)) +
  scale_shape_manual(values = c(19, 15)) +
  theme_dark_black_classiclegend() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  labs(x = "Behavior", y = "EMG", title = "Beta Freq in Soleus", subtitle = "Slope of the regression")




