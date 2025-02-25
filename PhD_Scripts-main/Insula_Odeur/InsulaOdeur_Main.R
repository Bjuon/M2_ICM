## Analyse Insula ##

#############################################
######### PARTIE I : CHARGEMENT #############
#############################################

# Folder 
DataDir = "C:/Users/mathieu.yeche/OneDrive - ICM/Thèse - Scientifique/Insula_Odeurs/"
OutputDir = "C:/Users/mathieu.yeche/OneDrive - ICM/Thèse - Scientifique/Insula_Odeurs/Figures/"

# Chargement des packages
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
library(umap)
library(officer)
library(magrittr)
library(readxl)

# Chargement des données
PrePost = read_xlsx(paste0(DataDir, "Data patients prepost odeurs_pr_analyse_Juillet2023.xlsx"), sheet = 'PatPréPost OK') 
Control = read_xlsx(paste0(DataDir, "Comp patients controls_pr_analyse_Juillet2023.xlsx"), sheet = 'Cont')
AllPat  = read_xlsx(paste0(DataDir, "Comp patients controls_pr_analyse_Juillet2023.xlsx"), sheet = 'Patients')
Lateral = read_xlsx(paste0(DataDir, "Comp patients controls_pr_analyse_Juillet2023.xlsx"), sheet = 'Patients loc tumeur DG')
PerOp   = read_xlsx(paste0(DataDir, "Patients Per-op_pr_analyse_2023.xlsx"), sheet = 'LongFormat')

AllPatSave = AllPat

#############################################
######### PARTIE II : EXPLORATION ###########
#############################################

ppt = officer::read_pptx()
ppt = officer::add_slide(ppt, layout = "Title and Content", master = "Office Theme")

## 1. Patients seuls
ppt = ph_with(ppt, value = "1. Patients seuls", location = ph_location_type(type = "title"))

AllPat$Type  =  ifelse(AllPat$Odor == "Neutre", "Neutre",
                ifelse(AllPat$Odor == "Menthe" | AllPat$Odor == "Eucalyptus", "Trigeminal",
                ifelse(AllPat$Odor == "Civette"| AllPat$Odor == "Acide isovalérique" | AllPat$Odor == "Cuir", "Degout", 
                ifelse(AllPat$Odor == "Tiare"  | AllPat$Odor == "Lilas" | AllPat$Odor == "Lavande" | AllPat$Odor == "Pamplemousse" | AllPat$Odor == "Paradisone"  | AllPat$Odor == "Defi", "Floral",       # nolint: line_length_linter.
                ifelse(AllPat$Odor == "Fraise" | AllPat$Odor == "Caramel", "Gourmand", 
                ifelse(AllPat$Odor == "Firsantol", "Santol", "NA"))))))

MY_APA = AllPat # Reutilisation de code GNG-Marche
for (varnum in 4:12) {
    
    print(colnames(MY_APA)[varnum])
    MY_APA$varn = MY_APA[[colnames(MY_APA)[varnum]]]
    ttest_result_groupe = summary(aov(varn ~ Type, data = MY_APA))[[1]]$`Pr(>F)`[1]
    ttest_result_odeur  = summary(aov(varn ~ Odor, data = MY_APA))[[1]]$`Pr(>F)`[1]
    
    localplot_groupe = ggplot(MY_APA, aes(x = Type, y = .data[[colnames(MY_APA)[varnum]]], color = Type)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                    label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_groupe, digits = 2)))
    
    localplot_odeur = ggplot(MY_APA, aes(x = Odor, y = .data[[colnames(MY_APA)[varnum]]], color = Odor)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                    label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_odeur, digits = 2)))
    
    fusionplot = gridExtra::grid.arrange(localplot_odeur, localplot_groupe, ncol = 2)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_groupe, location = ph_location_fullsize())
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
}

# PCA
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")


IncludedValuesInPCA = c(1:13) 
QualitativeValuesInPCA = c(1, 2, 3, 13)

if (any(is.na(AllPat))) {
    AllPat_fitted = missMDA::imputePCA(AllPat, 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 6)$
                completeObs
} else {
    AllPat_fitted = AllPat
}

