
## Libraries
library(tidyverse)
library(ggplot2)
library(svglite)
library(plyr)
library(dplyr)
library(reshape2)
library(stringr)
library(readxl)
library(mgcv)
library(gratia)
library(ggeffects)
library(svglite)

## Parameters

                        # Choose Beta
                        AlphaStart = 8    
                        StartBeta = 12    
                        MidBeta   = 20    
                        EndBeta   = 35    

                        # Peak Parameters
                        PicOrBand = 'Pic'
                        PeakWidth = 3     # en Hz
                        PeakProminance = 3 # Parametre du choix des pics 
                        CategAndMore = '+' # '+' for >= or 'only' for ==
                        PeakBand = 'LowB'  # 'LowB' , 'HighB' , 'FTGamma' , 'Alpha' , 'HFO'
                        AutoManuel = 'Manuel'
                        PeakTable = read.table('C:/LustreSync/hypoQAMPPE/PeakDetection.xlsx')  # table contenant les valeurs manuelles


                        # Input data
                        PtFq = 1/100      # Point frequency of PSD 
                        plotsPt = '100'   # 100 or 10k or 10kfilt

                        # Comparaisons
                        VariableToCompare = 'OFF'  # 'OFF', 'ON' or 'delta'
                        Timing_to_Use = 'pre'  # 'pre', 'post' or 'delta'
                        Method = 'BH'   # 'BH' or 'NoCorrection'


# Load
Type_of_Spectrum = 'detail' # 'detail' or 'raw'
Normalisation = 'AUC100'   # 'brut' or 'AUC100'
PlotSaveFolder = 'C:/LustreSync/hypoQAMPPE/Figures/AllPatPeaks'
BestCh_or_Mean = 'Best' # 'Best' or 'Mean'




Suff = paste('', Type_of_Spectrum, Normalisation, sep = '_')
## Load spectrum & clinical scores from Matlab
# Import PSD_OFF.csv
PSD_OFF = vroom::vroom(paste0(PlotSaveFolder, "/", BestCh_or_Mean, "ChanTableOFF", Suff, ".csv"), col_names = FALSE)
# Import PSD_Dlt.csv
PSD_Dlt = vroom::vroom(paste0(PlotSaveFolder, "/", BestCh_or_Mean, "ChanTableDlt", Suff, ".csv"), col_names = FALSE)
# Import PSD_ON.csv
PSD_ON = vroom::vroom(paste0(PlotSaveFolder, "/", BestCh_or_Mean, "ChanTableON", Suff, ".csv"), col_names = FALSE)
# Import MatchTable.csv
MatchTable = vroom::vroom(paste0(PlotSaveFolder, "/MatchTable", Suff, ".csv"), col_names = TRUE)
# Import FreqList.csv
FreqList = vroom::vroom(paste0(PlotSaveFolder, "/FreqList.csv"), col_names = FALSE, delim = " ")

# Import clinical scores
ClinScore  = readxl::read_excel("C:/LustreSync/hypoQAMPPE/PatientInfo3.xlsx")


## Preprocess data
# Match Patient ID from MatchTable with Patient ID from ClinScore
ClinScore = ClinScore[match(MatchTable$Name, ClinScore$PATIENTID),]
MatchTable$U3O = ClinScore$UPDRSIII_OFF
MatchTable$U3I = ClinScore$UPDRSIII_ON
MatchTable$U3R = ClinScore$UPDRSIII_IMPROV
MatchTable$U3D = ClinScore$UPDRSIII_OFF - ClinScore$UPDRSIII_ON
MatchTable$BestOnDelta = ClinScore$UPDRSIII_OFF - ClinScore$UPDRSIII_STIM_ON
MatchTable$BestOn = ClinScore$UPDRSIII_STIM_ON
MatchTable$BestOnImprov = (ClinScore$UPDRSIII_OFF - ClinScore$UPDRSIII_STIM_ON) / (ClinScore$UPDRSIII_OFF) * 100

MatchTable$Number_of_OFF_Spectrum = as.numeric(!is.na(as.numeric(MatchTable$HighestBetaRightId))) + as.numeric(!is.na(as.numeric(MatchTable$HighestBetaLeftId)))
MatchTable$Number_of_ON_Spectrum = ifelse(MatchTable$ONidx == 'NaN', 0, 
                    as.numeric(!is.na(as.numeric(MatchTable$HighestBetaRightId))) + as.numeric(!is.na(as.numeric(MatchTable$HighestBetaLeftId))))

colnames(FreqList) = c('Freq')

