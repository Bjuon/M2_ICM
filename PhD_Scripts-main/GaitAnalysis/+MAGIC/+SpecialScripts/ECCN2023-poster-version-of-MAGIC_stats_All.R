#############################################################################################
##  Derivé de MAGIC  -  Test stat   MAGIC_stats_All.R                              ##
##            version du 24 Avril 2023                                                                             ##
#############################################################################################

#############################################################################################
###### Initialisation
# DEFINE PATHS
print("ATTENTION PAS DE SUPPRESSION DES VARIABLES EN ENTREE")
rm(list = ls())
gc()

donotmake = FALSE

events  = c( "CUE", "FIX", "FO1", "FC1", "T0", "T0_EMG", "FO", "FC", "FOG_S", "FOG_E", "TURN_S", "TURN_E")
events  = c( "T0", "FOG_S", "FOG_E", "T0FOG")
# events  = c( "CUE")

if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/"
  sourcFile = "/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
} else {
  DataDir   = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats"
  LogDir    = "//l2export/iss02.home/mathieu.yeche/Cluster/outputs/"
  sourcFile = "//l2export/iss02.home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
}


## LIBRARY
LoadLibrary_and_RSourceFiles = function() {
library(sp)
library(reshape2)
library(RColorBrewer)
library(ggplot2)
library(svglite)
library(animation)
library(FedData)
library(lme4)
library(parallel)
library(plyr)
library(dplyr)
library(reshape2)
library(stringr)
library(performance)
library(emmeans)
library(carData)
library(car)
library(foreach)
library(doParallel)
}
LoadLibrary_and_RSourceFiles()

segType  = 'step'            #'trial'   'step' 
normtype = c('ldNOR')        # RAW or ldNOR
datatype = 'TF'              #'meanTF' #'PE' # TF 'FqBdes'
tBlock   = '05'
fqStart  = '1'
Montage  = 'extended';       # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'TF';             # 'TraceBrut' , 'TF',  'none'

print("Changer ici les parametres")
Contacts_of_interest = c("AllPat")
GroupingMode         = "grouping"

VerboseAnova         = FALSE      # Print anova results for each point, each var and interaction
todo_gifplot         = FALSE
todo_tfmapplot       = TRUE
todo_Plots           = todo_tfmapplot | todo_gifplot
Load_0Comput         = FALSE      # Only load result and not compute the whole model
Espacement_Freq      = "identity"    # arg for coord_trans : either "identity" or "log10"   => WORK ONLY WITH geom_tile() INSTEAD OF geom_raster(), WHICH IS MUCH SLOWER
PValueLimit          = 0.05
PValueBreaks         = c(0.05, 0.01)    # Will show a separate line for all of these pvalue, by default : c(0.05, 0.01)
SlidingWindowHalfSize= 1
todo_corr_Comport    = TRUE # To do correlation with comportement
todo_corr_Clinique   = TRUE # To do correlation with clinical scores
FigHigh = 24
FigWidth = 18

if (!todo_gifplot) {
         RestrictTimeCalculated = TRUE # Change here to TRUE to prevent statistical computing outside [-1 ; 1]
} else { RestrictTimeCalculated = FALSE }# DO NOT CHANGE 
# groups   = c('STN')
groups   = c('MAGIC_Only')



cl <- makeCluster(detectCores())
if (Sys.info()["nodename"] == "UMR-LAU-WP011") {
  DataDir   = 'C:/LustreSync/TMP/analyses'
  OutputDir = "C:/LustreSync/03_CartesTF/Stats"
  cl <- makeCluster(detectCores()-2)
}
registerDoParallel(cl)
clusterExport(cl, "LoadLibrary_and_RSourceFiles")
clusterEvalQ(cl, LoadLibrary_and_RSourceFiles())



