
pth <- "~/Git-hdir/toa/rusund"
source(file.path(pth, "rus-draft.R"))

dt[, .N, keyby = alkodager]
ttbl("alkodager")

# Run Desc and store the result
(bb <- Desc(as.factor(dt$alkodager)))
# Extract the freq data frame
freqDF <- bb[[1]]$freq
# Convert level to numeric, then sort
(freqSorted <- freqDF[order(as.numeric(as.character(freqDF$level))), ])
freqTbl <- data.table(dag = as.numeric(bb[[1]]$freq$level),
                      freq = bb[[1]]$freq$freq,
                      prosent = round(bb[[1]]$freq$perc*100, 1))
freqTbl <- freqTbl[order(dag)]


get_freq_cat <- function(var, d = dt){
  bb <- DescTools::Desc(as.factor(d[[var]]))
  ## Extract the freq data frame
  x <- bb[[1]]$freq
  ## Convert level to numeric, then sort
  freqSorted <- x[order(as.numeric(as.character(x$level))), ]
  freqTbl <- data.table(dag = as.numeric(bb[[1]]$freq$level),
                        freq = bb[[1]]$freq$freq,
                        prosent = round(bb[[1]]$freq$perc*100, 1))
}

dd <- get_freq_cat("alkodager")
dd <- dd[order(dag)]


# Create the highcharter plot
# Convert dag to character for proper categorical handling
freqTbl[, dag_cat := as.character(dag)]

# Method 1: Using hchart() - Simplest approach for categorical data
hc_plot1 <- freqTbl %>%
  hchart("column", hcaes(x = dag_cat, y = freq, prosent = prosent)) %>%
  hc_title(text = "Frequency Distribution by Dag") %>%
  hc_xAxis(
    title = list(text = "Antall dager"),
    type = "category"  # Explicitly set as categorical
  ) %>%
  hc_yAxis(title = list(text = "Frequency")) %>%
  hc_tooltip(
    pointFormat = "<b>Frequency:</b> {point.y}<br><b>Percent:</b> {point.prosent}%",
    headerFormat = "<span style='font-size:12px'>Antall dager: {point.key}</span><br/>"
  ) %>%
  hc_colors("#3498db")

hc_plot1


# Method 2: Manual approach with categorical x-axis
hc_plot2 <- highchart() %>%
  hc_add_series(
    data = freqTbl,
    type = "column",
    hcaes(x = dag_cat, y = freq, prosent = prosent),
    name = "Frequency"
  ) %>%
  hc_title(text = "Frequency Distribution by Dag") %>%
  hc_xAxis(
    title = list(text = "Antall dager"),
    categories = freqTbl$dag_cat,  # Set categories explicitly
    type = "category"
  ) %>%
  hc_yAxis(title = list(text = "Frequency")) %>%
  hc_tooltip(
    pointFormat = "<b>Frequency:</b> {point.y}<br><b>Percent:</b> {point.prosent}%",
    headerFormat = "<span style='font-size:12px'>Antall dager: {point.key}</span><br/>"
  ) %>%
  hc_colors("#3498db")

hc_plot2

# Method 3: Add tooltip to dataset
freqTbl[, tooltip := paste0("Prosent: ", prosent, "%")]

hc_plot3 <- highchart() %>%
  hc_chart(type = "column") %>%
  hc_title(text = "Antall dager har drukket alkohol") %>%
  hc_xAxis(categories = freqTbl$dag, title = list(text = "Dag")) %>%
  hc_yAxis(title = list(text = "Frequency")) %>%
  hc_tooltip(useHTML = TRUE, pointFormat = "{point.tooltip}") %>%
  hc_add_series(
    name = "Frequency",
    data = purrr::map2(freqTbl$freq, freqTbl$tooltip, ~ list(y = .x, tooltip = .y))
  )

hc_plot3

# Explanation
# - hc_xAxis(categories = freqTbl$dag) sets the x-axis labels.
# - purrr::map2() is used to pair freq and tooltip into a list of points.

x <- list(1, 2, 3)
y <- list(10, 20, 30)
purrr::map2(x, y, ~ list(b = .x, tooltip = .y))

## Per kjønn
dt[, alko6 := fifelse(totalenheter > 5, 1, 0)]
alkkb <- dt[, .N, keyby = .(Kjonn, alko6)]

alkkb[!is.na(alko6)]
kbsum <- alkkb[, .(sum=sum(N)), by = Kjonn]
alkkb[kbsum, on = "Kjonn", sum := sum]

alksum <- alkkb[, .(N=sum(N)), by = alko6]
alksum[, Kjonn := 3]
alksum[, sum := sum(N)]



alkkb[, pro := round(N/sum*100, digits = 1)]


proscat <- function(x, y, d = dt, na.rm = TRUE, digits = 1){

  elm <- is.element("numeric", class(d[[x]]))
  if (isFALSE(elm))
    stop(x, " is type: ", paste(class(d[[x]]), collapse = " "))

  kb <- d[, .N, keyby = c(x, y)]

  if (isTRUE(na.rm))
    kb <- kb[!is.na(y), env = list(y = y)]

  kbsum <- kb[, .(sum=sum(N)), by = c(x)]
  kb[kbsum, on = x, sum := sum]

  ## Total
  tot <- kb[, .(N=sum(N, na.rm = TRUE)), by = c(y)]
  tot[, (x) := 3]
  tot[, sum := sum(N, na.rm = TRUE)]

  DT <- data.table::rbindlist(list(kb, tot), use.names = TRUE)

  DT[, pros := round(N/sum*100, digits = digits)]
  return(DT[])
}
