

match_patient_names = function(locdata, locid){
    if  (!any(grepl("Patient_code",colnames(locdata)))) return(locdata)
    else locdata %<>% mutate(Patient = locid$IdLFP[match(Patient_code, locid$IdLOC)]) %>% relocate(Patient, .before = Sujet_long) %>% select(-Patient_code)
    return(locdata)
}

join_spectrum_loc = function(query_spectrum, locdata){
    locdata %<>% match_patient_names(locid)
    locdata$ChanelLabel = paste0(as.numeric(locdata$interplot)-1, locdata$interplot, ifelse(locdata$Hemisphere == "RH", 'D', 'G'))
    locdata %<>% select(Patient, ChanelLabel, ML, AP, DV) 
    query_spectrum %>%
        left_join(locdata, by = c("Patient", "ChanelLabel")) %>%
    return(query_spectrum)
}

join_clinic = function(query_spectrum, clinicd, SelectList){
    clinicd %<>% select(PATIENTID, SelectList)
    query_spectrum %>% 
        left_join(clinicd, by = c("Patient" = "PATIENTID")) %>%
    return(query_spectrum)
}

select_clinical_contacts = function(locplot, locThera, filter_contact = F, na_rm_func = T){
    locplot$Therapeutic = locThera[match(locplot$Electrode, locThera$id_loc), "plotherapeutic"]
    locplot$Therapeutic = ifelse(locplot$Therapeutic == "non", F, ifelse(locplot$Therapeutic == "oui", T, NA))
    if (na_rm_func)       locplot %<>% filter(!is.na(Therapeutic))
    if (filter_contact)    locplot %<>% filter(Therapeutic)
    return(locplot)
}

check_model = function(model) {
    print(summary(model))
    print(anova(model))
    print(mgcv::k.check(model))
    plot(gratia::draw(model) + ggplot2::theme_bw() )
    plot(ggeffects::ggemmeans(model, terms = c('frequency', 'Clinic')) %>% plot() )
    plot(gratia::appraise(model))
    plot(ggeffects::ggcheck(model))
    plot(ggeffects::ggeffect(model, terms = "Freq"))
    plot(modelbased::estimate_relation(model, length = 100, preserve_range = F))
}