for (nor in normtype) {
  for (Contact in Contacts_of_interest) { 
    for (gp in groups) {
      # SET SUBJECT
      if (gp == 'MAGIC_Only') {
         subjects <-
                  c(
                    'ALb_000a',
                    'VIj_000a',
                    'DEj_000a',
                    'GAl_000a',
                    'SAs_000a',
                    #'FRa_000a',
                    'GUg_0634',
                    'GIs_0550'
                  )
                
                listnameSubj =
                  c(
                    "ParkPitie_2020_06_25_ALb",
                    "ParkPitie_2021_04_01_VIj",
                    "ParkPitie_2019_04_25_DEj",
                    "ParkPitie_2020_09_17_GAl",
                    "ParkPitie_2021_10_21_SAs",
                    #  "ParkRouen_2021_10_04_FRa",
                    "ParkRouen_2020_11_30_GUg",
                    "ParkPitie_2020_07_02_GIs"
                  )
          
      }
      
      
      #############################################################################################
      ###### Chargement du fichier
      
      ##LOAD DATA
      listname = matrix(NaN, nrow = 1, ncol = 15)
      iname = 1
      
      
      for (ev in events) {
          
          if (ev ==  "T0FOG") {
            ev = "T0"  
            OnlyFOGtoSubset = TRUE
          } else {
            OnlyFOGtoSubset = FALSE
          }
          print(cat ('Nombre de sujets inclus : ', length(subjects), ' / Verifier que cela correspond au nombre attendu '))
          
          # Initialisation des matrices de resultats 
          pval = data.frame()
          TFpw = data.frame()
          
          # Initialisationde la liste par Sujet
          TFbySubject = tibble()
          s_count = 0
          
          if(!Load_0Comput){
            for (s in subjects) {
              
              #######################################################################################################
              ## CHARGEMENT #########################################################################################
              #######################################################################################################
              
              s_count = s_count + 1
              print(paste0('########## Patient ', s_count, ' of ', length(subjects), ' /// ', s, ' ', ev, ' ##########' ))
              
              RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
              setwd(paste(RecDir, '/POSTOP', sep = ""))
              if (s == 'DEj_000a' || s == 'DRc_000a'|| s == 'BEm_000a' || s == 'BAg_0496' || s == 'LOp_000a'|| s == 'GIs_0550' || s == 'COm_000a'|| s == 'REa_0526' ) { 
                protocol = 'GBMOV' } else { protocol = 'MAGIC'  }
              outputname <- listnameSubj[s_count]
              
              
              if ((nor == 'ldNOR') & segType  == 'step') {
                TF1Pat <- vroom::vroom(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_TF_', 'dNOR', '_', Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
              } else {
                TF1Pat <- vroom::vroom(paste(outputname, '_', protocol, '_POSTOP_GNG_GAIT_', segType, '_TF_',   nor , '_', Montage,'_', Artefact, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
              }

              if (1 == sum(unique(TF1Pat$Region) == "HotspotFOG", na.rm = TRUE)) {
                TF1Pat = subset(TF1Pat, TF1Pat$Region   == "HotspotFOG")
              } else {
                # Implementation de l'HighestBeta
                TFPat2 = subset(TF1Pat, TF1Pat$Freq > 13 & TF1Pat$Freq < 30)
                TFPat2 = subset(TFPat2, TFPat2$quality == 1)

                startTimeBeta = 18 + 0.5*ncol(TFPat2)
                endTimeBeta   = ncol(TFPat2) - 0.25*ncol(TFPat2)


                # Gauche
                TFPat3 = subset(TFPat2, grepl('G', TFPat2$Channel))
                TFPat3 = TFPat3[nchar(TFPat3$Channel) == 3,]
                valuelist = c()
                for (ch in unique(TFPat3$Channel)){
                  TFPat4 = subset(TFPat3, TFPat3$Channel == ch)
                  valuelist[ch] = sum(sum(TFPat4[, startTimeBeta:endTimeBeta], na.rm = TRUE), na.rm = TRUE)
                }
                ChOfInterestG = names(which.max(valuelist))
                
                # Droite
                TFPat3 = subset(TFPat2, grepl('D', TFPat2$Channel))
                TFPat3 = TFPat3[nchar(TFPat3$Channel) == 3,]
                valuelist = c()
                for (ch in unique(TFPat3$Channel)){
                  TFPat4 = subset(TFPat3, TFPat3$Channel == ch)
                  valuelist[ch] = sum(sum(TFPat4[, startTimeBeta:endTimeBeta], na.rm = TRUE), na.rm = TRUE)
                }
                ChOfInterestD = names(which.max(valuelist))

                # Attention, Gauche et Droite !!!
                print(paste0(s, " BestBeta : ", ChOfInterestG, ' et ', ChOfInterestD))
                TF1Pat = subset(TF1Pat, TF1Pat$Channel == ChOfInterestG | TF1Pat$Channel == ChOfInterestD)

              }

              TF1Pat = subset(TF1Pat, TF1Pat$quality == 1)
              
              TFbySubject = bind_rows(TFbySubject, TF1Pat)
              rm(TF1Pat)
              gc()
              
            } #  End for all subjects : chargement global
            
            AllAvailableTimePoints = data.frame(t(data.frame(colnames(TFbySubject))))
            timepoints_number      = ncol(TFbySubject) - 17
            
            data.table::fwrite(AllAvailableTimePoints, file = paste0(OutputDir, '/ModelOutput/', 'TimesNames', Contact, '_', ev, '.csv'))
            
            if (todo_corr_Comport) {


                  plotInd = function(res_pca, Grouping, Axe1, Axe2, paletteCouleur = "bpalette") {
                      factoextra::fviz_pca_ind(res_pca,
                          geom.ind = "point", 
                          habillage = res_pca$call$quali.sup$quali.sup[[Grouping]],
                          #col.ind = APA$g, # colorer by groups
                          palette = paletteCouleur,
                          addEllipses = TRUE, 
                          ellipse.level=0.95, # Ellipses de concentration
                          legend.title = "Groups",axes = c(Axe1, Axe2)
                          )
                      }




                  # PCA FROM MAGIC_PCA.R , version en vigueur au 25 Avril 2023
                  MY_Pat = "C:/Users/mathieu.yeche/Desktop/ResAPA_extension_LINKERS_v3.xlsx"
                   

                  MY_APA = readxl::read_excel(MY_Pat, sheet = 1)
                  MY_APA = MY_APA %>%
                      mutate( across(c(15:35),~as.numeric(as.character(.x))))
                  
                  MY_APA$is_FOG = as.factor(MY_APA$is_FOG)
                  MY_APA$Meta_FOG = as.factor(MY_APA$Meta_FOG)

                  
                  # Si Subject a 3 lettres alors le copier dans le champ PatID, else 
                  MY_APA$PatID = NA
                  for (rownumAPA in 1:nrow(MY_APA)) {
                    if (nchar(MY_APA$Subject[rownumAPA]) == 3) {
                      MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 3, 3)))
                    } else {
                      MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 4, 4)))
                    }
                  }
                  MY_APA$Subject = MY_APA$PatID

      
                  # PCA
                  IncludedValuesInPCA = c(1,2, 3,4,5,15:35, 43) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
                  QualitativeValuesInPCA = c(1, 2, 3, 4, 5, 43-16)
                  
                  All_APA_fitted = missMDA::imputePCA(MY_APA[,IncludedValuesInPCA], 
                                  quali.sup = QualitativeValuesInPCA , 
                                  ncp = 5)$
                                  completeObs
                  res_pca   = FactoMineR::PCA(All_APA_fitted, 
                                  quali.sup = QualitativeValuesInPCA , 
                                  ncp=9, 
                                  scale.unit=TRUE, graph=FALSE)

            reduced_pca = FALSE
            if (reduced_pca) {
              IncludedValuesInPCA = c(1,2, 3,4,5,15:20, 23, 33,34, 43) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
              QualitativeValuesInPCA = c(1, 2, 3, 4, 5, 15)
              
              All_APA_fitted = missMDA::imputePCA(MY_APA[,IncludedValuesInPCA], 
                              quali.sup = QualitativeValuesInPCA , 
                              ncp = 5)$
                              completeObs
              res_pca       = FactoMineR::PCA(All_APA_fitted, 
                              quali.sup = QualitativeValuesInPCA , 
                              ncp=3, 
                              scale.unit=TRUE, graph=FALSE)
            }

            donotmake = FALSE
            if (donotmake) {
              
              # Extract mean value in the PCA of Meta_FOG == 2 individuals
              MeanDim1 = mean(res_pca$ind$coord[res_pca$call$quali.sup$quali.sup$Meta_FOG == "Meta_FOG_2", 1])
              MeanDim2 = mean(res_pca$ind$coord[res_pca$call$quali.sup$quali.sup$Meta_FOG == "Meta_FOG_2", 2])
              # angle of the line between the origin and the mean of Meta_FOG == 2 individuals
              angle = atan(MeanDim2/MeanDim1)
              
              myPalette = c("#fa4616", "#d25736", "#281E78")
      
              ToPlot = data.frame(res_pca$ind$coord[,1:2])
              ToPlot$FOG = MY_APA$Meta_FOG
              ggplot(ToPlot, aes(x = FOG, y = Dim.2, color = FOG)) + 
                    geom_violin(alpha = 0.5) + 
                    ggbeeswarm::geom_beeswarm(cex = 0.8, size = 0.8, alpha = 0.2, corral = "random", corral.width = 0.9) +
                    theme_classic() +
                    geom_boxplot(width=0.1, alpha=0.1, outlier.shape = NA, position=position_dodge(1), outlier.size = FALSE) +
                    scale_color_manual(values = myPalette) +
                    scale_fill_manual(values = myPalette) +
                    theme(legend.position = "none") 
               
                t.test(ToPlot$Dim.2[ToPlot$FOG == 1], ToPlot$Dim.2[ToPlot$FOG == 0])
                t.test(ToPlot$Dim.2[ToPlot$FOG == 1], ToPlot$Dim.2[ToPlot$FOG == 2])


             for (var in 1:(length(IncludedValuesInPCA)-length(QualitativeValuesInPCA))) {
              MY_APA$yvar = MY_APA[[IncludedValuesInPCA[var+5]]]
              ggplot(MY_APA, aes(x = is_FOG == 1, y = yvar, color = Subject=='FRa')) + 
                geom_violin(alpha = 0.5) + 
                ggbeeswarm::geom_beeswarm( size = 0.8, alpha = 0.2) +
                theme_classic() +
                labs(title = paste0("Variable ", var, " : ", names(MY_APA)[IncludedValuesInPCA[var+5]]))+ 
                geom_boxplot(width=0.1, alpha=0.1, outlier.shape = NA, position=position_dodge(1))
              ggsave(filename = paste0("Variable_", var, "_", names(MY_APA)[IncludedValuesInPCA[var+5]],".png" ), width = 12, height = 9)
            }


             supp <- fviz_pca_biplot(res_pca, 
                # Fill individuals by groups
                geom.ind = "point",
                pointshape = 21,
                pointsize = 1.5,
                fill.ind = MY_APA$is_FOG,
                col.ind = "black",
                addEllipses = T,
                axes = c(1, 2),#changer à chaque fois l'axe
                select.ind = list(name = rownames(res_pca$call$quali.sup$quali.sup)[res_pca$call$quali.sup$quali.sup == 'PREOP:ON:C' | res_pca$call$quali.sup$quali.sup == 'PREOP:OFF:C'| res_pca$call$quali.sup$quali.sup == 'M6:Hot spot FOG:C'| res_pca$call$quali.sup$quali.sup == 'M6:Single ring:C'| res_pca$call$quali.sup$quali.sup == 'M6:Motor STN:C'|res_pca$call$quali.sup$quali.sup == 'PREOP:ON:I' | res_pca$call$quali.sup$quali.sup == 'PREOP:OFF:I'| res_pca$call$quali.sup$quali.sup == 'M6:Hot spot FOG:I'| res_pca$call$quali.sup$quali.sup == 'M6:Single ring:I'| res_pca$call$quali.sup$quali.sup == 'M6:Motor STN:I']),
                
                legend.title = list(fill = "Condition", color = "g"),
                repel = T       # Avoid label overplotting
              )+
              ggpubr::fill_palette("viridis")+      # Indiviual fill color
              ggpubr::color_palette("npg")  
            supp

            }

                        plotInd(res_pca, Grouping = 'Meta_FOG', Axe1 = 2, Axe2 = 1, paletteCouleur = c("#fa4616", "#d25736", "#281E78"))
                        
                        plotInd(res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
                        plotInd(res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
                        plotInd(res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

                        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
                        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
                        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

                        plotInd(res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
                        plotInd(res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
                        plotInd(res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")
                  
                 
              Kaiser = factoextra::fviz_eig(res_pca, addlabels = TRUE, ylim = c(0, 50)) +
                  geom_abline(slope = 0,intercept = 10,color='red')+ 
                  theme_classic()+
                  ggtitle("Composantes principales")
              
 
              #Correlogrammes
              COR1 <- res_pca$var$coord[, 1:2]
              COR2 = data.frame(COR1)
              COR2 = COR2[abs(COR2$Dim.1) > 0.5 | abs(COR2$Dim.2) > 0.5 ,]
              COR2$Var1 = rownames(COR2)
              COR2$Var1 =c( "Anteroposterior APA",    "Mediolateral APA "   , "1st Swing time"   ,    "Double Stance time"     ,      "2nd Swing time"   ,    "1st Stride time" ,"First step length"   ,"1st Swing speed"  ,     "1st step lateral speed"    , "Mean Speed during initiation", "Freq gait initiation" ,"Cadence" , "Center of Gravity",     "Max 1st swing vertical speed"  ,"1st contact vertical speed"  )
              COR       <- reshape2::melt(COR2) #pour metre les dimensions sur les lignes 
              myPalette = grDevices::colorRampPalette(c("#281E78","#ffffff","#ffffff","#ffffff","#fa4616"))
                cor <- ggplot(COR,aes(x = variable, y = Var1, fill = value))+
                geom_tile()+
                # increase the y label text size
                theme(axis.text.y = element_text(size = 500))+
                theme(text = element_text(size = 500))+
                scale_fill_gradientn(colours = myPalette(100),lim=c(-1,1))+
                theme_classic()
              
              plot = gridExtra::grid.arrange(Kaiser, cor, ncol = 2)





              pca = res_pca
              vecTF = paste0(sub(".*_", "", TFbySubject$Patient) , TFbySubject$Medication, TFbySubject$nTrial)
              vecCA = paste0(pca$call$quali.sup$quali.sup$Subject, pca$call$quali.sup$quali.sup$Condition, pca$call$quali.sup$quali.sup$TrialNum)
              # TempDF$TrialName = paste0(TFbySubject$Patient, '_', TFbySubject$Protocol, '_POSTOP_', TFbySubject$Medication, '_GNG_GAIT_', sprintf("%03d", TFbySubject$nTrial))
              
             
              indices_communs = match(vecTF, vecCA)
              TFbySubject$dimension1 = factoextra::get_pca_ind(pca)$coord[indices_communs, 1]
              TFbySubject$dimension2 = factoextra::get_pca_ind(pca)$coord[indices_communs, 2]
              TFbySubject$dimension3 = factoextra::get_pca_ind(pca)$coord[indices_communs, 3]
              TFbySubject$FOG        = pca$call$quali.sup$quali.sup$Meta_FOG[indices_communs]
            }
            if (todo_corr_Clinique) {
              #Load
              MY_Pat = "C:/Users/mathieu.yeche/OneDrive - ICM/Thèse - Scientifique/Clinique_LFP.xlsx"
              Clinique = readxl::read_excel(MY_Pat, sheet = 1)
              
              # Match each trial with its corresponding clinical row
              indices_communs = match(TFbySubject$Patient, Clinique$Code)

              # Reimplant the results in the LFP dataframe
              # U3 double on versus preop off
              dU3II = - Clinique$U3_preop_OFF + Clinique$U3_M7M3_doubleON
              TFbySubject$dU3II = dU3II[indices_communs]

              # delta PDQ39 
              dP39 = Clinique$PDQ39_preop 
              TFbySubject$dP39 = dP39[indices_communs]

              # delta FOG-Q 
              dFogQ = Clinique$FOGQ_preop 
              TFbySubject$dFogQ = dFogQ[indices_communs]

              # U3 correspondant (off/on)
              indices_communs_off = match(paste0(TFbySubject$Patient, TFbySubject$Medication), paste0(Clinique$Code, 'OFF'))
              indices_communs_on  = match(paste0(TFbySubject$Patient, TFbySubject$Medication), paste0(Clinique$Code, 'ON'))
              U3off = Clinique$U3_preop_OFF[indices_communs_off]
              U3on  = Clinique$U3_preop_ON[indices_communs_on]
              U3off[is.na(U3off)] = 0
              U3on[ is.na(U3on )] = 0
              U3merged = U3off + U3on
              U3merged[U3merged==0] = NA

              TFbySubject$U3 = U3merged

              # List of included Clinical test
              ClinicalTests = c('U3', 'dU3II', 'dP39', 'dFogQ')
cor(Clinique$FOGQ_M7-Clinique$FOGQ_preop, Clinique$PDQ39_M7-Clinique$PDQ39_preop, use = "complete.obs", method = "spearman")
              
            }

          } else { 
            AllAvailableTimePoints = vroom::vroom(     file = paste0(OutputDir, '/ModelOutput/', 'TimesNames', Contact,'_', ev, '.csv'))
            timepoints_number      = ncol(AllAvailableTimePoints) - 17 
          }
          
          # timeOfPassage = Sys.time()
          # 
          # for (Freqpoint in as.numeric(fqStart):100) {
          #   # print(paste0('##### ',Freqpoint, 'Hz ##### ', Sys.time(), ' /// temps last freq : ', round(Sys.time()-timeOfPassage, digits = 2), ' min'))
          #   # timeOfPassage = Sys.time()
          #   
          #   for (timefreq in 1:timepoints_number) {
          #    

          if (RestrictTimeCalculated) {
                colname   = colnames(TFbySubject)[18:(17+timepoints_number)]
                timepoint = gsub("x_", "-", colname, fixed = TRUE)
                timepoint = gsub("_" , ".", timepoint)
                timepoint = gsub("x" , "" , timepoint)
                timepoint = as.numeric(timepoint)
                # Trouver le plus proche de 1 et de -1
                firstIncludedTP = which(timepoint >= -1)[1] -1
                lastIncludedTP = which(timepoint >= 1)[1]
                
              } else {
                firstIncludedTP = 1
                lastIncludedTP = timepoints_number
              } 
          
          if (OnlyFOGtoSubset) {
            TFbySubject = subset(TFbySubject, TFbySubject$FOG == "Meta_FOG_2")
            }

            

ResPar = foreach(Freqpoint = as.numeric(fqStart):100, .combine = 'rbind') %:%   # Execution en parallele, variable de sortie = ResPar 
            foreach(timefreq = firstIncludedTP:lastIncludedTP, .combine = 'rbind') %dopar% {
              
              
              cat(paste0(Freqpoint, 'Hz : temps ', timefreq, ' sur ', timepoints_number, ' ----- ', Sys.time()))
              flush.console()
              if (!Load_0Comput) {
                
                # Recuperation du temps frequence
                DAT_LFP = subset(TFbySubject, TFbySubject$Freq == Freqpoint)
                if (ncol(DAT_LFP) == 17+timepoints_number) {
                  DAT_LFP = subset(DAT_LFP, select = c(1:17, timefreq+17)) # keep only 1 timepoint
                } else {
                  DAT_LFP = subset(DAT_LFP, select = c(1:17, timefreq+17, (17+timepoints_number+1):ncol(DAT_LFP))) # keep only 1 timepoint
                }
                
                
                ## Standadisation des donnees en input
                
                # Nom des variables
                timeName = colnames(DAT_LFP)[18]
                colnames(DAT_LFP)[18] = "value"
                if (GroupingMode == "Region"  ) {DAT_LFP$group = DAT_LFP$Region  }  
                if (GroupingMode == "grouping") {DAT_LFP$group = DAT_LFP$grouping} 
                
                # Transformation en variable numerique de la valeur
                DAT_LFP %>% mutate(num = as.numeric(value)) %>% filter( (is.na(num) & !is.na(value)) | (!is.na(num) & is.na(value)) ) %>% select(Patient, value, num)
                DAT_LFP$value <- as.numeric(DAT_LFP$value)
                
                # Remove NA
                if (!stringr::str_detect(ev, 'FC') || !stringr::str_detect(ev, 'FO')) { 
                  DAT_LFP$side = ifelse(is.na(DAT_LFP$side), "None", DAT_LFP$side) # Embetant pour certains events mais pas tous
                } 
                DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "Medication", "Task", "side", "Channel", "nTrial", "value")]), ]
                DAT_LFP = transform(transform(transform(DAT_LFP, 
                                                        hemisphere  = ifelse(stringr::str_detect(Channel, 'D'), 'R',  ifelse(stringr::str_detect(Channel, 'G'), 'L' , NA))), 
                                              ipsi_contra = ifelse(hemisphere == side, 'ipsi', ifelse(side == "None", 'None', 'contra'))),
                                    MetaCond    = paste( group, Event, Medication, Task, hemisphere, ipsi_contra, sep = '_'))  
                
                #######################################################################################################
                ## STATS ##############################################################################################
                #######################################################################################################
                
                if (ev == "T0" && !OnlyFOGtoSubset) {
                # AllInOne
                model   = lme4::lmer(10*log(value,base=10) ~ hemisphere + (1|Patient/Channel)+ (1|Task)+ (1|hemisphere), data = DAT_LFP)
                EMMean  = emmeans(model, ~  hemisphere, at = list(Medication = "OFF"))      
                emmean  = data.frame(EMMean)
                emIndv  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                              lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne')))))
                
                # FOG VERSUS NO FOG
                model   = lme4::lmer(10*log(value,base=10) ~ FOG + (1|Patient/Channel)+ (1|Task)+ (1|hemisphere), data = DAT_LFP)
                EMMean  = emmeans(model, ~  FOG, at = list(Medication = "OFF"))      
                emmean  = data.frame(EMMean)
                emVersus= data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, -1)), 
                                                       lapply(1:(nrow(emmean)/2) , function(i) paste0('FoGVersus')))))
                # FOG ONLY
                emFOG   = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(0, 1)), 
                                                       lapply(1:(nrow(emmean)/2) , function(i) paste0('GIb4FOG')))))
                # NO FOG ONLY
                emNoFOG = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 0)), 
                                                       lapply(1:(nrow(emmean)/2) , function(i) paste0('GINoFOG')))))
                
                rm(ModelOutput)
                emIndv$categ   = 'AllInOne'
                emVersus$categ = 'FoGVersus'
                emFOG$categ   = 'GIb4FOG'
                emNoFOG$categ = 'GINoFOG'

                  ModelOutput = rbind(emIndv, emVersus, emFOG, emNoFOG) 
                
                } else {
                if (length(unique(DAT_LFP$Medication)) > 1) {

                # Modèle 
                model = lme4::lmer(10*log(value,base=10) ~ Medication*Task*hemisphere + (1|Patient/Channel), data = DAT_LFP)
                # DELETE ipsi_contra           Que dans ce modèle et pas en dessous, ou on supprime cette var. En interaction avec hémisphère et med
                # DELETE nStep                 Lorsqu'il y a plusieurs fois l'evenement dans 1 Trial (FO, FC, FOG)
                
                
                if (VerboseAnova == TRUE) {
                  print(paste0( Contact,'_', ev, ' Freq', Freqpoint, 'Time', timeName ))
                  car::Anova(model)          #For Visual inspection
                  print(' ')
                  performance::check_model(model)  
                } 
                
                # Insertion dans la matrice de sortie
                
                # Toutes les variables :
                # toutes les conditions
                EMMean  = emmeans(model, ~  Medication*Task*hemisphere)        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres 
                emmean  = data.frame(EMMean)
                emCase  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), 
                                                        apply(       emmean , 1, function(x) paste(x[1], x[2], x[3], sep = '_')))))
                 # FOG Special
                model   = lme4::lmer(10*log(value,base=10) ~ hemisphere + (1|Patient/Channel)+ (1|Medication)+ (1|Task)+ (1|hemisphere), data = DAT_LFP)
                EMMean  = emmeans(model, ~  hemisphere)      
                emmean  = data.frame(EMMean)
                emIndv  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                              lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne')))))
                
                } else {
                # FOG Special
                model   = lme4::lmer(10*log(value,base=10) ~ hemisphere + (1|Patient/Channel)+ (1|Task)+ (1|hemisphere), data = DAT_LFP)
                EMMean  = emmeans(model, ~  hemisphere)      
                emmean  = data.frame(EMMean)
                emIndv  = data.frame(contrast(EMMean,       
                                              setNames(lapply(1:(nrow(emmean)/2),    function(i) c(1, 1)), 
                                              lapply(1:(nrow(emmean)/2) , function(i) paste0('AllInOne')))))
                
                }
                
                rm(ModelOutput)
                emIndv$categ   = 'AllInOne'
                if (length(unique(DAT_LFP$Medication)) > 1) {
                  emCase$categ   = 'NoContrast'
                  ModelOutput = rbind(emCase, emIndv) 
                } else {
                  ModelOutput = emIndv
                }

                }

              # Put all pvalues in ModelOutput
                
                
                ModelOutput = ModelOutput[stats::complete.cases(ModelOutput[, c("contrast", "df")]), ]
                
                
                # Save
                data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutput/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, 'ModelOutput.csv'))
              
              } else { # else de if(!Load_0Comput)
                timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutput/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, 'ModelOutput.csv'))
              }
              
              ## Pass to next step (plots)
               
                pval <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                TFpw <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                
                
              # initialize first column
              if (dim(pval)[2] == 0) {
                while (dim(pval)[1] < length(ModelOutput$contrast)) {
                  pval = tibble::add_row(pval)
                  TFpw = tibble::add_row(TFpw)
                }
                pval$categ    = ModelOutput$categ
                TFpw$categ    = ModelOutput$categ
                pval$MetaCond = ModelOutput$contrast
                TFpw$MetaCond = ModelOutput$contrast
              }
              
              # Assign Values
              pval[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$p.value
              TFpw[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$estimate
               
              ## Variables comportementales
              if (todo_corr_Comport) {
                DAT_LFPsave = DAT_LFP
                DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "value", "dimension1")]), ]
                   

                for (dimension in 1:3) {
                  
                  
                  
                  if (!Load_0Comput) {
                    
                    DAT_LFP$Comportement = NULL
                    DAT_LFP$Comportement = DAT_LFP[[ paste0('dimension', dimension)]]  
                      
                    remove(ModelOutput)
                    ModelOutput = data.frame()
                    ModelOutput = tibble::add_row(ModelOutput)

                    ModelOutput$contrast = 'AllInOne'
                    if (dimension == 2) {
                      ModelOutput$estimate = cor(    DAT_LFP$Comportement, 10*log(DAT_LFP$value,base=10), method = "spearman")
                    } else { 
                      ModelOutput$estimate = cor(    DAT_LFP$Comportement, 10*log(DAT_LFP$value,base=10), method = "spearman")
                    }
                    ModelOutput$SE       = 0
                    ModelOutput$df       = 0
                    ModelOutput$t.ratio  = 0
                    ModelOutput$p.value  = cor.test(DAT_LFP$Comportement, 10*log(DAT_LFP$value,base=10), method = "spearman")$p.value
                    ModelOutput$categ    = 'AllInOne' 
                    
                    
                    if (ev == "T0" && !OnlyFOGtoSubset){
                      ModelOutput = tibble::add_row(ModelOutput) 
                      ModelOutput$estimate[2] = cor(     DAT_LFP$Comportement, emNoFOG$emVersus, method = "spearman")
                      ModelOutput$SE[2]       = 0
                      ModelOutput$df[2]       = 1
                      ModelOutput$t.ratio[2]  = 0
                      ModelOutput$p.value[2]  = cor.test(DAT_LFP$Comportement, emNoFOG$emVersus, method = "spearman")$p.value
                      ModelOutput$categ[2]    = 'FOGversus' 
                    }
                    
                    # Save
                    data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutputComportement/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, 'Dim', dimension, 'ModelOutput.csv'))
                    
                  } else { # else de if(!Load_0Comput)
                    timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                    ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutputComportement/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, 'Dim', dimension, 'ModelOutput.csv'))
                  }
                  
                  ## Pass to next step (plots)
                  
                    pcomp <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    Tcomp <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    
                    
                  # initialize first column
                  if (dim(pcomp)[2] == 0) {
                    while (dim(pcomp)[1] < length(ModelOutput$contrast)) {
                      pcomp = tibble::add_row(pcomp)
                      Tcomp = tibble::add_row(Tcomp)
                    }
                    pcomp$categ    = ModelOutput$categ
                    Tcomp$categ    = ModelOutput$categ
                    pcomp$MetaCond = ModelOutput$contrast
                    Tcomp$MetaCond = ModelOutput$contrast
                  }
                  
                  # Assign Values
                  pcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$p.value
                  Tcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$estimate
                  
                  if (dimension == 1) {
                    pcomp1 = pcomp
                    Tcomp1 = Tcomp
                    } else if (dimension == 2) {
                    pcomp2 = pcomp
                    Tcomp2 = Tcomp
                    } else if (dimension == 3) {
                    pcomp3 = pcomp
                    Tcomp3 = Tcomp
                    }

                } # end for dimension
              } # end if todo_corr_Comport

                if (todo_corr_Clinique && todo_corr_Comport) { DAT_LFP = DAT_LFPsave }
                if (todo_corr_Clinique) {
                  
                  DAT_LFPsave = DAT_LFP
                
                    pcompC1 <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC1 <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC2 <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC2 <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC3 <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC3 <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC4 <- data.frame()
                    TcompC4 <- data.frame()

                  for (Test in ClinicalTests) {
                    
                    if (!Load_0Comput) {
                    
                      DAT_LFP = DAT_LFPsave
                      DAT_LFP$Clinique = DAT_LFP[[Test]]  
                      DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "value", "Clinique")]), ]


                      remove(ModelOutput)
                      ModelOutput = data.frame()
                      ModelOutput = tibble::add_row(ModelOutput)

                      ModelOutput$contrast = 'AllInOne'
                      if (Test == 'dU3II' && ev == 'T0' && !OnlyFOGtoSubset) {
                          # Aggregate DAT_LFP per patient
                          DAT_LFP2 = aggregate(DAT_LFP$value, by = list(DAT_LFP$Patient, DAT_LFP$Medication, DAT_LFP$Channel, DAT_LFP$Task, DAT_LFP$ipsi_contra), FUN = median)
                          DAT_LFP3 = aggregate(DAT_LFP$dU3II, by = list(DAT_LFP$Patient,                     DAT_LFP$Channel, DAT_LFP$Task, DAT_LFP$ipsi_contra), FUN = median)
                          # In DAT_LFP2 aggregate by substracting on the medication
                          DAT_LFP2 = aggregate(DAT_LFP2$x, by = list(DAT_LFP2$Group.1, DAT_LFP2$Group.3, DAT_LFP2$Group.4, DAT_LFP2$Group.5), FUN = function(x) x[2] - x[1])

                          DAT_LFP4 = merge(DAT_LFP2, DAT_LFP3, by = c("Group.1", "Group.2", "Group.3", "Group.4"))
                          DAT_LFP4 = DAT_LFP4[complete.cases(DAT_LFP4[, c("Group.1", "x.x", "x.y")]), ]

                          ModelOutput$estimate = as.numeric(cor.test(DAT_LFP4$x.y, 10*log(DAT_LFP4$x.x,base=10), method = "spearman")$estimate)
                          ModelOutput$SE       = 0
                          ModelOutput$df       = 0
                          ModelOutput$t.ratio  = 0
                          ModelOutput$p.value  = cor.test(DAT_LFP4$x.y, 10*log(DAT_LFP4$x.x,base=10), method = "spearman")$p.value
                          ModelOutput$categ    = 'AllInOne' 
                      } else {
                          ModelOutput$estimate = cor(     DAT_LFP$Clinique, 10*log(DAT_LFP$value,base=10), method = "spearman")
                          ModelOutput$SE       = 0
                          ModelOutput$df       = 0
                          ModelOutput$t.ratio  = 0
                          ModelOutput$p.value  = cor.test(DAT_LFP$Clinique, 10*log(DAT_LFP$value,base=10), method = "spearman")$p.value
                          ModelOutput$categ    = 'AllInOne' 
                      }

                    
                      # Save
                      data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutputClinique/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Test_', Test, 'ModelOutput.csv'))

                    } else { # else de if(!Load_0Comput)
                      timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                      ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutputClinique/', Contact,'_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Test_', Test, 'ModelOutput.csv'))
                    } 
                    
                    ## Pass to next step (plots)
                  
                    pcomp <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    Tcomp <- data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    

                    # initialize first column
                    if (dim(pcomp)[2] == 0) {
                      while (dim(pcomp)[1] < length(ModelOutput$contrast)) {
                        pcomp = tibble::add_row(pcomp)
                        Tcomp = tibble::add_row(Tcomp)
                      }
                      pcomp$categ    = ModelOutput$categ
                      Tcomp$categ    = ModelOutput$categ
                      pcomp$MetaCond = ModelOutput$contrast
                      Tcomp$MetaCond = ModelOutput$contrast
                    }
                    
                    # Assign Values
                    pcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$p.value
                    Tcomp[[paste0('Freq', Freqpoint, '-', timeName)]] = ModelOutput$estimate
                    
                    if (Test == 'U3') {
                      pcompC1 = pcomp
                      TcompC1 = Tcomp
                      } else if (Test == 'dU3II') {
                      pcompC2 = pcomp
                      TcompC2 = Tcomp
                      } else if (Test == 'dP39') {
                      pcompC3 = pcomp
                      TcompC3 = Tcomp
                      } else if (Test == 'dFogQ') {
                      pcompC4 = pcomp
                      TcompC4 = Tcomp
                      }

                      
                  } # End for Test
                } # End if todo_corr_Clinique

              remove(ModelOutput)
              remove(Stats)
              remove(DAT_LFP) # Remove pour que la prochaine itération ne calcule pas ces données en plus.
              
              
              output = list(pval, TFpw) #### ONLY FOR PARALLEL COMPUTING 
              if (todo_corr_Comport)  { output = c(output, list(pcomp1, Tcomp1, pcomp2, Tcomp2, pcomp3, Tcomp3)) } #### ONLY FOR PARALLEL COMPUTING
              if (todo_corr_Clinique) { output = c(output, list(pcompC1, TcompC1, pcompC2, TcompC2, pcompC3, TcompC3,pcompC4, TcompC4)) } #### ONLY FOR PARALLEL COMPUTING
              
              output
              
            } # End Parallel

                if (OnlyFOGtoSubset) {
                  ev = 'T0FOG'
                }

        save.image(file = paste0(OutputDir, '/ModelOutput/WorkSpace', Contact,'_', ev, '.RData'))
        
        
        ## Loop over ResPar Results 
        for (i_colrespar in seq(1,ncol(ResPar),by=2)) {
          if (i_colrespar == 1) {
            Case = 'Vanilla'
            Suf_Case = ''
          } else if (i_colrespar < 8 && todo_corr_Comport) {
            Case = 'Comportement'
            Suf_Case = paste0('_ComptDim', (i_colrespar-1)/2)
          } else if (i_colrespar > 8 && todo_corr_Comport && todo_corr_Clinique) {
            Case = 'Clinique'
            if (i_colrespar ==  9) { Suf_Case = '_U3   ' }
            if (i_colrespar == 11) { Suf_Case = '_dU3II' }
            if (i_colrespar == 13) { Suf_Case = '_dP39'  }
            if (i_colrespar == 15) { Suf_Case = '_dFogQ' }
          } else if (i_colrespar > 1 && !todo_corr_Comport && todo_corr_Clinique) {
            Case = 'Clinique'
            if (i_colrespar ==  3) { Suf_Case = '_U3   ' }
            if (i_colrespar ==  5) { Suf_Case = '_dU3II' }
            if (i_colrespar ==  7) { Suf_Case = '_dP39'  }
            if (i_colrespar ==  9) { Suf_Case = '_dFogQ' }
          }

          
          
                      MAGIC_Colormap = function(Case) {
                          if (Case == 'Vanilla') {
                              colormap_to_use  =
                                  grDevices::colorRampPalette(
                                      c(
                                          "#00007F",
                                          "blue",
                                          "#007FFF",
                                          "cyan",
                                          "#7FFF7F",
                                          "yellow",
                                          "#FF7F00",
                                          "red",
                                          "#7F0000"
                                      )
                                  )
                                  
                          } else if (Case == 'Comportement') {
                            #  colormap_to_use  = colorRamps::ygobb
                            # BrBG aussi interessant
                            # colormap_to_use  = colorRamps::blue2yellow
                            colormap_to_use  = grDevices::colorRampPalette(c("#281E78","#ffffff","#fa4616"))
                          } else if (Case == 'Clinique') {
                            # colormap_to_use  = colorRamps::blue2green
                            colormap_to_use  = grDevices::colorRampPalette(c("#281E78","#ffffff","#fa4616"))
                          }
                          
                          return(colormap_to_use)
                      }
          
          colormap_to_use = MAGIC_Colormap(Case)
          missingValuesColor = "black"
          
          ## Get back results from foreach iteration
          pval = ResPar[1,i_colrespar  ][[1]]
          TFpw = ResPar[1,i_colrespar+1][[1]]
        
          for (i_rowrespar in 2:nrow(ResPar)) {
            tfname = colnames(ResPar[i_rowrespar, i_colrespar    ][[1]])[3]
            pval[[tfname]]  = ResPar[i_rowrespar, i_colrespar    ][[1]][[3]]
            TFpw[[tfname]]  = ResPar[i_rowrespar, i_colrespar + 1][[1]][[3]]
          }
        
            
            #######################################################################################################
            ## PLOTS ##############################################################################################
            #######################################################################################################
            
            if (todo_Plots) {
              
              
              ## Plot All contre 0 => No contrast
              foreach(MetCondnum = 1:length(unique(pval$MetaCond))) %dopar% {
                MetCond  = pval$MetaCond[MetCondnum]
                PlotName = paste0('TF_', ev, '_', Contact, '_', MetCond, '_', PValueLimit , Suf_Case )
                PlotFolder  = paste0('/', pval$categ[MetCondnum], '/')
                
                print(paste0('PLOTS : Metacondition ', MetCondnum, ' sur ', length(pval$MetaCond), ' ----- ', Sys.time()))
                
                # Preparer la table
                data = data.frame(Freq = numeric(0), Time = numeric(0), Power = numeric(0), pvalue = numeric(0))
                
                #Recuperer les parametres de temps et frequence
                for (colnum in 3:length(colnames(pval))){
                  colname   = colnames(pval)[colnum]
                  timepoint = strsplit(colname, '-')[[1]][2]
                  timepoint = gsub("x_", "-", timepoint, fixed = TRUE)
                  timepoint = gsub("_" , ".", timepoint)
                  timepoint = gsub("x" , "" , timepoint)
                  timepoint = as.numeric(timepoint)
                  
                  freqpt  = strsplit(colname, '-')[[1]][1]
                  freqpt  = gsub("Freq" , "" , freqpt)
                  freqpt  = as.numeric(freqpt)
                  
                  # Ajouter dans la table finale la valeur
                  data                    = add_row(data)
                  data$Freq[  nrow(data)] = freqpt
                  data$Time[  nrow(data)] = timepoint
                  data$Power[ nrow(data)] = TFpw[MetCondnum,colnum]
                  data$pvalue[nrow(data)] = pval[MetCondnum,colnum]
                }  # end for (colnum...)
                
                # Write data to a file
                data.table::fwrite(data, file = paste0(OutputDir, '/ProcessedData/', PlotName, '.csv'))
                
                ## Plot Video (gif)
                if (todo_gifplot) {
                  lim  = max(abs(data$Power))
                  
                  # get time limit
                  includedCenterValues = subset(data, 
                                                (data$Time >= min(data$Time) + SlidingWindowHalfSize & 
                                                  data$Time <= max(data$Time) - SlidingWindowHalfSize))
                  
                  # Create a function that will plot each frame 
                  # Same ggplot as below (mais titre et centre du plot modifiés)
                  gif.frame = function(count){
                    
                    center = includedCenterValues$Time[count]
                    dat4frame = subset(data, 
                                      (data$Time >= center - SlidingWindowHalfSize  & 
                                          data$Time <= center + SlidingWindowHalfSize))
                    Switch = (0 >= center - SlidingWindowHalfSize  & 0 <= center + SlidingWindowHalfSize)
                    
                    a = ggplot(dat4frame, aes(x = Time, y = Freq, fill = Power)) +
                      # coord_trans(y = Espacement_Freq) +              # scale en log10
                      geom_raster(interpolate = TRUE) + 
                      geom_density_2d_filled(data = dat4frame[dat4frame$pvalue < PValueLimit,], aes(z = pvalue), show.legend = FALSE, n = 100) +
                      scale_fill_gradientn(colours = colormap_to_use(100), lim = c(-lim, lim), na.value = missingValuesColor) +
                      {if (Switch) geom_vline(xintercept = 0, linewidth = .2)} +  # add a vertical line at x = 0 conditionnaly
                      # geom_contour(data = dat4frame[dat4frame$pvalue < PValueLimit,], aes(z = pvalue, colour = "black"), show.legend = FALSE, breaks = PValueBreaks) +
                      theme_classic() + 
                      ggtitle(paste0(PlotName, " - Temps = ", round(center, digits = 2))) +
                      theme(plot.title = element_text(hjust = 0.5)) + # center the plot title
                      scale_colour_manual("", values = "black")       # For the geom contour
                    
                    print(a)
                  }
                  
                  gif.anim = function() lapply(1:length(unique(includedCenterValues$Time)), function(i)  gif.frame(i) )  
                  
                  saveGIF(gif.anim(), movie.name=paste0(OutputDir, PlotFolder , PlotName, '.gif'))
                  
                  rm(includedCenterValues)
                  
                } # End gif
                
                
                ## Plot Image fixe
                
                if (todo_tfmapplot) {
                  
                  # Data final preprocessing
                  data = subset(data, (data$Time >= -1 & data$Time <= 1))
                  lim  = max(abs(data$Power))
                  if (Case == "Vanilla") {
                    lim  = 15
                  } else if (Case == "Clinique") {
                    lim  = 1
                  } else if (Case == "Comportement") {
                    lim  = 0.5
                  }
                  # Plot
                  ggplot(data, aes(x = Time, y = Freq, fill = Power)) +
                    # coord_trans(y = Espacement_Freq) +              # scale en log10
                    geom_raster(interpolate = TRUE) + 
                    scale_fill_gradientn(colours = colormap_to_use(100), lim = c(-lim, lim), na.value = missingValuesColor) +
                    geom_vline(xintercept = 0, linewidth = .2) +         # add a vertical line at x = 0
                    # geom_contour(data = data[data$pvalue < PValueLimit,], aes(z = pvalue, colour = "black"), show.legend = FALSE, breaks = PValueBreaks) +
                    theme_classic() + 
                    geom_density_2d_filled(data = data[data$pvalue < PValueLimit,], aes(z = pvalue), show.legend = FALSE, n = 100) +
                    ggtitle(PlotName) +
                    geom_hline(yintercept = 12, linetype = "dashed", color = "#000000", size = 0.5) +
                    geom_hline(yintercept = 35, linetype = "dashed", color = "#000000", size = 0.5) +
                    theme(plot.title = element_text(hjust = 0.5)) + # center the plot title
                    scale_colour_manual("", values = "black")       # For the geom contour
                  
                  ## sauvegarde des graphes
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '.png'), width = FigWidth, height = FigHigh, units = "cm")
                  ggsave(paste0(OutputDir, PlotFolder , PlotName, '.svg'), width = FigWidth, height = FigHigh, units = "cm")
                }  # end fixed image plot
              } # end for MetCond
              rm(data)
              print("success")
            } #end plot
            
          } # end for ResPar
          
        } # end for event
    }
  }
}

