#' Calculate Cross-Tabulation with Counts and Percentages
#'
#' This function creates a cross-tabulation table with counts and percentages
#' for two or three grouping variables. It's designed to work with data.table
#' objects and provides flexible options for handling missing values and totals.
#'
#' @param x Character string. Name of the primary grouping variable (must be numeric/integer).
#'   This variable is used as the base for percentage calculations.
#' @param y Character string. Name of the secondary grouping variable.
#' @param z Character string, optional. Name of the tertiary grouping variable for
#'   three-way cross-tabulation. Default is NULL.
#' @param d data.table. The input data.table object. Default is 'dt'.
#' @param na.rm Logical. If TRUE, removes rows with NA values in grouping variables y (and z if provided).
#'   Default is TRUE.
#' @param digits Integer. Number of decimal places for percentage calculations. Default is 1.
#' @param total Logical. If TRUE, adds total rows to the output. Default is TRUE.
#'
#' @return A data.table with the following columns:
#' \itemize{
#'   \item The grouping variables (x, y, and z if provided)
#'   \item count: Number of observations in each group
#'   \item sum: Total count for each level of x (and z if three groups)
#'   \item percentage: Percentage of each group relative to the sum
#' }
#'
#' @details
#' The function calculates percentages within each level of the primary grouping variable (x).
#' When three groups are specified, percentages are calculated within each combination of x and z.
#'
#' For the total rows, the function automatically determines a safe value for the primary
#' grouping variable that doesn't conflict with existing values.
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' library(data.table)
#' dt <- data.table(
#'   group1 = sample(1:3, 100, replace = TRUE),
#'   group2 = sample(c("A", "B", "C"), 100, replace = TRUE),
#'   group3 = sample(c("X", "Y"), 100, replace = TRUE)
#' )
#'
#' # Two-group cross-tabulation
#' result_2groups <- proscat("group1", "group2", d = dt)
#'
#' # Three-group cross-tabulation
#' result_3groups <- proscat("group1", "group2", "group3", d = dt)
#'
#' # Without totals
#' result_no_total <- proscat("group1", "group2", total = FALSE, d = dt)
#' }
#'
#' @export
#' @import data.table
proscat <- function(x, y, z = NULL, d = dt, na.rm = TRUE, digits = 1, total = TRUE) {
  # Input validation
  if (!is.data.table(d)) {
    stop("Data must be a data.table")
  }

  # Check if columns exist
  cols_to_check <- c(x, y)
  if (!is.null(z)) cols_to_check <- c(cols_to_check, z)

  missing_cols <- setdiff(cols_to_check, names(d))
  if (length(missing_cols) > 0) {
    stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "))
  }

  # Check if x is numeric/integer (the grouping variable for percentages)
  if (!any(class(d[[x]]) %in% c("numeric", "integer"))) {
    stop(x, " must be numeric or integer, but is: ", paste(class(d[[x]]), collapse = " "))
  }

  # Create grouping variables list
  group_vars <- if (is.null(z)) c(x, y) else c(x, y, z)

  # Get counts by groups
  kb <- d[, .N, keyby = group_vars]

  # Remove NA values if requested
  if (na.rm) {
    na_condition <- paste0("!is.na(", y, ")")
    if (!is.null(z)) {
      na_condition <- paste0(na_condition, " & !is.na(", z, ")")
    }
    kb <- kb[eval(parse(text = na_condition))]
  }

  # Calculate sums by x (and z if present)
  sum_by_vars <- if (is.null(z)) x else c(x, z)
  kbsum <- kb[, .(sum = sum(N)), by = sum_by_vars]

  # Join sums back
  kb[kbsum, on = sum_by_vars, sum := sum]

  # Handle totals
  if (total) {
    # Find safe total value that doesn't conflict with existing values
    max_val <- max(d[[x]], na.rm = TRUE)
    total_val <- max_val + 1

    # Check if total value conflicts
    while (total_val %in% d[[x]]) {
      total_val <- total_val + 1
    }

    # Create total rows
    if (is.null(z)) {
      # Two-group case
      tot <- kb[, .(N = sum(N, na.rm = TRUE)), by = y]
      tot[, (x) := total_val]
      tot[, sum := sum(N, na.rm = TRUE)]
    } else {
      # Three-group case
      tot <- kb[, .(N = sum(N, na.rm = TRUE)), by = c(y, z)]
      tot[, (x) := total_val]
      # Calculate sum for each z group
      tot_sum <- tot[, .(sum = sum(N, na.rm = TRUE)), by = z]
      tot[tot_sum, on = "z", sum := sum]
    }

    DT <- rbindlist(list(kb, tot), use.names = TRUE)
  } else {
    DT <- kb
  }

  # Calculate percentages
  DT[, percentage := round(N/sum * 100, digits = digits)]

  # Rename columns for clarity
  setnames(DT, "N", "count")

  return(DT[])
}

