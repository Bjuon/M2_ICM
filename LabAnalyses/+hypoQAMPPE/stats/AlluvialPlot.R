# Code concu comme une fonction a executer depuis Matlab

DF = vroom::vroom('C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/tempMatlab2R.csv', show_col_types = FALSE)
Plotname = DF$filename[1]
DF = DF[, -which(names(DF) == "filename")]
suppressPackageStartupMessages(library(dplyr))
DF = DF %>% mutate_all(as.character)

Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")

p2 = parcats::parcats(easyalluvial::alluvial_wide(data = DF, max_variables = 8, fill_by = 'first_variable'), marginal_histograms = TRUE, data_input = DF)
htmlwidgets::saveWidget(widget = p2, file = paste0(Plotname,'WITHPAT.html'), selfcontained = TRUE)

DF = DF[, -which(names(DF) == "Patient")]

p = easyalluvial::alluvial_wide(data = DF, max_variables = 8, fill_by = 'first_variable') %>% easyalluvial::add_marginal_histograms(DF)
ggplot2::ggsave(paste0(Plotname,'.png'), plot = p, width = 100, height = 122, units = 'cm', dpi = 600)
ggplot2::ggsave(paste0(Plotname,'.svg'), plot = p)

p3 = parcats::parcats(easyalluvial::alluvial_wide(data = DF, max_variables = 8, fill_by = 'first_variable'), marginal_histograms = TRUE, data_input = DF)
htmlwidgets::saveWidget(widget = p3, file = paste0(Plotname,'.html'), selfcontained = TRUE)


cat("Done \n")

q(save = "no")