# Rename columns from PSD_OFF with Name from MatchTable$Name
colnames(PSD_OFF) = unlist(lapply(seq_len(nrow(MatchTable)), function(i) {
                    rep(MatchTable$Name[i], MatchTable$Number_of_OFF_Spectrum[i])
                }), 
                recursive = FALSE)
PSD_OFF = cbind(FreqList$Freq, PSD_OFF)
colnames(PSD_OFF)[1] = 'Freq'

# same for PSD_ON
colnames(PSD_ON) = unlist(lapply(seq_len(nrow(MatchTable)), function(i) {
                    rep(MatchTable$Name[i], MatchTable$Number_of_ON_Spectrum[i])
                }), 
                recursive = FALSE)
PSD_ON = cbind(FreqList$Freq, PSD_ON)
colnames(PSD_ON)[1] = 'Freq'

# same for PSD_Dlt
colnames(PSD_Dlt) = unlist(lapply(seq_len(nrow(MatchTable)), function(i) {
                    rep(MatchTable$Name[i], MatchTable$Number_of_ON_Spectrum[i])
                }), 
                recursive = FALSE)
PSD_Dlt = cbind(FreqList$Freq, PSD_Dlt)
colnames(PSD_Dlt)[1] = 'Freq'


## define GAM function

MY_GAM = function(PSD, MaxFreq, ScoreName, FigName, PlotSaveFolder, MatchTable) {
 
    args = unlist(as.list(match.call()))
    FigName = paste0(args$PSD, '~Cliniq', args$ScoreName)

    PSD = PSD[PSD$Freq <= MaxFreq,]
    
    last = ""
    for (colnum in seq_along(colnames(PSD))) {
        name = colnames(PSD)[colnum]
        if (name == last) {
            colnames(PSD)[colnum] = paste0(name, "_L")
        } else if (name != 'Freq') {
            last = name
            colnames(PSD)[colnum] = paste0(name, "_R")
        }
    }
    
    df = reshape2::melt(PSD, id.vars = c('Freq'))
    colnames(df) = c('frequency', 'Name', 'power')
    df$Hemisphere = as.factor(gsub(".*_", "", df$Name))
    df$Name = as.factor(gsub("_.*", "", df$Name))
    MatchTable$Clinic = MatchTable[[ScoreName]]
    df$Clinic = MatchTable$Clinic[match(df$Name, MatchTable$Name)]
    df$Name = as.factor(df$Name)
    df$Hemisphere = as.factor(gsub(".*_", "", df$Name))
    df = df[complete.cases(df),]
    
    model     = mgcv::bam(power ~ te(frequency, Clinic) + s(Hemisphere,bs="re"), data = df)
    modeLight = mgcv::bam(power ~ te(frequency, Clinic) , data = df)

    print(FigName)
    print(summary(model))
    print(paste0("Light ", FigName))
    print(summary(modeLight))

    DrawModel = gratia::draw(modeLight) + ggplot2::labs(title = paste0(FigName)) + ggplot2::theme_bw() + ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
    ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMl_", FigName, "_", MaxFreq, ".png"), DrawModel, width = 10, height = 10)
    ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMl_", FigName, "_", MaxFreq, ".svg"), DrawModel, width = 10, height = 10)
    
    Pred = ggeffects::ggemmeans(modeLight, terms = c('frequency', 'Clinic')) %>% plot() 
    ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMl_Predict_", FigName, "_", MaxFreq, ".png"), Pred, width = 10, height = 10)
    ggplot2::ggsave(paste0(PlotSaveFolder, "/GAMl_Predict_", FigName, "_", MaxFreq, ".svg"), Pred, width = 10, height = 10)
    
    Appr = gratia::appraise(model)
    ggplot2::ggsave(paste0(PlotSaveFolder,"/GAM_Appr_", FigName, "_", MaxFreq, ".png"), Appr, width = 10, height = 10)
}

## Compute statistical tests