if (donotmake) {
      # Violin plot BETA Low
      load("C:/Users/mathieu.yeche/Desktop/WorkSpaceAllPat_FOG_E.RData")
      TFbySubjectE1 = TFbySubject
      TPE = timepoints_number
      load("C:/Users/mathieu.yeche/Desktop/WorkSpaceAllPat_FOG_S.RData")
      TFbySubjectS1 = TFbySubject
      TPS = timepoints_number
      load("C:/Users/mathieu.yeche/Desktop/WorkSpaceAllPat_T0.RData")
      TFbySubjectT1 = TFbySubject
      TPT = timepoints_number


      
      
      colname      = colnames(TFbySubjectS)[18:(17+TPS)]
                      timepoint = gsub("x_", "-", colname, fixed = TRUE)
                      timepoint = gsub("_" , ".", timepoint)
                      timepoint = gsub("x" , "" , timepoint)
                      timepoint = as.numeric(timepoint)
                      firstIncludedTPNegative = which(timepoint >= -0.5)[1] -1
                      lastIncludedTPNegative = which(timepoint >= -0.1)[1]
                      firstIncludedTPPositive = which(timepoint >= 0.1)[1]
                      lastIncludedTPPositive = which(timepoint >= 0.5)[1]
                      
      colname      = colnames(TFbySubjectT)[18:(17+TPT)]
                      timepoint = gsub("x_", "-", colname, fixed = TRUE)
                      timepoint = gsub("_" , ".", timepoint)
                      timepoint = gsub("x" , "" , timepoint)
                      timepoint = as.numeric(timepoint)
                      firstIncludedTPNegativeT = which(timepoint >= -0.5)[1] -1
                      lastIncludedTPNegativeT = which(timepoint >= -0.1)[1]
                      firstIncludedTPPositiveT = which(timepoint >= 0.1)[1]
                      lastIncludedTPPositiveT = which(timepoint >= 0.5)[1]


      HighPass = 70
      LowPass  = 80
      TFbySubjectT = subset(TFbySubjectT1, TFbySubjectT1$Freq >= HighPass & TFbySubjectT1$Freq <= LowPass)      
      TFbySubjectS = subset(TFbySubjectS1, TFbySubjectS1$Freq >= HighPass & TFbySubjectS1$Freq <= LowPass)      
      TFbySubjectE = subset(TFbySubjectE1, TFbySubjectE1$Freq >= HighPass & TFbySubjectE1$Freq <= LowPass)      
      
    

      ViolinTable = data.frame(matrix(NA, nrow = length(unique(paste0(TFbySubjectS$Patient, '_', TFbySubjectS$Medication, '_', TFbySubjectS$nTrial)))))
      ViolinTable$Id =  unique(paste0(TFbySubjectS$Patient, '_', TFbySubjectS$Medication, '_', TFbySubjectS$nTrial))
      TFbySubjectT$Id = paste0(TFbySubjectT$Patient, '_', TFbySubjectT$Medication, '_', TFbySubjectT$nTrial)
      TFbySubjectE$Id = paste0(TFbySubjectE$Patient, '_', TFbySubjectE$Medication, '_', TFbySubjectE$nTrial)
      TFbySubjectS$Id = paste0(TFbySubjectS$Patient, '_', TFbySubjectS$Medication, '_', TFbySubjectS$nTrial)


      for (trial in ViolinTable$Id) {
        Tindex = which(TFbySubjectT$Id == trial)
        ViolinTable$Wait[ViolinTable$Id == trial]   = mean(colMeans(TFbySubjectT[TFbySubjectT$Id == trial, firstIncludedTPNegativeT:lastIncludedTPNegativeT], na.rm = TRUE))
        alpha = mean(colMeans(TFbySubjectT[TFbySubjectT$Id == trial, firstIncludedTPPositiveT:lastIncludedTPPositiveT], na.rm = TRUE))
        beta  = mean(colMeans(TFbySubjectS[TFbySubjectS$Id == trial, firstIncludedTPNegative:lastIncludedTPNegative], na.rm = TRUE))
        gamm  = mean(colMeans(TFbySubjectE[TFbySubjectE$Id == trial, firstIncludedTPPositive:lastIncludedTPPositive], na.rm = TRUE))
        ViolinTable$Normal[ViolinTable$Id == trial] = mean(c(alpha, beta, gamm))
        ViolinTable$GI[ViolinTable$Id == trial]     = mean(c(alpha      , gamm))
        f1 = mean(colMeans(TFbySubjectS[TFbySubjectS$Id == trial, firstIncludedTPPositive:lastIncludedTPPositive], na.rm = TRUE))
        f2 = mean(colMeans(TFbySubjectE[TFbySubjectE$Id == trial, firstIncludedTPNegative:lastIncludedTPNegative], na.rm = TRUE))
        ViolinTable$FOG[ViolinTable$Id == trial]    = mean(c(f1, f2))
        ViolinTable$preFOG[ViolinTable$Id == trial]    = beta
      }


ViolinTableMelted = reshape2::melt(ViolinTable)

                    ggplot(ViolinTableMelted, aes(x = variable, y = log(value),base = 10), color = variable) + 
                      geom_violin(alpha = 0.5) + 
                      ggbeeswarm::geom_beeswarm(cex = 2, size = 1.8, alpha = 0.2, corral = "random", corral.width = 0.9) +
                      theme_classic() +
                      geom_line(aes(x = variable, y = log(value),group = Id), color = "grey", alpha = 0.2) +
                      geom_boxplot(width=0.1, alpha=0.1, outlier.shape = NA, position=position_dodge(1), trailing = FALSE) 
                      
                    ggsave(filename = paste0("C:/Users/mathieu.yeche/Desktop/FTG", ".png" ), width = 12, height = 9)

ViolinTableMelted$value = log(ViolinTableMelted$value, base = 10)
write.csv(dcast(ViolinTableMelted, Id ~ variable, value.var = "value"))


}