res_pca      = FactoMineR::PCA(AllPat_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=5, 
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
        if (ppt == "None") { print(plt)
        } else {
            ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
            ppt = ph_with(ppt, value = plt, location = ph_location_fullsize())
        }
    }

VerifGeneralePCA = function(ppt, res_pca) {
    Kaiser = factoextra::fviz_eig(res_pca, addlabels = TRUE, ylim = c(0, 100)) +
    geom_abline(slope = 0,intercept = 10,color='red')+ 
    theme_classic()+
    ggtitle("Composantes principales")
    if (ppt == "None") { print(Kaiser)
    } else {
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = Kaiser, location = ph_location_fullsize())
    }
    #Correlogrammes
    COR1 = res_pca$var$coord[, 1:4]
    COR2 = data.frame(COR1)
    COR2$Var1 = rownames(COR2)
    COR       = reshape2::melt(COR2) #pour metre les dimensions sur les lignes 
    myPalette = grDevices::colorRampPalette(c("#281E78","#ffffff","#ffffff","#ffffff","#fa4616"))
    cor = ggplot(COR,aes(x = variable, y = Var1, fill = value))+ # nolint: object_usage_linter.
    geom_tile()+
    # increase the y label text size
    theme(axis.text.y = element_text(size = 500))+
    theme(text = element_text(size = 500))+
    scale_fill_gradientn(colours = myPalette(100),lim=c(-1,1))+
    theme_classic()
    if (ppt == "None") { print(cor)
    } else {
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = cor, location = ph_location_fullsize())
    }

    # varplot
    var1 = factoextra::fviz_pca_var(res_pca, 
        col.var = "contrib", # Color by the quality of the variables: blue if not very correlated with other variables
        gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), # Color by the quality of the variables: blue if not very correlated with other variables
        repel = TRUE, # Avoid text overlapping
        axes = c(1, 2), # Choose the axes to draw
        )

    if (ppt == "None") { print(var1)
    } else { 
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = var1, location = ph_location_fullsize())
    }  
}

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 3, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 3, "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")


# UMAP
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
# Write in the slide
ppt = ph_with(ppt, value = " - UMAP - A rajouter manuellement (puis save as)", location = ph_location_type(type = "title"))
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")

plotUmapPPT = function(ppt, nei, com, Grouping, APAumap, AllPat_fitted, paletteCouleur = "bpalette") {
    df = data.frame(APAumap$layout)
    plt = ggplot(df, aes(x = X1, y = X2, color = AllPat_fitted[[Grouping]])) +           # nolint: object_usage_linter.
        geom_point() +
        theme_bw() +
        labs(title = paste0("UMAP : ", Grouping)) +
        annotate("text", x = min(df$X1)+0.1 * (max(df$X1)-min(df$X1)), y = min(df$X2)+0.1 * (max(df$X2)-min(df$X2)), label = paste0("nei-com : ", nei, '-', com))
    if (ppt == "None") { print(plt)
    } else {
        ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
        ppt = ph_with(ppt, value = plt, location = ph_location_fullsize())
    }
}

AllPat_Umap = scale(AllPat_fitted[,4:12], center = TRUE, scale = TRUE)
nei = 35
com = 30
APAumap = umap::umap(AllPat_Umap, method="umap-learn",  n_neighbors = nei, n_components = com, metric = "euclidean", min_dist = 0.1)
plotUmapPPT(ppt, nei, com, "Type", APAumap, AllPat_fitted)
plotUmapPPT(ppt, nei, com, "Odor", APAumap, AllPat_fitted)
plotUmapPPT(ppt, nei, com, "Id", APAumap, AllPat_fitted)

## 2. Patients per-op
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
ppt = ph_with(ppt, value = "2. Patients per-op", location = ph_location_type(type = "title"))

# Delta stim - baseline pour chaque odeur

PerOpSave = PerOp
PerOp   = PerOp[PerOp$Area != "pre",]
PerOpAb = PerOp
PerOp   = PerOp[PerOp$Stim != 0    ,]