# PSD OFF ~ UPDRS III OFF
MY_GAM(PSD_OFF, 100, 'U3O', paste0('PSDoff~U3off_', Suff), PlotSaveFolder, MatchTable)
# PSD ON ~ UPDRS III ON
MY_GAM(PSD_ON, 100, 'U3I', paste0('PSDon~U3on_', Suff), PlotSaveFolder, MatchTable)
# PSD delta ~ UPDRS III improv
MY_GAM(PSD_Dlt, 100, 'U3R', paste0('PSDdelta_off-on_~U3improvement_', Suff), PlotSaveFolder, MatchTable)
# PSD delta ~ UPDRS III delta
MY_GAM(PSD_Dlt, 100, 'U3D', paste0('PSDdelta_off-on_~U3delta_off-on_', Suff), PlotSaveFolder, MatchTable)
# PSD delta ~ UPDRS III delta pre/postOP
MY_GAM(PSD_Dlt, 100, 'BestOnDelta', paste0('PSDdelta_off-on_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
# PSD ON ~ UPDRS III delta pre/postOP
MY_GAM(PSD_ON, 100, 'BestOnDelta', paste0('PSDon_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
# PSD delta ~ UPDRS III postOP on
MY_GAM(PSD_Dlt, 100, 'BestOn', paste0('PSDdelta_off-on_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
# PSD ON ~ UPDRS III postOP on
MY_GAM(PSD_ON, 100, 'BestOn', paste0('PSDon_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
# PSD delta ~ UPDRS III improv pre/postOP
MY_GAM(PSD_Dlt, 100, 'BestOnImprov', paste0('PSDdelta_off-on_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
# PSD ON ~ UPDRS III improv pre/postOP
MY_GAM(PSD_ON, 100, 'BestOnImprov', paste0('PSDon_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)






## Predicting GAM

# downsample to 1Hz

PSD_OFF_ds = PSD_OFF[PSD_OFF$Freq %% 1 == 0,]
PSD_ON_ds = PSD_ON[PSD_ON$Freq %% 1 == 0,]
PSD_Dlt_ds = PSD_Dlt[PSD_Dlt$Freq %% 1 == 0,]
PSD_OFF_ds = PSD_OFF_ds[PSD_OFF_ds$Freq > 0,]
PSD_ON_ds = PSD_ON_ds[PSD_ON_ds$Freq > 0,]
PSD_Dlt_ds = PSD_Dlt_ds[PSD_Dlt_ds$Freq > 0,]
for (fq in 1:100) {
    PSD_OFF_ds[fq,] = colMeans(PSD_OFF[abs(PSD_OFF$Freq - fq) < 0.5,])
    PSD_ON_ds[fq,] = colMeans(PSD_ON[abs(PSD_ON$Freq - fq) < 0.5,])
    PSD_Dlt_ds[fq,] = colMeans(PSD_Dlt[abs(PSD_Dlt$Freq - fq) < 0.5,])
}

print('use mean instead')


# New GAM function
MY_GAMpred = function(PSD, MaxFreq, ScoreName, FigName, PlotSaveFolder, MatchTable) {
    
    args = unlist(as.list(match.call()))
    FigName = paste0(args$PSD, '~Cliniq', args$ScoreName)

    PSD = PSD[PSD$Freq <= MaxFreq,]
    PatList = colnames(PSD)[-1]
    rownames(PSD) = PSD$Freq
    PSD$Freq = NULL
    t(PSD) -> PSD
    PSD = as.matrix(PSD)

    MatchTable$Clinic = MatchTable[[ScoreName]]
    Clinic = MatchTable$Clinic[match(PatList, MatchTable$Name)]

    PSD = PSD[!is.na(Clinic),]
    Clinic = Clinic[!is.na(Clinic)]
    PSD = PSD * 1000

    FrqMatrix = matrix(0, nrow = nrow(PSD), ncol = ncol(PSD))
    for (i in 1:nrow(PSD)) {
        FrqMatrix[i,] = as.numeric(colnames(PSD))
    }
    
    InputData = list(frequency = FrqMatrix, Clinic = Clinic, power = PSD)
    model = mgcv::gam(Clinic ~ s(frequency, by = power, k = 25), data = InputData)
    if (summary(model)$s.table[4]<0.05) {
        FigName = paste0('Sign_', FigName)
    }
    print(FigName)
    print(summary(model)) 
    #layout(matrix(c(1, 2), nrow = 2, ncol = 1))
    plot(model,scheme=1,col=1) 
    grDevices::recordPlot(paste0(PlotSaveFolder,"/GAM_PredCurv_", FigName, "_", MaxFreq, ".RData"))
    png(paste0(PlotSaveFolder,"/GAM_PredCurv_", FigName, "_", MaxFreq, ".png"), width = 700, height = 700)
    plot(model,scheme=1,col=1) 
    dev.off()
    svg(paste0(PlotSaveFolder,"/GAM_PredCurv_", FigName, "_", MaxFreq, ".svg"), width = 10, height = 10)
    plot(model,scheme=1,col=1) 
    dev.off()
    
    png(paste0(PlotSaveFolder,"/GAM_PredFitt_", FigName, "_", MaxFreq, ".png"), width = 700, height = 700)
    plot(fitted(model),InputData$Clinic)
    dev.off()
    svg(paste0(PlotSaveFolder,"/GAM_PredFitt_", FigName, "_", MaxFreq, ".svg"), width = 10, height = 10)
    plot(fitted(model),InputData$Clinic)
    dev.off()
    
    #layout(1)

    
    A = plot(model,scheme=1,col=1) 
    B = plot(fitted(model),InputData$Clinic)
    
    #save plot
    ggplot2::ggsave(paste0(PlotSaveFolder,"/GAM_PredCurv_", FigName, "_", MaxFreq, ".png"), A, width = 10, height = 10)
    ggplot2::ggsave(paste0(PlotSaveFolder,"/GAM_PredCurv_", FigName, "_", MaxFreq, ".svg"), A, width = 10, height = 10)
    ggplot2::ggsave(paste0(PlotSaveFolder,"/GAM_PredFitt_", FigName, "_", MaxFreq, ".png"), B, width = 10, height = 10)
    ggplot2::ggsave(paste0(PlotSaveFolder,"/GAM_PredFitt_", FigName, "_", MaxFreq, ".svg"), B, width = 10, height = 10)

}

MY_GAMpred(PSD_OFF_ds, 100, 'U3O', paste0('PSDoff~U3off_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_ds, 100, 'U3I', paste0('PSDon~U3on_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_ds, 100, 'U3R', paste0('PSDdelta_off-on_~U3improvement_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_ds, 100, 'U3D', paste0('PSDdelta_off-on_~U3delta_off-on_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_ds, 100, 'BestOnDelta', paste0('PSDdelta_off-on_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_ds, 100, 'BestOnDelta', paste0('PSDon_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_ds, 100, 'BestOn', paste0('PSDdelta_off-on_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_ds, 100, 'BestOn', paste0('PSDon_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_ds, 100, 'BestOnImprov', paste0('PSDdelta_off-on_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_ds, 100, 'BestOnImprov', paste0('PSDon_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)




## Spaghetti plot

Spaghetti  = function(PSD, MaxFreq, ScoreName, FigName, PlotSaveFolder, MatchTable) {
    
    args = unlist(as.list(match.call()))
    FigName = paste0(args$PSD, '~Cliniq', args$ScoreName)

    PSD = PSD[PSD$Freq <= MaxFreq,]
    
    df = reshape2::melt(PSD, id.vars = c('Freq'))
    colnames(df) = c('frequency', 'Name', 'power')
    MatchTable$Clinic = MatchTable[[ScoreName]]
    df$Clinic = MatchTable$Clinic[match(df$Name, MatchTable$Name)]
    df$Name = as.factor(df$Name)
    df = df[complete.cases(df),]
    df$Clinic = as.factor(df$Clinic)

    my_colors = colorRampPalette(c("blue", "red"))(length(unique(df$Clinic)))
    ggplot(df, aes(x = frequency, y = power, group = Name, color = Clinic)) + 
        geom_line() +
        xlab("Freq") +
        ylab("Power") +
        theme_bw() +
        scale_color_manual(values = my_colors, name = ScoreName)

    ggsave(paste0(PlotSaveFolder, "/Spag_", FigName, '.png'), width = 10, height = 10)
    ggsave(paste0(PlotSaveFolder, "/Spag_", FigName, '.svg'), width = 10, height = 10)
}

## Average per patient
# merge columns with same name
PSD_OFF_pat = aggregate(. ~ Freq, PSD_OFF_ds, mean)
PSD_ON_pat = aggregate(. ~ Freq, PSD_ON_ds, mean)
PSD_Dlt_pat = aggregate(. ~ Freq, PSD_Dlt_ds, mean)


MY_GAMpred(PSD_OFF_pat, 100, 'U3O', paste0('Hemis_PSDoff~U3off_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_pat, 100, 'U3I', paste0('Hemis_PSDon~U3on_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_pat, 100, 'U3R', paste0('Hemis_PSDdelta_off-on_~U3improvement_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_pat, 100, 'U3D', paste0('Hemis_PSDdelta_off-on_~U3delta_off-on_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_pat, 100, 'BestOnDelta', paste0('Hemis_PSDdelta_off-on_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_pat, 100, 'BestOnDelta', paste0('Hemis_PSDon_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_pat, 100, 'BestOn', paste0('Hemis_PSDdelta_off-on_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_pat, 100, 'BestOn', paste0('Hemis_PSDon_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_Dlt_pat, 100, 'BestOnImprov', paste0('Hemis_PSDdelta_off-on_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAMpred(PSD_ON_pat, 100, 'BestOnImprov', paste0('Hemis_PSDon_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)


Spaghetti(PSD_OFF_ds, 100, 'U3O', paste0('PSDoff~U3off_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_ON_ds, 100, 'U3I', paste0('PSDon~U3on_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_Dlt_ds, 100, 'U3R', paste0('PSDdelta_off-on_~U3improvement_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_Dlt_ds, 100, 'U3D', paste0('PSDdelta_off-on_~U3delta_off-on_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_Dlt_ds, 100, 'BestOnDelta', paste0('PSDdelta_off-on_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_ON_ds, 100, 'BestOnDelta', paste0('PSDon_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_Dlt_ds, 100, 'BestOn', paste0('PSDdelta_off-on_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_ON_ds, 100, 'BestOn', paste0('PSDon_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_Dlt_ds, 100, 'BestOnImprov', paste0('PSDdelta_off-on_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
Spaghetti(PSD_ON_ds, 100, 'BestOnImprov', paste0('PSDon_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)



## Normalized PSD
Mean_OFF = apply(PSD_OFF_ds[, -1], 1, mean, na.rm = TRUE)
PSD_OFF_ds_norm = PSD_OFF_ds - Mean_OFF
PSD_OFF_ds_norm$Freq = PSD_OFF_ds$Freq

Mean_ON = apply(PSD_ON_ds[, -1], 1, mean, na.rm = TRUE)
PSD_ON_ds_norm = PSD_ON_ds - Mean_ON
PSD_ON_ds_norm$Freq = PSD_ON_ds$Freq

Mean_Dlt = apply(PSD_Dlt_ds[, -1], 1, mean, na.rm = TRUE)
PSD_Dlt_ds_norm = PSD_Dlt_ds - Mean_Dlt
PSD_Dlt_ds_norm$Freq = PSD_Dlt_ds$Freq

## First gam with normalized PSD

MY_GAM(PSD_OFF_ds_norm, 100, 'U3O', paste0('Norm_PSDoff~U3off_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_ON_ds_norm, 100, 'U3I', paste0('Norm_PSDon~U3on_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_Dlt_ds_norm, 100, 'U3R', paste0('Norm_PSDdelta_off-on_~U3improvement_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_Dlt_ds_norm, 100, 'U3D', paste0('Norm_PSDdelta_off-on_~U3delta_off-on_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_Dlt_ds_norm, 100, 'BestOnDelta', paste0('Norm_PSDdelta_off-on_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_ON_ds_norm, 100, 'BestOnDelta', paste0('Norm_PSDon_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_Dlt_ds_norm, 100, 'BestOn', paste0('Norm_PSDdelta_off-on_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_ON_ds_norm, 100, 'BestOn', paste0('Norm_PSDon_~U3bestON_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_Dlt_ds_norm, 100, 'BestOnImprov', paste0('Norm_PSDdelta_off-on_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_ON_ds_norm, 100, 'BestOnImprov', paste0('Norm_PSDon_~U3improv_pre-postOP_', Suff), PlotSaveFolder, MatchTable)

## NormPat
Mean_OFF = apply(PSD_OFF_pat[, -1], 1, mean, na.rm = TRUE)
PSD_OFF_pat_norm = PSD_OFF_pat - Mean_OFF
PSD_OFF_pat_norm$Freq = PSD_OFF_pat$Freq

Mean_ON = apply(PSD_ON_pat[, -1], 1, mean, na.rm = TRUE)
PSD_ON_pat_norm = PSD_ON_pat - Mean_ON
PSD_ON_pat_norm$Freq = PSD_ON_pat$Freq

Mean_Dlt = apply(PSD_Dlt_pat[, -1], 1, mean, na.rm = TRUE)
PSD_Dlt_pat_norm = PSD_Dlt_pat - Mean_Dlt
PSD_Dlt_pat_norm$Freq = PSD_Dlt_pat$Freq

MY_GAM(PSD_Dlt_pat_norm, 100, 'U3D', paste0('NormPat_PSDdelta_off-on_~U3delta_off-on_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_Dlt_pat_norm, 100, 'BestOnDelta', paste0('NormPat_PSDdelta_off-on_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)
MY_GAM(PSD_ON_pat_norm, 100, 'BestOnDelta', paste0('NormPat_PSDon_~U3delta_pre-postOP_', Suff), PlotSaveFolder, MatchTable)