vis_gam_custom = function(x, view = NULL, cond = list(), n.grid = 100, too.far = 0.1, 
                           col = NA, color = "heat", contour.col = NULL, se = -1, type = "link", 
                           plot.type = "contour", zlim = NULL, nCol = 50, lp = 1,
                           rangeML = NULL, rangeDV = NULL, PSDlim_SF = NULL, localtitle = "", lastAP = F, ...) 
{
  fac.seq = function(fac, n.grid) {
    fn = length(levels(fac))
    gn = n.grid
    if (fn > gn) {
      mf = factor(levels(fac))[1:gn]
    } else {
      ln = floor(gn / fn)
      mf = rep(levels(fac)[fn], gn)
      mf[1:(ln * fn)] = rep(levels(fac), rep(ln, fn))
      mf = factor(mf, levels = levels(fac))
    }
    mf
  }
  dnm = names(list(...))
  v.names = names(x$var.summary)
  if (is.null(view)) {
    k = 0
    view = rep("", 2)
    for (i in 1:length(v.names)) {
      ok = TRUE
      if (is.matrix(x$var.summary[[i]])) 
        ok = FALSE
      else if (is.factor(x$var.summary[[i]])) {
        if (length(levels(x$var.summary[[i]])) <= 1) 
          ok = FALSE
      }
      else {
        if (length(unique(x$var.summary[[i]])) == 1) 
          ok = FALSE
      }
      if (ok) {
        k = k + 1
        view[k] = v.names[i]
      }
      if (k == 2) 
        break
    }
    if (k < 2) 
      stop("Model does not seem to have enough terms to do anything useful")
  } else {
    if (sum(view %in% v.names) != 2) 
      stop(gettextf("view variables must be one of %s", paste(v.names, collapse = ", ")))
    for (i in 1:2) if (!inherits(x$var.summary[[view[i]]], 
                                 c("numeric", "factor"))) 
      stop("Don't know what to do with parametric terms that are not simple numeric or factor variables")
  }
  ok = TRUE
  for (i in 1:2) if (is.factor(x$var.summary[[view[i]]])) {
    if (length(levels(x$var.summary[[view[i]]])) <= 1) 
      ok = FALSE
  }
  else {
    if (length(unique(x$var.summary[[view[i]]])) <= 1) 
      ok = FALSE
  }
  if (!ok) 
    stop(gettextf("View variables must contain more than one value. view = c(%s,%s).", 
                  view[1], view[2]))
  if (is.factor(x$var.summary[[view[1]]])) 
    m1 = fac.seq(x$var.summary[[view[1]]], n.grid)
  else {
    r1 = range(x$var.summary[[view[1]]])
    m1 = seq(r1[1], r1[2], length = n.grid)
  }
  if (is.factor(x$var.summary[[view[2]]])) 
    m2 = fac.seq(x$var.summary[[view[2]]], n.grid)
  else {
    r2 = range(x$var.summary[[view[2]]])
    m2 = seq(r2[1], r2[2], length = n.grid)
  }
  v1 = rep(m1, n.grid)
  v2 = rep(m2, rep(n.grid, n.grid))
  newd = data.frame(matrix(0, n.grid * n.grid, 0))
  for (i in 1:length(x$var.summary)) {
    ma = cond[[v.names[i]]]
    if (is.null(ma)) {
      ma = x$var.summary[[i]]
      if (is.numeric(ma)) 
        ma = ma[2]
    }
    if (is.matrix(x$var.summary[[i]])) 
      newd[[i]] = matrix(ma, n.grid * n.grid, ncol(x$var.summary[[i]]), 
                          byrow = TRUE)
    else newd[[i]] = rep(ma, n.grid * n.grid)
  }
  names(newd) = v.names
  newd[[view[1]]] = v1
  newd[[view[2]]] = v2
  if (type == "link") 
    zlab = paste("linear predictor")
  else if (type == "response") 
    zlab = type
  else stop("type must be \"link\" or \"response\"")
  fv = predict.gam(x, newdata = newd, se.fit = TRUE, type = type)
  z = fv$fit
  if (is.matrix(z)) {
    lp = min(ncol(z), max(1, round(lp)))
    z = z[, lp]
    fv$fit = fv$fit[, lp]
    fv$se.fit = fv$se.fit[, lp]
  }
  if (too.far > 0) {
    ex.tf = exclude.too.far(v1, v2, x$model[, view[1]], 
                             x$model[, view[2]], dist = too.far)
    fv$se.fit[ex.tf] = fv$fit[ex.tf] = NA
  }
  if (is.factor(m1)) {
    m1 = as.numeric(m1)
    m1 = seq(min(m1) - 0.5, max(m1) + 0.5, length = n.grid)
  }
  if (is.factor(m2)) {
    m2 = as.numeric(m2)
    m2 = seq(min(m1) - 0.5, max(m2) + 0.5, length = n.grid)
  }
  if (se <= 0) {
    old.warn = options(warn = -1)
    av = matrix(c(0.5, 0.5, rep(0, n.grid - 1)), n.grid, 
                 n.grid - 1)
    options(old.warn)
    max.z = max(z, na.rm = TRUE)
    z[is.na(z)] = max.z * 10000
    z = matrix(z, n.grid, n.grid)
    surf.col = t(av) %*% z %*% av
    surf.col[surf.col > max.z * 2] = NA
    if (!is.null(zlim)) {
      if (length(zlim) != 2 || zlim[1] >= zlim[2]) 
        stop("Something wrong with zlim")
      min.z = zlim[1]
      max.z = zlim[2]
    } 
    else {
      min.z = min(fv$fit, na.rm = TRUE)
      max.z = max(fv$fit, na.rm = TRUE)
    }
    if (min.z == max.z) {
      min.z = min.z - 1
      max.z = max.z + 1
    }
    surf.col = surf.col - min.z
    surf.col = surf.col/(max.z - min.z)
    surf.col = round(surf.col * nCol)
    con.col = 1
    if (color == "heat") {
      pal = heat.colors(nCol)
      con.col = 4
    }
    else if (color == "topo") {
      pal = topo.colors(nCol)
      con.col = 2
    }
    else if (color == "cm") {
      pal = cm.colors(nCol)
      con.col = 1
    }
    else if (color == "jet") {
      pal = pals::jet(nCol)
      con.col = 1
    }
    else if (color == "terrain") {
      pal = terrain.colors(nCol)
      con.col = 2
    }
    else if (color == "gray" || color == "bw") {
      pal = gray(seq(0.1, 0.9, length = nCol))
      con.col = 1
    }
    else stop("color scheme not recognised")
    if (is.null(contour.col)) 
      contour.col = con.col
    surf.col[surf.col < 1] = 1
    surf.col[surf.col > nCol] = nCol
    if (is.na(col)) 
      col = pal[as.array(surf.col)]
    z = matrix(fv$fit, n.grid, n.grid)
    
 
  }
    grid_data = data.frame(x = rep(m1, each = n.grid), y = rep(m2, n.grid), z = as.vector(z))
    plot = ggplot(grid_data, aes(x = x, y = y, fill = z)) +
      geom_tile() +
      scale_fill_gradientn(colors = pal, limits = PSDlim_SF) +
      labs(x = view[1], y = view[2], fill = "PSD") +
      theme_minimal() +
      coord_cartesian(xlim = rangeML, ylim = rangeDV) + 
      theme(aspect.ratio = 1) +
      ggtitle(localtitle)
    
    if (lastAP) {
      plot = plot + theme(legend.position = "right")
    } else {
      plot = plot + theme(legend.position = "none")
    }  

    if (plot.type == "contour") {
        plot = plot + geom_contour(aes(z = z), color = "black")
    }
        
    return(plot)
  
}