for (odor in unique(PerOp$Odor)) {
    print(odor)
    
    ttest_result_odeur  = t.test(PerOp[PerOp$Odor == odor,]$Stim, PerOp[PerOp$Odor == odor,]$Baseline, paired = TRUE)$p.value
    model_odor          = lmerTest::lmer(Stim - Baseline ~ (1|Patient) + (1|TumorSide) + (1|Area), data = PerOp[PerOp$Odor == odor,])
    model_result_odeur  = summary(model_odor)$coefficients[5]

    localplot_odeur = ggplot(PerOp[PerOp$Odor == odor,], aes(x = Patient, y = Stim-Baseline, color = Patient)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp : ", odor)) +
        annotate("text", x = 1.5, y = max(PerOp[PerOp$Odor == odor,]$Stim-PerOp[PerOp$Odor == odor,]$Baseline, na.rm = TRUE)*1.01, 
                label = paste0("t test : ", signif(ttest_result_odeur, digits = 2))) +
        annotate("text", x = 3.5, y = max(PerOp[PerOp$Odor == odor,]$Stim-PerOp[PerOp$Odor == odor,]$Baseline, na.rm = TRUE)*1.01, 
                label = paste0("model : ", signif(model_result_odeur, digits = 2)))

    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
}


# Rasterplot
PerOpRaster = PerOp
PerOpRaster = aggregate(Stim ~ Patient + Odor + Area, data = PerOp, FUN = mean)
PerOpRaste2 = aggregate(Baseline ~ Patient + Odor + Area, data = PerOp, FUN = mean)
PerOpRaster = merge(PerOpRaster, PerOpRaste2, by = c("Patient", "Odor", "Area"))

PerOpRaster$SuperoInf         = ifelse(grepl("S", PerOpRaster$Area), 1, 0)
PerOpRaster$AnteroPosterieur  = ifelse(grepl("P", PerOpRaster$Area), 2, ifelse(grepl("M", PerOpRaster$Area), 1, 0))
PerOpRaster$text  = paste0(round(PerOpRaster$Stim, digits = 2), "-(", PerOpRaster$Baseline, ")=", round(PerOpRaster$Stim, digits = 2) - PerOpRaster$Baseline)
PerOpRaster$text2 = round(PerOpRaster$Stim, digits = 2)
PerOpRaster$text3 = paste0( "BSL=", PerOpRaster$Baseline)

PerOpAb$Stim0 = ifelse(PerOpAb$Stim == 0, 1, 0)
PerOpA1 = aggregate(Stim0 ~ Patient + Odor + Area, data = PerOpAb, FUN = mean)
PerOpA2 = aggregate(Baseline ~ Patient + Odor + Area, data = PerOpAb, FUN = mean)
PerOpAb = merge(PerOpA1, PerOpA2, by = c("Patient", "Odor", "Area"))
PerOpAb$SuperoInf         = ifelse(grepl("S", PerOpAb$Area), 1, 0)
PerOpAb$AnteroPosterieur  = ifelse(grepl("P", PerOpAb$Area), 2, ifelse(grepl("M", PerOpAb$Area), 1, 0))
PerOpAb$text = round(PerOpAb$Stim0, digits = 2)

for (odor in unique(PerOpRaster$Odor)) {
    print(odor)
    localplot_odeur = ggplot(PerOpRaster[PerOpRaster$Odor == odor,], aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim-Baseline)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text), colour = "#ffffff", check_overlap = TRUE) +
        theme_bw() +
        scale_fill_gradient(low = "#00006d", high = "#8fd6ff", lim = c(-1, 15)) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp Stim-Baseline : ", odor)) + 
        facet_wrap(~Patient)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())

    localplot_odeur = ggplot(PerOpRaster[PerOpRaster$Odor == odor,], aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text2), colour = "#000000", check_overlap = TRUE) +
        geom_text(aes(1, 0.5, label=text3), colour = "#000000", check_overlap = TRUE, ) +
        theme_bw() +
        scale_fill_gradientn(colours = grDevices::colorRampPalette(c("#00007F","blue","#007FFF","cyan","#7FFF7F","yellow","#FF7F00","red","#7F0000"))(100),lim = c(-10, 10)) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp Stim seule : ", odor)) + 
        facet_wrap(~Patient)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())

    localplot_odeur = ggplot(PerOpAb[PerOpAb$Odor == odor,], aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim0)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text), colour = "#ffffff", check_overlap = TRUE) +
        theme_bw() +
        scale_fill_gradient(low = "#ffeb7c", high = "#6b5b00", lim = c(0, 1)) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp % d'abolition : ", odor)) + 
        facet_wrap(~Patient)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())

}

