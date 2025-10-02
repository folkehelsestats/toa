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
#' @param ylim Numeric vector of length 2, optional. Sets fixed y-axis limits as c(min, max).
#'   If NULL (default), y-axis limits are determined automatically by the data.
#'   Example: c(0, 70) sets y-axis from 0 to 70.
#' @param xtitle Character string, optional. X-axis title. If NULL (default), no title is shown.
#' @param ytitle Character string, optional. Y-axis title. If NULL (default), no title is shown.
#' @param flip Logical. Whether to flip the chart orientation (horizontal bars).
#'   Default is FALSE.
#' @param type Character string. Chart type, either "column" or "line". Default is "column".
#' @param line_symbols Character vector, optional. Symbols for line markers when type="line".
#'   Should match the number of groups. Available symbols: "circle", "square", "diamond",
#'   "triangle", "triangle-down". If NULL, uses different symbols for each group automatically.
#'   Default is NULL.
#' @param dot_size Numeric. Size (radius in pixels) of the markers/dots for line charts.
#'   Only applies when type="line". Default is 4.
#' @param smooth Logical. Whether to create smooth spline curves for line charts.
#'   When TRUE, uses "spline" type for curved lines between points. When FALSE,
#'   uses straight line segments. Only applies when type="line". Default is TRUE.
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
#' @section Smooth Lines:
#' When smooth=TRUE and type="line", the function uses spline interpolation to
#' create curved lines between data points. This creates a more visually appealing
#' trend visualization but may not accurately represent the exact path between
#' measured data points. Use with caution when precise data representation is critical.
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
#' # Chart with fixed y-axis scale
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Fixed Y-axis Scale",
#'           ylim = c(0, 70))
#'
#' # Smooth line chart with custom symbols and fixed scale
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Smooth Trend Analysis",
#'           type = "line",
#'           smooth = TRUE,
#'           ylim = c(0, 100),
#'           line_symbols = c("circle", "square", "diamond"))
#'
#' # Regular (angular) line chart
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Angular Line Chart",
#'           type = "line",
#'           smooth = FALSE)
#'
#' # Horizontal bar chart with fixed scale
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Horizontal View",
#'           flip = TRUE,
#'           ylim = c(0, 50))
#'
#' # Custom y-axis intervals with fixed scale
#' make_hist(survey_data, age_group, percentage, gender, count,
#'           title = "Fine-grained Y-axis",
#'           yint = 5,
#'           ylim = c(0, 60))
#' }
#'
#' @seealso
#' \code{\link[highcharter]{hchart}} for the underlying charting function.
#' \code{\link[highcharter]{hc_add_series}} for adding series to charts.
#' \code{\link[viridis]{viridis}} for the fallback color palette.
#'
#' @export
#' @import highcharter
#' @importFrom viridis viridis
make_hist <- function(d, x, y, group, n,
                      title,
                      subtitle = NULL,
                      yint = 10,
                      ylim = NULL,
                      xtitle = NULL,
                      ytitle = NULL,
                      flip = FALSE,
                      type = "column",
                      line_symbols = NULL,
                      dot_size = 4,
                      smooth = TRUE) {

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

  # Validate ylim parameter
  if (!is.null(ylim)) {
    if (!is.numeric(ylim) || length(ylim) != 2) {
      stop("'ylim' must be a numeric vector of length 2, e.g., c(0, 100)")
    }
    if (ylim[1] >= ylim[2]) {
      stop("'ylim' first value must be less than second value, e.g., c(0, 100)")
    }
  }

  # Get number of groups and set up colors
  gp <- length(unique(d[[group]]))

  # Set default subtitle
  if (is.null(subtitle)) {
    subtitle <- "Kilde: Rusundersøkelse 2024"
  }

  # Set axis title text (empty string if NULL)
  x_title_text <- if (is.null(xtitle)) " " else xtitle
  y_title_text <- if (is.null(ytitle)) " " else ytitle

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

  # Hdir colors
  colors04 <- c("#025169", "#0069E8",
                "#7C145C", "#047FA4",
                "#C68803", "#38A389",
                "#6996CE", "#366558",
                "#BF78DE", "#767676")

  # Define color palettes
  if (gp == 2) {
    hdir <- c("rgba(49,101,117,1)", "rgba(138,41,77,1)")
  } else if (gp <= 7) {
    hdir <- colors04[1:gp]
  } else {
    hdir <- viridis::viridis(gp, option = "D")
  }

  # Set up line symbols if type is "line"
  if (type == "line") {
    available_symbols <- c("circle", "square", "diamond", "triangle", "triangle-down")

    if (is.null(line_symbols)) {
      line_symbols <- rep(available_symbols, length.out = gp)
    } else {
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

  # Create the base chart
  chart <- highcharter::highchart() |>
    highcharter::hc_chart(inverted = flip)

  # Configure y-axis
  if (!is.null(ylim)) {
    chart <- chart |>
      highcharter::hc_yAxis(
        title = list(text = y_title_text),
        labels = list(format = "{value}%"),
        tickInterval = yint,
        min = ylim[1],
        max = ylim[2]
      )
  } else {
    chart <- chart |>
      highcharter::hc_yAxis(
        title = list(text = y_title_text),
        labels = list(format = "{value}%"),
        tickInterval = yint,
        min = 0
      )
  }

  # Configure x-axis
  if (use_categories) {
    chart <- chart |>
      highcharter::hc_xAxis(
        title = list(text = x_title_text),
        categories = unique(d[[x]]),
        tickInterval = 1,
        labels = list(step = 1)
      )
  } else {
    chart <- chart |>
      highcharter::hc_xAxis(
        title = list(text = x_title_text),
        labels = list(step = 1)
      )
  }

  chart <- chart |>
    highcharter::hc_title(text = title) |>
    highcharter::hc_subtitle(text = subtitle) |>
    highcharter::hc_credits(
      enabled = TRUE,
      text = "Helsedirektoratet",
      href = "https://www.helsedirektoratet.no/"
    ) |>
    highcharter::hc_tooltip(
      useHTML = TRUE,
      shared = TRUE,
      headerFormat = '<span style="font-size: 14px; font-weight: bold;">{point.key}</span><br/>',
      pointFormat = paste0(
        '<span style="color:{series.color}">\u25CF</span> ',
        '<span style="color:black">{series.name}</span>: ',
        '<b>{point.', n, '} ({point.y}%)</b><br/>'
      )
    ) |>
    highcharter::hc_caption(text = "Tall om alkohol") |>
    highcharter::hc_legend(
      align = "left",
      verticalAlign = "bottom",
      layout = "horizontal",
      x = 50,
      y = 0
    ) |>
    highcharter::hc_exporting(enabled = TRUE)

  if (use_categories) {
    mapping <- highcharter::hcaes(x = x_index, y = !!rlang::sym(y))
  } else {
    mapping <- highcharter::hcaes(x = !!rlang::sym(x), y = !!rlang::sym(y))
  }

  # Add series manually for both line and column charts
  group_levels <- unique(d[[group]])
  for (i in seq_along(group_levels)) {
    group_data <- d[d[[group]] == group_levels[i], ]

    if (type == "line") {
      # Determine chart type based on smooth parameter
      chart_type <- if (smooth) "spline" else "line"

      chart <- chart |>
        highcharter::hc_add_series(
          data = group_data,
          type = chart_type,
          name = group_levels[i],
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
              mouseOver = htmlwidgets::JS("function() {
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
              mouseOut = htmlwidgets::JS("function() {
                var chart = this.series.chart;
                chart.xAxis[0].removePlotBand('hover-band');
              }")
            )
          )
        )
    } else {
      # Column chart
      chart <- chart |>
        highcharter::hc_add_series(
          data = group_data,
          type = "column",
          name = group_levels[i],
          mapping,
          color = hdir[i],
          states = list(
            hover = list(brightness = 0.2)
          ),
          point = list(
            events = list(
              mouseOver = htmlwidgets::JS("function() {
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
              mouseOut = htmlwidgets::JS("function() {
                var chart = this.series.chart;
                chart.xAxis[0].removePlotBand('hover-band');
              }")
            )
          )
        )
    }
  }

  chart <- chart |>
    hc_add_dependency(name = "modules/exporting.js") |>
    hc_add_dependency(name = "modules/export-data.js") |>
    hc_add_dependency(name = "modules/accessibility.js")

  return(chart)
}
