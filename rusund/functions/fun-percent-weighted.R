#' Calculate Weighted Cross-Tabulation with Counts and Percentages
#'
#' This function creates a cross-tabulation table with weighted counts and percentages
#' for two or three grouping variables. It extends the proscat function to handle
#' weighted data using a specified weight column.
#'
#' @param x Character string. Name of the primary grouping variable (must be numeric/integer).
#'   This variable is used as the base for percentage calculations.
#' @param y Character string. Name of the secondary grouping variable.
#' @param z Character string, optional. Name of the tertiary grouping variable for
#'   three-way cross-tabulation. Default is NULL.
#' @param weight Character string, optional. Name of the weight column. If NULL,
#'   performs unweighted analysis (equivalent to proscat). Default is NULL.
#' @param d data.table. The input data.table object. Default is 'dt'.
#' @param na.rm Logical. If TRUE, removes rows with NA values in grouping variables y (and z if provided).
#'   Default is TRUE.
#' @param digits Integer. Number of decimal places for percentage calculations. Default is 1.
#' @param total Logical. If TRUE, adds total rows to the output. Default is TRUE.
#'
#' @return A data.table with the following columns:
#' \itemize{
#'   \item The grouping variables (x, y, and z if provided)
#'   \item count: Number of observations (unweighted) in each group
#'   \item weighted_count: Sum of weights in each group (only if weight is specified)
#'   \item sum: Total weighted count for each level of x (and z if three groups)
#'   \item percentage: Percentage of each group relative to the weighted sum
#' }
#'
#' @details
#' When a weight column is specified, the function calculates:
#' \itemize{
#'   \item count: Unweighted number of observations
#'   \item weighted_count: Sum of weights for each group
#'   \item percentage: Based on weighted counts relative to weighted sums
#' }
#'
#' When no weight is specified, the function behaves like the original proscat function.
#'
#' @examples
#' \dontrun{
#' # Create sample data with weights
#' library(data.table)
#' dt <- data.table(
#'   group1 = sample(1:3, 100, replace = TRUE),
#'   group2 = sample(c("A", "B", "C"), 100, replace = TRUE),
#'   group3 = sample(c("X", "Y"), 100, replace = TRUE),
#'   weights = runif(100, 0.5, 2.0)  # Random weights
#' )
#'
#' # Weighted two-group cross-tabulation
#' result_weighted <- proscat_weighted("group1", "group2", weight = "weights", d = dt)
#'
#' # Weighted three-group cross-tabulation
#' result_3groups <- proscat_weighted("group1", "group2", "group3", weight = "weights", d = dt)
#'
#' # Unweighted (same as original proscat)
#' result_unweighted <- proscat_weighted("group1", "group2", d = dt)
#' }
#'
#' @export
#' @import data.table
proscat_weighted <- function(x, y, z = NULL, weight = NULL, d = dt, na.rm = TRUE, digits = 1, total = TRUE) {
  # Input validation
  if (!is.data.table(d)) {
    stop("Data must be a data.table")
  }

  # Check if columns exist
  cols_to_check <- c(x, y)
  if (!is.null(z)) cols_to_check <- c(cols_to_check, z)
  if (!is.null(weight)) cols_to_check <- c(cols_to_check, weight)

  missing_cols <- setdiff(cols_to_check, names(d))
  if (length(missing_cols) > 0) {
    stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "))
  }

  # Check if x is numeric/integer
  if (!any(class(d[[x]]) %in% c("numeric", "integer"))) {
    stop(x, " must be numeric or integer, but is: ", paste(class(d[[x]]), collapse = " "))
  }

  # Check if weight column is numeric
  if (!is.null(weight) && !any(class(d[[weight]]) %in% c("numeric", "integer"))) {
    stop(weight, " must be numeric or integer, but is: ", paste(class(d[[weight]]), collapse = " "))
  }

  # Create grouping variables list
  group_vars <- if (is.null(z)) c(x, y) else c(x, y, z)

  # Get counts and weighted counts by groups
  if (is.null(weight)) {
    # Unweighted analysis
    kb <- d[, .N, keyby = group_vars]
    setnames(kb, "N", "count")
  } else {
    # Weighted analysis
    kb <- d[, .(count = .N,
                weighted_count = sum(get(weight), na.rm = TRUE)),
            keyby = group_vars]
  }

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

  if (is.null(weight)) {
    # Unweighted sums
    kbsum <- kb[, .(sum = sum(count)), by = sum_by_vars]
  } else {
    # Weighted sums
    kbsum <- kb[, .(sum = sum(weighted_count)), by = sum_by_vars]
  }

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
      if (is.null(weight)) {
        tot <- kb[, .(count = sum(count, na.rm = TRUE)), by = y]
        tot[, sum := sum(count, na.rm = TRUE)]
      } else {
        tot <- kb[, .(count = sum(count, na.rm = TRUE),
                      weighted_count = sum(weighted_count, na.rm = TRUE)), by = y]
        tot[, sum := sum(weighted_count, na.rm = TRUE)]
      }
      tot[, (x) := total_val]
    } else {
      # Three-group case
      if (is.null(weight)) {
        tot <- kb[, .(count = sum(count, na.rm = TRUE)), by = c(y, z)]
        tot_sum <- tot[, .(sum = sum(count, na.rm = TRUE)), by = z]
      } else {
        tot <- kb[, .(count = sum(count, na.rm = TRUE),
                      weighted_count = sum(weighted_count, na.rm = TRUE)), by = c(y, z)]
        tot_sum <- tot[, .(sum = sum(weighted_count, na.rm = TRUE)), by = z]
      }
      tot[, (x) := total_val]
      tot[tot_sum, on = "z", sum := sum]
    }

    DT <- rbindlist(list(kb, tot), use.names = TRUE)
  } else {
    DT <- kb
  }

  # Calculate percentages
  if (is.null(weight)) {
    DT[, percentage := round(count/sum * 100, digits = digits)]
  } else {
    DT[, percentage := round(weighted_count/sum * 100, digits = digits)]
  }

  return(DT[])
}

# Example usage and testing
if (FALSE) {
  # Create sample data with weights
  set.seed(123)
  dt <- data.table(
    group1 = sample(1:3, 100, replace = TRUE),
    group2 = sample(c("A", "B", "C"), 100, replace = TRUE),
    group3 = sample(c("X", "Y"), 100, replace = TRUE),
    weights = runif(100, 0.5, 2.0)
  )

  # Weighted two-group analysis
  result_weighted <- proscat_weighted("group1", "group2", weight = "weights", d = dt)
  print("Weighted 2-group:")
  print(result_weighted)

  # Weighted three-group analysis
  result_3groups <- proscat_weighted("group1", "group2", "group3", weight = "weights", d = dt)
  print("Weighted 3-group:")
  print(result_3groups)

  # Unweighted (for comparison)
  result_unweighted <- proscat_weighted("group1", "group2", d = dt)
  print("Unweighted:")
  print(result_unweighted)
}
