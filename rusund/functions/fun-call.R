
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
library("here")

funs <- c("fun-percent.R", "fun-age.R", "fun-graph.R", "fun-bar.R")
invisible(
  mapply(function(x) source(file.path(here::here(), "rusund", "functions", x), echo = FALSE), funs)
)