PerOpDelta    = PerOpRaster
PerOpPourcent = PerOpRaster
PerOpDelta$Stim    =  PerOpDelta$Stim    - PerOpDelta$Baseline
PerOpPourcent$Stim = (PerOpPourcent$Stim - PerOpPourcent$Baseline) / abs(PerOpPourcent$Baseline)

PerOpR2Med = aggregate(Baseline  ~ Odor + Patient, data = PerOpRaster, FUN = median)
PerOpR2Med = aggregate(Baseline  ~ Odor          , data = PerOpRaster, FUN = median)

PerOpAbMed = aggregate(Stim0     ~ Odor + Area, data = PerOpAb,     FUN = median)
PerOpRaMed = aggregate(Stim      ~ Odor + Area, data = PerOpRaster, FUN = median)
PerOpDeMed = aggregate(Stim      ~ Odor + Area, data = PerOpDelta , FUN = median)
PerOpPcMed = aggregate(Stim      ~ Odor + Area, data = PerOpPourcent , FUN = median)
PerOpRaMed$Baseline = PerOpR2Med$Baseline[match(PerOpRaMed$Odor, PerOpR2Med$Odor)]
PerOpAbMed$text = round(PerOpAbMed$Stim0    , digits = 2)
PerOpRaMed$text = round(PerOpRaMed$Stim     , digits = 1)
PerOpRaMed$tex2 = round(PerOpRaMed$Baseline , digits = 2)
PerOpDeMed$text = round(PerOpDeMed$Stim     , digits = 2)
PerOpPcMed$text = paste0(round(PerOpPcMed$Stim     , digits = 2)*100,'%')

PerOpDeMed$SuperoInf         = ifelse(grepl("S", PerOpDeMed$Area), 1, 0)
PerOpDeMed$AnteroPosterieur  = ifelse(grepl("P", PerOpDeMed$Area), 2, ifelse(grepl("M", PerOpDeMed$Area), 1, 0))
PerOpAbMed$SuperoInf         = ifelse(grepl("S", PerOpAbMed$Area), 1, 0)
PerOpAbMed$AnteroPosterieur  = ifelse(grepl("P", PerOpAbMed$Area), 2, ifelse(grepl("M", PerOpAbMed$Area), 1, 0))
PerOpRaMed$SuperoInf         = ifelse(grepl("S", PerOpRaMed$Area), 1, 0)
PerOpRaMed$AnteroPosterieur  = ifelse(grepl("P", PerOpRaMed$Area), 2, ifelse(grepl("M", PerOpRaMed$Area), 1, 0))
PerOpPcMed$SuperoInf         = ifelse(grepl("S", PerOpPcMed$Area), 1, 0)
PerOpPcMed$AnteroPosterieur  = ifelse(grepl("P", PerOpPcMed$Area), 2, ifelse(grepl("M", PerOpPcMed$Area), 1, 0))

    localplot_odeur = ggplot(PerOpDeMed, aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text), colour = "#ffffff", check_overlap = TRUE) +
        theme_bw() +
        scale_fill_gradient(low = "#00006d", high = "#8fd6ff", lim = c(-1, 15)) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp Stim-Baseline, median across patient ")) + 
        facet_wrap(~Odor)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
    localplot_odeur

    localplot_odeur = ggplot(PerOpRaMed, aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text), colour = "#000000", check_overlap = TRUE) +
        geom_text(aes(1, 0.5, label=tex2), colour = "#000000", check_overlap = TRUE, ) +
        theme_bw() +
        scale_fill_gradientn(colours = grDevices::colorRampPalette(c("#00007F","blue","#007FFF","cyan","#7FFF7F","yellow","#FF7F00","red","#7F0000"))(100),lim = c(-10, 10)) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp Stim seule, median across patients ")) + 
        facet_wrap(~Odor)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
    localplot_odeur

    localplot_odeur = ggplot(PerOpAbMed, aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim0)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text), colour = "#ffffff", check_overlap = TRUE) +
        theme_bw() +
        scale_fill_gradient(low = "#ffeb7c", high = "#6b5b00", lim = c(0, 1)) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp % d'abolition, median across patients ")) + 
        facet_wrap(~Odor)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
    localplot_odeur

    localplot_odeur = ggplot(PerOpPcMed, aes(x = AnteroPosterieur, y = SuperoInf, fill = Stim)) +
        geom_tile() +
        geom_text(aes(AnteroPosterieur, SuperoInf, label=text), colour = "#ffffff", check_overlap = TRUE) +
        theme_bw() +
        scale_fill_gradient(low = "#8dfbdf", high = "#00654c", lim = c(0, max(PerOpPcMed$Stim))) +
        theme(legend.position = "none") +
        labs(title = paste0("PerOp Amelioration stim-bsl rapportée à l'intensité de la BSL, median across patients ")) + 
        facet_wrap(~Odor)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
    localplot_odeur