# Example usage and testing
if (FALSE) {
  # Create sample data
  set.seed(123)
  dt <- data.table(
    group1 = sample(1:3, 100, replace = TRUE),
    group2 = sample(c("A", "B", "C"), 100, replace = TRUE),
    group3 = sample(c("X", "Y"), 100, replace = TRUE)
  )

  # Two-group analysis
  result_2groups <- proscat("group1", "group2", d = dt)
  print(result_2groups)

  # Three-group analysis
  result_3groups <- proscat("group1", "group2", "group3", d = dt)
  print(result_3groups)
}

#' Calculate Cross-Tabulation with Flexible Total Handling
#'
#' An enhanced version of proscat() that provides more flexible handling of total rows,
#' including support for character grouping variables and custom total labels.
#'
#' @param x Character string. Name of the primary grouping variable. Can be numeric, integer, or character.
#' @param y Character string. Name of the secondary grouping variable.
#' @param z Character string, optional. Name of the tertiary grouping variable. Default is NULL.
#' @param d data.table. The input data.table object. Default is 'dt'.
#' @param na.rm Logical. If TRUE, removes rows with NA values in grouping variables. Default is TRUE.
#' @param digits Integer. Number of decimal places for percentage calculations. Default is 1.
#' @param total Logical. If TRUE, adds total rows to the output. Default is TRUE.
#' @param total_label Character or numeric. Label to use for total rows. If x is numeric and
#'   total_label is character, will use max(x) + 1. Default is "Total".
#'
#' @return A data.table with cross-tabulation results including counts and percentages.
#'
#' @details
#' This version extends the basic proscat() function by allowing:
#' \itemize{
#'   \item Character primary grouping variables
#'   \item Custom labels for total rows
#'   \item More flexible total value assignment
#' }
#'
#' @examples
#' \dontrun{
#' # With character grouping variable
#' dt_char <- data.table(
#'   group1 = sample(c("Low", "Medium", "High"), 100, replace = TRUE),
#'   group2 = sample(c("A", "B"), 100, replace = TRUE)
#' )
#' result <- proscat_v2("group1", "group2", d = dt_char, total_label = "All")
#' }
#'
#' @seealso \code{\link{proscat}}
#' @export
#' @import data.table
proscat_v2 <- function(x, y, z = NULL, d = dt, na.rm = TRUE, digits = 1,
                       total = TRUE, total_label = "Total") {

  # Input validation (same as above)
  if (!is.data.table(d)) {
    stop("Data must be a data.table")
  }

  cols_to_check <- c(x, y)
  if (!is.null(z)) cols_to_check <- c(cols_to_check, z)

  missing_cols <- setdiff(cols_to_check, names(d))
  if (length(missing_cols) > 0) {
    stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "))
  }

  # More flexible handling - allow character x if total_label is used
  x_is_numeric <- any(class(d[[x]]) %in% c("numeric", "integer"))

  if (!x_is_numeric && total && is.numeric(total_label)) {
    stop("Cannot add numeric total_label to non-numeric column ", x)
  }

  # Create grouping variables
  group_vars <- if (is.null(z)) c(x, y) else c(x, y, z)

  # Get counts
  kb <- d[, .N, keyby = group_vars]

  # Handle NA removal
  if (na.rm) {
    if (is.null(z)) {
      kb <- kb[!is.na(get(y))]
    } else {
      kb <- kb[!is.na(get(y)) & !is.na(get(z))]
    }
  }

  # Calculate sums
  sum_by_vars <- if (is.null(z)) x else c(x, z)
  kbsum <- kb[, .(sum = sum(N)), by = sum_by_vars]
  kb[kbsum, on = sum_by_vars, sum := sum]

  # Add totals
  if (total) {
    if (x_is_numeric) {
      total_val <- if (is.character(total_label)) {
        max(d[[x]], na.rm = TRUE) + 1
      } else {
        total_label
      }

      while (total_val %in% d[[x]]) {
        total_val <- total_val + 1
      }
    } else {
      # Character x column
      total_val <- total_label
    }

    if (is.null(z)) {
      tot <- kb[, .(N = sum(N, na.rm = TRUE)), by = y]
      tot[, (x) := total_val]
      tot[, sum := sum(N, na.rm = TRUE)]
    } else {
      tot <- kb[, .(N = sum(N, na.rm = TRUE)), by = c(y, z)]
      tot[, (x) := total_val]
      tot_sum <- tot[, .(sum = sum(N, na.rm = TRUE)), by = z]
      tot[tot_sum, on = "z", sum := sum]
    }

    DT <- rbindlist(list(kb, tot), use.names = TRUE)
  } else {
    DT <- kb
  }

  # Calculate percentages
  DT[, percentage := round(N/sum * 100, digits = digits)]
  setnames(DT, "N", "count")

  return(DT[])
}


## Percentage with 2 categories
## proscat("Kjonn", "alko6")
## total - Add total if TRUE
proscat_old <- function(x, y, d = dt, na.rm = TRUE, digits = 1, total = TRUE){

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
