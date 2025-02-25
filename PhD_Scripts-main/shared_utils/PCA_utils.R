

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
  COR1 = res_pca$var$coord[, 1:3]
  COR2 = data.frame(COR1)
  COR2$Var1 = rownames(COR2)
  COR       = reshape2::melt(COR2) #pour metre les dimensions sur les lignes 
  limCor  = max(c(abs(COR$value), 1))
  myPalette = grDevices::colorRampPalette(c("#281E78","#ffffff","#ffffff","#ffffff","#fa4616"))
  cor = ggplot(COR,aes(x = variable, y = Var1, fill = value))+ # nolint: object_usage_linter.
    geom_tile()+
    scale_fill_gradientn(colours = myPalette(100),lim=c(-limCor,limCor))+
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

plotIndPPT_withSelection = function(ppt, res_pca, Grouping, Axe1, Axe2, paletteCouleur = "bpalette", SubsetVar, SubsetVal) {
  print(list(row.names(res_pca$call$quali.sup$quali.sup)[res_pca$call$quali.sup$quali.sup[[SubsetVar]] == SubsetVal]))
  plt = factoextra::fviz_pca_ind(res_pca,
                                 geom.ind = "point", 
                                 habillage = res_pca$call$quali.sup$quali.sup[[Grouping]],
                                 #col.ind = APA$g, # colorer by groups
                                 palette = paletteCouleur,
                                 addEllipses = TRUE, # Ellipses de concentration
                                 legend.title = "Groups",axes = c(Axe1, Axe2),
                                 select.ind = list(name = row.names(res_pca$call$quali.sup$quali.sup)[res_pca$call$quali.sup$quali.sup[[SubsetVar]] == SubsetVal])
  )
  if (ppt == "None") { print(plt)
  } else {
    ppt = add_slide(ppt, layout = "Title and Content", master = "Office Theme")
    ppt = ph_with(ppt, value = plt, location = ph_location_fullsize())
  }
}



GetPCAresults = function(res_pca, ncp = 5, indices_sup = NULL, df = NULL) {
  PCA_loadings = cbind(res_pca$call$quali.sup$quali.sup, res_pca$ind$coord)
  PCA_distance = cbind(res_pca$call$quali.sup$quali.sup, res_pca$ind$dist )
  colnames(PCA_distance)[6] = "dist"
  if(!is.null(indices_sup)) {
    PCA_loadings_ind.sup = cbind(DataFusion[indices_sup,1:5], res_pca$ind.sup$coord)
    PCA_distance_ind.sup = cbind(DataFusion[indices_sup,1:5], res_pca$ind.sup$dist)
    PCA_loadings = rbind(PCA_loadings, PCA_loadings_ind.sup)
    colnames(PCA_distance_ind.sup)[6] = "dist"
    PCA_distance = rbind(PCA_distance, PCA_distance_ind.sup)
  }
  PCAresults = cbind(PCA_loadings, PCA_distance[,6])
  return(PCAresults)
}