## 3. Patients pre-post
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
ppt = ph_with(ppt, value = "3. Patients pre-post", location = ph_location_type(type = "title"))

PrePostDelta= PrePost
PrePostDelta$idx = paste0(PrePostDelta$Id, PrePostDelta$odeurs)
PrePostPost = PrePostDelta[PrePostDelta$Groupes == "Post",]
PrePostPre  = PrePostDelta[PrePostDelta$Groupes == "pre",]

indices_communs = match(PrePostPost$idx, PrePostPre$idx)

PrePostDelta = PrePostPost
PrePostDelta[,4:11] = PrePostPre[indices_communs,4:11] - PrePostPost[,4:11]

### REUTILISATION DU CODE GNG-MARCHE ###
AllPat = PrePostDelta
AllPat$Odor = AllPat$odeurs
AllPat$Type  =  ifelse(AllPat$Odor == "Neutre", "Neutre",
                ifelse(AllPat$Odor == "Menthe" | AllPat$Odor == "Eucalyptus", "Trigeminal",
                ifelse(AllPat$Odor == "Civette"| AllPat$Odor == "Acide isovalérique" | AllPat$Odor == "Cuir", "Degout", 
                ifelse(AllPat$Odor == "Tiare"  | AllPat$Odor == "Lilas" | AllPat$Odor == "Lavande" | AllPat$Odor == "Pamplemousse" | AllPat$Odor == "Paradisone" | AllPat$Odor == "Defi", "Floral",       # nolint: line_length_linter.
                ifelse(AllPat$Odor == "Fraise" | AllPat$Odor == "Caramel", "Gourmand", 
                ifelse(AllPat$Odor == "Firsantol", "Santol", "NA"))))))

MY_APA = AllPat # Reutilisation de code GNG-Marche
for (varnum in 4:11) {
    
    print(colnames(MY_APA)[varnum])
    MY_APA$varn = MY_APA[[colnames(MY_APA)[varnum]]]
    ttest_result_groupe = summary(aov(varn ~ Type, data = MY_APA))[[1]]$`Pr(>F)`[1]
    ttest_result_odeur  = summary(aov(varn ~ Odor, data = MY_APA))[[1]]$`Pr(>F)`[1]
    
    localplot_groupe = ggplot(MY_APA, aes(x = Type, y = .data[[colnames(MY_APA)[varnum]]], color = Type)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                    label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_groupe, digits = 2)))
    
    localplot_odeur = ggplot(MY_APA, aes(x = Odor, y = .data[[colnames(MY_APA)[varnum]]], color = Odor)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                    label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_odeur, digits = 2)))
    
    fusionplot = gridExtra::grid.arrange(localplot_odeur, localplot_groupe, ncol = 2)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_groupe, location = ph_location_fullsize())
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
}

ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")