## Visu manuelle

plot_gam = function(model, query, PlotSaveFolder, FolderSupp = "", emm_specs = "~ Side_Freq*AP*ML*DV", ligne = "Treatment", GridDensity = 20, AP_Step = 1, PaletteMain = "pals::parula", PaletteDiff = "pals::kovesi.diverging_linear_bjy_30_90_c45") {

# Emm
  rangeML_left  = grDevices::extendrange(query %>% filter(Side == "left")  %>% pull(ML), f = 0.1)
  rangeDV_left  = grDevices::extendrange(query %>% filter(Side == "left")  %>% pull(DV), f = 0.1)
  rangeML_right = grDevices::extendrange(query %>% filter(Side == "right") %>% pull(ML), f = 0.1)
  rangeDV_right = grDevices::extendrange(query %>% filter(Side == "right") %>% pull(DV), f = 0.1)  

  AP_range       = seq(ceiling(min(query$AP)), floor(max(query$AP)), by = AP_Step)
  rangeML  = grDevices::extendrange(query  %>% pull(ML), f = 0.1)
  rangeDV  = grDevices::extendrange(query  %>% pull(DV), f = 0.1)

  emm = emmeans::emmeans(model, 
                        specs = as.formula(emm_specs), 
                        by = c("AP", "ML", "DV"),
                        at = list(AP = AP_range,
                                ML = seq(rangeML[1], rangeML[2], length.out = GridDensity),
                                DV = seq(rangeDV[1], rangeDV[2], length.out = GridDensity),
                                Side_Freq = unique(query$Side_Freq)),
                        rg.limit = 100000)
  
  emmdf = as.data.frame(emm)

# Contrastes
  unique_side = unique(query$Side)
  unique_freq = unique(query$Freq)
  contrast_df = data.frame()

  for (s in unique_side) {
    for (f in unique_freq) {
      off_label = paste0(s, ".OFF.", f)
      on_label  = paste0(s, ".ON.", f)
      if (all(c(off_label, on_label) %in% levels(query$Side_Freq))) {
        sub_emm = emmeans::emmeans(
          model,
          specs = as.formula(emm_specs), 
          by = c("AP", "ML", "DV"),
          at = list(
            Side_Freq = c(off_label, on_label),
            AP = AP_range,
            ML = seq(rangeML[1], rangeML[2], length.out = GridDensity),
            DV = seq(rangeDV[1], rangeDV[2], length.out = GridDensity)
          ),
          rg.limit = 100000
        )
        contrast_df = rbind(contrast_df, as.data.frame(contrast(sub_emm, method = "pairwise")))
      }
    }
  }
  
  if (ligne == "beta") {
    beta_contrast = data.frame()
    for (s in c("left", "right")) {
      for (f in c("OFF", "ON")) {
        low_label = paste0(s, f, "lowBeta")
        high_label  = paste0(s, f, "highBeta")
        if (all(c(low_label, high_label) %in% levels(query$Side_Freq))) {
          sub_emm = emmeans::emmeans(
            model,
            specs = as.formula(emm_specs), 
            by = c("AP", "ML", "DV"),
            at = list(
              Side_Freq = c(low_label, high_label),
              AP = AP_range,
              ML = seq(rangeML[1], rangeML[2], length.out = GridDensity),
              DV = seq(rangeDV[1], rangeDV[2], length.out = GridDensity)
            ),
            rg.limit = 100000
          )
          beta_contrast %<>% rbind(as.data.frame(contrast(sub_emm, method = "pairwise")))
        }
      }
    }
    beta_contrast %<>% select(contrast, AP, ML, DV, estimate, p.value)
    names(beta_contrast) = c("Side_Freq", "AP", "ML", "DV", "emmean", "p.value")
  }
  contrast_df   %<>% select(contrast, AP, ML, DV, estimate, p.value)
  names(contrast_df)   = c("Side_Freq", "AP", "ML", "DV", "emmean", "p.value")


  # plot
  global_min = min(emmdf$emmean, na.rm = TRUE)
  global_max = max(emmdf$emmean, na.rm = TRUE)
  sidefreqs = unique(emmdf$Side_Freq)
  difflim = c(min(contrast_df$emmean, na.rm = T), max(contrast_df$emmean, na.rm = T))
  
  if (ligne == "Treatment") {
    sflist_notreat = unique(interaction(query$Side, query$Freq))
    query_for_plot = query %>% select(Patient, Side, ChanelLabel, Treatment, AP, ML, DV) %>% distinct()
    query_for_plot$AP = AP_range[findInterval(query_for_plot$AP, AP_range, all.inside = TRUE)]

    for (sf in sflist_notreat) {
      side = ifelse(grepl("left", sf), "left", "right")
      splitsf = unlist(strsplit(sf, "\\."))
      # Subset EMM data for theses 2 Side_Freq
      subdata = emmdf %>% dplyr::filter(Side_Freq %in% c(paste0(splitsf[1], ".OFF.", splitsf[2]), paste0(splitsf[1], ".ON.", splitsf[2])))
      subdata$Treatment = ifelse(grepl("ON", subdata$Side_Freq), "ON", "OFF")
      subdata$p.value   = NA

      if (grepl("left", sf)) rangeDV_local = rangeDV_left else rangeDV_local = rangeDV_right
      if (grepl("left", sf)) rangeML_local = rangeML_left else rangeML_local = rangeML_right

      diffdata = contrast_df %>% filter(Side_Freq == paste0(splitsf[1], ".OFF.", splitsf[2], " - ", splitsf[1], ".ON.", splitsf[2])) %>% mutate(Treatment = "OFF-ON")
      if (nrow(diffdata) == 0) print("Fatal error: no contrast data found, diffdata is empty")

      # Build base plot
      p = ggplot(subdata, aes(x = ML, y = DV, fill = emmean)) +
        geom_raster(interpolate = T) +
        scale_fill_paletteer_c(PaletteMain, limits=c(global_min, global_max), oob=scales::squish, na.value="gray90", transform = "identity") +
        facet_grid(Treatment ~ AP) +
        coord_cartesian(ylim = rangeDV_local, xlim = rangeML_local) +
        theme_Publication() 

      # Add some rug/point layers for query
      p = p + geom_rug(data = query_for_plot %>% filter(Side == side),
                        aes(x = ML, y = DV),
                        inherit.aes = FALSE, sides = "trbl", alpha = 0.3)
      p = p + geom_point(data = query_for_plot %>% filter(Side == side),
                          aes(x = ML, y = DV),
                          inherit.aes = FALSE, size = 1)

      q = ggplot(diffdata, aes(x = ML, y = DV, fill = emmean)) +
        geom_raster(interpolate = T) +
        scale_fill_paletteer_c(PaletteDiff, limits=difflim, oob=scales::squish, na.value="gray90", transform = "identity") +
        facet_grid( ~ AP) +
        coord_cartesian(ylim = rangeDV_local, xlim = rangeML_local) +
        theme_Publication() 

      if (any(diffdata %>% pull(p.value) < 0.05)) {
        q = q + geom_contour(aes(z = log10(p.value), color = as.character("0.05")),
                     breaks = log10("0.05"), linewidth = .25, color = "black")
      }

      qp = p + q + plot_annotation(title = sf) + 
        plot_layout(guides = "collect", ncol = 2, nrow = 1, widths = c(2, 1)) & theme(legend.position = "bottom")
    
      if (!dir.exists(paste0(PlotSaveFolder, "/ModelPlot/", FolderSupp))) dir.create(paste0(PlotSaveFolder, "/ModelPlot/",FolderSupp), recursive = T)
      ggplot2::ggsave(paste0(PlotSaveFolder, "/ModelPlot/", FolderSupp, "GAM_PSDperLocperTreatment_", sf, ".png"), qp, width = 10, height = 30, units = "cm")
    }
  }

  if (ligne == "Beta") {
    WIP
  }

  if (ligne == "Freq") {
    WIP
    }

  

}


