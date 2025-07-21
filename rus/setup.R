
# Description: This script reads in the data from the Rusundersøkelsen 2024 dataset.
# The codes here is based on Stata file "til tall om alkohol.do"
pkgs <- c("data.table", "haven", "skimr", "codebook", "tcltk")
invisible(lapply(pkgs, function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
    library(pkg, character.only = TRUE)
}))

Sys.setlocale("LC_ALL", "nb-NO.UTF-8")

setwd("O:\\Prosjekt\\Rusdata")
DT <- haven::read_dta(file.path("Rusundersøkelsen", "Rusus 2024", "nytt forsøk februar 25 rus24.dta"))
dt <- as.data.table(DT)

