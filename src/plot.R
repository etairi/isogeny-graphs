packages = c("base", "ggplot2", "ggpubr", "rstudioapi", "scales", "tidyverse")
for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
  }
  library(p, character.only = TRUE)
}

# For a full list of colors support by R refer to:
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf
plot_colors <- c("firebrick2", "deepskyblue3")
plot_labels <- c("Expected", "Simulated")
plot_width  <- 11.69
plot_height <- c(8.27, 12.27)
plot_dim    <- c(3, 3)

data_dir <- "/output/"
plot_dir <- "/plots/"
csv_headers <- c("expected", "simulation")
data_files  <- c("simulation_j(E_A).csv",
                "simulation_j(E_B).csv")
plot_file   <- "simulation_j(E_AB).pdf"


get_directory <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file <- "--file="
  rstudio <- "RStudio"
  
  match <- grep(rstudio, args)
  if (length(match) > 0) {
    return(dirname(rstudioapi::getSourceEditorContext()$path))
  } else {
    match <- grep(file, args)
    if (length(match) > 0) {
      return(dirname(normalizePath(sub(file, "", args[match]))))
    } else {
      return(dirname(normalizePath(sys.frames()[[1]]$ofile)))
    }
  }
}

plot_bar <- function(x, y, min, max, color = plot_colors[2]) {
  p <- ggplot(data.frame(as.integer(x), y)) +
    geom_bar(aes(x, y), stat = "identity", position = "dodge", fill = color) + ylim(min, max) + 
    theme_light() + theme(text = element_text(size = 25), axis.title.x = element_blank(), axis.title.y = element_blank())
  
  return(p)
}

plot_histo <- function(data, bins, colors = plot_colors, labels = plot_labels) {
  p <- ggplot(data, aes(value, fill = var)) + 
    geom_histogram(position = "dodge", bins = bins) + 
    scale_fill_manual(labels = labels, values = colors) + theme_light() + 
    scale_x_continuous(breaks = pretty_breaks()) + 
    scale_y_continuous(breaks = pretty_breaks(), labels = comma) + 
    theme(legend.position = "none", axis.title.x = element_blank(), axis.title.y = element_blank())
  
  return(p)
}

export_plot <- function(filename, plot, simul) {
  pdf(filename, width = plot_width, height = if (simul == 1) plot_height[1] else plot_height[2])
  print(plot)
  dev.off()
}

read_csv <- function(filename, headers) {
  if (length(headers) < 2) {
    stop(cat("Argument headers (= ", length(headers), ") must have length at least 2.\n", sep = ""))
  }
  
  filepath <- file.path(dirname(get_directory()), data_dir, filename)
  if (!file.exists(filepath)) {
    stop(cat("File (= ", filename, ") does not exist.\n", sep = ""))
  }
  
  data <- read.csv(file = filepath, header = TRUE, sep = ",")
  values <- data[, headers]
  y <- values[[headers[1]]] - values[[headers[2]]]
  x <- seq_along(y)
  min <- floor(min(y, na.rm = TRUE))
  max <- ceiling(max(y, na.rm = TRUE))
  
  return(list(x, y, min, max))
}

read_dat <- function(filenames) {
  if (length(filenames) < 2) {
    stop(cat("Argument filenames (= ", length(filenames), ") must have length at least 2.\n", sep = ""))
  }

  simul_filepath <- file.path(dirname(get_directory()), data_dir, filenames[1])
  if (!file.exists(simul_filepath)) {
    stop(cat("File (= ", filenames[1], ") does not exist.\n", sep = ""))
  }
  simul <- read.csv(simul_filepath, header = FALSE)

  uniform_filepath <- file.path(dirname(get_directory()), data_dir, filenames[2])
  if (!file.exists(uniform_filepath)) {
    stop(cat("File (= ", filenames[2], ") does not exist.\n", sep = ""))
  }
  uniform <- read.csv(uniform_filepath, header = FALSE)
  
  data <- data.frame(uniform, simul) %>%
    gather(var, value)
  
  return(data)
}

main <- function() {
  dir.create(file.path(dirname(get_directory()), plot_dir), showWarnings = FALSE)
  files <- list.files(file.path(dirname(get_directory()), data_dir))
  files <- files[grepl("*.dat$", files)]
  file_groups <- split(files, sub("-[a-z].*", "", files))
  plots <- list()
  simul <- NULL
  i <- 1

  for (df in data_files) {
    simul <- 1
    data <- read_csv(df, csv_headers)
    stopifnot(length(data) == 4)

    p <- plot_bar(as.numeric(unlist(data[1])),
                  as.numeric(unlist(data[2])),
                  as.numeric(unlist(data[3])),
                  as.numeric(unlist(data[4])))

    filename <- sub(".csv", ".pdf", df)
    filepath <- file.path(dirname(get_directory()), plot_dir, filename)
    export_plot(filepath, p, simul)
  }

  for (fg in file_groups) {
    local({
      stopifnot(length(fg) == 2)
      
      data <- read_dat(fg)
      bins = max(data$value, na.rm = TRUE)
      
      p <- plot_histo(data, bins)
      plots[[i]] <<- p
    })
    i <- i + 1
  }

  simul <- 2
  plot <- ggarrange(plotlist = plots, ncol = plot_dim[1], nrow = plot_dim[2], common.legend = TRUE, legend = "bottom")
  filepath <- file.path(dirname(get_directory()), plot_dir, plot_file)
  export_plot(filepath, plot, simul)
}

if (!interactive()) {
  main()
} else if (identical(environment(), globalenv())) {
  quit(status = main())
}
