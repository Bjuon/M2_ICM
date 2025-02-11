
Path = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"
todo_PCA_plots = TRUE

PCA_allPat = function(Path, todo_PCA_plots) { 
    
    LoadLibrary()
    
    MY_APA  = readxl::read_excel(Path, sheet = 1)
    All_APA = MY_APA |>
        dplyr::mutate(dplyr::across(c(15:37),~as.numeric(as.character(.x))))
    
    IncludedValuesInPCA = c(1, 2, 3, 4, 5,15:37) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
    QualitativeValuesInPCA = c(1, 2, 3, 4, 5)
    
    All_APA_fitted = missMDA::imputePCA(All_APA[,IncludedValuesInPCA], 
                    quali.sup = QualitativeValuesInPCA , 
                    ncp = 5)$
                    completeObs
    res_pca = FactoMineR::PCA(All_APA_fitted, 
                    quali.sup = QualitativeValuesInPCA , 
                    ncp=9, 
                    scale.unit=TRUE, graph=FALSE)

    if (todo_PCA_plots) { 
        
        plotModele(res_pca)

        plotInd(res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

        plotInd(res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")
    }

    return(res_pca)


}


PCA_resAPA = function(MY_Pat = "Z:/DATA/ResAPA_extension_LINKERS_v3.xlsx", ACC_PatFold = "C:/Users/mathieu.yeche/Downloads/PCA_ACC/", todo_plots = TRUE) { 

    MY_APA = readxl::read_excel(MY_Pat, sheet = 1)
    MY_APA = MY_APA %>%
        mutate( across(c(15:35),~as.numeric(as.character(.x))))
    
    delete FRa ? because not normal subject
    delete bad trials

    # Add ACC Data

    WIP error     # nolint
    
    All_APA = MY_APA
    
    # PCA
    IncludedValuesInPCA = c(1,3,4,5,15:35) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
    QualitativeValuesInPCA = c(1, 3-1, 4-1, 5-1)
    
    All_APA_fitted = missMDA::imputePCA(All_APA[,IncludedValuesInPCA], 
                    quali.sup = QualitativeValuesInPCA , 
                    ncp = 5)$
                    completeObs
    res_pca   <- PCA(All_APA_fitted, 
                    quali.sup = QualitativeValuesInPCA , 
                    ncp=9, 
                    scale.unit=TRUE, graph=FALSE)

    if (todo_plots) { 
        
        plotModele(res_pca)

        plotInd(res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

        plotInd(res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
        plotInd(res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")
    }

    return(res_pca)

}




plotInd = function(res_pca, Grouping, Axe1, Axe2, paletteCouleur = "bpalette") {
    factoextra::fviz_pca_ind(res_pca,
        geom.ind = "point", 
        habillage = res_pca$call$quali.sup$quali.sup[[Grouping]],
        #col.ind = APA$g, # colorer by groups
        palette = paletteCouleur,
        addEllipses = TRUE, # Ellipses de concentration
        legend.title = "Groups",axes = c(Axe1, Axe2)
        )
    }

plotModele = function(res_pca) {
    # Kaiser criterion
    Kaiser = factoextra::fviz_eig(res_pca, addlabels = TRUE, ylim = c(0, 50)) +
        geom_abline(slope = 0,intercept = 10,color='red')+ 
        theme_classic()+
        ggtitle("Composantes principales")
    

    #Correlogrammes
    COR1 <- res_pca$var$coord
    COR       <- reshape2::melt(COR1) #pour metre les dimensions sur les lignes 
    myPalette <- colorRampPalette(c("royalblue2","white","white","indianred1"))
    cor <- ggplot(COR[COR$Var2 %in% c('Dim.1','Dim.2','Dim.3','Dim.4','Dim.5'),],aes(x = Var2, y = Var1, fill = value))+
    geom_tile()+
    scale_fill_gradientn(colours = myPalette(100),lim=c(-1,1))+
    theme_classic()
    
    plot = gridExtra::grid.arrange(Kaiser, cor, ncol = 2)
}

PCA_MarcheLancee = function(fileCSV = "Z:/DATA/MAGIC_DemiTour_18Pat_v1.csv", todo_plots = TRUE) {

    library(ggplot2)
    # Load the data
    MarcheLancee = vroom::vroom(fileCSV)


    MarcheLancee = aggregate(MarcheLancee, 
            by = list(MarcheLancee$TrialName), 
            FUN = function(x) {if(is.character(x)) {
                            x[1]
                        } else {
                            median(x[!is.na(x)])
                        }})

    # Fusion _L and _R columns
    for (colnamei in colnames(MarcheLancee)) {
    if (grepl("_L", colnamei)) {
        colnamej = gsub("_L", "_R", colnamei)
        if (colnamej %in% colnames(MarcheLancee)) {
        MarcheLancee[[colnamei]] = (MarcheLancee[[colnamei]] + MarcheLancee[[colnamej]]) / 2
        MarcheLancee[[colnamej]] = NULL
        }
    }
    }
    colnames(MarcheLancee) = gsub("_L", "", colnames(MarcheLancee))

    # check with : colnames(MarcheLancee)
    IncludedValuesInPCA = c(2,3,5,7:9,11:29,40) # correspond a Quantitatives + GNG (40) + Patient (3) + TrialName (2) + cond (5)
    QualitativeValuesInPCA = c(2-1, 3-1,  5-2,   40-40+length(IncludedValuesInPCA))
    res_pca   <- PCA(MarcheLancee[,IncludedValuesInPCA], 
                    quali.sup = QualitativeValuesInPCA , 
                    ncp=9, 
                    scale.unit=TRUE, graph=FALSE)

    if (todo_plots) { 
        
        plotModele(res_pca)

        plotInd(res_pca, Grouping = 'Cond', Axe1 = 1, Axe2 = 2)
        plotInd(res_pca, Grouping = 'Cond', Axe1 = 3, Axe2 = 2)
        plotInd(res_pca, Grouping = 'Cond', Axe1 = 1, Axe2 = 3)

        plotInd(res_pca, Grouping = 'GONOGO', Axe1 = 1, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'GONOGO', Axe1 = 3, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'GONOGO', Axe1 = 1, Axe2 = 3, "lancet")

        plotInd(res_pca, Grouping = 'Patient', Axe1 = 1, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'Patient', Axe1 = 3, Axe2 = 2, "lancet")
        plotInd(res_pca, Grouping = 'Patient', Axe1 = 1, Axe2 = 3, "lancet")
    }

    return(res_pca)
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
        colormap_to_use  = colorRamps::ygobb
      # BrBG aussi interessant
      # colormap_to_use  = colorRamps::blue2yellow
    } else if (Case == 'Clinique') {
        colormap_to_use  = colorRamps::blue2green
    }
    
    return(colormap_to_use)
}


test_UMAP = function(Path, todo_PCA_plots) { 
    MY_APA  = readxl::read_excel(Path, sheet = 1)
    All_APA = MY_APA |>
        dplyr::mutate(dplyr::across(c(15:37),~as.numeric(as.character(.x))))
    
    IncludedValuesInPCA = c(1, 2, 3, 4, 5,15:37) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
    QualitativeValuesInPCA = c(1, 2, 3, 4, 5)
    
    All_APA_fitted = missMDA::imputePCA(All_APA[,IncludedValuesInPCA], 
                    quali.sup = QualitativeValuesInPCA , 
                    ncp = 5)$
                    completeObs
    

    All_APA_fitted = scale(All_APA_fitted[,6:28], center = TRUE, scale = TRUE)
    APAumap = umap::umap(All_APA_fitted, n_neighbors = 10, n_components = 10, metric = "euclidean")
    
    plot(APAumap$layout, col = as.factor(All_APA$GoNogo), pch = 19)
    legend("topleft",                    # Add legend to plot
           legend =c(1,2,3,4), col = 1:4, pch = 19)

    return(res_pca)


}


LoadLibrary = function() {
library(sp)
library(reshape2)
library(RColorBrewer)
library(ggplot2)
library(svglite)
library(plyr)
library(dplyr)
library(reshape2)
library(stringr)
library(FactoMineR)
library(factoextra)
library(Factoshiny)
library(FactoInvestigate)
}





###############################
## New data : Aout 2023 #######
###############################

## Objectif :
# Verif homogeneite 2 groupes
# Voir si cela fait sens de normaliser entre les groupes
# Ajout potentiel de t_reac
# Tester PCA reduite
# Resultat sur Meta_FOG ?

MY_Pat = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"              

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

# 1) Verif homogeneite 2 groupes
MY_APA$Groupe = ifelse((MY_APA$GoNogo == 'R' | MY_APA$GoNogo == 'S') , 'GI', 'MY')
MY_APA$Groupe = as.factor(MY_APA$Groupe)
MY_APA$GoNogo = as.factor(MY_APA$GoNogo)
MY_APA$Subject = as.factor(MY_APA$Subject)

library(officer)
library(magrittr)
ppt = officer::read_pptx()
ppt = officer::add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    for (varnum in 15:36) {
        if (varnum == 36) {
            varnum = 8
        }
        print(colnames(MY_APA)[varnum])
        ttest_result_groupe <- t.test(MY_APA[MY_APA$Groupe == 'MY', varnum], MY_APA[MY_APA$Groupe == 'GI', varnum])
        ttest_result_gonogo <- t.test(MY_APA[MY_APA$GoNogo == 'S', varnum], MY_APA[MY_APA$GoNogo == 'I', varnum])
        
        localplot_groupe = ggplot(MY_APA, aes(x = Groupe, y = .data[[colnames(MY_APA)[varnum]]], color = Groupe)) +
            ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
            geom_violin(alpha = 0.5) + 
            geom_boxplot(width = 0.2) +
            theme_bw() +
            theme(legend.position = "none") +
            labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
            annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                     label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_groupe$p.value, digits = 2)))
        
        localplot_gonogo = ggplot(MY_APA, aes(x = GoNogo, y = .data[[colnames(MY_APA)[varnum]]], color = GoNogo)) +
            ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
            geom_violin(alpha = 0.5) + 
            geom_boxplot(width = 0.2) +
            theme_bw() +
            theme(legend.position = "none") +
            labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
            annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                     label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_gonogo$p.value, digits = 2)))
        
        fusionplot = gridExtra::grid.arrange(localplot_groupe, localplot_gonogo, ncol = 2)
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = localplot_groupe, location = ph_location_fullsize())
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = localplot_gonogo, location = ph_location_fullsize())
    }


