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
proscat <- function(x, y, d = dt, na.rm = TRUE, digits = 1){
  kb <- d[, .N, keyby = c(x, y)]

  if (isTRUE(na.rm))
    kb <- kb[!is.na(y), env = list(y = y)]

  kbsum <- kb[, .(sum=sum(N)), by = c(x)]

  kb[kbsum, on = x, sum := sum]
  kb[, pros := round(N/sum*100, digits = digits)]
  return(kb[])
}
                                        # Replace values to 0
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
