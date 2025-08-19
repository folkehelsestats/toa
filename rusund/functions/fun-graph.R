#' Create Interactive Highchart Graph with Categories and Groups
#'
#' Creates customizable interactive graph using highcharter with support for
#' multiple groups, different chart types (column/line), and Norwegian health survey
#' styling. Includes automatic color assignment, hover effects, and export functionality.
#'
#' @param d data.frame or data.table. The input dataset containing the variables to plot.
#' @param x Unquoted variable name. The x-axis variable (categories).
#' @param y Unquoted variable name. The y-axis variable (values, typically percentages).
#' @param group Unquoted variable name. The grouping variable for creating multiple series.
#' @param n Unquoted variable name. The count variable to display in tooltips (raw numbers).
#' @param title Character string. Main title for the chart.
#' @param subtitle Character string, optional. Subtitle for the chart. If NULL,
#'   defaults to "Kilde: Rusundersøkelse 2024". Default is NULL.
#' @param yint Numeric. Interval for y-axis tick marks. Default is 10.
#' @param flip Logical. Whether to flip the chart orientation (horizontal bars).
#'   Default is FALSE.
#' @param type Character string. Chart type, either "column" or "line". Default is "column".
#' @param line_symbols Character vector, optional. Symbols for line markers when type="line".
#'   Should match the number of groups. Available symbols: "circle", "square", "diamond",
#'   "triangle", "triangle-down". If NULL, uses different symbols for each group automatically.
#'   Default is NULL.
#' @param dot_size Numeric. Size (radius in pixels) of the markers/dots for line charts.
#'   Only applies when type="line". Default is 4.
#'
#' @return A highchart object that can be displayed or further customized.
#'
#' @details
#' The function automatically handles color assignment based on the number of groups:
#' \itemize{
#'   \item 2 groups: Custom teal and purple palette
#'   \item 3-7 groups: Extended custom palette with good contrast
#'   \item 8+ groups: Falls back to viridis color scale
#' }
#'
#' For line charts, different symbols are automatically assigned to each group to
#' improve distinguishability, especially important for accessibility and
#' black-and-white printing.
#'
#' The chart includes several interactive features:
#' \itemize{
#'   \item Hover effects with category highlighting
#'   \item Detailed tooltips showing both counts and percentages
#'   \item Export functionality (PNG, JPEG, PDF, SVG, CSV, Excel)
#'   \item Norwegian health survey styling and credits
#' }
#'
#' @section Color Palettes:
#' The function uses carefully selected colors optimized for Norwegian health surveys:
#' \itemize{
#'   \item Primary colors: Dark teal (#2E7D7B) and purple (#8A2952)
#'   \item Extended palette includes complementary blues, oranges, greens, and earth tones
#'   \item All colors meet accessibility contrast requirements
#' }
#'
#' @section Line Chart Symbols:
#' When using type="line", the function automatically assigns different symbols
#' to each group in this order:
#' \enumerate{
#'   \item circle
#'   \item square
#'   \item diamond
#'   \item triangle
#'   \item triangle-down
#' }
#'
#' For more than 5 groups, symbols will cycle through the available options.
#'
#' @examples
#' \dontrun{
#' library(highcharter)
#' library(dplyr)
#'
#' # Sample data
#' survey_data <- data.frame(
#'   age_group = rep(c("18-24", "25-34", "35-44", "45-54"), each = 3),
#'   gender = rep(c("Male", "Female", "Other"), 4),
#'   percentage = runif(12, 10, 80),
#'   count = sample(50:200, 12)
#' )
#'
#' # Basic column chart
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Survey Results by Age and Gender")
#'
#' # Line chart with custom symbols
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Trend Analysis",
#'           type = "line",
#'           line_symbols = c("circle", "square", "diamond"))
#'
#' # Horizontal bar chart
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Horizontal View",
#'           flip = TRUE)
#'
#' # Custom y-axis intervals
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Fine-grained Y-axis",
#'           yint = 5)
#' }
#'
#' @seealso
#' \code{\link[highcharter]{hchart}} for the underlying charting function.
#' \code{\link[viridis]{viridis}} for the fallback color palette.
#'
#' @export
#' @import highcharter
#' @importFrom viridis viridis
make_hist <- function(d, x, y, group, n,
                      title,
                      subtitle = NULL,
                      yint = 10,
                      flip = FALSE,
                      type = "column",
                      line_symbols = NULL,
                      dot_size = 4) {

  # Convert arguments to character strings for consistent handling
  x <- as.character(substitute(x))
  y <- as.character(substitute(y))
  group <- as.character(substitute(group))
  n <- as.character(substitute(n))

  # Input validation
  required_vars <- c(x, y, group, n)
  missing_vars <- setdiff(required_vars, names(d))
  if (length(missing_vars) > 0) {
    stop("Variables not found in data: ", paste(missing_vars, collapse = ", "))
  }

  if (!type %in% c("column", "line")) {
    stop("'type' must be either 'column' or 'line'")
  }

  # Get number of groups and set up colors
  gp <- length(unique(d[[group]]))

  # Set default subtitle
  if (is.null(subtitle)) {
    subtitle <- "Kilde: Rusundersøkelse 2024"
  }

  # Handle x-axis based on variable type
  is_x_numeric <- is.numeric(d[[x]])

  if (is_x_numeric) {
    use_categories <- FALSE
    x_axis_config <- list(
      title = list(text = " "),
      labels = list(step = 1)
    )
  } else {
    x_levels <- unique(d[[x]])
    d$x_index <- match(d[[x]], x_levels) - 1
    use_categories <- TRUE
    x_axis_config <- list(
      title = list(text = " "),
      categories = x_levels,
      tickInterval = 1,
      labels = list(step = 1)
    )
  }


  ## Extended custom palette with good contrast for up to 7 groups
  colors01 <- c(
    "#2E7D7B",  # Dark teal (original)
    "#8A2952",  # Purple (original)
    "#5CB3CC",  # Light blue (original)
    "#CC8A33",  # Orange (original)
    "#4A7C59",  # Forest green (new - similar to teal but distinguishable)
    "#B8336A",  # Rose/pink (new - similar to purple but lighter)
    "#7A4F01"   # Dark brown (new - earthy tone that complements orange)
  )

  ## Lighter
  colors02 <- c(
    "#00796B",  # Dark teal (improved - brighter for contrast)
    "#9C27B0",  # Purple (improved - more vibrant)
    "#03A9F4",  # Light blue (improved - stronger contrast)
    "#FF9800",  # Orange (improved - brighter and clearer)
    "#388E3C",  # Forest green (improved - more saturated)
    "#E91E63",  # Rose/pink (improved - vivid and readable)
    "#795548"   # Dark brown (improved - softer and more legible)
  )

  ## Darker
  colors03 <- c(
    "#005B55",  # Dark teal (darker version)
    "#5E1B3A",  # Purple (darker version)
    "#2A7A8F",  # Light blue (darker version)
    "#A65F00",  # Orange (darker version)
    "#2E5E3F",  # Forest green (darker version)
    "#8A1E4A",  # Rose/pink (darker version)
    "#5C3B00"   # Dark brown (darker version)
  )

  # Define color palettes
  if (gp == 2) {
    hdir <- c("rgba(49,101,117,1)", "rgba(138,41,77,1)")
  } else if (gp <= 7) {
    # Extended custom palette with good contrast for up to 7 groups
    hdir <- hdir_color[1:gp]
  } else {
    hdir <- viridis(gp, option = "D")  # Fallback to viridis for many groups
  }

  # Set up line symbols if type is "line"
  if (type == "line") {
    available_symbols <- c("circle", "square", "diamond", "triangle", "triangle-down")

    if (is.null(line_symbols)) {
      # Auto-assign symbols, cycling through available ones if needed
      line_symbols <- rep(available_symbols, length.out = gp)
    } else {
      # Validate provided symbols
      invalid_symbols <- setdiff(line_symbols, available_symbols)
      if (length(invalid_symbols) > 0) {
        warning("Invalid symbols found: ", paste(invalid_symbols, collapse = ", "),
                ". Using default symbols instead.")
        line_symbols <- rep(available_symbols, length.out = gp)
      } else if (length(line_symbols) != gp) {
        warning("Number of symbols (", length(line_symbols),
                ") doesn't match number of groups (", gp, "). Recycling symbols.")
        line_symbols <- rep(line_symbols, length.out = gp)
      }
    }
  }

  # Create the base chart using highchart() for both line and column
  chart <- highchart() |>
    hc_chart(inverted = flip) |>
    hc_yAxis(
      title = list(text = " "),
      labels = list(format = "{value}%"),
      tickInterval = yint
    ) |>
    hc_xAxis(
      x_axis_config
      ## title = list(text = " "),
      ## tickInterval = 1,
      ## labels = list(
      ##   step = 1 # Show every level
      ## )
    ) |>
    hc_title(text = title) |>
    hc_subtitle(text = subtitle) |>
    hc_credits(
      enabled = TRUE,
      text = "Helsedirektoratet",
      href = "https://www.helsedirektoratet.no/"
    ) |>
    hc_tooltip(
      useHTML = TRUE,
      shared = TRUE,
      headerFormat = '<span style="font-size: 14px; font-weight: bold;">{point.key}</span><br/>',
      pointFormat = paste0(
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
    hc_exporting(
      enabled = TRUE
    ##   buttons = list(
    ##     contextButton = list(
    ##       menuItems = c(
    ##         "downloadPNG", "downloadJPEG", "downloadPDF", "downloadSVG",
    ##         "downloadCSV", "downloadXLS"
    ##       )
    ##     )
    ##   )
    )

  if (use_categories) {
    mapping <- hcaes(x = x_index, y = !!y)
  } else {
    mapping <- hcaes(x = !!x, y = !!y)
  }

  # Add series manually for both line and column charts
  group_levels <- unique(d[[group]])
  for (i in seq_along(group_levels)) {
    # Filter data for this specific group
    group_data <- d[d[[group]] == group_levels[i], ]

    if (type == "line") {
      # Line chart with symbols
      chart <- chart |>
        hc_add_series(
          data = group_data,
          type = "line",
          name = group_levels[i],
          ## hcaes(x = !!x, y = !!y),
          mapping,
          marker = list(
            symbol = line_symbols[i],
            enabled = TRUE,
            radius = dot_size
          ),
          color = hdir[i],
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
    } else {
      # Column chart
      chart <- chart |>
        hc_add_series(
          data = group_data,
          type = "column",
          name = group_levels[i],
          ## hcaes(x = !!x, y = !!y),
          mapping,
          color = hdir[i],
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
        )
    }
  }

  return(chart)
}