# 2) Voir si cela fait sens de normaliser par groupe

IncludedValuesInPCA = c(1,2, 3,4,5,15:29, 31:35, 43) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
QualitativeValuesInPCA = c(1, 2, 3, 4, 5, 43-17)

## Classic PCA
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        
All_APA_fitted = missMDA::imputePCA(MY_APA[,IncludedValuesInPCA], 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 5)$
                completeObs
res_pca   = FactoMineR::PCA(All_APA_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=9, 
                scale.unit=TRUE, graph=FALSE)

plotIndPPT = function(ppt, res_pca, Grouping, Axe1, Axe2, paletteCouleur = "bpalette") {
    plt = factoextra::fviz_pca_ind(res_pca,
        geom.ind = "point", 
        habillage = res_pca$call$quali.sup$quali.sup[[Grouping]],
        #col.ind = APA$g, # colorer by groups
        palette = paletteCouleur,
        addEllipses = TRUE, # Ellipses de concentration
        legend.title = "Groups",axes = c(Axe1, Axe2)
        )
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = plt, location = ph_location_fullsize())
    }

VerifGeneralePCA = function(ppt, res_pca) {
    Kaiser = factoextra::fviz_eig(res_pca, addlabels = TRUE, ylim = c(0, 50)) +
    geom_abline(slope = 0,intercept = 10,color='red')+ 
    theme_classic()+
    ggtitle("Composantes principales")
    
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = Kaiser, location = ph_location_fullsize())

    #Correlogrammes
    COR1 = res_pca$var$coord[, 1:4]
    COR2 = data.frame(COR1)
    COR2$Var1 = rownames(COR2)
    COR       = reshape2::melt(COR2) #pour metre les dimensions sur les lignes 
    myPalette = grDevices::colorRampPalette(c("#281E78","#ffffff","#ffffff","#ffffff","#fa4616"))
    cor = ggplot(COR,aes(x = variable, y = Var1, fill = value))+
    geom_tile()+
    # increase the y label text size
    theme(axis.text.y = element_text(size = 500))+
    theme(text = element_text(size = 500))+
    scale_fill_gradientn(colours = myPalette(100),lim=c(-1,1))+
    theme_classic()

    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = cor, location = ph_location_fullsize())
}

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Meta_FOG', Axe1 = 2, Axe2 = 1, paletteCouleur = c("#fa4616", "#d25736", "#281E78"))
    
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")


ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        

