#############################################################################################
##                                                                                         ##
##                                     MAGIC  -  Test stat                                 ##
##                                                                                         ##
#############################################################################################

#############################################################################################
###### Initialisation
# DEFINE PATHS
rm(list = ls())
gc()

events  = c( "CUE", "FIX", "FO1", "FC1", "T0", "T0_EMG", "FO", "FC", "FOG_S", "FOG_E", "TURN_S", "TURN_E")
events  = c( "FO1", "FC1", "FO", "FC","T0", "T0_EMG",  "CUE", "FIX", "TURN_S", "TURN_E", "FOG_S", "FOG_E")
# events  = c( "CUE")

if (.Platform$OS.type == "unix")  {
  DataDir   = '/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  OutputDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats"
  LogDir    = "/network/lustre/iss02/home/mathieu.yeche/Cluster/outputs/"
  sourcFile = "/network/lustre/iss02/home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
} else {
  DataDir    = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses'
  DataDir_GI = '//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MarcheReelle/02_electrophy'
  OutputDir  = "//l2export/iss02.pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/03_CartesTF/Stats"
  LogDir     = "//l2export/iss02.home/mathieu.yeche/Cluster/outputs/"
  sourcFile  = "//l2export/iss02.home/mathieu.yeche/Cluster/Matlab/LabAnalyses/+MAGIC/r/MAGIC_Stats_SourceFile.R"
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
library(FactoMineR)
library(factoextra)
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
Montage  = 'extended'       # 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal
Artefact = 'TF'             # 'TraceBrut' , 'TF',  'none'

Contacts_of_interest = c("HotspotFOG","Motor") # or grouping + "HighestBeta"
GroupingMode         = "Region"

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
         RestrictTimeCalculated = TRUE   # Change here to TRUE to prevent statistical computing outside [-1 ; 1]
} else { RestrictTimeCalculated = FALSE }# DO NOT CHANGE 
# groups   = c('STN')
groups   = c('MAGIC_Only')



cl = makeCluster(detectCores())
if (Sys.info()["nodename"] == "UMR-LAU-WP011") {
  DataDir   = 'C:/LustreSync/TMP/analyses'
  OutputDir = "C:/LustreSync/03_CartesTF/Stats"
  cl = makeCluster(detectCores()-2)
}
registerDoParallel(cl)
clusterExport(cl, "LoadLibrary_and_RSourceFiles")
clusterEvalQ(cl, LoadLibrary_and_RSourceFiles())


print("Some custom code can be found in Mathieu Yeche's PhD Scripts => Poster ECCN mai 2023")


