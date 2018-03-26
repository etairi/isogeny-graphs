packages = c("base", "ggplot2", "rstudioapi")
for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
  }
  library(p, character.only = TRUE)
}

# For a full list of colors support by R refer to:
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf
plot_color  <- "deepskyblue3"
plot_width  <- 11.69
plot_height <-  8.27

data_dir <- "/output/"
plot_dir <- "/plots/"
files <- c("simulation_j(E_A).csv",
           "simulation_j(E_B).csv",
           "simulation_j(E_AB).csv",
           "simulation_j(E_BA).csv")

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

plot_data <- function(x, y, min, max, color = plot_color) {
  p <- ggplot(data.frame(x, y)) +
    geom_bar(aes(x, y), stat = "identity", position = "dodge", fill = color) + ylim(min, max) + 
    theme_light() + theme(text = element_text(size = 25), axis.title.x = element_blank(), axis.title.y = element_blank())
  
  return(p)
}

export_plot <- function(filename, plot) {
  pdf(filename, width = plot_width, height = plot_height)
  print(plot)
  dev.off()
}

read_data <- function(filename, headers) {
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

main <- function() {
  dir.create(file.path(dirname(get_directory()), plot_dir), showWarnings = FALSE)
  headers <- c("expected", "simulation")

  for (f in files) {  
    data <- read_data(f, headers)
    stopifnot(length(data) == 4)

    p <- plot_data(as.numeric(unlist(data[1])),
                   as.numeric(unlist(data[2])),
                   as.numeric(unlist(data[3])),
                   as.numeric(unlist(data[4])))

    filename <- sub(".csv", ".pdf", f)
    filepath <- file.path(dirname(get_directory()), plot_dir, filename)
    export_plot(filepath, p)
  }
}

if (!interactive()) {
  main()
} else if (identical(environment(), globalenv())) {
  quit(status = main())
}
