#' Categorize Age Variable into Groups
#'
#' This function creates age groups from a continuous age variable using specified
#' breaks and labels. It's designed to work with data.table objects and provides
#' flexible options for defining age categories commonly used in demographic analysis.
#'
#' @param dt data.table. The input data.table object containing the age variable.
#' @param var Character string. Name of the age variable to be categorized.
#' @param breaks Numeric vector. Break points for age categories. Should include
#'   the minimum value to ensure all ages are captured.
#' @param labels Character vector, optional. Labels for the age groups. If NULL,
#'   default labels will be generated automatically. Length should be one less
#'   than the number of breaks. Default is NULL.
#' @param new_var Character string, optional. Name of the new categorical variable
#'   to be created. If NULL, defaults to "{var}_group". Default is NULL.
#' @param right Logical. Should intervals be closed on the right (and open on the left)
#'   or vice versa? Default is FALSE.
#' @param include.lowest Logical. Should the lowest break point be included in the
#'   first interval? Default is TRUE.
#' @param validate Logical. Should input validation be performed? Default is TRUE.
#' @param copy Logical. Should a copy of the data.table be returned instead of
#'   modifying in place? Default is FALSE.
#' @param missing_values Numeric vector, optional. Values that should be treated
#'   as missing (e.g., survey codes like 999 for "don't know", 998 for "no answer").
#'   These values will be converted to NA before categorization. Default is NULL.
#'
#' @return The modified data.table with the new age group variable added. If copy=TRUE,
#'   returns a new data.table; otherwise modifies the input data.table by reference.
#'
#' @details
#' The function uses base R's \code{cut()} function internally to create the age categories.
#' Common age groupings in demographic analysis include:
#' \itemize{
#'   \item Pediatric: 0-18 years
#'   \item Young adult: 19-30 years
#'   \item Middle age: 31-50 years
#'   \item Older adult: 51+ years
#' }
#'
#' The breaks vector should always include the minimum expected age (often 0) and
#' a maximum value that exceeds the highest age in your data.
#'
#' @section Missing Value Handling:
#' Survey data often uses special numeric codes to represent different types of
#' missing responses:
#' \itemize{
#'   \item 999: "Don't know"
#'   \item 998: "Prefer not to answer"
#'   \item 997: "Not applicable"
#'   \item -1, -9: Various missing codes
#' }
#'
#' The \code{missing_values} parameter allows you to specify these codes, which
#' will be converted to NA before age categorization. This ensures that survey
#' response codes don't interfere with legitimate age values and are properly
#' treated as missing data in the resulting age groups.
#'
#' When validate=TRUE, the function checks for:
#' \itemize{
#'   \item Existence of the specified age variable
#'   \item Numeric age variable
#'   \item Proper breaks vector (numeric, sorted, minimum length 2)
#'   \item Matching labels length (if provided)
#'   \item Coverage of all valid age values by the breaks (excluding missing codes)
#'   \item Valid missing_values parameter (if provided)
#' }
#'
#' @examples
#' library(data.table)
#'
#' # Create sample data
#' dt <- data.table(
#'   id = 1:100,
#'   age = sample(18:80, 100, replace = TRUE),
#'   gender = sample(c("M", "F"), 100, replace = TRUE)
#' )
#'
#' # Basic usage with automatic labels
#' age_breaks <- c(0, 18, 30, 50, 100)
#' dt_grouped <- group_age(dt, "age", breaks = age_breaks, copy = TRUE)
#'
#' # With custom labels
#' age_labels <- c("Youth", "Young Adult", "Middle Age", "Senior")
#' dt_custom <- group_age(dt, "age",
#'                        breaks = age_breaks,
#'                        labels = age_labels,
#'                        new_var = "age_category",
#'                        copy = TRUE)
#'
#' # With missing value codes (common in surveys)
#' dt_survey <- data.table(
#'   id = 1:100,
#'   age = c(sample(18:80, 90, replace = TRUE), rep(999, 5), rep(998, 5))
#' )
#'
#' # Handle survey missing codes
#' dt_clean <- group_age(dt_survey, "age",
#'                       breaks = c(0, 18, 30, 50, 100),
#'                       labels = c("Youth", "Young Adult", "Middle Age", "Senior"),
#'                       missing_values = c(998, 999),  # "no answer", "don't know"
#'                       copy = TRUE)
#'
#' # Check the result
#' table(dt_clean$age_group, useNA = "ifany")
#'
#' @seealso
#' \code{\link[base]{cut}} for the underlying categorization function.
#' \code{\link[data.table]{data.table}} for data.table operations.
#'
#' @export
#' @import data.table
group_age <- function(dt, var, breaks,
                      labels = NULL,
                      new_var = NULL,
                      right = FALSE,
                      include.lowest = TRUE,
                      validate = TRUE,
                      copy = FALSE,
                      missing_values = NULL) {

  # Input validation
  if (validate) {
    # Check if input is data.table
    if (!is.data.table(dt)) {
      stop("Input 'dt' must be a data.table object.")
    }

    # Check if variable exists
    if (!var %in% names(dt)) {
      stop("Variable '", var, "' not found in the data.table.")
    }

    # Check if age variable is numeric
    if (!is.numeric(dt[[var]])) {
      stop("Variable '", var, "' must be numeric, but is: ",
           paste(class(dt[[var]]), collapse = " "))
    }

    # Validate breaks
    if (!is.numeric(breaks) || length(breaks) < 2) {
      stop("'breaks' must be a numeric vector with at least 2 elements.")
    }

    if (is.unsorted(breaks)) {
      stop("'breaks' must be in ascending order.")
    }

    # Validate missing_values if provided
    if (!is.null(missing_values)) {
      if (!is.numeric(missing_values)) {
        stop("'missing_values' must be a numeric vector.")
      }

      # Check if any missing values exist in the data
      missing_present <- any(missing_values %in% dt[[var]])
      if (missing_present) {
        message("Found ", sum(dt[[var]] %in% missing_values, na.rm = TRUE),
                " observations with missing value codes that will be converted to NA.")
      }
    }

    # Check if breaks cover all non-missing age values
    if (!is.null(missing_values)) {
      # Exclude missing values when checking range
      valid_ages <- dt[[var]][!dt[[var]] %in% missing_values & !is.na(dt[[var]])]
      if (length(valid_ages) > 0) {
        age_range <- range(valid_ages, na.rm = TRUE)
      } else {
        warning("No valid age values found after excluding missing value codes.")
        age_range <- c(NA, NA)
      }
    } else {
      age_range <- range(dt[[var]], na.rm = TRUE)
    }

    if (!is.na(age_range[1]) && !is.na(age_range[2])) {
      if (min(breaks) > age_range[1] || max(breaks) < age_range[2]) {
        warning("Breaks may not cover all valid age values. Valid age range: [",
                age_range[1], ", ", age_range[2], "], Breaks range: [",
                min(breaks), ", ", max(breaks), "]")
      }
    }

    # Validate labels if provided
    if (!is.null(labels)) {
      expected_length <- length(breaks) - 1
      if (length(labels) != expected_length) {
        stop("Length of 'labels' (", length(labels),
             ") must equal length of 'breaks' - 1 (", expected_length, ").")
      }
    }

    # Check for existing variable name conflict
    if (is.null(new_var)) {
      new_var <- paste0(var, "_group")
    }

    if (new_var %in% names(dt)) {
      warning("Variable '", new_var, "' already exists and will be overwritten.")
    }
  } else {
    # Minimal validation even when validate=FALSE
    if (!is.data.table(dt)) {
      stop("Input must be a data.table.")
    }

    if (is.null(new_var)) {
      new_var <- paste0(var, "_group")
    }
  }

  # Create copy if requested
  if (copy) {
    dt <- copy(dt)
  }

  # Handle missing values by converting them to NA
  if (!is.null(missing_values)) {
    # Create a temporary variable for processing
    temp_var <- paste0(var, "_temp_processed")
    dt[, (temp_var) := get(var)]

    # Convert missing value codes to NA
    dt[get(temp_var) %in% missing_values, (temp_var) := NA]

    # Create age groups using the processed variable
    dt[, (new_var) := cut(get(temp_var),
                          breaks = breaks,
                          labels = labels,
                          right = right,
                          include.lowest = include.lowest)]

    # Remove temporary variable
    dt[, (temp_var) := NULL]
  } else {
    # Create age groups directly
    dt[, (new_var) := cut(get(var),
                          breaks = breaks,
                          labels = labels,
                          right = right,
                          include.lowest = include.lowest)]
  }

  # Return result
  return(dt[])
}