AllPat = PrePost
AllPat$Odor = AllPat$odeurs
AllPat$Type  =  ifelse(AllPat$Odor == "Neutre", "Neutre",
                ifelse(AllPat$Odor == "Menthe" | AllPat$Odor == "Eucalyptus", "Trigeminal",
                ifelse(AllPat$Odor == "Civette"| AllPat$Odor == "Acide isovalérique" | AllPat$Odor == "Cuir", "Degout", 
                ifelse(AllPat$Odor == "Tiare"  | AllPat$Odor == "Lilas" | AllPat$Odor == "Lavande" | AllPat$Odor == "Pamplemousse" | AllPat$Odor == "Paradisone" | AllPat$Odor == "Defi", "Floral",       # nolint: line_length_linter.
                ifelse(AllPat$Odor == "Fraise" | AllPat$Odor == "Caramel", "Gourmand", 
                ifelse(AllPat$Odor == "Firsantol", "Santol", "NA"))))))

IncludedValuesInPCA = c(1:13) 
QualitativeValuesInPCA = c(1, 2, 3, 12, 13)

if (any(is.na(AllPat))) {
    AllPat_fitted = missMDA::imputePCA(AllPat, 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 6)$
                completeObs
} else {
    AllPat_fitted = AllPat
}

res_pca      = FactoMineR::PCA(AllPat_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=5, 
                scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Groupes', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Groupes', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Groupes', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 3, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 3, "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")




## 4. Left vs Right
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
ppt = ph_with(ppt, value = "4. Left vs Right", location = ph_location_type(type = "title"))

AllPat = Lateral
AllPat$Odor = AllPat$odeurs
AllPat$Type  =  ifelse(AllPat$Odor == "Neutre", "Neutre",
                ifelse(AllPat$Odor == "Menthe" | AllPat$Odor == "Eucalyptus", "Trigeminal",
                ifelse(AllPat$Odor == "Civette"| AllPat$Odor == "Acide isovalérique" | AllPat$Odor == "Cuir", "Degout", 
                ifelse(AllPat$Odor == "Tiare"  | AllPat$Odor == "Lilas" | AllPat$Odor == "Lavande" | AllPat$Odor == "Pamplemousse" | AllPat$Odor == "Paradisone" | AllPat$Odor == "Defi", "Floral",       # nolint: line_length_linter.
                ifelse(AllPat$Odor == "Fraise" | AllPat$Odor == "Caramel", "Gourmand", 
                ifelse(AllPat$Odor == "Firsantol", "Santol", "NA"))))))

IncludedValuesInPCA = c(1:14) 
QualitativeValuesInPCA = c(1, 2, 3, 13, 14)

if (any(is.na(AllPat))) {
    AllPat_fitted = missMDA::imputePCA(AllPat, 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 6)$
                completeObs
} else {
    AllPat_fitted = AllPat
}

res_pca      = FactoMineR::PCA(AllPat_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=5, 
                scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Groupes', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Groupes', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Groupes', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 3, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 3, "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")



## 5. Controles
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
ppt = ph_with(ppt, value = "5. Controles", location = ph_location_type(type = "title"))


AllPat = AllPatSave
summary(AllPat)
summary(Control)

longformat = reshape2::melt(Control, id.vars = c("code", "Group", "Odor"))
longformat = longformat[!is.na(longformat$value),]

longforma2 = reshape2::melt(AllPat, id.vars = c("Id", "Group", "Odor"))
longforma2 = longforma2[!is.na(longforma2$value),]
colnames(longforma2) = c("code", "Group", "Odor", "variable", "value")

longformat = rbind(longformat, longforma2)
longformat = longformat[complete.cases(longformat),]

localplot_gp = ggplot(longformat, aes(x = Group, y = value, color = Group)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0('All var in controls and pat')) 
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_gp, location = ph_location_fullsize())

longformat$value[longformat$Group == "Cont"] = longformat$value[longformat$Group == "Cont"]/2

localplot_gp = ggplot(longformat, aes(x = Group, y = value, color = Group)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0('All var in controls and pat')) 
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_gp, location = ph_location_fullsize())


AllPat = Control 

