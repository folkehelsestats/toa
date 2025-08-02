## var - variable for frequency
## dt - dataset to use
ttbl <- function(var, d = dt, sum = TRUE, codebook = NULL, digits = 1){
  var <- substitute(var)
  var <- as.character(var)

  dt <- data.table::copy(d)
  x <- dt[, .N, by = var, env = list(var = var)]
  x[, sum := sum(N, na.rm = T)][, prosent := round(100 * N/sum, digits = digits), by = var, env = list(var = var)][, sum := NULL]

  data.table::setkeyv(x, var)

  ss <- dt[, .(mean = mean(var, na.rm = TRUE), median = median(var, na.rm = TRUE)), env = list(var = var)][]
  tot <- x[, sum(N, na.rm = T)]
  totn <- x[!is.na(var), sum(N, na.rm = T), env = list(var = var)]

  cat("Total all   ", tot, "\n")
  cat("Total !is.na", totn, "\n")
  print(ss, "\n")
  x[]

}

## Just like ttbl but with more info
get_freq_cat <- function(var, d = dt){
  bb <- DescTools::Desc(as.factor(d[[var]]))
  ## Extract the freq data frame
  x <- bb[[1]]$freq
  ## Convert level to numeric, then sort
  freqSorted <- x[order(as.numeric(as.character(x$level))), ]
  freqTbl <- data.table(var = as.numeric(bb[[1]]$freq$level),
                        freq = bb[[1]]$freq$freq,
                        prosent = round(bb[[1]]$freq$perc*100, 1))
  data.table::setnames(freqTbl, "var", var)
}

## Percentage with 2 categories
## proscat("Kjonn", "alko6")
## total - Add total if TRUE
proscat <- function(x, y, d = dt, na.rm = TRUE, digits = 1, total = TRUE){

  elm <- any(class(d[[x]]) %in% c("numeric", "integer"))
  if (isFALSE(elm))
    stop(x, " is type: ", paste(class(d[[x]]), collapse = " "))

  kb <- d[, .N, keyby = c(x, y)]

  if (isTRUE(na.rm))
    kb <- kb[!is.na(y), env = list(y = y)]

  kbsum <- kb[, .(sum=sum(N)), by = c(x)]
  kb[kbsum, on = x, sum := sum]

  ## Total
  val <- length(kbsum[[x]])+1 #need to know the max number of categories

  velm <- is.element(val, kbsum[[x]])
  if (isTRUE(velm))
    stop(val, " can't be a total because it is part of the values in ", x)

  if (total){
    tot <- kb[, .(N=sum(N, na.rm = TRUE)), by = c(y)]
    tot[, (x) := val]
    tot[, sum := sum(N, na.rm = TRUE)]

    DT <- data.table::rbindlist(list(kb, tot), use.names = TRUE)
  } else {
    DT <- kb
  }

  DT[, pros := round(N/sum*100, digits = digits)]
  return(DT[])
}


## Replace values to 0
replace_with_zero <- function(cols, values = c(99999, 99998), d = dt){
  d[, (cols) := lapply(.SD, function(x) {
    if (is.numeric(x)) {
      # sometime it's decimal numbers
      x[as.integer(x) %in% values & !is.na(x)] <- 0
    } else if (is.character(x)) {
      x[x %chin% as.character(values)] <- NA_character_
    }
    x
  }), .SDcols = cols]
}

## dt[, (cols) := lapply(.SD, replace_with_zero_vec, values = c(99, 98)), .SDcols = cols]
replace_with_zero_vec <- function(x, value = 99) {
  if (is.numeric(x)) {
    x[as.integer(x) %in% value & !is.na(x)] <- 0
  } else if (is.character(x)) {
    x[x %in% as.character(value)] <- NA_character_
  }
  x
}

## Example
## # Define age group breaks and labels
## age_breaks <- c(0, 18, 30, 50, 100)
## age_labels <- c("0-18", "19-30", "31-50", "51+")

age_cat <- function(dt, var, breaks, labels = NULL, new_var_name = NULL, right = TRUE, include.lowest = TRUE) {
  if (!is.data.table(dt)) {
    stop("Input must be a data.table.")
  }

  # Default name for new variable
  if (is.null(new_var_name)) {
    new_var_name <- paste0(var, "_group")
  }

  # Create categorized variable
  dt[, (new_var_name) := cut(get(var),
                             breaks = breaks,
                             labels = labels,
                             right = right,
                             include.lowest = include.lowest)]

  return(dt)
}