RainbowPlot = function(df, VarNum, VarCateg, Grouping = NULL, title_plot = "", ylabel_plot = "", palette = NULL, AddNumbersOfSubjects = FALSE, pval_df = NULL, theme = theme_minimal()) {
  # Don't hesitate to use mutate to ameliorate names coding of VarCateg
  # PCAresults %>% mutate(Group = recode(Group, 
  #                                      "insul1" = "Patients",
  #                                      "Cont" = "Controls")
  # ) %>% RainbowPlot(
  #   "Group", 
  #   "dist", 
  #   ylabel_plot = "Euclidian Distance", 
  #   title_plot  = "PCA Distance between Patients and Controls"
  # )
  #
  #  pval_df must be structured with the following columns:
  #  a contrast column (typically from ammeans) that will be splitted arround " -" by stringr::str_split(pval_df$contrast, pattern = " - ")
  #  pval_text = texte affiché associe à la comparaison (soit '***' ou 'p=0.001')
  #  
  # Inspired from
  # https://www.cedricscherer.com/2021/06/06/visualizing-distributions-with-raincloud-plots-and-how-to-create-them-with-ggplot2/
  # https://gist.github.com/z3tt/8b2a06d05e8fae308abbf027ce357f01
  
  # library(ggtext)
  # library(colorspace)
  if (is.null(Grouping)) {Grouping = VarCateg ; todolegend = FALSE} else {todolegend = TRUE}
  
  if (is.null(palette)) {
    if (length(unique(df[[Grouping]])) < 5) pal = c("#FF8C00", "#A034F0", "#159090", "#809015")
    else pal = grDevices::rainbow(length(unique(df[[Grouping]])))
  } else pal = eval(parse(text = palette))(length(unique(df[[Grouping]])))
  
  p = df %>% 
    mutate(VarCateg = as.factor( !!sym(VarCateg))) %>%
    mutate(VarNum   = as.numeric(!!sym(VarNum  ))) %>%
    mutate(Grouping = as.factor( !!sym(Grouping))) %>%
    group_by(VarCateg)  %>%
    filter(!is.na(VarNum)) %>% 
    ggplot(aes(x = VarCateg, y = VarNum)) + 
    ggdist::stat_halfeye(
      aes(color = Grouping,
          fill = after_scale(colorspace::lighten(color, .2))),
      alpha = .5,
      adjust = .5, 
      width = .75, 
      .width = 0,
      justification = -.22, 
      point_color = NA) + 
    geom_boxplot(
      aes(color = Grouping,
          color = after_scale(colorspace::darken(color, .1, space = "HLS")),
          fill = after_scale(colorspace::desaturate(colorspace::lighten(color, .8), .4))),
      width = .25, 
      outlier.shape = NA
    ) +
    geom_point(
      aes(color = Grouping,
          color = after_scale(colorspace::darken(color, .1, space = "HLS"))),
      fill = "white",
      shape = 21,
      stroke = .25,
      size = 2,
      position = position_jitter(seed = 1, width = .12)
    ) + 
    geom_point(
      aes(fill = Grouping),
      color = "transparent",
      shape = 21,
      stroke = .4,
      size = 2,
      alpha = .3,
      position = position_jitter(seed = 1, width = .12)
    ) + 
    {if (!is.null(pval_df)) {
      ggpubr::geom_signif(
        comparisons = stringr::str_split(pval_df$contrast, pattern = " - "),
        step_increase = (max(df[[VarNum]]) - min(df[[VarNum]])) * 0.05,
        annotations = ifelse(is.numeric(pval_df$pval_text), sprintf("p = %.4f", pval_df$pval_text), pval_df$pval_text),
        color = "black",
      )
    }} +
    stat_summary(
      geom = "text",
      fun = "median",
      aes(label = round(..y.., 2),
          color = Grouping,
          color = after_scale(colorspace::darken(color, .1, space = "HLS"))),
      family = "Apercu Mono",
      fontface = "bold",
      size = 4.5,
      vjust = -3.5
    ) +
    coord_flip(xlim = c(1.4, NA), clip = "off") +
    scale_fill_manual(values = pal, guide = "none") +
    labs(
      x = NULL,
      y = ylabel_plot,
      title = title_plot
    ) +
    theme_minimal( base_size = 15) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      axis.ticks = element_blank(),
      axis.text.x = element_text(family = "Apercu Mono"),
      axis.text.y = element_text(
        color = (colorspace::darken(pal, .1, space = "HLS")), 
        size = 18
      ),
      axis.title.x = element_text(margin = margin(t = 10),
                                  size = 16) ,
      # plot.subtitle = element_text(
      #   color = "grey40", hjust = 0,
      #   margin = margin(0, 0, 20, 0)
      # ),
      plot.title.position = "plot",
      plot.margin = margin(15, 15, 10, 15)
    ) 
  
    if (!todolegend) {
      p = p + scale_color_manual(values = pal, guide = "none")
    } else {
      p = p + scale_color_manual(values = pal) +
        theme(legend.position = "bottom")
    }
    
    if (AddNumbersOfSubjects != FALSE) {
      if (is.numeric(AddNumbersOfSubjects)) {
        add_sample = function(x) return(c(y = max(x) + .025, label = length(x)/AddNumbersOfSubjects))
      } else {
        add_sample = function(x) return(c(y = max(x) + .025, label = length(x)))
      }
      
      p = p + stat_summary(
        geom = "text",
        fun.data = add_sample,
        aes(label = paste("n =", ..label..),
            color = Grouping,
            color = after_scale(colorspace::darken(color, .1, space = "HLS"))),
        family = "Roboto Condensed",
        size = 4,
        hjust = 0
      ) 
    }
  
  
  return(p)
}






