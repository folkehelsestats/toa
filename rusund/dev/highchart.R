library(highcharter)
library(dplyr)

data(diamonds, package = "ggplot2")

data <- count(diamonds, cut, color)

hc <- hchart(data, "column", hcaes(x = color, y = n, group = cut)) |>
  hc_yAxis(title = list(text = "Cases")) |>
  hc_title(text = "Diamonds Are Forever") |>
  hc_subtitle(text = "Source: Diamonds data set") |>
  hc_credits(enabled = TRUE, text = "http://jkunst.com/highcharter/") |>
  hc_tooltip(sort = TRUE, table = TRUE) |>
  hc_caption(text = "This is a caption text to show the style of this type of text")

hc

# Use plotBands to highlight background categorically
hc2 <- hchart(data, "column", hcaes(x = color, y = n, group = cut)) |>
  hc_yAxis(title = list(text = "Cases")) |>
  hc_title(text = "Diamonds Are Forever - PlotBands Method") |>
  hc_subtitle(text = "Source: Diamonds data set") |>
  hc_credits(enabled = TRUE, text = "http://jkunst.com/highcharter/") |>
  hc_tooltip(sort = TRUE, table = TRUE) |>
  hc_caption(text = "Category background using plotBands") |>
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
        hover = list(
          brightness = 0.2
        )
      ),
      point = list(
        events = list(
          mouseOver = JS("function() {
            var chart = this.series.chart;
            var categoryIndex = this.x;

            // Remove existing plotBand
            chart.xAxis[0].removePlotBand('hover-band');

            // Add plotBand for the category
            chart.xAxis[0].addPlotBand({
              id: 'hover-band',
              from: categoryIndex - 0.4,
              to: categoryIndex + 0.4,
              color: 'rgba(255, 99, 132, 0.1)',
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
  )

hc2

# Explanation
# - Uses addPlotBand() and removePlotBand() for the background effect
# - Simpler approach using Highcharts' built-in plotBand functionality
# - Pink/red background highlighting
options(highcharter.lang = list(
  contextButtonTitle = "Eksporter figur",
  downloadPNG = "Last ned PNG",
  downloadJPEG = "Last ned JPEG",
  downloadPDF = "Last ned PDF",
  downloadSVG = "Last ned SVG",
  downloadCSV = "Last ned CSV",
  downloadXLS = "Last ned Excel-fil"
))

make_hist <- function(d, x, y, group,  n = NULL, title, yint = 10) {
  x <- as.character(substitute(x))
  y <- as.character(substitute(y))
  group <- as.character(substitute(group))
  if (!is.null(n))
    n <- as.character(substitute(n))
  hchart(d, "column", hcaes(x = !!x, y = !!y, group = !!group)) |>
    hc_colors(c("rgba(49,101,117,1)", "rgba(138,41,77,1)")) |>
    hc_yAxis(
      title = list(text = " "),
      labels = list(format = "{value}%"),
      tickInterval = yint
    ) |>
    hc_xAxis(title = list(text = " ")) |>
    hc_title(text = title) |>
    hc_subtitle(text = "Kilde: Rusundersøkelse 2024") |>
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
      pointFormat = if (!is.null(n)) {
                      paste0(
                        '<span style="color:{series.color}">\u25CF</span> ',
                        '<span style="color:black">{series.name}</span>: ',
                        '<b>{point.', n, '} ({point.y}%)</b><br/>'
                      )
                    } else {
                      paste0(
                        '<span style="color:{series.color}">\u25CF</span> ',
                        '<span style="color:black">{series.name}</span>: ',
                        '<b>{point.y}%</b><br/>'
                      )
                    }
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