if (donotmake) {

1+1
for (EVENT_CHANGE_HERE in c("T0", "T0prefog" , "FOG_S" ,  "FOG_E")) {

  if (EVENT_CHANGE_HERE != "T0prefog") {
    load(paste0("C:/Users/mathieu.yeche/Desktop/WorkSpaceAllPat_", EVENT_CHANGE_HERE,".RData"))
  } else {
    load(paste0("C:/Users/mathieu.yeche/Desktop/WorkSpaceAllPat_T0.RData"))
  }
    
            MY_APA$PatID = NA
                    for (rownumAPA in 1:nrow(MY_APA)) {
                      if (nchar(MY_APA$Subject[rownumAPA]) == 3) {
                        MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 3, 3)))
                      } else {
                        MY_APA$PatID[rownumAPA] = paste0(substr(MY_APA$Subject[rownumAPA], 1, 2), tolower(substr(MY_APA$Subject[rownumAPA], 4, 4)))
                      }
                    }
                    MY_APA$Subject = MY_APA$PatID

  if (EVENT_CHANGE_HERE == "T0prefog") {
    # keep only in TFbySubject the trials for which MY_APA$is_FOG = 1
    MY_APA = subset(MY_APA, MY_APA$is_FOG == 1)
    TFbySubject = subset(TFbySubject, 
      paste0(sub(".*_", "", TFbySubject$Patient), "_", TFbySubject$Medication, "_", TFbySubject$nTrial) %in% 
      paste0(MY_APA$PatID,                        "_", MY_APA$Condition,       "_", MY_APA$TrialNum))

  }

  bandnames = c("Theta","Alpha", "LowBeta","HighBeta","Beta","Gamma")
  bandstart = c(4,8, 13,21,13,36)
  bandend   = c(7,12,20,35,35,90)

  globalResult = data.frame()

    for (bandnum in seq_along(bandstart)) {
      sfreq = bandstart[bandnum]
      efreq = bandend[bandnum]

      TFbySubjectBand = subset(TFbySubject, TFbySubject$Freq >= sfreq & TFbySubject$Freq <= efreq)

      ResParBand = foreach(timefreq = 1:timepoints_number, .combine = 'rbind') %dopar% {
                  # Recuperation du temps frequence
                  DAT_LFP = subset(TFbySubjectBand, select = c(1:17, timefreq+17))                 
                  
                  # Nom des variables
                  timeName = colnames(DAT_LFP)[18]
                  timeName = gsub("x_", "-", timeName, fixed = TRUE)
                  timeName = gsub("_" , ".", timeName)
                  timeName = gsub("x" , "" , timeName)
                  timeName = as.numeric(timeName)
                  


                  colnames(DAT_LFP)[18] = "value"
                  
                  # Transformation en variable numerique de la valeur
                  DAT_LFP %>% mutate(num = as.numeric(value)) %>% filter( (is.na(num) & !is.na(value)) | (!is.na(num) & is.na(value)) ) %>% select(Patient, value, num)
                  DAT_LFP$value <- as.numeric(DAT_LFP$value)
                  
                  # Remove NA
                  if (!stringr::str_detect(ev, 'FC') || !stringr::str_detect(ev, 'FO')) { 
                    DAT_LFP$side = ifelse(is.na(DAT_LFP$side), "None", DAT_LFP$side) # Embetant pour certains events mais pas tous
                  } 
                  DAT_LFP = DAT_LFP[complete.cases(DAT_LFP[, c("Patient", "Medication", "Task", "side", "Channel", "nTrial", "value")]), ]
                  DAT_LFP = transform(transform(transform(DAT_LFP, 
                                                          hemisphere  = ifelse(stringr::str_detect(Channel, 'D'), 'R',  ifelse(stringr::str_detect(Channel, 'G'), 'L' , NA))), 
                                                ipsi_contra = ifelse(hemisphere == side, 'ipsi', ifelse(side == "None", 'None', 'contra'))),
                                      MetaCond    = paste( Event, Medication, Task, hemisphere, ipsi_contra, sep = '_'))  
                  
                  #######################################################################################################
                  ## STATS ##############################################################################################
                  #######################################################################################################
                  
                  # Modèle 
                  model = lme4::lmer(10*log(value,base=10) ~ Medication + Task*hemisphere + Freq + (1 |Patient/Channel), data = DAT_LFP)
                  # DELETE ipsi_contra           Que dans ce modèle et pas en dessous, ou on supprime cette var. En interaction avec hémisphère et med
                  # DELETE nStep                 Lorsqu'il y a plusieurs fois l'evenement dans 1 Trial (FO, FC, FOG)
                  
                  
                  if (VerboseAnova == TRUE) {
                    print(paste0( Contact,'_', ev, ' Freq', Freqpoint, 'Time', timeName ))
                    car::Anova(model)          #For Visual inspection
                    print(' ')
                    performance::check_model(model)  
                  } 
                  
                  # Insertion dans la matrice de sortie
                  
                  # Toutes les variables :
                  # toutes les conditions
                  EMMean  = emmeans(model, ~  Medication)        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres 
                  emmean  = data.frame(EMMean)
                  emCase  = data.frame(contrast(EMMean,       
                                                setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))), 
                                                          apply(       emmean , 1, function(x) x[1]))))
                  
                  # Output
                  output = data.frame()
                  output = tibble::add_row(output)
                  output = tibble::add_row(output)
                  output$Band = bandnames[bandnum]
                  output$contrast = emCase$contrast
                  output$Time = timeName
                  output$estimate = emCase$estimate
                  output$SE = emCase$SE
                  output$p.value = emCase$p.value

                  output   
      
      } # End of timefreq loop

      globalResult = rbind(globalResult, ResParBand)

    } # End of band loop

    globalResult = subset(globalResult, globalResult$Band != "Beta")

    #PLOT
    for (medication in unique(globalResult$contrast)) {
      ToPlot = subset(globalResult, contrast == medication)
      ToPlot$estimate = as.numeric(ToPlot$estimate)
      ToPlot$SE = as.numeric(ToPlot$SE)

      # Order the different bands 
      ToPlot$Band = factor(ToPlot$Band, levels = c("Theta","Alpha", "LowBeta","HighBeta","Beta","Gamma"))
      # Change the palette
      myPalette = grDevices::colorRampPalette(c("#281E78","#fa4616"))
      myPalette = myPalette(length(unique(ToPlot$Band)))
        # Use this palette for filling

      ggplot(ToPlot, aes(x = Time, y = estimate, color = Band, group = Band)) + 
        geom_line() + 
        geom_ribbon(aes(ymin = estimate - SE, ymax = estimate + SE, fill = Band), alpha = 0.05, linetype = 0) +
        labs(title = paste0(EVENT_CHANGE_HERE, "_", medication), x = "Time", y = "Power") + 
        theme_bw() + 
        theme(legend.position = "none") + 
        scale_color_manual(values = myPalette) +
        scale_fill_manual(values = myPalette)

      ggsave(paste0("C:/Users/mathieu.yeche/Documents/R Environment and Data/plot/", EVENT_CHANGE_HERE, "_", medication, ".png"), width = 10, height = 10)
      ggsave(paste0("C:/Users/mathieu.yeche/Documents/R Environment and Data/plot/", EVENT_CHANGE_HERE, "_", medication, ".svg"), width = 10, height = 10)
  
        #zerophase filter
        bf  = signal::butter(3, 0.5)
        ToPlot$estimate  = signal::filtfilt(bf$b, bf$a, ToPlot$estimate)
        ToPlot$SE        = signal::filtfilt(bf$b, bf$a, ToPlot$SE)

      ggplot(ToPlot, aes(x = Time, y = estimate, color = Band, group = Band)) + 
        geom_line() + 
        geom_ribbon(aes(ymin = estimate - SE, ymax = estimate + SE, fill = Band), alpha = 0.05, linetype = 0) +
        labs(title = paste0(EVENT_CHANGE_HERE, "_", medication), x = "Time", y = "Power") + 
        theme_bw() + 
        theme(legend.position = "none") + 
        scale_color_manual(values = myPalette) +
        scale_fill_manual(values = myPalette)

      ggsave(paste0("C:/Users/mathieu.yeche/Documents/R Environment and Data/plot/", EVENT_CHANGE_HERE, "_", medication, "_filt.png"), width = 10, height = 10)
      ggsave(paste0("C:/Users/mathieu.yeche/Documents/R Environment and Data/plot/", EVENT_CHANGE_HERE, "_", medication, "_filt.svg"), width = 10, height = 10)
    } # End of medication loop
  } # End of event loop


  { ## T reaction
    MY_Pat = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/DATA/ResAPA_extension_LINKERS_v3.xlsx"
    MY_APA = readxl::read_excel(MY_Pat, sheet = 1)
    MY_APA = MY_APA %>%
        mutate( across(c(8),~as.numeric(as.character(.x))))
      
    # MY_APA = subset(MY_APA, Condition != "ON")
    myPalette = grDevices::colorRampPalette(c("#281E78","#fa4616"))

    # boxplot of T0 for GoNogo = 'C' and 'I'
    ggplot(MY_APA, aes(GoNogo, real_t_reac)) + 
      geom_boxplot() + 
      labs(title = "Reaction Time", x = "GoNogo", y = "Time") + 
      theme_bw() + 
      theme(legend.position = "none") +
      ylim(0.1, 0.6)

    # same with mean by Subject
    df = data.frame()
    for (subject in unique(MY_APA$Subject)) {
      df = rbind(df, data.frame(Subject = subject, 
                                GoNogo = "C", 
                                real_t_reac = mean(subset(MY_APA, Subject == subject & GoNogo == "C")$real_t_reac, na.rm = TRUE)))
      df = rbind(df, data.frame(Subject = subject, 
                                GoNogo = "I", 
                                real_t_reac = mean(subset(MY_APA, Subject == subject & GoNogo == "I")$real_t_reac, na.rm = TRUE)))
    }

    ggplot(df, aes(GoNogo, real_t_reac)) + 
      geom_boxplot() + 
      labs(title = "Reaction Time", x = "GoNogo", y = "Time") + 
      theme_bw() + 
      theme(legend.position = "none") +
      ylim(0.1, 0.6) +
ggplot(df, aes(GoNogo, real_t_reac)) + 
  geom_boxplot() + 
  stat_summary(fun = mean, geom = "text", aes(label = round(..y.., 2)), vjust = -1) +
  labs(title = "Reaction Time", x = "GoNogo", y = "Time") + 
  theme_bw() + 
  theme(legend.position = "none") +
  ylim(0.1, 0.6)
  }

  


} # End if NOT TO DO 