# Converted from Sara's Python code
# xmfMatrixPath = "C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/reg_mat/74_w2w_t1mri_2_acpc.xfm"
# matrix4x4 = readFromXFMFile(xmfMatrixPath)
# df %<>% applyInverseTransformToDF(matrix4x4)
GetMatrixFromTransform = function(TransformName) {
  if (TransformName == "t1mri_2_acpc" | TransformName == "nifti_2_acpc" | TransformName == "NIIWorld_2_acpc") {
    return(readFromXFMFile("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/reg_mat/74_w2w_t1mri_2_acpc.xfm"))
  } else if (TransformName == "acpc_2_t1mri" | TransformName == "acpc_2_nifti" | TransformName == "acpc_2_NIIWorld") {
    return(matlib::inv(readFromXFMFile("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/reg_mat/74_w2w_t1mri_2_acpc.xfm")))
  } else if (TransformName == "acpc_2_leftSTNbox") {
    return(readFromXFMFile("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/lh-stn-axis/74_w2w_acpc_LeftSTNAxis.xfm"))
  } else if (TransformName == "acpc_2_rightSTNbox") {
    return(readFromXFMFile("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/rh-stn-axis/74_w2w_acpc_RightSTNAxis.xfm"))
  } else if (TransformName == "leftSTNbox_2_acpc") {
    return(matlib::inv(readFromXFMFile("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/lh-stn-axis/74_w2w_acpc_LeftSTNAxis.xfm")))
  } else if (TransformName == "rightSTNbox_2_acpc") {
    return(matlib::inv(readFromXFMFile("C:/Users/mathieu.yeche/Desktop/Imagerie_GoGait/TransformationAxes/rh-stn-axis/74_w2w_acpc_RightSTNAxis.xfm")))
  } else {
    return(errrror)
  }
}