## PCA with normalization by group
MY_APA_norm = MY_APA
for (varnum in 15:35) {
    if (varnum == 36) {
            varnum = 8
    }
    MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] = 
        (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] - 
        mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE) ) /
        sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE)

    MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] = 
        (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] - 
        mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE) ) /
        sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE)
}

All_APA_fitted = missMDA::imputePCA(MY_APA_norm[,IncludedValuesInPCA], 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 5)$
                completeObs
res_pca   = FactoMineR::PCA(All_APA_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=9, 
                scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Meta_FOG', Axe1 = 2, Axe2 = 1, paletteCouleur = c("#fa4616", "#d25736", "#281E78"))
    
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")


ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        

## Reduced PCA

RedIncludedValuesInPCA = c(1,2, 3,4,5,15:20, 23, 33,34, 43) # debute a t_APA car avant random jitter, jusqu'a Diff_V. correspond a Quantitatives + GNG (5) + Patient (3) + TrialName (1) + cond (4)
RedQualitativeValuesInPCA = c(1, 2, 3, 4, 5, 15)

All_APA_fitted = missMDA::imputePCA(MY_APA[,RedIncludedValuesInPCA], 
            quali.sup = RedQualitativeValuesInPCA , 
            ncp = 5)$
            completeObs
res_pca       = FactoMineR::PCA(All_APA_fitted, 
            quali.sup = RedQualitativeValuesInPCA , 
            ncp=5, 
            scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Meta_FOG', Axe1 = 2, Axe2 = 1, paletteCouleur = c("#fa4616", "#d25736", "#281E78"))
    
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")


ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        

# Selective temporal normalisation


ToNormalize = c(15, 19:22, 26, 28, 30:32)

MY_APA_norm = MY_APA
for (varnum in ToNormalize) {
    MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] = 
        (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] - 
        mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE) ) /
        sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE)

    MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] = 
        (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] - 
        mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE) ) /
        sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE)
}