stopCluster(cl)

#############################################################################################
###### Sortie


print("!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!! END All Patients !!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!")

IdForNotification = paste(ev,collapse ="_")
Timing = format(Sys.time(), "%F_%H-%M-%S")
# if (!curl::has_internet()) {
  filename = paste(LogDir, Timing, "-R_Stats" , IdForNotification , "SUCCESS", ".txt",sep = "")
  fileSuccess<-file(filename)
  writeLines("Hello", fileSuccess)
  close(fileSuccess)
# } else {
#   load()
#   httr::GET("https://smsapi.free-mobile.fr/...")
# }



## CST
if (donotmake) {

# Load libraries
library(ggplot2)
library(readxl)

# Load data  Z:\DATA\ResAPA_extension_LINKERS_v3.xlsx
Rtime = read_excel("Z:/DATA/ResAPA_extension_LINKERS_v3.xlsx")

# Plot
ggplot(Rtime, aes(x = paste0(GoNogo) , y = real_t_reac )) + 
# I want only 1 point per subject
stat_summary(aes(x = paste0(GoNogo) , y = real_t_reac, color = Subject ), fun.y = mean, geom = "point", size = 3) +
# I want only 1 boxplot per condition for all subjects
geom_boxplot(alpha = 0.5, outlier.shape = NA) +
#trait entre chaque patient
geom_line(aes(x = paste0(GoNogo) , y = real_t_reac, group = Subject, color = Subject ), alpha = 0.5) +
# nice theme
theme_bw() +
# nice labels
labs(x = "Condition", y = "Reaction time (ms)", title = "Reaction time per condition") +
# x axis 0 to 1
scale_x_discrete(limits = c("C", "I")) +
# geom_facet
facet_grid(~Condition) 

}