AllPat$Type  =  ifelse(AllPat$Odor == "Neutre", "Neutre",
                ifelse(AllPat$Odor == "Menthe" | AllPat$Odor == "Eucalyptus", "Trigeminal",
                ifelse(AllPat$Odor == "Civette"| AllPat$Odor == "Acide isovalérique" | AllPat$Odor == "Cuir", "Degout", 
                ifelse(AllPat$Odor == "Tiare"  | AllPat$Odor == "Lilas" | AllPat$Odor == "Lavande" | AllPat$Odor == "Pamplemousse" | AllPat$Odor == "Paradisone"  | AllPat$Odor == "Defi", "Floral",       # nolint: line_length_linter.
                ifelse(AllPat$Odor == "Fraise" | AllPat$Odor == "Caramel", "Gourmand", 
                ifelse(AllPat$Odor == "Firsantol", "Santol", 
                ifelse(AllPat$Odor == "Miel", "AExclure", "NA")))))))

AllPat = AllPat[AllPat$Type != "AExclure",]

MY_APA = AllPat # Reutilisation de code GNG-Marche
for (varnum in 7:12) {
    
    print(colnames(MY_APA)[varnum])
    MY_APA$varn = MY_APA[[colnames(MY_APA)[varnum]]]
    ttest_result_groupe = summary(aov(varn ~ Type, data = MY_APA))[[1]]$`Pr(>F)`[1]
    ttest_result_odeur  = summary(aov(varn ~ Odor, data = MY_APA))[[1]]$`Pr(>F)`[1]
    
    localplot_groupe = ggplot(MY_APA, aes(x = Type, y = .data[[colnames(MY_APA)[varnum]]], color = Type)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                    label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_groupe, digits = 2)))
    
    localplot_odeur = ggplot(MY_APA, aes(x = Odor, y = .data[[colnames(MY_APA)[varnum]]], color = Odor)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        annotate("text", x = 1.5, y = max(MY_APA[[colnames(MY_APA)[varnum]]]*1.01, na.rm = TRUE), 
                    label = paste0(colnames(MY_APA)[varnum] ," : ", signif(ttest_result_odeur, digits = 2)))
    
    fusionplot = gridExtra::grid.arrange(localplot_odeur, localplot_groupe, ncol = 2)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_groupe, location = ph_location_fullsize())
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
}


IncludedValuesInPCA = c(1:3, 7:13)      # modifié !!!
QualitativeValuesInPCA = c(1, 2, 3, 10) # modifié !!!

if (any(is.na(AllPat[,IncludedValuesInPCA]))) {
    AllPat_fitted = missMDA::imputePCA(AllPat, 
                quali.sup = QualitativeValuesInPCA , 
                ncp = 6)$
                completeObs
} else {
    AllPat_fitted = AllPat[,IncludedValuesInPCA]
}

res_pca      = FactoMineR::PCA(AllPat_fitted, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=5, 
                scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 3, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 3, "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'code', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'code', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'code', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")

Control_fitted = AllPat_fitted

## 6. Comparaison des patients avec les controles
ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
ppt = ph_with(ppt, value = "6. Comparaison des patients avec les controles", location = ph_location_type(type = "title"))


for (i in 0:5) {
    # Control_fitted[,4+i] = scale(Control_fitted[,4+i], center = TRUE, scale = TRUE)   # nolint
    Control_fitted[,4+i] = Control_fitted[,4+i] / 2
}
colnames(Control_fitted)[1] = "Id"

AllPat = AllPatSave
AllPat$Type  =  ifelse(AllPat$Odor == "Neutre", "Neutre",
                ifelse(AllPat$Odor == "Menthe" | AllPat$Odor == "Eucalyptus", "Trigeminal",
                ifelse(AllPat$Odor == "Civette"| AllPat$Odor == "Acide isovalérique" | AllPat$Odor == "Cuir", "Degout", 
                ifelse(AllPat$Odor == "Tiare"  | AllPat$Odor == "Lilas" | AllPat$Odor == "Lavande" | AllPat$Odor == "Pamplemousse" | AllPat$Odor == "Paradisone"  | AllPat$Odor == "Defi", "Floral",       # nolint: line_length_linter.
                ifelse(AllPat$Odor == "Fraise" | AllPat$Odor == "Caramel", "Gourmand", 
                ifelse(AllPat$Odor == "Firsantol", "Santol", "NA"))))))