readFromXFMFile = function(xmfMatrixPath) {
  buf = suppressWarnings(readLines(xmfMatrixPath))
  mat = matrix(0, nrow = 4, ncol = 4)
  for (i in seq_along(buf)) {
    line = trimws(buf[i])
    numsStr = strsplit(line, "\\s+")[[1]]
    if (grepl("0x", numsStr[1])) {
      numsFloat = sapply(numsStr, function(x) strtoi(x, base = 16))
    } else {
      numsFloat = as.numeric(numsStr)
    }
    mat[i, ] = numsFloat
  }
  return(mat)
}

applyTransformToPoint = function(pts, matrix4x4) {
  if (is.character(matrix4x4)) matrix4x4 = GetMatrixFromTransform(matrix4x4)
  if (is.list(pts)) listflag = TRUE else listflag = FALSE
  if (listflag) pts = unlist(pts)
  if (is.vector(pts)) pts = rbind(pts)
  
  pointsHomo = cbind(pts, 1)
  pointsHomoTransformed = matrix4x4 %*% t(pointsHomo)
  transformed = t(pointsHomoTransformed)[, 1:3]

  if (listflag) transformed = list(transformed[1], transformed[2], transformed[3])
  if (!listflag && nrow(transformed) == 1) as.vector(transformed) else transformed
}