All_APA_fitted = missMDA::imputePCA(MY_APA_norm[,IncludedValuesInPCA], 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 5)$
                    completeObs
res_pca   = FactoMineR::PCA(All_APA_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=9, 
                scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Meta_FOG', Axe1 = 2, Axe2 = 1, paletteCouleur = c("#fa4616", "#d25736", "#281E78"))
    
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Condition', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 3, Axe2 = 2, "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'GoNogo', Axe1 = 1, Axe2 = 3, "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Subject', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")


ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        


print(ppt, target = "C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/PCA_MYetACC_v2.pptx")








#################################
##### UMAP : Septembre 2023 #####
#################################

MY_Pat = "C:/LustreSync/DATA/ResAPA_32Pat_forPCA.xlsx"              

MY_APA = readxl::read_excel(MY_Pat, sheet = 1)
MY_APA = MY_APA %>%
  mutate( across(c(15:35),~as.numeric(as.character(.x))))

MY_APA$is_FOG = as.factor(MY_APA$is_FOG)
MY_APA$Meta_FOG[MY_APA$Meta_FOG == 0] = "absFOG"
MY_APA$Meta_FOG[MY_APA$Meta_FOG == 2] = "FOG"
MY_APA$Meta_FOG[MY_APA$Meta_FOG == 1] = "absFOG"
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
MY_APA$GoNogo = as.factor(MY_APA$GoNogo)
MY_APA$Subject = as.factor(MY_APA$Subject)


IncludedValuesInPCA = c(1,2, 3,4,5,15:29, 31:35, 43)
QualitativeValuesInPCA = c(1, 2, 3, 4, 5, 43-17)
ToNormalize = c(15, 19:22, 26, 28, 30:32)

MY_APA_norm = MY_APA
for (varnum in ToNormalize) {
  MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] = 
    (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'GI'] - 
       mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE) ) /
    sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'GI'], na.rm = TRUE)
  
  MY_APA_norm[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] = 
    (MY_APA[[colnames(MY_APA)[varnum]]][MY_APA_norm$Groupe == 'MY'] - 
       mean(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE) ) /
    sd(MY_APA[[colnames(MY_APA)[varnum]]][MY_APA$Groupe == 'MY'], na.rm = TRUE)
}