#' Create Standard Demographic Age Groups
#'
#' A convenience wrapper around \code{group_age()} that creates commonly used
#' demographic age categories.
#'
#' @param dt data.table. The input data.table object.
#' @param var Character string. Name of the age variable.
#' @param type Character string. Type of age grouping. Options are:
#'   \itemize{
#'     \item "standard": 0-17, 18-34, 35-54, 55-74, 75+
#'     \item "pediatric": 0-2, 3-5, 6-12, 13-17, 18+
#'     \item "geriatric": <65, 65-74, 75-84, 85+
#'     \item "working": <18, 18-64, 65+
#'   }
#' @param new_var Character string, optional. Name for the new variable.
#' @param missing_values Numeric vector, optional. Values that should be treated
#'   as missing (e.g., survey codes). These values will be converted to NA
#'   before categorization. Default is NULL.
#' @param copy Logical. Return a copy instead of modifying by reference?
#'
#' @return Modified data.table with age group variable added.
#'
#' @examples
#' # Create standard demographic groups
#' dt_demo <- group_age_standard(dt, "age", type = "standard")
#'
#' # Create working-age focused groups
#' dt_work <- group_age_standard(dt, "age", type = "working", copy = TRUE)
#'
#' @export
group_age_standard <- function(dt, var, type = "standard", new_var = NULL,
                               copy = FALSE, missing_values = NULL) {

  # Define standard age groupings
  age_configs <- list(
    standard = list(
      breaks = c(0, 18, 35, 55, 75, Inf),
      labels = c("0-17", "18-34", "35-54", "55-74", "75+")
    ),
    pediatric = list(
      breaks = c(0, 3, 6, 13, 18, Inf),
      labels = c("0-2", "3-5", "6-12", "13-17", "18+")
    ),
    geriatric = list(
      breaks = c(0, 65, 75, 85, Inf),
      labels = c("<65", "65-74", "75-84", "85+")
    ),
    working = list(
      breaks = c(0, 18, 65, Inf),
      labels = c("<18", "18-64", "65+")
    ),
    unodc = list(
      breaks = c(16, 19, 25, 35, 65),
      labels = c("16-18", "19-24", "25-34", "35-64"))
  )

  if (!type %in% names(age_configs)) {
    stop("Invalid type. Choose from: ", paste(names(age_configs), collapse = ", "))
  }

  config <- age_configs[[type]]

  if (is.null(new_var)) {
    new_var <- paste0(var, "_", type)
  }

  group_age(dt = dt,
            var = var,
            breaks = config$breaks,
            labels = config$labels,
            new_var = new_var,
            copy = copy,
            missing_values = missing_values)
}

## Example
## # Define age group breaks and labels
## age_breaks <- c(0, 18, 30, 50, 100) #ensure lowest value included
## age_labels <- c("0-18", "19-30", "31-50", "51+")

## new_var - Name of new variable created for the age group
group_age_v1 <- function(dt, var, breaks,
                      labels = NULL,
                      new_var = NULL,
                      right = TRUE,
                      include.lowest = TRUE) {
  if (!is.data.table(dt)) {
    stop("Input must be a data.table.")
  }

  # Default name for new variable
  if (is.null(new_var)) {
    new_var <- paste0(var, "_group")
  }

  ## Create categorized variable
  dt[, (new_var) := cut(get(var),
                        breaks = breaks,
                        labels = labels,
                        right = right,
                        include.lowest = include.lowest)]

  return(dt)
}
