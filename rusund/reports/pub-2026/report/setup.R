
workdir <- file.path(getwd(), "..")
curdir <- normalizePath(workdir)
## pth2025 <- file.path(here::here("rusund/reports/pub-2025"))

source("https://raw.githubusercontent.com/folkehelsestats/toa/refs/heads/main/rusund/setup.R")

funs <- c("hdir-color.R",
          "fun-percent.R",
          "fun-age.R",
          "fun-graph.R",
          "fun-bar.R",
          "fun-percent-weighted.R",
          "fun-units.R",
          "fun-simple-graph.R",
          "fun-ci-graph.R")

fun_url <- "https://raw.githubusercontent.com/folkehelsestats/toa/refs/heads/main/rusund/functions"

invisible(
  mapply(function(x) source(file.path(fun_url, x), echo = FALSE), funs)
)

dataPath <- "O:\\Prosjekt\\Rusdata"
source(file.path(dataPath, "folder-path.R"))


## Data 2024
## --------------------------------------------------
DT <- readRDS(file.path(Rususdata, "Rusus_2025", "rusus2025_20251126.rds"))
dt <- as.data.table(DT)

## Data 2012 - 2025
## --------------------------------------------------
## ddt <- readRDS(file.path(Rususdata, "Rusus_2012_2023/arkiv/data_2012_2024.rds")) #this need clean-history.R
ddt <- readRDS(file.path(Rususdata, "rusus_2012_2025.rds")) # has been cleaned with clean-history.R
# Normaliserer vekt for 2005 til 1
## ddt[year == 2005, vekt := vekt/mean(vekt, na.rm=TRUE)]



## ## Gir norsk tekster i highchart
## options(highcharter.lang = list(
##   contextButtonTitle = "Eksport figur",
##   downloadPNG = "Last ned PNG",
##   downloadJPEG = "Last ned JPEG",
##   downloadPDF = "Last ned PDF",
##   downloadSVG = "Last ned SVG",
##   downloadCSV = "Last ned CSV",
##   downloadXLS = "Last ned Excel-fil"
## ))