rm(AllPat_fitted)
AllPat_fitted = AllPat[,1:3]
for (i in 0:5) {
    AllPat_fitted[,4+i] =       AllPat[,7+i]
  # AllPat_fitted[,4+i] = scale(AllPat[,7+i], center = TRUE, scale = TRUE)   # nolint
}
AllPat_fitted[,10] = AllPat[,13]

Merged = rbind(Control_fitted, AllPat_fitted)

MY_APA = Merged # Reutilisation de code GNG-Marche
for (varnum in 4:9) { #modifie pour ici
    
    print(colnames(MY_APA)[varnum])
    MY_APA$varn = MY_APA[[colnames(MY_APA)[varnum]]]
    ttest_result_groupe = summary(aov(varn ~ Type, data = MY_APA))[[1]]$`Pr(>F)`[1]
    ttest_result_odeur  = summary(aov(varn ~ Odor, data = MY_APA))[[1]]$`Pr(>F)`[1]
    
    localplot_groupe = ggplot(MY_APA, aes(x = Group, y = .data[[colnames(MY_APA)[varnum]]], color = Group)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        facet_wrap(~Type) 
       
    localplot_odeur = ggplot(MY_APA, aes(x = Group, y = .data[[colnames(MY_APA)[varnum]]], color = Group)) +
        ggbeeswarm::geom_beeswarm(alpha = 0.5, size = 0.1) +
        geom_violin(alpha = 0.5) + 
        geom_boxplot(width = 0.2) +
        theme_bw() +
        theme(legend.position = "none") +
        labs(title = paste0(varnum, ' : ', colnames(MY_APA)[varnum])) +
        facet_wrap(~Odor)
        
    fusionplot = gridExtra::grid.arrange(localplot_odeur, localplot_groupe, ncol = 2)
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_groupe, location = ph_location_fullsize())
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = localplot_odeur, location = ph_location_fullsize())
}

IncludedValuesInPCA = c(1:10)      # modifié !!!
QualitativeValuesInPCA = c(1, 2, 3, 10) # modifié !!!

res_pca      = FactoMineR::PCA(Merged, 
                quali.sup = QualitativeValuesInPCA , 
                ncp=5, 
                scale.unit=TRUE, graph=FALSE)

VerifGeneralePCA(ppt, res_pca)

plotIndPPT(ppt, res_pca, Grouping = 'Group', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Group', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Group', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 3, Axe2 = 2, paletteCouleur = "lancet")
plotIndPPT(ppt, res_pca, Grouping = 'Type', Axe1 = 1, Axe2 = 3, paletteCouleur = "lancet")

plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 3, Axe2 = 2, "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Odor', Axe1 = 1, Axe2 = 3, "bpalette")

plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 3, Axe2 = 2, paletteCouleur = "bpalette")
plotIndPPT(ppt, res_pca, Grouping = 'Id', Axe1 = 1, Axe2 = 3, paletteCouleur = "bpalette")


AllPat_Umap = scale(Merged[,4:9], center = TRUE, scale = TRUE)
nei = 35
com = 3
APAumap = umap::umap(AllPat_Umap, method="umap-learn",  n_neighbors = nei, n_components = com, metric = "euclidean", min_dist = 0.1)
plotUmapPPT(ppt, nei, com, "Group", APAumap, Merged)
plotUmapPPT(ppt, nei, com, "Type",  APAumap, Merged)
plotUmapPPT(ppt, nei, com, "Odor",  APAumap, Merged)
plotUmapPPT(ppt, nei, com, "Id",    APAumap, Merged)

AllPat_Umap = scale(Merged[,4:9], center = TRUE, scale = TRUE)
nei = 10
com = 3
APAumap = umap::umap(AllPat_Umap, method="umap-learn",  n_neighbors = nei, n_components = com, metric = "euclidean", min_dist = 0.1)
plotUmapPPT(ppt, nei, com, "Group", APAumap, Merged)
plotUmapPPT(ppt, nei, com, "Type",  APAumap, Merged)
plotUmapPPT(ppt, nei, com, "Odor",  APAumap, Merged)
plotUmapPPT(ppt, nei, com, "Id",    APAumap, Merged)



print(ppt, target = paste0(OutputDir, "Exploration_AllPat.pptx"))





























