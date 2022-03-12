## -----------------------------------------------------------------------------
example <- ggplot(complete_table, aes(Mig_agenda, age_inclusion)) +
  geom_boxplot()+
  theme_ipsum_rc()


## -----------------------------------------------------------------------------
ragg::agg_png(paste0(output_dir,"/figs/example_plot.png"), 
              width = 14, height = 12, units = "in", 
              res = 300)
plot(example)
invisible(dev.off())
knitr::include_graphics(paste0(output_dir,"/figs/example_plot.png"))