AllPat_fitted = missMDA::imputePCA(MY_APA_norm[,IncludedValuesInPCA], 
                                    quali.sup = QualitativeValuesInPCA , 
                                    ncp = 5)$
  completeObs


AllPat_Umap = scale(AllPat_fitted[,6:25], center = TRUE, scale = TRUE)

plt = function(APAumap, AllPat_fitted, GroupingVar) {
  plot(APAumap$layout, col = as.factor(AllPat_fitted[[GroupingVar]]), pch = 19) 
  legend("topright", legend = unique(AllPat_fitted[[GroupingVar]]), col = unique(as.factor(AllPat_fitted[[GroupingVar]])), pch = 19)
}

pltSave = function(APAumap, AllPat_fitted, GroupingVar, nei, comp, dist) {
  jpeg(paste0("C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/umap/", nei, "-", comp,"_rplot_d=", dist, ".jpg"), width = 600, height = 600)
  plot(APAumap$layout, col = as.factor(AllPat_fitted[[GroupingVar]]), pch = 19) 
  legend("topright", legend = unique(AllPat_fitted[[GroupingVar]]), col = unique(as.factor(AllPat_fitted[[GroupingVar]])), pch = 19)
  dev.off()
}

APAumap = umap::umap(AllPat_Umap, n_neighbors = 20, n_components = 10, metric = "euclidean")
plt(APAumap, AllPat_fitted, "Meta_FOG")
plt(APAumap, AllPat_fitted, "Condition")
plt(APAumap, AllPat_fitted, "GoNogo")
plt(APAumap, AllPat_fitted, "TrialNum")
plt(APAumap, AllPat_fitted, "Subject")

compvector = c(2,3,4,5,7,10,20,30)
distvector = c(0.0001, 0.1, 0.25, 0.5, 0.8, 0.99)
distvector = c(0.0001, 0.25, 0.99)
for (nei in 22:45) {
  for (comp in compvector) {
    for (dist in distvector) {
      if (comp>2*nei) { next }
      APAumap = umap::umap(AllPat_Umap, method="umap-learn",  n_neighbors = nei, n_components = comp, metric = "euclidean", min_dist = dist)
      pltSave(APAumap, AllPat_fitted, "Meta_FOG", nei, comp, dist)
      print(paste0(nei, '-',comp,' : ', Sys.time()))
    }
  }
}