for (nor in normtype) {
  for (Contact in Contacts_of_interest) { 
    for (gp in groups) {
      # SET SUBJECT
      if (gp == 'MAGIC_Only') {
        subjects =
          c(
            'ALb_000a',
            'FEp_0536',   
            'VIj_000a',
            'DEp_0535',
            'GAl_000a',
            'SOh_0555',
            'GUg_0634',
            # "FRa_000a",
            # "SAs_000a",
            'FRj_0610'
          )
        
        listnameSubj =
          c(
            "ParkPitie_2020_06_25_ALb",
            "ParkPitie_2020_02_20_FEp",
            "ParkPitie_2021_04_01_VIj",
            "ParkPitie_2020_01_16_DEp",
            "ParkPitie_2020_09_17_GAl",
            "ParkPitie_2020_10_08_SOh",
            "ParkRouen_2020_11_30_GUg",
            # "ParkRouen_2021_10_04_FRa",
            # "ParkPitie_2021_10_21_SAs",
            "ParkRouen_2021_02_08_FRj"
          )
          
      }
      
      if (gp == 'STN') {
        subjects =
          c(
            'DEj_000a',
            'ALb_000a',
            'FEp_0536',   
            'VIj_000a',
            'DEp_0535',
            'GAl_000a',
            'SOh_0555',
            'GUg_0634',
            'FRj_0610',
            'BAg_0496',
            'DRc_000a',
            'COm_000a',
            'BEm_000a',
            "REa_0526",
            "SAs_000a",
            "GIs_0550",
            # "FRa_000a",
            'LOp_000a',
            'ParkPitie_2013_03_21_ROe',
            'ParkPitie_2013_04_04_REs',
            'ParkPitie_2013_06_06_SOj',
            'ParkPitie_2013_10_10_COd',
            'ParkPitie_2013_10_17_FRl',
            'ParkPitie_2013_10_24_CLn',
            'ParkPitie_2014_04_18_MAd',
            'ParkPitie_2014_06_19_LEc',
            'ParkPitie_2015_01_15_MEp',
            'ParkPitie_2015_03_05_RAt',
            'ParkPitie_2015_04_30_VAp',
            'ParkPitie_2015_05_07_ALg',
            'ParkPitie_2015_05_28_DEm',
            'ParkPitie_2015_10_01_SAj'
          )
        
        listnameSubj =
          c(
            "ParkPitie_2019_04_25_DEj",      #GOGAIT_POSTOP_DESJO20
            "ParkPitie_2020_06_25_ALb",
            "ParkPitie_2020_02_20_FEp",
            "ParkPitie_2021_04_01_VIj",
            "ParkPitie_2020_01_16_DEp",
            "ParkPitie_2020_09_17_GAl",
            "ParkPitie_2020_10_08_SOh",
            "ParkRouen_2020_11_30_GUg",
            "ParkRouen_2021_02_08_FRj",
            "ParkPitie_2019_02_21_BAg",      #GOGAIT_POSTOP_BARGU14
            "ParkPitie_2019_03_14_DRc",      #GOGAIT_POSTOP_DROCA16
            "ParkPitie_2019_10_24_COm",
            "ParkPitie_2019_10_03_BEm",
            "ParkPitie_2020_01_09_REa",
            "ParkPitie_2021_10_21_SAs",
            "ParkPitie_2020_07_02_GIs",
            #  "ParkRouen_2021_10_04_FRa",
            "ParkPitie_2019_11_28_LOp",
            'ParkPitie_2013_03_21_ROe',
            'ParkPitie_2013_04_04_REs',
            'ParkPitie_2013_06_06_SOj',
            'ParkPitie_2013_10_10_COd',
            'ParkPitie_2013_10_17_FRl',
            'ParkPitie_2013_10_24_CLn',
            'ParkPitie_2014_04_18_MAd',
            'ParkPitie_2014_06_19_LEc',
            'ParkPitie_2015_01_15_MEp',
            'ParkPitie_2015_03_05_RAt',
            'ParkPitie_2015_04_30_VAp',
            'ParkPitie_2015_05_07_ALg',
            'ParkPitie_2015_05_28_DEm',
            'ParkPitie_2015_10_01_SAj'
          )
          
      }
      
      #############################################################################################
      ###### Chargement du fichier
      
      ##LOAD DATA
      listname = matrix(NaN, nrow = 1, ncol = 15)
      iname = 1
      
      
      for (ev in events) {
          
          if (ev ==  "FOG_S" ||  ev ==  "FOG_E") {
            subjects =
              c(
                'ALb_000a',
                'VIj_000a',
                'DEj_000a',
                'GAl_000a',
                'SAs_000a',
                #'FRa_000a',
                'GUg_0634',
                'GIs_0550',
                error('sujets ACC')
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
                "ParkPitie_2020_07_02_GIs",
                error('sujets ACC')
              )
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

              
              # precise groupe of protocol : GI or GNG
              if (s == 'ParkPitie_2013_03_21_ROe' || s == 'ParkPitie_2013_04_04_REs' || s == 'ParkPitie_2013_06_06_SOj' || s == 'ParkPitie_2013_10_10_COd' || s == 'ParkPitie_2013_10_17_FRl'|| s == 'ParkPitie_2013_10_24_CLn' 
                  || s == 'ParkPitie_2014_04_18_MAd' || s == 'ParkPitie_2014_06_19_LEc' || s == 'ParkPitie_2015_01_15_MEp' || s == 'ParkPitie_2015_03_05_RAt' || s ==  'ParkPitie_2015_04_30_VAp' 
                  || s ==  'ParkPitie_2015_05_07_ALg' || s == 'ParkPitie_2015_05_28_DEm' || s == 'ParkPitie_2015_10_01_SAj') { 
                task_name = 'GI' 
                suff_name = ''
              } else { 
                task_name = 'GNG_GAIT'  
                suff_name = paste('_', Montage,'_', Artefact, sep="")
              }
              
              #######################################################################################################
              ## CHARGEMENT #########################################################################################
              #######################################################################################################
              
              s_count = s_count + 1
              print(paste0('########## Patient ', s_count, ' of ', length(subjects), ' /// ', s, ' ', ev, ' ##########' ))
              
              
              # define recdir depending on protocol group
              if (task_name == 'GI'){
                WorkDir = paste(DataDir , s, sep = "/")
              } else {
                RecDir = list.dirs(paste(DataDir , s, sep = "/"), full.names = T, recursive = F)
                WorkDir = paste(RecDir, '/POSTOP', sep = "") 
              }
              
              if (task_name == 'GI' || s == 'DEj_000a' || s == 'DRc_000a'|| s == 'BEm_000a' || s == 'BAg_0496' || s == 'LOp_000a'|| s == 'GIs_0550' || s == 'COm_000a'|| s == 'REa_0526' ) { 
                protocol = 'GBMOV' 
              } else { 
                protocol = 'MAGIC'  
              }
              outputname = listnameSubj[s_count]
              
              
              if ((nor == 'ldNOR') && segType  == 'step') {
                TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_', 'dNOR', suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
                } else {
                TF1Pat = vroom::vroom(paste(WorkDir, '/', outputname, '_', protocol, '_POSTOP_', task_name, '_', segType, '_TF_',   nor , suff_name, '_', 'tBlock', tBlock, '_', 'fqStart', fqStart, '_', ev, '.csv', sep = ""), show_col_types = FALSE)
                }
            
            if (GroupingMode == "Region"  ) {TF1Pat = subset(TF1Pat, TF1Pat$Region   == Contact)}  #Keep Only 1 electrode
              if (GroupingMode == "grouping") {
                if ("HighestBeta" == Contact) {
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

                    print(paste0(s, " BestBeta : ", ChOfInterestG, ' et ', ChOfInterestD))
                    TF1Pat = subset(TF1Pat, TF1Pat$Channel == ChOfInterestG | TF1Pat$Channel == ChOfInterestD)
                  }
                } else {
                  TF1Pat = subset(TF1Pat, TF1Pat$grouping == Contact)
                }  #Keep Only 1 electrode
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
              print("ici adapter le GNG en GNG ou Spont/Fast")
              
              
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
              COR1 = res_pca$var$coord[, 1:2]
              COR2 = data.frame(COR1)
              COR2 = COR2[abs(COR2$Dim.1) > 0.5 | abs(COR2$Dim.2) > 0.5 ,]
              COR2$Var1 = rownames(COR2)
              COR2$Var1 =c( "Anteroposterior APA",    "Mediolateral APA "   , "1st Swing time"   ,    "Double Stance time"     ,      "2nd Swing time"   ,    "1st Stride time" ,"First step length"   ,"1st Swing speed"  ,     "1st step lateral speed"    , "Mean Speed during initiation", "Freq gait initiation" ,"Cadence" , "Center of Gravity",     "Max 1st swing vertical speed"  ,"1st contact vertical speed"  )
              COR       = reshape2::melt(COR2) #pour metre les dimensions sur les lignes 
              myPalette = grDevices::colorRampPalette(c("#281E78","#ffffff","#ffffff","#ffffff","#fa4616"))
                cor = ggplot(COR,aes(x = variable, y = Var1, fill = value))+
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
              
              source(MAGIC_PCA.R)
              pca = PCA_allPat(paste(DataDir , ResAPA_32Pat_forPCA.xlsx, sep = "/"), todo_PCA_plots = FALSE)
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
            AllAvailableTimePoints = vroom::vroom(     file = paste0(OutputDir, '/ModelOutput/', 'TimesNames', Contact, '_', ev, '.csv'))
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
                DAT_LFP$value = as.numeric(DAT_LFP$value)
                
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
                
                # Preparation de la matrice de sortie
                Stats = reshape2::dcast(ddply(ddply(DAT_LFP,
                                          .(MetaCond, Patient), summarise, Patient = unique(Patient)), 
                                    .(MetaCond), mutate, nb_Patient = length(unique(Patient))) 
                              %>% arrange(desc(nb_Patient)), MetaCond + nb_Patient ~ Patient, fun.aggregate = length) 
                Stats = transform(Stats, 
                                  evenement  = unique(DAT_LFP$Event), 
                                  position   = unique(DAT_LFP$Freq),
                                  time       = timeName,
                                  group      = sapply(strsplit(MetaCond, '_'), '[[', 1), 
                                  Medication = sapply(strsplit(MetaCond, '_'), '[[', 3), 
                                  Task       = sapply(strsplit(MetaCond, '_'), '[[', 4),
                                  hemisphere = sapply(strsplit(MetaCond, '_'), '[[', 5),
                                  ipsi_contra= sapply(strsplit(MetaCond, '_'), '[[', 6))
                
                # Modèle 
                model = lme4::lmer(10*log(value,base=10) ~ Medication*Task*hemisphere*ipsi_contra + nStep + (1|Patient/Channel), data = DAT_LFP)
                # 10*log(value,base=10) transforme en dB, pas d'outlier trop transformés, distribution gaussienne 
                # Medication*Task       Paradigme experimental
                # hemisphere 
                # ipsi_contra           Que dans ce modèle et pas en dessous, ou on supprime cette var. En interaction avec hémisphère et med
                # nStep                 Lorsqu'il y a plusieurs fois l'evenement dans 1 Trial (FO, FC, FOG)
                # (1|Patient/Channel)   Generalement, 1 seul channel par evenement (generalement)
                
                # NON PRIS EN COMPTE : 
                # nTrial                ne semble pas avoir une influence tres importante (et extrêmement corrélé à Task)
                # grouping              peu de diff entre les diff sites possible d'enregistrement sur l electrode
                # Run                   variable technique indiquant la division du fichier d'enregistrement
          
                if (VerboseAnova == TRUE) {
                  print(paste0( Contact, ev, ' Freq', Freqpoint, 'Time', timeName ))
                  car::Anova(model)          #For Visual inspection
                  print(' ')
                  performance::check_model(model)  
                } 
                
                # Insertion dans la matrice de sortie
                
                # Toutes les variables :
                # toutes les conditions
                EMMean  = emmeans(model, ~  Medication*Task*hemisphere*ipsi_contra)        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres 
                emmean  = data.frame(EMMean)
                emGlobal= data.frame(contrast(EMMean,       
                                              setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))),  # nolint
                                                        apply(       emmean , 1, function(x) paste(x[1], x[2], x[3], x[4], sep = '_')))))
                # OFF - ON
                emmMED  = data.frame(contrast(EMMean,        
                                              setNames(lapply(1:(nrow(emmean)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emmean)/2-i), rep(0, nrow(emmean)/2-i))),                                                  # nolint 
                                                       lapply(1:(nrow(emmean)/2),   function(i)   paste(paste0(emmean[i*2-1,1], '-',emmean[i*2,1]), emmean[i*2,2], emmean[i*2,3], emmean[i*2,4], sep = '_')))))                             # nolint
                # GOc - GOi
                EMMcog  = emmeans(model, ~  Medication*Task*hemisphere*ipsi_contra, at = list(Task = c("GOc" , "GOi")))       
                emmCOG  = data.frame(EMMcog)
                emmCOG  = data.frame(contrast(EMMcog,
                                              setNames(Filter(length, lapply(1:(nrow(emmCOG)), function(i) if (i %% 4 == 1 || i %% 4 == 2) c(rep(0, i-1), 1, 0, -1, rep(0, nrow(emmCOG)-i-2)))),                                                                   # nolint
                                                       Filter(length, lapply(1:(nrow(emmCOG)), function(i) if (i %% 4 == 1 || i %% 4 == 2) paste(paste0(emmCOG[i,2], '-',emmCOG[i+2,2]), emmCOG[i,1], emmCOG[i,3], emmCOG[i,4], sep = '_'))))))                    # nolint
                # GOi - NoGO conditionnel
                if (sum(stringr::str_detect("NoGO", unique(DAT_LFP$Task)))) {
                  EMNoGO  = emmeans(model, ~  Medication*Task*hemisphere*ipsi_contra, at = list(Task = c("GOi" , "NoGO"), ipsi_contra = "None"))      
                  emNoGO  = data.frame(EMNoGO)
                  emNoGO  = data.frame(contrast(EMNoGO,
                                                setNames(Filter(length, lapply(1:(nrow(emNoGO)), function(i) if (i %% 4 == 1 || i %% 4 == 2) c(rep(0, i-1), 1, 0, -1, rep(0, nrow(emNoGO)-i-2)))),                                                        # nolint
                                                         Filter(length, lapply(1:(nrow(emNoGO)), function(i) if (i %% 4 == 1 || i %% 4 == 2) paste(paste0(emNoGO[i,2], '-',emNoGO[i+2,2]), emNoGO[i,1], emNoGO[i,3], emNoGO[i,4], sep = '_'))))))         # nolint
                }
                
                # ipsi_contra indifferent : 
                model = update(model, ~ -Medication:Task:hemisphere:ipsi_contra)        
                
                # toutes les conditions                          (on suprimme le NoGo qui de toute facon n'a jamais de cote)
                EMBBase = emmeans(model, ~  Medication*Task*hemisphere, at = list(Task = c("GOc" , "GOi"))) 
                emBBase = data.frame(EMBBase)
                emmBoth = data.frame(contrast(EMBBase,        
                                              setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))), # nolint
                                                        apply(       emBBase , 1, function(x) paste(x[1], x[2], x[3], sep = '_')))))
                # OFF - ON
                emBMED  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                              setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                       lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), emBBase[i*2,2], emBBase[i*2,3], 'BothSide', sep = '_'))))) # nolint
                # GOc - GOi      
                emBCOG  = data.frame(contrast(EMBBase,
                                              setNames(Filter(length, lapply(1:(nrow(emBBase)), function(i) if (i %% 4 == 1 || i %% 4 == 2) c(rep(0, i-1), 1, 0, -1, rep(0, nrow(emBBase)-i-2)))),  # nolint
                                                       Filter(length, lapply(1:(nrow(emBBase)), function(i) if (i %% 4 == 1 || i %% 4 == 2) paste(paste0(emBBase[i,2], '-',emBBase[i+2,2]), emBBase[i,1], emBBase[i,3], 'BothSide', sep = '_')))))) # nolint
                
                
                # Put main results in Stats var
                Stats = merge(Stats, transform(emGlobal, 
                                               Medication = sapply(strsplit(contrast, '_'), '[[', 1), 
                                               Task       = sapply(strsplit(contrast, '_'), '[[', 2),
                                               hemisphere = sapply(strsplit(contrast, '_'), '[[', 3),
                                               ipsi_contra= sapply(strsplit(contrast, '_'), '[[', 4))[, c('Medication', 'Task', 'hemisphere', 'ipsi_contra', 'estimate', 'SE', 'p.value')], 
                              by = c('Medication', 'Task', 'hemisphere','ipsi_contra'), all = T)
                Stats = Stats[complete.cases(Stats[, c("MetaCond", "SE")]), ]
                                
              # Put all pvalues in ModelOutput
                rm(ModelOutput)
                emGlobal$categ = 'NoContrast'
                emmMED$categ   = 'OFF-ON'
                emmCOG$categ   = 'GOc-GOi'
                emmBoth$categ  = 'NoContrast-BothIpsiContra'
                emBMED$categ   = 'OFF-ON-BothIpsiContra'
                emBCOG$categ   = 'GOc-GOi-BothIpsiContra'
                
                if (sum(stringr::str_detect("NoGO", unique(DAT_LFP$Task)))) {
                         emNoGO$categ   = 'GOi-NoGO'
                         ModelOutput = rbind(emGlobal, emmMED, emmCOG, emNoGO, emmBoth, emBMED, emBCOG)
                } else { ModelOutput = rbind(emGlobal, emmMED, emmCOG,         emmBoth, emBMED, emBCOG) }
                
                ModelOutput = ModelOutput[stats::complete.cases(ModelOutput[, c("contrast", "df")]), ]
                
                
                # Save
                data.table::fwrite(Stats,       file = paste0(OutputDir, '/Tables/',      Contact, ev, '-Freq', Freqpoint, '-Time_', timeName, 'Stats.csv'))
                data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutput/', Contact, '_', ev, '-Freq', Freqpoint, '-Time_', timeName, 'ModelOutput.csv'))
              
              } else { # else de if(!Load_0Comput)
                timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutput/', Contact, '_', ev, '-Freq', Freqpoint, '-Time_', timeName, 'ModelOutput.csv'))
              }
              
              ## Pass to next step (plots)
               
                pval = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                TFpw = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                
                
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
                  remove(ModelOutput)
                  if (!Load_0Comput) {
                    DAT_LFP$Comportement = NULL
                    DAT_LFP$Comportement = DAT_LFP[[ paste0('dimension', dimension)]]  
                    
                    # Model + emTrends
                    model  = lme4::lmer(10*log(value,base=10) ~ Comportement*Medication*Task*hemisphere*ipsi_contra + nStep + (1|Patient/Channel), data = DAT_LFP)
                    EMMean = emtrends(model, ~ Medication*Task*hemisphere*ipsi_contra, var="Comportement")

                    emmean  = data.frame(EMMean)
                    emGlobal= data.frame(contrast(EMMean,       
                                                  setNames(lapply(1:nrow(emmean),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emmean)-i))),  # nolint
                                                            apply(       emmean , 1, function(x) paste(x[1], x[2], x[3], x[4], sep = '_')))))
                    # OFF - ON
                    emmMED  = data.frame(contrast(EMMean,        
                                                  setNames(lapply(1:(nrow(emmean)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emmean)/2-i), rep(0, nrow(emmean)/2-i))),  # nolint
                                                          lapply(1:(nrow(emmean)/2),   function(i)   paste(paste0(emmean[i*2-1,1], '-',emmean[i*2,1]), emmean[i*2,2], emmean[i*2,3], emmean[i*2,4], sep = '_'))))) # nolint
                    # GOc - GOi
                    EMMcog  = emtrends(model, ~ Medication*Task*hemisphere*ipsi_contra, var="Comportement", at = list(Task = c("GOc" , "GOi")))       
                    emmCOG  = data.frame(EMMcog)
                    emmCOG  = data.frame(contrast(EMMcog,
                                                  setNames(Filter(length, lapply(1:(nrow(emmCOG)), function(i) if (i %% 4 == 1 || i %% 4 == 2) c(rep(0, i-1), 1, 0, -1, rep(0, nrow(emmCOG)-i-2)))),  # nolint
                                                          Filter(length, lapply(1:(nrow(emmCOG)), function(i) if (i %% 4 == 1 || i %% 4 == 2) paste(paste0(emmCOG[i,2], '-',emmCOG[i+2,2]), emmCOG[i,1], emmCOG[i,3], emmCOG[i,4], sep = '_')))))) # nolint
                    # GOi - NoGO conditionnel
                    if (sum(stringr::str_detect("NoGO", unique(DAT_LFP$Task)))) {
                      EMNoGO  = emmeans(model, ~  Medication*Task*hemisphere*ipsi_contra, at = list(Task = c("GOi" , "NoGO"), ipsi_contra = "None"))      
                      emNoGO  = data.frame(EMNoGO)
                      emNoGO  = data.frame(contrast(EMNoGO,
                                                    setNames(Filter(length, lapply(1:(nrow(emNoGO)), function(i) if (i %% 4 == 1 || i %% 4 == 2) c(rep(0, i-1), 1, 0, -1, rep(0, nrow(emNoGO)-i-2)))),  # nolint
                                                            Filter(length, lapply(1:(nrow(emNoGO)), function(i) if (i %% 4 == 1 || i %% 4 == 2) paste(paste0(emNoGO[i,2], '-',emNoGO[i+2,2]), emNoGO[i,1], emNoGO[i,3], emNoGO[i,4], sep = '_')))))) # nolint
                    }
                    
                    # ipsi_contra indifferent : 
                    model = update(model, ~ -Comportement:Medication:Task:hemisphere:ipsi_contra)        
                    
                    # toutes les conditions                          (on suprimme le NoGo qui de toute facon n'a jamais de cote)
                    EMBBase = emtrends(model, ~ Medication*Task*hemisphere, var="Comportement", at = list(Task = c("GOc" , "GOi")))
                    emBBase = data.frame(EMBBase)
                    emmBoth = data.frame(contrast(EMBBase,        
                                                  setNames(lapply(1:nrow(emBBase),    function(i) c(rep(0, i-1), 1, rep(0, nrow(emBBase)-i))),  # nolint
                                                            apply(       emBBase , 1, function(x) paste(x[1], x[2], x[3], sep = '_')))))
                    # OFF - ON
                    emBMED  = data.frame(contrast(EMBBase,        # Rajouter    , at = list(nTrial = 0, ipsi_contra = "contra")    si besoin pour se placer a des var particulieres
                                                  setNames(lapply(1:(nrow(emBBase)/2),   function(i)   c(rep(0, i-1), rep(0, i-1), 1, -1, rep(0, nrow(emBBase)/2-i), rep(0, nrow(emBBase)/2-i))),  # nolint
                                                          lapply(1:(nrow(emBBase)/2),   function(i)   paste(paste0(emBBase[i*2-1,1], '-',emBBase[i*2,1]), emBBase[i*2,2], emBBase[i*2,3], 'BothSide', sep = '_'))))) # nolint
                    # GOc - GOi      
                    emBCOG  = data.frame(contrast(EMBBase,
                                                  setNames(Filter(length, lapply(1:(nrow(emBBase)), function(i) if (i %% 4 == 1 || i %% 4 == 2) c(rep(0, i-1), 1, 0, -1, rep(0, nrow(emBBase)-i-2)))),  # nolint
                                                          Filter(length, lapply(1:(nrow(emBBase)), function(i) if (i %% 4 == 1 || i %% 4 == 2) paste(paste0(emBBase[i,2], '-',emBBase[i+2,2]), emBBase[i,1], emBBase[i,3], 'BothSide', sep = '_')))))) # nolint
                    
                    # Put all pvalues in ModelOutput
                    rm(ModelOutput)
                    emGlobal$categ = 'NoContrast'
                    emmMED$categ   = 'OFF-ON'
                    emmCOG$categ   = 'GOc-GOi'
                    emmBoth$categ  = 'NoContrast-BothIpsiContra'
                    emBMED$categ   = 'OFF-ON-BothIpsiContra'
                    emBCOG$categ   = 'GOc-GOi-BothIpsiContra'
                    
                    if (sum(stringr::str_detect("NoGO", unique(DAT_LFP$Task)))) {
                            emNoGO$categ   = 'GOi-NoGO'
                            ModelOutput = rbind(emGlobal, emmMED, emmCOG, emNoGO, emmBoth, emBMED, emBCOG)
                    } else { ModelOutput = rbind(emGlobal, emmMED, emmCOG,         emmBoth, emBMED, emBCOG) }
                    
                    ModelOutput = ModelOutput[stats::complete.cases(ModelOutput[, c("contrast", "df")]), ]
                    
                    # Save
                    data.table::fwrite(ModelOutput, file = paste0(OutputDir, '/ModelOutputComportement/', Contact, '_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Dim', dimension, 'ModelOutput.csv'))
                  
                  } else { # else de if(!Load_0Comput)
                    timeName    = AllAvailableTimePoints[[1,timefreq+17]]
                    ModelOutput = vroom::vroom(     file = paste0(OutputDir, '/ModelOutputComportement/', Contact, '_', ev, '-Freq', Freqpoint, '-Time_', timeName, '_Dim', dimension, 'ModelOutput.csv'))
                  }
                  
                  ## Pass to next step (plots)
                  
                    pcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    Tcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    
                    
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
                
                    pcompC1 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC1 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC2 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC2 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC3 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    TcompC3 = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    pcompC4 = data.frame()
                    TcompC4 = data.frame()

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
                  
                    pcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    Tcomp = data.frame() #### ONLY FOR PARALLEL COMPUTING 
                    
                    
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
              if (todo_corr_Comport) { output = c(output, list(pcomp1, Tcomp1, pcomp2, Tcomp2, pcomp3, Tcomp3)) } #### ONLY FOR PARALLEL COMPUTING
              if (todo_corr_Clinique) { output = c(output, list(pcompC1, TcompC1, pcompC2, TcompC2, pcompC3, TcompC3,pcompC4, TcompC4)) } #### ONLY FOR PARALLEL COMPUTING
              
              output
          } # End Parallel 


        save.image(file = paste0(OutputDir, '/ModelOutput/WorkSpace', Contact, '_', ev, '.RData'))

        
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

          source(MAGIC_PCA.R)
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
              foreach(MetCondnum = 1:length(unique(pval$MetaCond))) %dopar% { # nolint
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
                  
                  gif.anim = function() lapply(1:length(unique(includedCenterValues$Time)), function(i)  gif.frame(i) )   # nolint
                  
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
                    geom_density_2d_filled(data = dat4frame[dat4frame$pvalue < PValueLimit,], aes(z = pvalue), show.legend = FALSE, n = 100) +
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
  fileSuccess=file(filename)
  writeLines("Hello", fileSuccess)
  close(fileSuccess)
# } else {
#   load()
#   httr::GET("https://smsapi.free-mobile.fr/...")
# }

print("FAIRE UN MASQUE POUR VALUES")
print("PRENDRE EN COMPTE LES MODIFS ECCN")