applyInverseTransformToDF = function(df, matrix4x4) {
  for (rownum in seq_len(nrow(df))) {
    point = c(df$ML[rownum], df$AP[rownum], df$DV[rownum])
    point = inverseTransformPoints(point, matrix4x4)
    df$ML[rownum] = point[1]
    df$AP[rownum] = point[2]
    df$DV[rownum] = point[3]
  }
  return(df)
}
inverseTransformPoints = function(point, matrix4x4) {
  tmatrixInv = matlib::inv(matrix4x4)
  return(applyTransformToPoint(point, tmatrixInv))
}



## Add STN Boundaries
geom_STNBoundaries = function(p, slicinglevel, sideofthebrain, atlas, pathSTN_VTK, slice_tolerance = 0.1, object = "nofacet") {
vtk = reticulate::import("vtk")

if (sideofthebrain == "left") {
  filenameSM = paste0(pathSTN_VTK, "74_LH_STN_SM-ON-pmMR.MR-Geometry_NIIWorld.vtk")
  filenameAS = paste0(pathSTN_VTK, "74_LH_STN_AS-ON-pmMR.MR-Geometry_NIIWorld.vtk")
  filenameLI = paste0(pathSTN_VTK, "74_LH_STN_LI-ON-pmMR.MR-Geometry_NIIWorld.vtk")
} else {
  filenameSM = paste0(pathSTN_VTK, "74_RH_STN_SM-ON-pmMR.MR-Geometry_NIIWorld.vtk")
  filenameAS = paste0(pathSTN_VTK, "74_RH_STN_AS-ON-pmMR.MR-Geometry_NIIWorld.vtk")
  filenameLI = paste0(pathSTN_VTK, "74_RH_STN_LI-ON-pmMR.MR-Geometry_NIIWorld.vtk")
}

for (territory in c("SM", "AS", "LI")) {
    filenamelocal = switch(territory, "SM" = filenameSM, "AS" = filenameAS, "LI" = filenameLI)
    colorlocal   = switch(territory, "SM" = "#2e8c57", "AS" = "#b552cc", "LI" = "#cc9c1c")
    
    VTKreader = vtk$vtkPolyDataReader()
    VTKreader$SetFileName(filenamelocal)
    VTKreader$Update()
    VTKdata = VTKreader$GetOutput()
    VTKpts  = VTKdata$GetPoints()

    VTKpoint_list = vector("list", VTKdata$GetNumberOfPoints())
    for (i in seq_len(VTKdata$GetNumberOfPoints())) {
    VTKcoords = VTKpts$GetPoint(as.integer(i - 1))
    if (atlas == "ACPC" | atlas == "box")            VTKcoords = applyTransformToPoint(VTKcoords, GetMatrixFromTransform("NIIWorld_2_acpc"))
    if (atlas == "box"  & sideofthebrain == "left")  VTKcoords = applyTransformToPoint(VTKcoords, GetMatrixFromTransform("acpc_2_leftSTNbox"))
    if (atlas == "box"  & sideofthebrain == "right") VTKcoords = applyTransformToPoint(VTKcoords, GetMatrixFromTransform("acpc_2_rightSTNbox"))
    VTKpoint_list[[i]] = VTKcoords
    }

    df_points = as.data.frame(do.call(rbind, VTKpoint_list))
    colnames(df_points) = c("ML","AP","DV")
    df_points %<>% mutate(ML = as.numeric(ML), AP = as.numeric(AP), DV = as.numeric(DV))

    if (object == "facet") {
    df_facet = data.frame()
    for (sl in slicinglevel) {
        df_slice = subset(df_points, abs(df_points$AP - sl) < slice_tolerance)
        hpts = chull(df_slice$ML, df_slice$DV)
        hpts = c(hpts, hpts[1])
        df_slice = df_slice[hpts,] %>% mutate(AP = sl)
        df_facet = rbind(df_facet, df_slice)
    }
    p = p + geom_polygon(data=df_facet, aes(fill = NULL, color = territory), fill=NA, color=colorlocal)
    } else {
    df_slice = subset(df_points, abs(df_points$AP - slicinglevel) < slice_tolerance)
    hpts = chull(df_slice$ML, df_slice$DV)
    hpts = c(hpts, hpts[1])
    p = p + geom_polygon(data=df_slice[hpts,], aes(fill = NULL, color = territory), fill=NA, color=colorlocal)
    }

}

return(p)
}