## Highchart with categories and total
## d - Dataset
## yint - interval of y-axis
## n - Count to show in tooltip if needed
## type - Include line graph ie. type = "line"
make_hist <- function(d, x, y, group, n,
                      title,
                      subtitle = NULL,
                      yint = 10,
                      flip = FALSE,
                      type = "column") {
  x <- as.character(substitute(x))
  y <- as.character(substitute(y))
  group <- as.character(substitute(group))
  n <- as.character(substitute(n))
  gp <- length(unique(d[[group]]))

  if (is.null(subtitle))
    subtitle <- "Kilde: Rusundersøkelse 2024"

  if (gp == 2){
    hdir <- c("rgba(49,101,117,1)", "rgba(138,41,77,1)")
  } else if (gp <= 7) {
    # Extended custom palette with good contrast for up to 7 groups
    custom_colors <- c(
      "#2E7D7B",  # Dark teal (original)
      "#8A2952",  # Purple (original)
      "#5CB3CC",  # Light blue (original)
      "#CC8A33",  # Orange (original)
      "#4A7C59",  # Forest green (new - similar to teal but distinguishable)
      "#B8336A",  # Rose/pink (new - similar to purple but lighter)
      "#7A4F01"   # Dark brown (new - earthy tone that complements orange)
    )
    hdir <- custom_colors[1:gp]
  } else {
    hdir <- viridis(gp, option = "D")  # Fallback to viridis for many groups
  }

  hchart(d, chart_type, hcaes(x = !!x, y = !!y, group = !!group)) |>
    hc_colors(hdir) |>
    hc_chart(inverted = flip) |>  # Add this line to control chart orientation
    hc_yAxis(
      title = list(text = " "),
      labels = list(format = "{value}%"),
      tickInterval = yint
    ) |>
    hc_xAxis(
      title = list(text = " "),
      tickInterval = 1,
      labels = list(
        ## rotation = -45,  # Rotate labels 45 degrees
        step = 1 #step 2 show every other level etc
      )) |>
    hc_title(text = title) |>
    hc_subtitle(text = subtitle) |>
    hc_credits(
      enabled = TRUE,
      text = "Helsedirektoratet",
      href = "https://www.helsedirektoratet.no/"
    ) |>
    ## hc_tooltip(sort = TRUE, table = TRUE) |>
    hc_tooltip(
      useHTML = TRUE,
      shared = TRUE,
      headerFormat = '<span style="font-size: 14px; font-weight: bold;">{point.key}</span><br/>',
      pointFormat =
                      paste0(
                        '<span style="color:{series.color}">\u25CF</span> ',
                        '<span style="color:black">{series.name}</span>: ',
                        '<b>{point.', n, '} ({point.y}%)</b><br/>'
                      )
    ) |>
  hc_caption(text = "Tall om alkohol") |>
    hc_legend(
      align = "left",
      verticalAlign = "bottom",
      layout = "horizontal",
      x = 50,
      y = 0
    ) |>
    hc_plotOptions(
      column = list(
        states = list(
          hover = list(brightness = 0.2)
        ),
        point = list(
          events = list(
            mouseOver = JS("function() {
              var chart = this.series.chart;
              var categoryIndex = this.x;
              chart.xAxis[0].removePlotBand('hover-band');
              chart.xAxis[0].addPlotBand({
                id: 'hover-band',
                from: categoryIndex - 0.4,
                to: categoryIndex + 0.4,
                color: 'rgba(204, 211, 255, 0.25)',
                zIndex: 0
              });
            }"),
            mouseOut = JS("function() {
              var chart = this.series.chart;
              chart.xAxis[0].removePlotBand('hover-band');
            }")
          )
        )
      ),
      line = list(
        marker = list(
          enabled = TRUE,
          radius = 4,
          symbol = "circle"
        ),
        lineWidth = 2,
        states = list(
          hover = list(
            lineWidth = 3
          )
        ),
        point = list(
          events = list(
            mouseOver = JS("function() {
              var chart = this.series.chart;
              var categoryIndex = this.x;
              chart.xAxis[0].removePlotBand('hover-band');
              chart.xAxis[0].addPlotBand({
                id: 'hover-band',
                from: categoryIndex - 0.4,
                to: categoryIndex + 0.4,
                color: 'rgba(204, 211, 255, 0.25)',
                zIndex: 0
              });
            }"),
            mouseOut = JS("function() {
              var chart = this.series.chart;
              chart.xAxis[0].removePlotBand('hover-band');
            }")
          )
        )
      )
    ) |>
    hc_exporting(
      enabled = TRUE,
      buttons = list(
        contextButton = list(
          menuItems = c(
           "downloadPNG", "downloadJPEG", "downloadPDF", "downloadSVG",
            "downloadCSV", "downloadXLS"
          )
        )
      )
      ## Ensure export use local browser
      ## useLocalStorage = TRUE,
      ## fallbackToExportServer = FALSE
    )
}

## If need to change font size for x-axis
## hc_xAxis(
##   title = list(text = " "),
##   tickInterval = 1,
##   labels = list(
##     step = 1,
##     style = list(fontSize = "10px")
##   )
## )


## Split results to All, men and women
## select - value for y to be selected
split_gender <- function(d, x, y, select, total = FALSE){

  all <- proscat(x = x, y = y, d=d, total = total)
  men <- proscat(x = x, y = y, d=d[kjonn == 1], total = total)
  wom <- proscat(x = x, y = y, d=d[kjonn == 2], total = total)

  ## For table
  all[, pop := "Alle"]
  men[, pop := "Menn"]
  wom[, pop := "Kvinner"]

  ## For figure
  allx <- all[get(y) == select][, pop := "Alle"]
  menx <- men[get(y) == select][, pop := "Menn"]
  womx <- wom[get(y) == select][, pop := "Kvinner"]

  dt <- data.table::rbindlist(list(all, men, wom))
  dtx <- data.table::rbindlist(list(allx, menx, womx))

  return(list(d1 = dt, d2 = dtx))
}
